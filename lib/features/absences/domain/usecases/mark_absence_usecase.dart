import '../repositories/absence_repository.dart';

class MarkAbsenceUseCase {
  final AbsenceRepository repository;

  MarkAbsenceUseCase(this.repository);

  Future<void> call({
    required String studentId,
    required DateTime date,
    required String time,
    String status = 'offline',
  }) {
    return repository.markAbsence(
      studentId: studentId,
      date: date,
      time: time,
      status: status,
    );
  }
} 