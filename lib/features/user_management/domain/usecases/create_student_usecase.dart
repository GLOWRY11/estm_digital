import '../entities/user_entity.dart';
import '../repositories/user_repository.dart';

class CreateStudentUseCase {
  final UserRepository repository;

  CreateStudentUseCase(this.repository);

  Future<ExtendedUserEntity> call({
    required String email,
    required String password,
    String? displayName,
    String? phoneNumber,
    String? address,
    String? profileImageUrl,
    required String classId,
    DateTime? dateOfBirth,
    int? studentId,
  }) {
    return repository.createStudent(
      email: email,
      password: password,
      displayName: displayName,
      phoneNumber: phoneNumber,
      address: address,
      profileImageUrl: profileImageUrl,
      classId: classId,
      dateOfBirth: dateOfBirth,
      studentId: studentId,
    );
  }
} 