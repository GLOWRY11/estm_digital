import 'package:sqflite/sqflite.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/entities/class_entity.dart';
import '../../domain/repositories/user_repository.dart';
import '../models/user_model.dart';
import '../models/class_model.dart';
import '../../../../core/local_database.dart';
import 'package:uuid/uuid.dart';

class UserRepositoryImpl implements UserRepository {
  final LocalDatabase _localDatabase;
  final _uuid = const Uuid();

  UserRepositoryImpl(this._localDatabase);

  @override
  Future<ExtendedUserEntity> createTeacher({
    required String email,
    required String password,
    String? displayName,
    String? phoneNumber,
    String? address,
    String? profileImageUrl,
  }) async {
    final db = await _localDatabase.database;
    
    // Vérifier si l'email existe déjà
    final existing = await db.query('users', where: 'email = ?', whereArgs: [email]);
    if (existing.isNotEmpty) {
      throw Exception('Un utilisateur avec cet email existe déjà');
    }
    
    final uid = _uuid.v4();
    final teacher = ExtendedUserModel(
      uid: uid,
      email: email,
      displayName: displayName,
      role: 'teacher',
      phoneNumber: phoneNumber,
      address: address,
      profileImageUrl: profileImageUrl,
      isActive: true,
      createdAt: DateTime.now(),
    );
    
    final userData = teacher.toMap();
    userData['password'] = password;
    
    await db.insert('users', userData);
    return teacher;
  }

  @override
  Future<ExtendedUserEntity> createStudent({
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
    final db = await _localDatabase.database;
    
    // Vérifier si l'email existe déjà
    final existing = await db.query('users', where: 'email = ?', whereArgs: [email]);
    if (existing.isNotEmpty) {
      throw Exception('Un utilisateur avec cet email existe déjà');
    }
    
    final uid = _uuid.v4();
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
    );
    
    final userData = student.toMap();
    userData['password'] = password;
    
    await db.insert('users', userData);
    return student;
  }

  @override
  Future<void> updateUser(ExtendedUserEntity user) async {
    final db = await _localDatabase.database;
    final userModel = ExtendedUserModel(
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
      userModel.toMap(),
      where: 'id = ?',
      whereArgs: [user.uid],
    );
  }

  @override
  Future<void> deleteUser(String uid) async {
    final db = await _localDatabase.database;
    await db.delete('users', where: 'id = ?', whereArgs: [uid]);
  }

  @override
  Future<void> deactivateUser(String uid) async {
    final db = await _localDatabase.database;
    await db.update(
      'users',
      {'isActive': 0, 'lastModifiedAt': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [uid],
    );
  }

  @override
  Future<void> activateUser(String uid) async {
    final db = await _localDatabase.database;
    await db.update(
      'users',
      {'isActive': 1, 'lastModifiedAt': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [uid],
    );
  }

  @override
  Future<List<ExtendedUserEntity>> getTeachers() async {
    final db = await _localDatabase.database;
    final maps = await db.query('users', where: 'role = ?', whereArgs: ['teacher']);
    return maps.map((map) => ExtendedUserModel.fromMap(map)).toList();
  }

  @override
  Future<List<ExtendedUserEntity>> getStudents() async {
    final db = await _localDatabase.database;
    final maps = await db.query('users', where: 'role = ?', whereArgs: ['student']);
    return maps.map((map) => ExtendedUserModel.fromMap(map)).toList();
  }

  @override
  Future<List<ExtendedUserEntity>> getStudentsByClass(String classId) async {
    final db = await _localDatabase.database;
    final maps = await db.query(
      'users',
      where: 'role = ? AND classId = ?',
      whereArgs: ['student', classId],
    );
    return maps.map((map) => ExtendedUserModel.fromMap(map)).toList();
  }

  @override
  Future<ExtendedUserEntity?> getUserById(String uid) async {
    final db = await _localDatabase.database;
    final maps = await db.query('users', where: 'id = ?', whereArgs: [uid]);
    if (maps.isEmpty) return null;
    return ExtendedUserModel.fromMap(maps.first);
  }

  @override
  Future<List<ClassEntity>> getClasses() async {
    final db = await _localDatabase.database;
    final maps = await db.query('classes');
    return maps.map((map) => ClassModel.fromMap(map)).toList();
  }

  @override
  Future<ClassEntity> createClass({
    required String name,
    required String description,
    required int year,
    required String department,
  }) async {
    final db = await _localDatabase.database;
    final id = _uuid.v4();
    final classEntity = ClassModel(
      id: id,
      name: name,
      description: description,
      year: year,
      department: department,
    );
    
    await db.insert('classes', classEntity.toMap());
    return classEntity;
  }

  @override
  Future<void> updateClass(ClassEntity classEntity) async {
    final db = await _localDatabase.database;
    final classModel = ClassModel(
      id: classEntity.id,
      name: classEntity.name,
      description: classEntity.description,
      year: classEntity.year,
      department: classEntity.department,
    );
    
    await db.update(
      'classes',
      classModel.toMap(),
      where: 'id = ?',
      whereArgs: [classEntity.id],
    );
  }

  @override
  Future<void> deleteClass(String classId) async {
    final db = await _localDatabase.database;
    await db.delete('classes', where: 'id = ?', whereArgs: [classId]);
  }
} 