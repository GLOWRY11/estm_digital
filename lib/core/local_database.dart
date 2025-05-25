import 'dart:io';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:developer' as developer;

class LocalDatabase {
  static Database? _database;
  static const String _databaseName = 'estm_digital.db';
  static const int _databaseVersion = 3;

  // Table names
  static const String tableUsers = 'users';
  static const String tableAbsences = 'absences';
  static const String tableRooms = 'rooms';
  static const String tableSessions = 'sessions';
  static const String tableNotifications = 'notifications';
  static const String tableComplaints = 'complaints';

  // Getter pour la compatibilité
  Future<Database> get database async => await open();

  static Future<Database> open() async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    // Initialiser SQLite FFI pour desktop
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    String documentsDirectory;
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      documentsDirectory = Directory.current.path;
    } else {
      documentsDirectory = await getDatabasesPath();
    }
    
    final path = join(documentsDirectory, _databaseName);
    developer.log('Ouverture de la base de données SQLite: $path');
    
    _database = await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
    
    return _database!;
  }

  static Future<void> _onCreate(Database db, int version) async {
    developer.log('Création des tables de la base de données');
    
    // Table Users
    await db.execute('''
      CREATE TABLE $tableUsers (
        id TEXT PRIMARY KEY,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        role TEXT NOT NULL CHECK(role IN ('admin', 'teacher', 'student')),
        displayName TEXT,
        phoneNumber TEXT,
        address TEXT,
        profileImageUrl TEXT,
        classId TEXT,
        studentId INTEGER,
        isActive INTEGER DEFAULT 1,
        createdAt TEXT NOT NULL,
        lastModifiedAt TEXT,
        lastLoginAt TEXT
      )
    ''');
    developer.log('Table users créée');
    
    // Table Absences
    await db.execute('''
      CREATE TABLE absences (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        etudiantId TEXT NOT NULL,
        teacherId TEXT NOT NULL,
        courseId TEXT,
        isPresent INTEGER NOT NULL DEFAULT 0,
        date TEXT NOT NULL,
        startTime TEXT NOT NULL,
        endTime TEXT NOT NULL,
        attendanceHistoryId TEXT,
        qrCodeData TEXT,
        notes TEXT,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (etudiantId) REFERENCES $tableUsers (id),
        FOREIGN KEY (teacherId) REFERENCES $tableUsers (id)
      )
    ''');
    developer.log('Table absences créée');
    
    // Table Absence (pour compatibilité avec le modèle existant)
    await db.execute('''
      CREATE TABLE Absence (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        isPresent INTEGER NOT NULL DEFAULT 0,
        date TEXT NOT NULL,
        startTime TEXT,
        endTime TEXT,
        attendanceHistoryId INTEGER,
        etudiantId INTEGER NOT NULL
      )
    ''');
    developer.log('Table Absence créée');
    
    // Table Rooms
    await db.execute('''
      CREATE TABLE $tableRooms (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        capacity INTEGER NOT NULL,
        location TEXT,
        isActive INTEGER DEFAULT 1,
        createdAt TEXT NOT NULL
      )
    ''');
    developer.log('Table rooms créée');
    
    // Table Sessions (Emploi du temps)
    await db.execute('''
      CREATE TABLE $tableSessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        course TEXT NOT NULL,
        roomId INTEGER,
        classId TEXT NOT NULL,
        teacherId TEXT NOT NULL,
        startTime TEXT NOT NULL,
        endTime TEXT NOT NULL,
        dayOfWeek INTEGER NOT NULL,
        isActive INTEGER DEFAULT 1,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (roomId) REFERENCES $tableRooms (id),
        FOREIGN KEY (teacherId) REFERENCES $tableUsers (id)
      )
    ''');
    developer.log('Table sessions créée');
    
    // Table Notifications
    await db.execute('''
      CREATE TABLE $tableNotifications (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        date TEXT NOT NULL,
        isRead INTEGER DEFAULT 0,
        etudiantId TEXT,
        enseignantId TEXT,
        targetRole TEXT,
        priority TEXT DEFAULT 'normal',
        createdAt TEXT NOT NULL,
        FOREIGN KEY (etudiantId) REFERENCES $tableUsers (id),
        FOREIGN KEY (enseignantId) REFERENCES $tableUsers (id)
      )
    ''');
    developer.log('Table notifications créée');
    
    // Table Complaints (déjà existante mais améliorée)
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableComplaints (
        id TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        text TEXT NOT NULL,
        status TEXT DEFAULT 'pending' CHECK(status IN ('pending', 'in_progress', 'resolved', 'rejected')),
        priority TEXT DEFAULT 'normal' CHECK(priority IN ('low', 'normal', 'high', 'urgent')),
        category TEXT,
        adminResponse TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT,
        resolvedAt TEXT,
        FOREIGN KEY (userId) REFERENCES $tableUsers (id)
      )
    ''');
    developer.log('Table complaints créée');
    
    // Index pour performance
    await db.execute('CREATE INDEX idx_users_email ON $tableUsers (email)');
    await db.execute('CREATE INDEX idx_users_role ON $tableUsers (role)');
    await db.execute('CREATE INDEX idx_absences_etudiant_date ON absences (etudiantId, date)');
    await db.execute('CREATE INDEX idx_sessions_day_time ON $tableSessions (dayOfWeek, startTime)');
    await db.execute('CREATE INDEX idx_notifications_target ON $tableNotifications (etudiantId, enseignantId, isRead)');

    // Insérer des données par défaut
    await _insertDefaultData(db);
  }

  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    developer.log('Mise à jour de la base de données de v$oldVersion vers v$newVersion');
    
    // Migration logic pour futures versions
    if (oldVersion < 2) {
      // Ajouter la colonne lastLoginAt
      try {
        await db.execute('ALTER TABLE $tableUsers ADD COLUMN lastLoginAt TEXT');
        developer.log('Colonne lastLoginAt ajoutée avec succès');
      } catch (e) {
        developer.log('Erreur lors de l\'ajout de lastLoginAt: $e');
        // La colonne existe peut-être déjà, on continue
      }
    }
    
    if (oldVersion < 3) {
      // Ajouter la table Absence pour compatibilité avec le modèle existant
      try {
        await db.execute('''
          CREATE TABLE Absence (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            isPresent INTEGER NOT NULL DEFAULT 0,
            date TEXT NOT NULL,
            startTime TEXT,
            endTime TEXT,
            attendanceHistoryId INTEGER,
            etudiantId INTEGER NOT NULL
          )
        ''');
        developer.log('Table Absence créée avec succès lors de la migration');
      } catch (e) {
        developer.log('Erreur lors de la création de la table Absence: $e');
        // La table existe peut-être déjà, on continue
      }
    }
  }

  static Future<void> _insertDefaultData(Database db) async {
    final now = DateTime.now().toIso8601String();

    // Fonction de hashage locale (même que dans UserService)
    String hashPassword(String password) {
      final bytes = utf8.encode(password + 'estm_salt');
      final digest = md5.convert(bytes);
      return digest.toString();
    }

    // Utilisateur admin par défaut
    await db.insert(tableUsers, {
      'id': 'admin-001',
      'email': 'admin@estm.sn',
      'password': hashPassword('admin123'),
      'role': 'admin',
      'displayName': 'Administrateur ESTM',
      'isActive': 1,
      'createdAt': now,
    });

    // Enseignant par défaut
    await db.insert(tableUsers, {
      'id': 'teacher-001',
      'email': 'teacher@estm.sn',
      'password': hashPassword('teacher123'),
      'role': 'teacher',
      'displayName': 'Enseignant Test',
      'isActive': 1,
      'createdAt': now,
    });

    // Étudiant par défaut
    await db.insert(tableUsers, {
      'id': 'student-001',
      'email': 'student@estm.sn',
      'password': hashPassword('student123'),
      'role': 'student',
      'displayName': 'Étudiant Test',
      'classId': 'L3-INFO',
      'studentId': 2024001,
      'isActive': 1,
      'createdAt': now,
    });

    // Salles par défaut
    await db.insert(tableRooms, {
      'name': 'Amphithéâtre A',
      'capacity': 150,
      'location': 'Bâtiment Principal',
      'createdAt': now,
    });

    await db.insert(tableRooms, {
      'name': 'Salle TP 1',
      'capacity': 30,
      'location': 'Bâtiment Informatique',
      'createdAt': now,
    });

    await db.insert(tableRooms, {
      'name': 'Salle TD 2',
      'capacity': 40,
      'location': 'Bâtiment Sciences',
      'createdAt': now,
    });
  }

  // Méthodes utilitaires
  static Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }

  static Future<void> deleteDatabase() async {
    final documentsDirectory = await getDatabasesPath();
    final path = join(documentsDirectory, _databaseName);
    await databaseFactory.deleteDatabase(path);
    _database = null;
  }

  // Méthodes de backup et restore
  static Future<String> backup() async {
    final db = await open();
    final tables = [tableUsers, tableAbsences, tableRooms, tableSessions, tableNotifications, tableComplaints];
    
    String backup = '';
    for (String table in tables) {
      final List<Map<String, dynamic>> records = await db.query(table);
      backup += '-- Table $table\n';
      for (Map<String, dynamic> record in records) {
        backup += 'INSERT INTO $table VALUES (${record.values.map((v) => "'$v'").join(', ')});\n';
      }
      backup += '\n';
    }
    return backup;
  }

  static Future<bool> testConnection() async {
    try {
      final db = await open();
      await db.rawQuery('SELECT 1');
      return true;
    } catch (e) {
      return false;
    }
  }
} 