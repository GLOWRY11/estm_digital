import '../repositories/user_repository.dart';
import '../entities/user_entity.dart';

class CreateTeacherUseCase {
  final UserRepository repository;

  CreateTeacherUseCase(this.repository);

  Future<ExtendedUserEntity> call({
    required String email,
    required String password,
    String? displayName,
    String? phoneNumber,
    String? address,
    String? profileImageUrl,
  }) {
    return repository.createTeacher(
      email: email,
      password: password,
      displayName: displayName,
      phoneNumber: phoneNumber,
      address: address,
      profileImageUrl: profileImageUrl,
    );
  }
} 