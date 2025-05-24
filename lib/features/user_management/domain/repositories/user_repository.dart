import '../entities/class_entity.dart';
import '../entities/user_entity.dart';

abstract class UserRepository {
  // Teacher operations
  Future<ExtendedUserEntity> createTeacher({
    required String email,
    required String password,
    String? displayName,
    String? phoneNumber,
    String? address,
    String? profileImageUrl,
  });

  // Student operations
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
  });

  // User operations
  Future<void> updateUser(ExtendedUserEntity user);
  Future<void> deleteUser(String uid);
  Future<void> deactivateUser(String uid);
  Future<void> activateUser(String uid);

  // Query operations
  Future<List<ExtendedUserEntity>> getTeachers();
  Future<List<ExtendedUserEntity>> getStudents();
  Future<List<ExtendedUserEntity>> getStudentsByClass(String classId);
  Future<ExtendedUserEntity?> getUserById(String uid);

  // Class operations
  Future<List<ClassEntity>> getClasses();
  Future<ClassEntity> createClass({
    required String name,
    required String description,
    required int year,
    required String department,
  });
  Future<void> updateClass(ClassEntity classEntity);
  Future<void> deleteClass(String classId);
} 