import 'dart:developer' as developer;
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/local_database.dart';
import '../models/class_model.dart';
import '../models/user_model.dart';

// Cette classe simule le comportement d'une source de données distante
// mais utilise en réalité SQLite localement (pour les besoins de la démonstration)
class UserRemoteDataSource {
  final Uuid _uuid = const Uuid();

  UserRemoteDataSource();

  // Teacher operations
  Future<ExtendedUserModel> createTeacher({
    required String email,
    required String password,
    String? displayName,
    String? phoneNumber,
    String? address,
    String? profileImageUrl,
  }) async {
    try {
      developer.log('Création d\'un enseignant: $email');
      final db = await LocalDatabase.open();
      
      // Vérifier si l'email existe déjà
      final existingUsers = await db.query(
        'users',
        where: 'email = ?',
        whereArgs: [email],
      );
      
      if (existingUsers.isNotEmpty) {
        throw Exception('Un utilisateur avec cet email existe déjà');
      }
      
      final uid = _uuid.v4();
      
      // Créer l'utilisateur
      final teacher = ExtendedUserModel(
        uid: uid,
        email: email,
        displayName: displayName,
        role: 'teacher',
        phoneNumber: phoneNumber,
        address: address,
        profileImageUrl: profileImageUrl,
        classId: null,
        dateOfBirth: null,
        studentId: null,
        isActive: true,
        createdAt: DateTime.now(),
        lastModifiedAt: null,
      );

      // Insérer l'utilisateur dans la base de données
      await db.insert('users', {
        'id': teacher.uid,
        'email': teacher.email,
        'password': password,
        'displayName': teacher.displayName,
        'role': teacher.role,
        'phoneNumber': teacher.phoneNumber,
        'address': teacher.address,
        'profileImageUrl': teacher.profileImageUrl,
        'classId': teacher.classId,
        'dateOfBirth': teacher.dateOfBirth?.toIso8601String(),
        'studentId': teacher.studentId,
        'isActive': teacher.isActive ? 1 : 0,
        'createdAt': teacher.createdAt.toIso8601String(),
        'lastModifiedAt': teacher.lastModifiedAt?.toIso8601String(),
      });
      
      developer.log('Enseignant créé avec succès: ${teacher.uid}');
      return teacher;
    } catch (e) {
      developer.log('Erreur lors de la création de l\'enseignant: $e');
      throw Exception('Échec de la création de l\'enseignant: $e');
    }
  }

  // Student operations
  Future<ExtendedUserModel> createStudent({
    required String email,
    required String password,
    String? displayName,
    String? phoneNumber,
    String? address,
    String? profileImageUrl,
    required String classId,
    DateTime? dateOfBirth,
    int? studentId,
  }) async {
    try {
      developer.log('Création d\'un étudiant: $email');
      final db = await LocalDatabase.open();
      
      // Vérifier si l'email existe déjà
      final existingUsers = await db.query(
        'users',
        where: 'email = ?',
        whereArgs: [email],
      );
      
      if (existingUsers.isNotEmpty) {
        throw Exception('Un utilisateur avec cet email existe déjà');
      }
      
      final uid = _uuid.v4();
      
      // Créer l'utilisateur
      final student = ExtendedUserModel(
        uid: uid,
        email: email,
        displayName: displayName,
        role: 'student',
        phoneNumber: phoneNumber,
        address: address,
        profileImageUrl: profileImageUrl,
        classId: classId,
        dateOfBirth: dateOfBirth,
        studentId: studentId,
        isActive: true,
        createdAt: DateTime.now(),
        lastModifiedAt: null,
      );

      // Insérer l'utilisateur dans la base de données
      await db.insert('users', {
        'id': student.uid,
        'email': student.email,
        'password': password,
        'displayName': student.displayName,
        'role': student.role,
        'phoneNumber': student.phoneNumber,
        'address': student.address,
        'profileImageUrl': student.profileImageUrl,
        'classId': student.classId,
        'dateOfBirth': student.dateOfBirth?.toIso8601String(),
        'studentId': student.studentId,
        'isActive': student.isActive ? 1 : 0,
        'createdAt': student.createdAt.toIso8601String(),
        'lastModifiedAt': student.lastModifiedAt?.toIso8601String(),
      });
      
      developer.log('Étudiant créé avec succès: ${student.uid}');
      return student;
    } catch (e) {
      developer.log('Erreur lors de la création de l\'étudiant: $e');
      throw Exception('Échec de la création de l\'étudiant: $e');
    }
  }

  // User operations
  Future<void> updateUser(ExtendedUserModel user) async {
    try {
      developer.log('Mise à jour de l\'utilisateur: ${user.uid}');
      final db = await LocalDatabase.open();
      
      final updatedUser = ExtendedUserModel(
        uid: user.uid,
        email: user.email,
        displayName: user.displayName,
        role: user.role,
        phoneNumber: user.phoneNumber,
        address: user.address,
        profileImageUrl: user.profileImageUrl,
        classId: user.classId,
        dateOfBirth: user.dateOfBirth,
        studentId: user.studentId,
        isActive: user.isActive,
        createdAt: user.createdAt,
        lastModifiedAt: DateTime.now(),
      );

      await db.update(
        'users',
        updatedUser.toMap(),
        where: 'id = ?',
        whereArgs: [user.uid],
      );
      
      developer.log('Utilisateur mis à jour avec succès');
    } catch (e) {
      developer.log('Erreur lors de la mise à jour de l\'utilisateur: $e');
      throw Exception('Échec de la mise à jour de l\'utilisateur: $e');
    }
  }

