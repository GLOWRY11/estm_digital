import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/absence_datasource.dart';
import '../../data/repositories/absence_repository_impl.dart';
import '../../domain/repositories/absence_repository.dart';
import '../../domain/usecases/get_absences_by_student_usecase.dart';
import '../../domain/usecases/mark_absence_usecase.dart';
import '../../domain/usecases/sync_absences_usecase.dart';

// DataSource provider
final absenceDataSourceProvider = Provider<AbsenceDataSource>((ref) {
  return AbsenceDataSource();
});

// Repository provider
final absenceRepositoryProvider = Provider<AbsenceRepository>((ref) {
  final dataSource = ref.watch(absenceDataSourceProvider);
  return AbsenceRepositoryImpl(dataSource: dataSource);
});

// UseCases providers
final markAbsenceUseCaseProvider = Provider<MarkAbsenceUseCase>((ref) {
  final repository = ref.watch(absenceRepositoryProvider);
  return MarkAbsenceUseCase(repository);
});

final getAbsencesByStudentUseCaseProvider = Provider<GetAbsencesByStudentUseCase>((ref) {
  final repository = ref.watch(absenceRepositoryProvider);
  return GetAbsencesByStudentUseCase(repository);
});

final syncAbsencesUseCaseProvider = Provider<SyncAbsencesUseCase>((ref) {
  final repository = ref.watch(absenceRepositoryProvider);
  return SyncAbsencesUseCase(repository);
});

// State providers
final studentAbsencesProvider = FutureProvider.family((ref, String studentId) {
  final useCase = ref.watch(getAbsencesByStudentUseCaseProvider);
  return useCase(studentId);
}); 