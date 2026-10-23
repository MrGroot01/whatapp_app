import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';


class DatabaseHelper {
  static Database? _db;

  // Open the local database and create or upgrade its tables.
  static Future<Database> getDatabase() async {
    if (_db != null) return _db!;

    final folder = await getDatabasesPath();

    _db = await openDatabase(
      join(folder, 'whatsapp_app.db'),
      version: 8,
      onCreate: (db, version) async {
        await _createUsersTable(db);
        await _createChatTables(db);
        await _createProfileTable(db);
        await _createOutboxTable(db);
        await _createContactsTable(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 3) {
          // Old test users have no password, so remove them.
          await db.delete('users');
          await db.execute(
            'ALTER TABLE users ADD COLUMN nickname TEXT',
          );
          await db.execute(
            'ALTER TABLE users ADD COLUMN salt TEXT',
          );
          await db.execute(

            'ALTER TABLE users ADD COLUMN password_hash TEXT',
          );
        }

        if (oldVersion < 4) {
          await db.execute(
            'ALTER TABLE users ADD COLUMN profile_image TEXT',
          );
        }

        if (oldVersion < 5) {
          await _createProfileTable(db);
        }


        if (oldVersion < 6) {
          await _createOutboxTable(db);
        }
        if (oldVersion < 7) {
          await _createContactsTable(db);
        }
        if (oldVersion < 8) {
          // new column: when a scheduled message may be sent (0 = send now)
          try {
            await db.execute(
              'ALTER TABLE outbox ADD COLUMN send_at INTEGER NOT NULL DEFAULT 0',
            );
          } catch (e) {
            // the column already exists (the outbox table was just created)
          }
        }
      },
    );

    return _db!;
  }