  Future<void> deleteUser(String uid) async {
    try {
      developer.log('Suppression de l\'utilisateur: $uid');
      final db = await LocalDatabase.open();
      
      // Vérifier si l'utilisateur existe
      final userExists = await db.query(
        'users',
        where: 'id = ?',
        whereArgs: [uid],
        limit: 1,
      );
      
      if (userExists.isEmpty) {
        throw Exception('Utilisateur non trouvé');
      }
      
      // Mise à jour du statut de l'utilisateur (suppression douce)
      await db.update(
        'users',
        {
          'isActive': 0,
          'lastModifiedAt': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [uid],
      );
      
      developer.log('Utilisateur désactivé avec succès');
    } catch (e) {
      developer.log('Erreur lors de la suppression de l\'utilisateur: $e');
      throw Exception('Échec de la suppression de l\'utilisateur: $e');
    }
  }

  Future<void> activateUser(String uid) async {
    try {
      developer.log('Activation de l\'utilisateur: $uid');
      final db = await LocalDatabase.open();
      
      await db.update(
        'users',
        {
          'isActive': 1,
          'lastModifiedAt': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [uid],
      );
      
      developer.log('Utilisateur activé avec succès');
    } catch (e) {
      developer.log('Erreur lors de l\'activation de l\'utilisateur: $e');
      throw Exception('Échec de l\'activation de l\'utilisateur: $e');
    }
  }

  // Query operations
  Future<List<ExtendedUserModel>> getTeachers() async {
    try {
      developer.log('Récupération de la liste des enseignants');
      final db = await LocalDatabase.open();
      
      final queryResult = await db.query(
        'users',
        where: 'role = ?',
        whereArgs: ['teacher'],
      );

      final teachers = queryResult.map((row) => ExtendedUserModel.fromMap(row)).toList();
      developer.log('${teachers.length} enseignants récupérés');
      return teachers;
    } catch (e) {
      developer.log('Erreur lors de la récupération des enseignants: $e');
      throw Exception('Échec de la récupération des enseignants: $e');
    }
  }

  Future<List<ExtendedUserModel>> getStudents() async {
    try {
      developer.log('Récupération de la liste des étudiants');
      final db = await LocalDatabase.open();
      
      final queryResult = await db.query(
        'users',
        where: 'role = ?',
        whereArgs: ['student'],
      );

      final students = queryResult.map((row) => ExtendedUserModel.fromMap(row)).toList();
      developer.log('${students.length} étudiants récupérés');
      return students;
    } catch (e) {
      developer.log('Erreur lors de la récupération des étudiants: $e');
      throw Exception('Échec de la récupération des étudiants: $e');
    }
  }

  Future<List<ExtendedUserModel>> getStudentsByClass(String classId) async {
    try {
      developer.log('Récupération des étudiants de la classe: $classId');
      final db = await LocalDatabase.open();
      
      final queryResult = await db.query(
        'users',
        where: 'role = ? AND classId = ?',
        whereArgs: ['student', classId],
      );

      final students = queryResult.map((row) => ExtendedUserModel.fromMap(row)).toList();
      developer.log('${students.length} étudiants récupérés pour la classe: $classId');
      return students;
    } catch (e) {
      developer.log('Erreur lors de la récupération des étudiants par classe: $e');
      throw Exception('Échec de la récupération des étudiants par classe: $e');
    }
  }

  Future<ExtendedUserModel?> getUserById(String uid) async {
    try {
      developer.log('Récupération de l\'utilisateur: $uid');
      final db = await LocalDatabase.open();
      
      final results = await db.query(
        'users',
        where: 'id = ?',
        whereArgs: [uid],
        limit: 1,
      );
      
      if (results.isEmpty) {
        developer.log('Utilisateur non trouvé: $uid');
        return null;
      }
      
      final user = ExtendedUserModel.fromMap(results.first);
      developer.log('Utilisateur récupéré: ${user.email}');
      return user;
    } catch (e) {
      developer.log('Erreur lors de la récupération de l\'utilisateur: $e');
      throw Exception('Échec de la récupération de l\'utilisateur: $e');
    }
  }

  // Class operations
  Future<List<ClassModel>> getClasses() async {
    try {
      developer.log('Récupération de la liste des classes');
      // Non implémenté - retourne une liste vide pour le moment
      return [];
    } catch (e) {
      developer.log('Erreur lors de la récupération des classes: $e');
      throw Exception('Échec de la récupération des classes: $e');
    }
  }

  Future<ClassModel> createClass({
    required String name,
    required String description,
    required int year,
    required String department,
  }) async {
    throw Exception('Non implémenté');
  }

  Future<void> updateClass(ClassModel classModel) async {
    try {
      developer.log('Mise à jour de la classe: ${classModel.id}');
      final db = await LocalDatabase.open();
      
      await db.update(
        'classes',
        {
          'name': classModel.name,
          'description': classModel.description,
          'year': classModel.year,
          'department': classModel.department,
          'lastModifiedAt': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [classModel.id],
      );
      
      developer.log('Classe mise à jour avec succès');
    } catch (e) {
      developer.log('Erreur lors de la mise à jour de la classe: $e');
      throw Exception('Échec de la mise à jour de la classe: $e');
    }
  }

  Future<void> deleteClass(String classId) async {
    try {
      developer.log('Suppression de la classe: $classId');
      final db = await LocalDatabase.open();
      
      await db.delete(
        'classes',
        where: 'id = ?',
        whereArgs: [classId],
      );
      
      developer.log('Classe supprimée avec succès');
    } catch (e) {
      developer.log('Erreur lors de la suppression de la classe: $e');
      throw Exception('Échec de la suppression de la classe: $e');
    }
  }
} 