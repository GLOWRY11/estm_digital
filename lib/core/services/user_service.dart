import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import '../local_database.dart';
import '../../features/auth/domain/entities/user.dart';
import 'dart:developer' as developer;

class UserService {
  static const _uuid = Uuid();

  // Méthodes d'authentification
  static Future<User?> getUserByEmailAndPassword(String email, String password) async {
    try {
      final db = await LocalDatabase.open();
      final hashedPassword = _hashPassword(password);
      
      final result = await db.query(
        LocalDatabase.tableUsers,
        where: 'email = ? AND password = ? AND isActive = 1',
        whereArgs: [email, hashedPassword],
        limit: 1,
      );

      if (result.isNotEmpty) {
        return _mapToUser(result.first);
      }
      return null;
    } catch (e) {
      throw Exception('Erreur lors de la connexion: $e');
    }
  }

  static Future<bool> insertUser({
    required String email,
    required String password,
    required String role,
    String? displayName,
    String? phoneNumber,
    String? address,
    String? classId,
    int? studentId,
  }) async {
    try {
      final db = await LocalDatabase.open();
      
      // Vérifier si l'email existe déjà
      final existing = await db.query(
        LocalDatabase.tableUsers,
        where: 'email = ?',
        whereArgs: [email],
      );

      if (existing.isNotEmpty) {
        throw Exception('Un utilisateur avec cet email existe déjà');
      }

      final userId = _uuid.v4();
      final hashedPassword = _hashPassword(password);
      final now = DateTime.now().toIso8601String();

      await db.insert(LocalDatabase.tableUsers, {
        'id': userId,
        'email': email,
        'password': hashedPassword,
        'role': role,
        'displayName': displayName,
        'phoneNumber': phoneNumber,
        'address': address,
        'classId': classId,
        'studentId': studentId,
        'isActive': 1,
        'createdAt': now,
      });

      return true;
    } catch (e) {
      throw Exception('Erreur lors de la création de l\'utilisateur: $e');
    }
  }

  // CRUD Operations
  static Future<String> createTeacher({
    required String email,
    required String password,
    required String displayName,
    String? phoneNumber,
    String? address,
  }) async {
    final userId = _uuid.v4();
    await insertUser(
      email: email,
      password: password,
      role: 'teacher',
      displayName: displayName,
      phoneNumber: phoneNumber,
      address: address,
    );
    return userId;
  }

  static Future<String> createStudent({
    required String email,
    required String password,
    required String displayName,
    required String classId,
    required int studentId,
    String? phoneNumber,
    String? address,
  }) async {
    final userId = _uuid.v4();
    await insertUser(
      email: email,
      password: password,
      role: 'student',
      displayName: displayName,
      phoneNumber: phoneNumber,
      address: address,
      classId: classId,
      studentId: studentId,
    );
    return userId;
  }

  static Future<bool> updateUser(String userId, Map<String, dynamic> updates) async {
    try {
      final db = await LocalDatabase.open();
      
      // Ajouter la date de modification
      updates['lastModifiedAt'] = DateTime.now().toIso8601String();
      
      // Si le mot de passe est modifié, le hasher
      if (updates.containsKey('password')) {
        updates['password'] = _hashPassword(updates['password']);
      }

      final result = await db.update(
        LocalDatabase.tableUsers,
        updates,
        where: 'id = ?',
        whereArgs: [userId],
      );

      return result > 0;
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour: $e');
    }
  }

