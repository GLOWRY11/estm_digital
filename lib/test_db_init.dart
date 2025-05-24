import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:developer' as developer;
import 'core/local_database.dart';
import 'package:uuid/uuid.dart';

class TestDatabaseScreen extends StatefulWidget {
  const TestDatabaseScreen({Key? key}) : super(key: key);

  @override
  State<TestDatabaseScreen> createState() => _TestDatabaseScreenState();
}

class _TestDatabaseScreenState extends State<TestDatabaseScreen> {
  String _result = 'Appuyez sur Test pour vérifier la base de données...';
  bool _isLoading = false;

  Future<void> _testDatabase() async {
    setState(() {
      _isLoading = true;
      _result = 'Test en cours...';
    });

    try {
      // Ouvrir la base de données
      final Database db = await LocalDatabase.open();
      
      // Liste des tables attendues
      final expectedTables = [
        'users',
        'classes',
        'absences',
        'rooms',
        'sessions',
        'complaints',
        'sync_log',
      ];
      
      // Récupérer la liste des tables existantes
      final List<Map<String, dynamic>> tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%' AND name NOT LIKE 'android_%'",
      );
      
      final existingTables = tables.map((t) => t['name'] as String).toList();
      developer.log('Tables existantes: $existingTables');
      
      // Vérifier si toutes les tables attendues existent
      final missingTables = expectedTables.where((t) => !existingTables.contains(t)).toList();
      
      if (missingTables.isNotEmpty) {
        setState(() {
          _result = 'État initial: Tables manquantes: ${missingTables.join(', ')}';
        });
        
        // Réinitialiser la base de données
        await _resetDatabase(db);
        
        // Vérifier à nouveau
        final tablesAfterReset = await db.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%' AND name NOT LIKE 'android_%'",
        );
        
        final existingTablesAfterReset = tablesAfterReset.map((t) => t['name'] as String).toList();
        
        setState(() {
          _result = 'État initial: Tables manquantes: ${missingTables.join(', ')}\n\n'
                  'État après réinitialisation: Tables présentes: ${existingTablesAfterReset.join(', ')}';
        });
      } else {
        setState(() {
          _result = 'Toutes les tables sont présentes: ${existingTables.join(', ')}';
        });
      }
      
