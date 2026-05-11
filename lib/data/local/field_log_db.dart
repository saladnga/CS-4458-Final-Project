import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import '../../model/field_log.dart';

class FieldLogDb {
  FieldLogDb._();
  static final FieldLogDb instance = FieldLogDb._();
  static const _dbName = 'field_logs.db';
  static const _dbVersion = 1;
  static const _table = 'field_logs';

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _open();
    return _db!;
  }

  // Initialize Local SQFlite Database
  Future<Database> _open() async {
    final dir = await getDatabasesPath();
    final path = p.join(dir, _dbName);

    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: (db, version) async {
        await db.execute('''
            CREATE TABLE $_table (
            id TEXT PRIMARY KEY NOT NULL,
            title TEXT NOT NULL,
            notes TEXT NOT NULL,
            user_id TEXT,
            latitude REAL NOT NULL,
            longitude REAL NOT NULL,
            weather_description TEXT,
            local_image_path TEXT,
            remote_image_url TEXT,
            created_at INTEGER NOT NULL,
            updated_at INTEGER NOT NULL,
            synced_to_server INTEGER NOT NULL
            )
        ''');
        await db.execute(
          'CREATE INDEX idx_field_logs_created_at ON $_table (created_at DESC)',
        );
      },
    );
  }

  // Insert operation (Local database)
  Future<void> insert(FieldLog log) async {
    final db = await database;
    await db.insert(
      _table,
      log.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Update operation (Local database)
  Future<void> update(FieldLog log) async {
    final db = await database;
    await db.update(_table, log.toMap(), where: 'id = ?', whereArgs: [log.id]);
  }

  // Delete operation (Local database)
  Future<void> delete(String id) async {
    final db = await database;
    await db.delete(_table, where: 'id = ?', whereArgs: [id]);
  }

  // Fetch data by newest
  Future<List<FieldLog>> getAllByNewestFirst(String userId) async {
    final db = await database;
    final rows = await db.query(
      _table,
      orderBy: 'created_at DESC',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    return rows.map(FieldLog.fromMap).toList();
  }

  // Search data by id
  Future<FieldLog?> getById(String id) async {
    final db = await database;
    final rows = await db.query(
      _table,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return FieldLog.fromMap(rows.first);
  }

  // Sync to server (local for no connection)
  Future<List<FieldLog>> pendingSync(String userId) async {
    final db = await database;
    final rows = await db.query(
      _table,
      where: 'synced_to_server = ? AND user_id = ?',
      whereArgs: [0, userId],
      orderBy: 'created_at DESC',
    );
    return rows.map(FieldLog.fromMap).toList();
  }
}
