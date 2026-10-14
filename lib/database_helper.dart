import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static Database? _db;

  // Open the notebook (and create / upgrade it)
  static Future<Database> getDatabase() async {
    if (_db != null) return _db!;

    final folder = await getDatabasesPath();
    _db = await openDatabase(
      join(folder, 'whatsapp_app.db'),
      version: 5,
      onCreate: (db, version) async {
        await _createUsersTable(db);
        await _createChatTables(db);
        await _createProfileTable(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await _createChatTables(db);
        }
        if (oldVersion < 3) {
          // old test users have no password, so remove them
          await db.delete('users');
          await db.execute('ALTER TABLE users ADD COLUMN nickname TEXT');
          await db.execute('ALTER TABLE users ADD COLUMN salt TEXT');
          await db.execute('ALTER TABLE users ADD COLUMN password_hash TEXT');
        }
        if (oldVersion < 4) {
          // new column to remember each user's profile picture
          await db.execute('ALTER TABLE users ADD COLUMN profile_image TEXT');
        }
        if (oldVersion < 5) {
          // profile pictures now belong to the Firebase account id
          await _createProfileTable(db);
        }
      },
    );
    return _db!;
  }

  static Future<void> _createUsersTable(Database db) async {
    await db.execute(
      'CREATE TABLE users ('
          'email TEXT PRIMARY KEY, '
          'verified INTEGER NOT NULL DEFAULT 0, '
          'nickname TEXT, '
          'salt TEXT, '
          'password_hash TEXT, '
          'profile_image TEXT)',
    );
  }

  static Future<void> _createChatTables(Database db) async {
    await db.execute(
      'CREATE TABLE IF NOT EXISTS messages ('
          'id INTEGER PRIMARY KEY AUTOINCREMENT, '
          'contact TEXT NOT NULL, '
          'text TEXT NOT NULL, '
          'is_me INTEGER NOT NULL, '
          'time_ms INTEGER NOT NULL, '
          'status INTEGER NOT NULL DEFAULT 0)',
    );
    await db.execute(
      'CREATE TABLE IF NOT EXISTS chat_seeded (contact TEXT PRIMARY KEY)',
    );
  }

  static Future<void> _createProfileTable(Database db) async {
    await db.execute(
      'CREATE TABLE IF NOT EXISTS profile_images ('
          'uid TEXT PRIMARY KEY, '
          'path TEXT NOT NULL)',
    );
  }

  // ---------- PASSWORD HELPERS ----------
  // A salt is a random text added to the password before hashing,
  // so two users with the same password get different hashes.
  static String _makeSalt() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    return base64Url.encode(bytes);
  }

  static String _hash(String password, String salt) {
    return sha256.convert(utf8.encode('$salt$password')).toString();
  }

  // ---------- USERS (old local login, no longer used by Firebase login) ----------
  static Future<bool> emailExists(String email) async {
    final db = await getDatabase();
    final rows = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    return rows.isNotEmpty;
  }

  static Future<void> registerUser({
    required String email,
    required String nickname,
    required String password,
  }) async {
    final db = await getDatabase();
    final salt = _makeSalt();
    await db.insert('users', {
      'email': email.toLowerCase(),
      'nickname': nickname,
      'salt': salt,
      'password_hash': _hash(password, salt),
      'verified': 0,
    });
  }

  static Future<Map<String, Object?>?> getUser(String email) async {
    final db = await getDatabase();
    final rows = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first;
  }

  static Future<bool> checkPassword(String email, String password) async {
    final user = await getUser(email);
    if (user == null) return false;

    final salt = user['salt'] as String?;
    final saved = user['password_hash'] as String?;
    if (salt == null || saved == null) return false;

    return _hash(password, salt) == saved;
  }

  // UPDATE only the verified flag. (insert + replace would erase the password)
  static Future<void> markVerified(String email) async {
    final db = await getDatabase();
    await db.update(
      'users',
      {'verified': 1},
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
  }

  static Future<bool> isVerified(String email) async {
    final db = await getDatabase();
    final rows = await db.query(
      'users',
      where: 'email = ? AND verified = ?',
      whereArgs: [email.toLowerCase(), 1],
    );
    return rows.isNotEmpty;
  }

  // How many users have verified on this phone
  static Future<int> countVerifiedUsers() async {
    final db = await getDatabase();
    final result = await db.rawQuery(
      'SELECT COUNT(*) AS total FROM users WHERE verified = 1',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Which emails have verified on this phone
  static Future<List<String>> getVerifiedEmails() async {
    final db = await getDatabase();
    final rows = await db.query(
      'users',
      columns: ['email'],
      where: 'verified = ?',
      whereArgs: [1],
    );
    return rows.map((r) => r['email'] as String).toList();
  }

  // ---------- PROFILE PICTURE (old, by email) ----------
  static Future<void> saveProfileImage(String email, String path) async {
    final db = await getDatabase();
    await db.update(
      'users',
      {'profile_image': path},
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
  }

  static Future<String?> getProfileImage(String email) async {
    final db = await getDatabase();
    final rows = await db.query(
      'users',
      columns: ['profile_image'],
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return rows.first['profile_image'] as String?;
  }

  // ---------- PROFILE PICTURE (new, by Firebase account id) ----------
  static Future<void> saveProfileImageForUid(String uid, String path) async {
    final db = await getDatabase();
    await db.insert(
      'profile_images',
      {'uid': uid, 'path': path},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<String?> getProfileImageForUid(String uid) async {
    final db = await getDatabase();
    final rows = await db.query(
      'profile_images',
      where: 'uid = ?',
      whereArgs: [uid],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return rows.first['path'] as String?;
  }

  // ---------- CHAT ----------
  // "contact" now holds a unique key: <account id>_<contact id>
  static Future<List<Map<String, Object?>>> getMessages(String contact) async {
    final db = await getDatabase();
    return db.query(
      'messages',
      where: 'contact = ?',
      whereArgs: [contact],
      orderBy: 'time_ms ASC, id ASC',
    );
  }

  static Future<int> addMessage({
    required String contact,
    required String text,
    required bool isMe,
    required int timeMs,
    required int status,
  }) async {
    final db = await getDatabase();
    return db.insert('messages', {
      'contact': contact,
      'text': text,
      'is_me': isMe ? 1 : 0,
      'time_ms': timeMs,
      'status': status,
    });
  }

  // status: 0 = sent, 1 = delivered, 2 = read
  static Future<void> updateStatus(int id, int status) async {
    final db = await getDatabase();
    await db.update(
      'messages',
      {'status': status},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<void> deleteMessage(int id) async {
    final db = await getDatabase();
    await db.delete('messages', where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> clearChat(String contact) async {
    final db = await getDatabase();
    await db.delete('messages', where: 'contact = ?', whereArgs: [contact]);
  }

  // So the demo messages are added only the first time a chat is opened
  static Future<bool> isSeeded(String contact) async {
    final db = await getDatabase();
    final rows = await db.query(
      'chat_seeded',
      where: 'contact = ?',
      whereArgs: [contact],
    );
    return rows.isNotEmpty;
  }

  static Future<void> markSeeded(String contact) async {
    final db = await getDatabase();
    await db.insert(
      'chat_seeded',
      {'contact': contact},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}