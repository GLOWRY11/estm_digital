import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart' as path;

void main() {
  late Database db;
  
  // Set up sqflite_ffi for testing
  setUpAll(() {
    // Initialize FFI
    sqfliteFfiInit();
    // Set global factory for tests
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    // Create a test DB
    String dbPath = await getDatabasesPath();
    final testDbPath = path.join(dbPath, 'test_database.db');
    
    // Delete existing test database if any
    await deleteDatabase(testDbPath);
    
    // Open the database
    db = await openDatabase(
      testDbPath,
      version: 1,
      onCreate: (Database db, int version) async {
        // Create test tables
        await db.execute('''
          CREATE TABLE users(
            id TEXT PRIMARY KEY,
            email TEXT NOT NULL,
            password TEXT NOT NULL,
            displayName TEXT,
            role TEXT NOT NULL,
            isActive INTEGER NOT NULL DEFAULT 1,
            createdAt TEXT
          )
        ''');
      }
    );
  });

  tearDown(() async {
    // Close the database
    await db.close();
  });

  group('LocalDatabase Tests', () {
    test('Insert and query user', () async {
      final timestamp = DateTime.now().toIso8601String();
      // Test data
      final userData = {
        'id': 'test_id_123',
        'email': 'test@example.com',
        'password': 'password123',
        'displayName': 'Test User',
        'role': 'student',
        'isActive': 1,
        'createdAt': timestamp,
      };
      
      // Insert the user
      await db.insert('users', userData);
      
      // Query the user back
      final List<Map<String, dynamic>> results = await db.query(
        'users',
        where: 'id = ?',
        whereArgs: ['test_id_123'],
      );
      
      expect(results.length, 1);
      expect(results.first['email'], 'test@example.com');
      expect(results.first['displayName'], 'Test User');
      expect(results.first['role'], 'student');
    });
    
    test('Update user data', () async {
      final timestamp = DateTime.now().toIso8601String();
      // Insert initial data
      await db.insert('users', {
        'id': 'update_test_id',
        'email': 'initial@example.com',
        'password': 'initial123',
        'displayName': 'Initial User',
        'role': 'student',
        'isActive': 1,
        'createdAt': timestamp,
      });
      
      // Update the user
      await db.update(
        'users',
        {
          'email': 'updated@example.com',
          'displayName': 'Updated User',
        },
        where: 'id = ?',
        whereArgs: ['update_test_id'],
      );
      
      // Query the updated user
      final List<Map<String, dynamic>> results = await db.query(
        'users',
        where: 'id = ?',
        whereArgs: ['update_test_id'],
      );
      
      expect(results.length, 1);
      expect(results.first['email'], 'updated@example.com');
      expect(results.first['displayName'], 'Updated User');
      // Password shouldn't change
      expect(results.first['password'], 'initial123');
    });
    
    test('Delete user', () async {
      final timestamp = DateTime.now().toIso8601String();
      // Insert user to delete
      await db.insert('users', {
        'id': 'delete_test_id',
        'email': 'delete@example.com',
        'password': 'delete123',
        'displayName': 'Delete User',
        'role': 'student',
        'isActive': 1,
        'createdAt': timestamp,
      });
      
      // Verify user exists
      var results = await db.query(
        'users',
        where: 'id = ?',
        whereArgs: ['delete_test_id'],
      );
      expect(results.length, 1);
      
      // Delete the user
      await db.delete(
        'users',
        where: 'id = ?',
        whereArgs: ['delete_test_id'],
      );
      
      // Verify user is deleted
      results = await db.query(
        'users',
        where: 'id = ?',
        whereArgs: ['delete_test_id'],
      );
      expect(results.length, 0);
    });
  });
} 