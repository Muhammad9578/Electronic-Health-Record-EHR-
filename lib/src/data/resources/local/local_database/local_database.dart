import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '/src/core/helpers/helpers.dart';
import '../../../models/medical_record.dart';

class LocalDatabase {
  late Database _database;

  LocalDatabase() {
    debugLog("inside LocalDatabase constructer");
    open();
  }

  Future<void> open() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'ehr_records.db');

    _database = await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE medical_records(
        id INTEGER PRIMARY KEY,
        name TEXT,
        size TEXT,
        createdOn INTEGER,
        description TEXT,
        path TEXT,
        extension TEXT
      )
    ''');
  }

  Future<int> addMedicalRecord(MedicalRecord record) async {
    return await _database.insert('medical_records', record.toJson());
  }

  Future<List<MedicalRecord>> getAllMedicalRecords() async {
    final List<Map<String, dynamic>> maps =
        await _database.query('medical_records');

    return List.generate(maps.length, (i) {
      return MedicalRecord.fromJson(maps[i]);
    });
  }
}
