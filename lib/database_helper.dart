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
      version: 2,
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE users (email TEXT PRIMARY KEY, verified INTEGER)',
        );
        await _createChatTables(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await _createChatTables(db);
        }
      },
    );
    return _db!;
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

  // ---------- USERS ----------
  static Future<void> markVerified(String email) async {
    final db = await getDatabase();
    await db.insert(
      'users',
      {'email': email.toLowerCase(), 'verified': 1},
      conflictAlgorithm: ConflictAlgorithm.replace,
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

  // ---------- CHAT ----------
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