  static Future<bool> deleteUser(String userId) async {
    try {
      final db = await LocalDatabase.open();
      
      // Soft delete - marquer comme inactif
      final result = await db.update(
        LocalDatabase.tableUsers,
        {
          'isActive': 0,
          'lastModifiedAt': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [userId],
      );

      return result > 0;
    } catch (e) {
      throw Exception('Erreur lors de la suppression: $e');
    }
  }

  static Future<bool> hardDeleteUser(String userId) async {
    try {
      final db = await LocalDatabase.open();
      
      final result = await db.delete(
        LocalDatabase.tableUsers,
        where: 'id = ?',
        whereArgs: [userId],
      );

      return result > 0;
    } catch (e) {
      throw Exception('Erreur lors de la suppression définitive: $e');
    }
  }

  // Queries
  static Future<List<User>> queryUsers({
    String? role,
    bool? isActive,
    String? classId,
    int? limit,
    int? offset,
  }) async {
    try {
      final db = await LocalDatabase.open();
      
      String whereClause = '1=1';
      List<dynamic> whereArgs = [];

      if (role != null) {
        whereClause += ' AND role = ?';
        whereArgs.add(role);
      }

      if (isActive != null) {
        whereClause += ' AND isActive = ?';
        whereArgs.add(isActive ? 1 : 0);
      }

      if (classId != null) {
        whereClause += ' AND classId = ?';
        whereArgs.add(classId);
      }

      final result = await db.query(
        LocalDatabase.tableUsers,
        where: whereClause,
        whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
        orderBy: 'createdAt DESC',
        limit: limit,
        offset: offset,
      );

      return result.map((userData) => _mapToUser(userData)).toList();
    } catch (e) {
      throw Exception('Erreur lors de la recherche: $e');
    }
  }

  static Future<User?> getUserById(String userId) async {
    try {
      final db = await LocalDatabase.open();
      
      final result = await db.query(
        LocalDatabase.tableUsers,
        where: 'id = ?',
        whereArgs: [userId],
        limit: 1,
      );

      if (result.isNotEmpty) {
        return _mapToUser(result.first);
      }
      return null;
    } catch (e) {
      throw Exception('Erreur lors de la récupération: $e');
    }
  }

  static Future<List<User>> getUsersByRole(String role) async {
    return await queryUsers(role: role, isActive: true);
  }

  static Future<List<User>> getActiveUsers() async {
    return await queryUsers(isActive: true);
  }

  static Future<List<User>> getUsersByClass(String classId) async {
    return await queryUsers(classId: classId, isActive: true);
  }

  // Statistiques
  static Future<Map<String, int>> getUserStats() async {
    try {
      final db = await LocalDatabase.open();
      
      final total = await db.rawQuery('SELECT COUNT(*) as count FROM ${LocalDatabase.tableUsers} WHERE isActive = 1');
      final admins = await db.rawQuery('SELECT COUNT(*) as count FROM ${LocalDatabase.tableUsers} WHERE role = "admin" AND isActive = 1');
      final teachers = await db.rawQuery('SELECT COUNT(*) as count FROM ${LocalDatabase.tableUsers} WHERE role = "teacher" AND isActive = 1');
      final students = await db.rawQuery('SELECT COUNT(*) as count FROM ${LocalDatabase.tableUsers} WHERE role = "student" AND isActive = 1');

      return {
        'total': total.first['count'] as int,
        'admins': admins.first['count'] as int,
        'teachers': teachers.first['count'] as int,
        'students': students.first['count'] as int,
      };
    } catch (e) {
      throw Exception('Erreur lors du calcul des statistiques: $e');
    }
  }

  // Utilitaires
  static String _hashPassword(String password) {
    // Simple hash MD5 pour la démo - utiliser bcrypt en production
    final bytes = utf8.encode('${password}estm_salt');
    final digest = md5.convert(bytes);
    return digest.toString();
  }

  static User _mapToUser(Map<String, dynamic> userData) {
    return User(
      id: userData['id'] as String,
      email: userData['email'] as String,
      displayName: userData['displayName'] as String?,
      role: userData['role'] as String,
      phoneNumber: userData['phoneNumber'] as String?,
      address: userData['address'] as String?,
      profileImageUrl: userData['profileImageUrl'] as String?,
      classId: userData['classId'] as String?,
      studentId: userData['studentId'] as int?,
      isActive: userData['isActive'] == 1,
      createdAt: userData['createdAt'] != null 
          ? DateTime.parse(userData['createdAt'] as String)
          : DateTime.now(),
      lastModifiedAt: userData['lastModifiedAt'] != null
          ? DateTime.parse(userData['lastModifiedAt'] as String)
          : null,
      lastLoginAt: userData['lastLoginAt'] != null
          ? DateTime.parse(userData['lastLoginAt'] as String)
          : null,
    );
  }

  // Méthodes de validation
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  static bool isValidPassword(String password) {
    return password.length >= 6;
  }

  static bool isValidRole(String role) {
    return ['admin', 'teacher', 'student'].contains(role);
  }

  // Méthodes de recherche avancée
  static Future<List<User>> searchUsers(String query) async {
    try {
      final db = await LocalDatabase.open();
      
      final result = await db.query(
        LocalDatabase.tableUsers,
        where: '''
          (email LIKE ? OR displayName LIKE ? OR classId LIKE ?) 
          AND isActive = 1
        ''',
        whereArgs: ['%$query%', '%$query%', '%$query%'],
        orderBy: 'displayName ASC',
      );

      return result.map((userData) => _mapToUser(userData)).toList();
    } catch (e) {
      throw Exception('Erreur lors de la recherche: $e');
    }
  }

  // Gestion de session
  static Future<bool> updateLastLogin(String userId) async {
    try {
      return await updateUser(userId, {
        'lastLoginAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      // Si l'erreur est liée à la colonne manquante, on l'ignore pour l'instant
      if (e.toString().contains('no such column: lastLoginAt')) {
        developer.log('Colonne lastLoginAt non trouvée, ignorée pour cette connexion');
        return true; // On continue sans erreur
      }
      rethrow;
    }
  }
} 