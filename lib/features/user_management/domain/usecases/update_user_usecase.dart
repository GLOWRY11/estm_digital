import '../entities/user_entity.dart';
import '../repositories/user_repository.dart';

class UpdateUserUseCase {
  final UserRepository repository;

  UpdateUserUseCase(this.repository);

  Future<void> call(ExtendedUserEntity user) {
    return repository.updateUser(user);
  }
} 