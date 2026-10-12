import 'package:sqflite/sqflite.dart';
import 'database_helper.dart';

// The "who is logged in right now" note.
// Kept in SQLite, so it survives app stop and phone restart.
class SessionHelper {
  static Future<Database> _db() async {
    final db = await DatabaseHelper.getDatabase();
    // make the small table the first time (it holds only one row)
    await db.execute(
      'CREATE TABLE IF NOT EXISTS session (id INTEGER PRIMARY KEY, email TEXT)',
    );
    return db;
  }

  // Write: "this email is logged in"
  static Future<void> saveSession(String email) async {
    final db = await _db();
    await db.insert(
      'session',
      {'id': 1, 'email': email.toLowerCase()},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Read: "who is logged in?" (null if nobody)
  static Future<String?> getSession() async {
    final db = await _db();
    final rows = await db.query('session', where: 'id = ?', whereArgs: [1]);
    if (rows.isEmpty) return null;
    return rows.first['email'] as String?;
  }

  // Erase the note (used when the user logs out)
  static Future<void> clearSession() async {
    final db = await _db();
    await db.delete('session');
  }
}