  // ---------- TABLE CREATION ----------
  static Future<void> _createContactsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS contacts (
        owner TEXT NOT NULL,
        id TEXT NOT NULL,
        name TEXT NOT NULL,
        phone TEXT NOT NULL DEFAULT '',
        country_code TEXT NOT NULL DEFAULT '+91',
        last_message TEXT NOT NULL DEFAULT 'Tap to start chatting',
        time TEXT NOT NULL DEFAULT '',
        PRIMARY KEY (owner, id)
      )
    ''');
  }
  static Future<void> _createOutboxTable(Database db) async {
    await db.execute('''
    CREATE TABLE IF NOT EXISTS outbox (
      id TEXT PRIMARY KEY,
      owner TEXT NOT NULL,
      chat_id TEXT NOT NULL,
      payload TEXT NOT NULL,
      state INTEGER NOT NULL DEFAULT 0,
      attempts INTEGER NOT NULL DEFAULT 0,
      send_at INTEGER NOT NULL DEFAULT 0,
      created_ms INTEGER NOT NULL
    )
  ''');
  }

  static Future<void> saveContacts(
      String owner,
      List<Map<String, dynamic>> contacts,
      ) async {
    final db = await getDatabase();

    await db.transaction((txn) async {
      for (final contact in contacts) {
        final id = (contact['id'] ?? '').toString();
        if (id.isEmpty) continue;

        await txn.insert(
          'contacts',
          {
            'owner': owner,
            'id': id,
            'name': (contact['name'] ?? 'Contact').toString(),
            'phone': (contact['phone'] ?? '').toString(),
            'country_code':
            (contact['countryCode'] ?? '+91').toString(),
            'last_message': (contact['lastMessage'] ??
                'Tap to start chatting')
                .toString(),
            'time': (contact['time'] ?? '').toString(),
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  static Future<List<Map<String, Object?>>> getContacts(
      String owner,
      ) async {
    final db = await getDatabase();

    return db.query(
      'contacts',
      where: 'owner = ?',
      whereArgs: [owner],
      orderBy: 'name COLLATE NOCASE ASC',
    );
  }

  static Future<void> saveContact({
    required String owner,
    required String id,
    required String name,
    required String phone,
    required String countryCode,
    String lastMessage = 'Tap to start chatting',
    String time = '',
  }) async {
    await saveContacts(owner, [
      {
        'id': id,
        'name': name,
        'phone': phone,
        'countryCode': countryCode,
        'lastMessage': lastMessage,
        'time': time,
      },
    ]);
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
      'CREATE TABLE IF NOT EXISTS chat_seeded ('
          'contact TEXT PRIMARY KEY)',
    );
  }

  static Future<void> _createProfileTable(Database db) async {
    await db.execute(
      'CREATE TABLE IF NOT EXISTS profile_images ('
          'uid TEXT PRIMARY KEY, '
          'path TEXT NOT NULL)',
    );
  }

  // ---------- OFFLINE OUTBOX ----------

  // Stores messages waiting for Firebase synchronization.
  // state: 0 = pending, 1 = failed and awaiting an explicit retry.
  // send_at: 0 = send as soon as there is internet,
  //          otherwise the time (ms) when a scheduled message may be sent.

  static Future<void> outboxInsert({
    required String id,
    required String owner,
    required String chatId,
    required String payload,
    required int createdMs,
    int sendAtMs = 0,
  }) async {
    final db = await getDatabase();

    await db.insert(
      'outbox',
      {
        'id': id,
        'owner': owner,
        'chat_id': chatId,
        'payload': payload,
        'state': 0,
        'attempts': 0,
        'created_ms': createdMs,
        'send_at': sendAtMs,
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  // messages that are ready to send (their time has come)
  static Future<List<Map<String, Object?>>> outboxPending(
      String owner,
      ) async {
    final db = await getDatabase();
    final now = DateTime.now().millisecondsSinceEpoch;

    return db.query(
      'outbox',
      where: 'owner = ? AND state = 0 AND send_at <= ?',
      whereArgs: [owner, now],
      orderBy: 'created_ms ASC, id ASC',
    );
  }

  static Future<List<Map<String, Object?>>> outboxForChat(
      String owner,
      String chatId,
      ) async {
    final db = await getDatabase();
    final now = DateTime.now().millisecondsSinceEpoch;

    return db.query(
      'outbox',
      where: 'owner = ? AND chat_id = ? AND send_at <= ?',
      whereArgs: [owner, chatId, now],
      orderBy: 'created_ms ASC, id ASC',
    );
  }

  static Future<int> outboxPendingCount(String owner) async {
    final db = await getDatabase();
    final now = DateTime.now().millisecondsSinceEpoch;

    final result = await db.rawQuery(
      'SELECT COUNT(*) AS total '
          'FROM outbox WHERE owner = ? AND state = 0 AND send_at <= ?',
      [owner, now],
    );

    return Sqflite.firstIntValue(result) ?? 0;
  }

  // scheduled messages whose time has not come yet
  static Future<List<Map<String, Object?>>> outboxScheduled(
      String owner,
      ) async {
    final db = await getDatabase();
    final now = DateTime.now().millisecondsSinceEpoch;

    return db.query(
      'outbox',
      where: 'owner = ? AND state = 0 AND send_at > ?',
      whereArgs: [owner, now],
      orderBy: 'send_at ASC, id ASC',
    );
  }

  static Future<void> outboxMarkAttempt(String id) async {
    final db = await getDatabase();

    await db.rawUpdate(
      'UPDATE outbox SET attempts = attempts + 1 WHERE id = ?',
      [id],
    );
  }

  static Future<void> outboxMarkFailed(String id) async {
    final db = await getDatabase();

    await db.update(
      'outbox',
      {'state': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<void> outboxRetry(String id) async {
    final db = await getDatabase();

    await db.update(
      'outbox',
      {'state': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<void> outboxDelete(String id) async {
    final db = await getDatabase();

    await db.delete(
      'outbox',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ---------- PASSWORD HELPERS ----------

  static String _makeSalt() {
    final random = Random.secure();
    final bytes = List<int>.generate(
      16,
          (_) => random.nextInt(256),
    );
    return base64Url.encode(bytes);
  }

  static String _hash(String password, String salt) {
    return sha256.convert(utf8.encode('$salt$password')).toString();
  }

  // ---------- USERS: OLD LOCAL LOGIN ----------

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

  static Future<bool> checkPassword(
      String email,
      String password,
      ) async {
    final user = await getUser(email);
    if (user == null) return false;

    final salt = user['salt'] as String?;
    final saved = user['password_hash'] as String?;

    if (salt == null || saved == null) return false;

    return _hash(password, salt) == saved;
  }

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

  static Future<int> countVerifiedUsers() async {
    final db = await getDatabase();

    final result = await db.rawQuery(
      'SELECT COUNT(*) AS total FROM users WHERE verified = 1',
    );

    return Sqflite.firstIntValue(result) ?? 0;
  }

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

  // ---------- PROFILE PICTURE: BY EMAIL ----------

  static Future<void> saveProfileImage(
      String email,
      String path,
      ) async {
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

  // ---------- PROFILE PICTURE: BY FIREBASE UID ----------

  static Future<void> saveProfileImageForUid(
      String uid,
      String path,
      ) async {
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

  // contact is a unique key: account ID + contact ID.
  static Future<List<Map<String, Object?>>> getMessages(
      String contact,
      ) async {
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

  // Existing message status: 0 = sent, 1 = delivered, 2 = read.
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

    await db.delete(
      'messages',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<void> clearChat(String contact) async {
    final db = await getDatabase();

    await db.delete(
      'messages',
      where: 'contact = ?',
      whereArgs: [contact],
    );
  }

  // ---------- DEMO MESSAGE SEEDING ----------

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