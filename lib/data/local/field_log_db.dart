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

  Future<void> insert(FieldLog log) async {
    final db = await database;
    await db.insert(
      _table,
      log.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> update(FieldLog log) async {
    final db = await database;
    await db.update(_table, log.toMap(), where: 'id = ?', whereArgs: [log.id]);
  }

  Future<List<FieldLog>> getAllByNewestFirst() async {
    final db = await database;
    final rows = await db.query(_table, orderBy: 'created_at DESC');
    return rows.map(FieldLog.fromMap).toList();
  }

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

  Future<List<FieldLog>> pendingSync() async {
    final db = await database;
    final rows = await db.query(
      _table,
      where: 'synced_to_server = ?',
      whereArgs: [0],
      orderBy: 'created_at DESC',
    );
    return rows.map(FieldLog.fromMap).toList();
  }

  Future<void> delete(String id) async {
    final db = await database;
    await db.delete(_table, where: 'id = ?', whereArgs: [id]);
  }
}
