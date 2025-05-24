import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class SQLiteDatabaseHelper {
  static final SQLiteDatabaseHelper _instance = SQLiteDatabaseHelper._internal();
  factory SQLiteDatabaseHelper() => _instance;
  
  SQLiteDatabaseHelper._internal();
  
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'estm_digital.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Users table
    await db.execute('''
      CREATE TABLE users (
        uid TEXT PRIMARY KEY,
        email TEXT NOT NULL,
        displayName TEXT,
        role TEXT NOT NULL,
        phoneNumber TEXT,
        address TEXT,
        profileImageUrl TEXT,
        classId TEXT,
        dateOfBirth TEXT,
        studentId INTEGER,
        isActive INTEGER NOT NULL,
        createdAt TEXT NOT NULL,
        lastModifiedAt TEXT,
        syncStatus INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Classes table
    await db.execute('''
      CREATE TABLE classes (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        year INTEGER NOT NULL,
        department TEXT NOT NULL,
        syncStatus INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Sync log table
    await db.execute('''
      CREATE TABLE sync_log (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        entityType TEXT NOT NULL,
        entityId TEXT NOT NULL,
        action TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        data TEXT,
        synced INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }
} 