import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'media.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE media(id INTEGER PRIMARY KEY, path TEXT,'
          ' type TEXT, name TEXT, data TEXT, extension TEXT)',
        );
      },
    );
  }

  Future<void> insertMedia(Map<String, dynamic> data) async {
    final db = await database;
    await db.insert(
      'media',
      data,
    );
  }

  Future<void> updateMedia(Map<String, dynamic> data) async {
    final db = await database;
    await db.insert(
      'media',
      data,
    );
  }

  Future<void> updateWordById(int id, Map<String, dynamic> values) async {
    try {
      Database db = await database;

      await db.update(
        'media',
        values,
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getAllMedia(
      {int limit = 10, int offset = 0, required String type}) async {
    final db = await database;
    return await db.query(
      'media',
      where: 'type = ?',
      whereArgs: [type],
      limit: limit,
      offset: offset,
    );
  }
}