      // Tester chaque table
      for (final table in expectedTables) {
        await _testTable(db, table);
      }
    } catch (e) {
      setState(() {
        _result = 'Erreur lors du test: $e';
      });
      developer.log('Erreur lors du test de la base de données: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Future<void> _resetDatabase(Database db) async {
    // Supprimer les tables existantes (dans l'ordre pour éviter les problèmes de contraintes)
    await db.execute('DROP TABLE IF EXISTS absences');
    await db.execute('DROP TABLE IF EXISTS complaints');
    await db.execute('DROP TABLE IF EXISTS sessions');
    await db.execute('DROP TABLE IF EXISTS rooms');
    await db.execute('DROP TABLE IF EXISTS classes');
    await db.execute('DROP TABLE IF EXISTS sync_log');
    await db.execute('DROP TABLE IF EXISTS users');
    
    // Recréer les tables
    // Table utilisateurs
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
    
    // Table salles
    await db.execute('''
      CREATE TABLE rooms(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        capacity INTEGER NOT NULL,
        syncStatus INTEGER NOT NULL DEFAULT 0
      )
    ''');
    
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
    
    // Ajouter des données de test
    await _insertTestData(db);
  }
  
  Future<void> _insertTestData(Database db) async {
    final uuid = Uuid();
    
    // Créer des classes de test
    final classId1 = uuid.v4();
    final classId2 = uuid.v4();
    
    await db.insert('classes', {
      'id': classId1,
      'name': 'Licence 1 Informatique',
      'description': 'Première année de licence en informatique',
      'year': 1,
      'department': 'Informatique',
      'syncStatus': 0,
    });
    
    await db.insert('classes', {
      'id': classId2,
      'name': 'Master 1 Réseaux',
      'description': 'Première année de master en réseaux',
      'year': 4,
      'department': 'Réseaux et Télécommunications',
      'syncStatus': 0,
    });
    
    // Créer des salles de test
    final roomId1 = uuid.v4();
    final roomId2 = uuid.v4();
    
    await db.insert('rooms', {
      'id': roomId1,
      'name': 'Salle A101',
      'capacity': 30,
      'syncStatus': 0,
    });
    
    await db.insert('rooms', {
      'id': roomId2,
      'name': 'Labo Informatique',
      'capacity': 25,
      'syncStatus': 0,
    });
    
    // Créer des utilisateurs de test
    final adminId = uuid.v4();
    final teacherId = uuid.v4();
    final studentId1 = uuid.v4();
    final studentId2 = uuid.v4();
    
    await db.insert('users', {
      'id': adminId,
      'email': 'admin@estm.sn',
      'password': 'password123',
      'displayName': 'Admin Test',
      'role': 'admin',
      'isActive': 1,
      'createdAt': DateTime.now().toIso8601String(),
      'syncStatus': 0,
    });
    
    await db.insert('users', {
      'id': teacherId,
      'email': 'enseignant@estm.sn',
      'password': 'password123',
      'displayName': 'Enseignant Test',
      'role': 'teacher',
      'isActive': 1,
      'createdAt': DateTime.now().toIso8601String(),
      'syncStatus': 0,
    });
    
    await db.insert('users', {
      'id': studentId1,
      'email': 'etudiant@estm.sn',
      'password': 'password123',
      'displayName': 'Étudiant Test',
      'role': 'student',
      'classId': classId1,
      'studentId': 12345,
      'isActive': 1,
      'createdAt': DateTime.now().toIso8601String(),
      'syncStatus': 0,
    });
    
    await db.insert('users', {
      'id': studentId2,
      'email': 'etudiant2@estm.sn',
      'password': 'password123',
      'displayName': 'Étudiant Test 2',
      'role': 'student',
      'classId': classId2,
      'studentId': 12346,
      'isActive': 1,
      'createdAt': DateTime.now().toIso8601String(),
      'syncStatus': 0,
    });
    
    // Créer des sessions (cours) de test
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    
    // Session 1 - Aujourd'hui
    await db.insert('sessions', {
      'id': uuid.v4(),
      'course': 'Introduction à la programmation',
      'roomId': roomId1,
      'classId': classId1,
      'start': DateTime(now.year, now.month, now.day, 8, 0).toIso8601String(),
      'end': DateTime(now.year, now.month, now.day, 10, 0).toIso8601String(),
      'syncStatus': 0,
    });
    
    // Session 2 - Demain
    await db.insert('sessions', {
      'id': uuid.v4(),
      'course': 'Réseaux informatiques',
      'roomId': roomId2,
      'classId': classId2,
      'start': DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 14, 0).toIso8601String(),
      'end': DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 16, 0).toIso8601String(),
      'syncStatus': 0,
    });
    
    // Session 3 - Hier
    await db.insert('sessions', {
      'id': uuid.v4(),
      'course': 'Bases de données',
      'roomId': roomId1,
      'classId': classId1,
      'start': DateTime(yesterday.year, yesterday.month, yesterday.day, 10, 0).toIso8601String(),
      'end': DateTime(yesterday.year, yesterday.month, yesterday.day, 12, 0).toIso8601String(),
      'syncStatus': 0,
    });
    
    // Créer des absences de test
    await db.insert('absences', {
      'id': uuid.v4(),
      'studentId': studentId1,
      'date': yesterday.toIso8601String().split('T')[0],
      'time': '10:15',
      'status': 'absent',
      'syncStatus': 0,
    });
    
    await db.insert('absences', {
      'id': uuid.v4(),
      'studentId': studentId2,
      'date': yesterday.toIso8601String().split('T')[0],
      'time': '10:15',
      'status': 'present',
      'syncStatus': 0,
    });
    
    await db.insert('absences', {
      'id': uuid.v4(),
      'studentId': studentId1,
      'date': now.toIso8601String().split('T')[0],
      'time': '08:15',
      'status': 'present',
      'syncStatus': 0,
    });
    
    // Créer des réclamations de test
    await db.insert('complaints', {
      'id': uuid.v4(),
      'userId': studentId1,
      'text': 'Problème d\'accès à la salle informatique',
      'status': 'open',
      'createdAt': yesterday.toIso8601String(),
    });
    
    await db.insert('complaints', {
      'id': uuid.v4(),
      'userId': studentId2,
      'text': 'Difficulté avec le TD de réseaux',
      'status': 'handled',
      'createdAt': DateTime(now.year, now.month, now.day - 3).toIso8601String(),
    });
    
    await db.insert('complaints', {
      'id': uuid.v4(),
      'userId': teacherId,
      'text': 'Problème de vidéoprojecteur dans la salle A101',
      'status': 'open',
      'createdAt': now.toIso8601String(),
    });
    
    // Enregistrements de synchronisation
    await db.insert('sync_log', {
      'entityType': 'absence',
      'entityId': '1',
      'action': 'create',
      'timestamp': now.toIso8601String(),
      'data': '{"studentId": "$studentId1", "date": "${yesterday.toIso8601String().split('T')[0]}", "status": "absent"}',
      'synced': 1,
    });
  }
  
  Future<void> _testTable(Database db, String tableName) async {
    try {
      final count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM $tableName'));
      setState(() {
        _result = '$_result\nTable $tableName: $count enregistrements';
      });
    } catch (e) {
      setState(() {
        _result = '$_result\nErreur lors du test de la table $tableName: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Base de Données'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: _isLoading ? null : _testDatabase,
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Tester et réparer la base de données'),
            ),
            const SizedBox(height: 16),
            const Text('Résultat:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: SingleChildScrollView(
                child: Text(_result),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 