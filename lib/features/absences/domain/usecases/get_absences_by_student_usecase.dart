import '../entities/absence_entity.dart';
import '../repositories/absence_repository.dart';

class GetAbsencesByStudentUseCase {
  final AbsenceRepository repository;

  GetAbsencesByStudentUseCase(this.repository);

  Future<List<AbsenceEntity>> call(String studentId) {
    return repository.getAbsencesByStudent(studentId);
  }
} 