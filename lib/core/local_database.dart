import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:developer' as developer;

class LocalDatabase {
  static Database? _database;

  // Getter pour la compatibilité
  Future<Database> get database async => await open();

  static Future<Database> open() async {
    if (_database != null) return _database!;
    
    final dir = await getApplicationDocumentsDirectory();
    final path = join(dir.path, 'estm_digital.db');
    developer.log('Ouverture de la base de données SQLite: $path');
    
    _database = await openDatabase(
      path, 
      version: 1, 
      onCreate: (db, v) async {
        developer.log('Création des tables de la base de données');
        
        // Table utilisateurs simple
        await db.execute('''
          CREATE TABLE users(
            id TEXT PRIMARY KEY,
            email TEXT NOT NULL,
            password TEXT NOT NULL,
            displayName TEXT,
            role TEXT NOT NULL,
            phoneNumber TEXT,
            address TEXT,
            profileImageUrl TEXT,
            classId TEXT,
            dateOfBirth TEXT,
            studentId INTEGER,
            isActive INTEGER NOT NULL DEFAULT 1,
            createdAt TEXT,
            lastModifiedAt TEXT,
            syncStatus INTEGER NOT NULL DEFAULT 0
          )
        ''');
        developer.log('Table users créée');
        
        // Table classes
        await db.execute('''
          CREATE TABLE classes(
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            description TEXT,
            year INTEGER NOT NULL,
            department TEXT NOT NULL,
            syncStatus INTEGER NOT NULL DEFAULT 0
          )
        ''');
        developer.log('Table classes créée');
        
        // Table absences
        await db.execute('''
          CREATE TABLE absences(
            id TEXT PRIMARY KEY,
            studentId TEXT NOT NULL,
            date TEXT NOT NULL,
            time TEXT NOT NULL,
            status TEXT NOT NULL,
            syncStatus INTEGER NOT NULL DEFAULT 0,
            FOREIGN KEY (studentId) REFERENCES users(id)
          )
        ''');
        developer.log('Table absences créée');
        
        // Table salles
        await db.execute('''
          CREATE TABLE rooms(
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            capacity INTEGER NOT NULL,
            syncStatus INTEGER NOT NULL DEFAULT 0
          )
        ''');
        developer.log('Table rooms créée');
        
        // Table sessions (cours programmés)
        await db.execute('''
          CREATE TABLE sessions(
            id TEXT PRIMARY KEY,
            course TEXT NOT NULL,
            roomId TEXT NOT NULL,
            classId TEXT NOT NULL,
            start TEXT NOT NULL,
            end TEXT NOT NULL,
            syncStatus INTEGER NOT NULL DEFAULT 0,
            FOREIGN KEY (roomId) REFERENCES rooms(id),
            FOREIGN KEY (classId) REFERENCES classes(id)
          )
        ''');
        developer.log('Table sessions créée');
        
        // Table complaints (réclamations)
        await db.execute('''
          CREATE TABLE complaints(
            id TEXT PRIMARY KEY,
            userId TEXT NOT NULL,
            text TEXT NOT NULL,
            status TEXT NOT NULL,
            createdAt TEXT NOT NULL,
            FOREIGN KEY (userId) REFERENCES users(id)
          )
        ''');
        developer.log('Table complaints créée');
        
        // Table sync_log
        await db.execute('''
          CREATE TABLE sync_log(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            entityType TEXT NOT NULL,
            entityId TEXT NOT NULL,
            action TEXT NOT NULL,
            timestamp TEXT NOT NULL,
            data TEXT,
            synced INTEGER NOT NULL DEFAULT 0
          )
        ''');
        developer.log('Table sync_log créée');

        // Absence
        await db.execute('''
          CREATE TABLE Absence(
            id INTEGER PRIMARY KEY,
            isPresent INTEGER NOT NULL,
            date TEXT NOT NULL,
            startTime TEXT,
            endTime TEXT,
            attendanceHistoryId INTEGER,
            etudiantId INTEGER NOT NULL
          )
        ''');

        // AbsenceHistorique
        await db.execute('''
          CREATE TABLE AbsenceHistorique(
            id INTEGER PRIMARY KEY,
            date TEXT NOT NULL,
            presentCount INTEGER,
            absentCount INTEGER,
            enseignantId INTEGER NOT NULL
          )
        ''');

        // Notification
        await db.execute('''
          CREATE TABLE Notification(
            id INTEGER PRIMARY KEY,
            content TEXT NOT NULL,
            date TEXT NOT NULL,
            isRead INTEGER NOT NULL,
            etudiantId INTEGER,
            enseignantId INTEGER
          )
        ''');

        // Fonctionnaire
        await db.execute('''
          CREATE TABLE Fonctionnaire(
            id INTEGER PRIMARY KEY,
            name TEXT NOT NULL,
            email TEXT NOT NULL,
            password TEXT NOT NULL
          )
        ''');

        // Etudiant
        await db.execute('''
          CREATE TABLE Etudiant(
            id INTEGER PRIMARY KEY,
            name TEXT NOT NULL,
            email TEXT NOT NULL,
            filiereId INTEGER NOT NULL
          )
        ''');

        // Filiere
        await db.execute('''
          CREATE TABLE Filiere(
            id INTEGER PRIMARY KEY,
            name TEXT NOT NULL,
            annee TEXT
          )
        ''');

        // Enseignant
        await db.execute('''
          CREATE TABLE Enseignant(
            id INTEGER PRIMARY KEY,
            name TEXT NOT NULL,
            email TEXT NOT NULL
          )
        ''');

        // Seance
        await db.execute('''
          CREATE TABLE Seance(
            id INTEGER PRIMARY KEY,
            date TEXT NOT NULL,
            startTime TEXT NOT NULL,
            endTime TEXT NOT NULL,
            enseignantId INTEGER NOT NULL
          )
        ''');

        // Module
        await db.execute('''
          CREATE TABLE Module(
            id INTEGER PRIMARY KEY,
            name TEXT NOT NULL
          )
        ''');

        // Element
        await db.execute('''
          CREATE TABLE Element(
            id INTEGER PRIMARY KEY,
            name TEXT NOT NULL,
            moduleId INTEGER NOT NULL
          )
        ''');

        // Enseignant_Element (association N-N)
        await db.execute('''
          CREATE TABLE Enseignant_Element(
            id INTEGER PRIMARY KEY,
            enseignantId INTEGER NOT NULL,
            elementId INTEGER NOT NULL
          )
        ''');
      },
      onOpen: (db) async {
        developer.log('Base de données ouverte');
      }
    );
    
    return _database!;
  }
} 