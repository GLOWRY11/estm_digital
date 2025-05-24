import '../entities/class_entity.dart';
import '../repositories/user_repository.dart';

class CreateClassUseCase {
  final UserRepository repository;

  CreateClassUseCase(this.repository);

  Future<ClassEntity> call({
    required String name,
    required String description,
    required int year,
    required String department,
  }) {
    return repository.createClass(
      name: name,
      description: description,
      year: year,
      department: department,
    );
  }
} 