import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/medication.dart';

class DatabaseService {
  static const _databaseName = 'medication_reminder.db';
  static const _databaseVersion = 1;

  static const medicationsTable = 'medications';
  static const columnId = 'id';
  static const columnName = 'name';
  static const columnDosage = 'dosage';
  static const columnFrequencyInHours = 'frequencyInHours';
  static const columnStartTime = 'startTime';
  static const columnIsActive = 'isActive';
  static const columnNotes = 'notes';

  DatabaseService._privateConstructor();
  static final DatabaseService instance = DatabaseService._privateConstructor();

  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $medicationsTable (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnName TEXT NOT NULL,
        $columnDosage TEXT NOT NULL,
        $columnFrequencyInHours INTEGER NOT NULL,
        $columnStartTime TEXT NOT NULL,
        $columnIsActive INTEGER NOT NULL,
        $columnNotes TEXT
      )
    ''');
  }

  Future<int> insertMedication(Medication medication) async {
    Database db = await database;
    return await db.insert(medicationsTable, medication.toMap());
  }

  Future<List<Medication>> getAllMedications() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(medicationsTable);
    return List.generate(maps.length, (i) => Medication.fromMap(maps[i]));
  }

  Future<List<Medication>> getActiveMedications() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      medicationsTable,
      where: '$columnIsActive = ?',
      whereArgs: [1],
    );
    return List.generate(maps.length, (i) => Medication.fromMap(maps[i]));
  }

  Future<int> updateMedication(Medication medication) async {
    Database db = await database;
    return await db.update(
      medicationsTable,
      medication.toMap(),
      where: '$columnId = ?',
      whereArgs: [medication.id],
    );
  }

  Future<int> deleteMedication(int id) async {
    Database db = await database;
    return await db.delete(
      medicationsTable,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }
}
