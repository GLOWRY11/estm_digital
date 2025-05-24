import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/scheduling_datasource.dart';
import '../../data/repositories/scheduling_repository_impl.dart';
import '../../domain/entities/room_entity.dart';
import '../../domain/entities/session_entity.dart';
import '../../domain/repositories/scheduling_repository.dart';
import '../../domain/usecases/create_session_usecase.dart';
import '../../domain/usecases/get_weekly_sessions_usecase.dart';

// DataSource provider
final schedulingDataSourceProvider = Provider<SchedulingDataSource>((ref) {
  return SchedulingDataSource();
});

// Repository provider
final schedulingRepositoryProvider = Provider<SchedulingRepository>((ref) {
  final dataSource = ref.watch(schedulingDataSourceProvider);
  return SchedulingRepositoryImpl(dataSource: dataSource);
});

// UseCases providers
final createSessionUseCaseProvider = Provider<CreateSessionUseCase>((ref) {
  final repository = ref.watch(schedulingRepositoryProvider);
  return CreateSessionUseCase(repository);
});

final getWeeklySessionsUseCaseProvider = Provider<GetWeeklySessionsUseCase>((ref) {
  final repository = ref.watch(schedulingRepositoryProvider);
  return GetWeeklySessionsUseCase(repository);
});

// State providers
final roomsProvider = FutureProvider<List<RoomEntity>>((ref) {
  final repository = ref.watch(schedulingRepositoryProvider);
  return repository.getRooms();
});

final weeklySessionsProvider = FutureProvider.family<List<SessionEntity>, DateTime?>((ref, date) {
  final useCase = ref.watch(getWeeklySessionsUseCaseProvider);
  return useCase(date: date);
});

final currentDateProvider = StateProvider<DateTime>((ref) {
  return DateTime.now();
});

// Provider pour les sessions filtrées par classe
final classSessionsProvider = FutureProvider.family<List<SessionEntity>, String>((ref, classId) {
  final repository = ref.watch(schedulingRepositoryProvider);
  return repository.getSessionsByClass(classId);
});

// Provider pour les sessions filtrées par salle
final roomSessionsProvider = FutureProvider.family<List<SessionEntity>, String>((ref, roomId) {
  final repository = ref.watch(schedulingRepositoryProvider);
  return repository.getSessionsByRoom(roomId);
}); 