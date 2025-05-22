import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<UserEntity> call(String email, String password, String role) async {
    return await repository.registerWithEmailAndPassword(email, password, role);
  }
} 