import '../repositories/absence_repository.dart';

class SyncAbsencesUseCase {
  final AbsenceRepository repository;

  SyncAbsencesUseCase(this.repository);

  Future<void> call() {
    return repository.syncAbsences();
  }
} 