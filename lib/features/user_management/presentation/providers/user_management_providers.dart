import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/user_repository_impl.dart';
import '../../../../core/local_database.dart';
import '../../domain/entities/class_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/user_repository.dart';
import '../../domain/usecases/create_student_usecase.dart';
import '../../domain/usecases/create_teacher_usecase.dart';

// Provider pour la base de données locale
final localDatabaseProvider = Provider<LocalDatabase>((ref) {
  return LocalDatabase();
});

// Provider pour le repository des utilisateurs
final userRepositoryProvider = Provider<UserRepositoryImpl>((ref) {
  final localDatabase = ref.watch(localDatabaseProvider);
  return UserRepositoryImpl(localDatabase);
});

// Use cases
final createTeacherUseCaseProvider = Provider<CreateTeacherUseCase>((ref) {
  return CreateTeacherUseCase(ref.watch(userRepositoryProvider));
});

final createStudentUseCaseProvider = Provider<CreateStudentUseCase>((ref) {
  return CreateStudentUseCase(ref.watch(userRepositoryProvider));
});

// State providers
final teachersProvider = FutureProvider<List<ExtendedUserEntity>>((ref) async {
  final repository = ref.watch(userRepositoryProvider);
  return repository.getTeachers();
});

final studentsProvider = FutureProvider<List<ExtendedUserEntity>>((ref) async {
  final repository = ref.watch(userRepositoryProvider);
  return repository.getStudents();
});

final classesProvider = FutureProvider<List<ClassEntity>>((ref) async {
  final repository = ref.watch(userRepositoryProvider);
  return repository.getClasses();
});

final selectedClassIdProvider = StateProvider<String?>((ref) => null);

final studentsByClassProvider = FutureProvider.family<List<ExtendedUserEntity>, String>((ref, classId) async {
  final repository = ref.watch(userRepositoryProvider);
  return repository.getStudentsByClass(classId);
});

// State notifiers
class UserFormNotifier extends StateNotifier<AsyncValue<void>> {
  final UserRepository _repository;

  UserFormNotifier({required UserRepository repository})
      : _repository = repository,
        super(const AsyncValue.data(null));

  Future<void> createTeacher({
    required String email,
    required String password,
    String? displayName,
    String? phoneNumber,
    String? address,
    String? profileImageUrl,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _repository.createTeacher(
        email: email,
        password: password,
        displayName: displayName,
        phoneNumber: phoneNumber,
        address: address,
        profileImageUrl: profileImageUrl,
      );
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> createStudent({
    required String email,
    required String password,
    String? displayName,
    String? phoneNumber,
    String? address,
    String? profileImageUrl,
    required String classId,
    DateTime? dateOfBirth,
    int? studentId,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _repository.createStudent(
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
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> updateUser(ExtendedUserEntity user) async {
    state = const AsyncValue.loading();
    try {
      await _repository.updateUser(user);
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> deleteUser(String uid) async {
    state = const AsyncValue.loading();
    try {
      await _repository.deleteUser(uid);
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}

final userFormNotifierProvider = StateNotifierProvider<UserFormNotifier, AsyncValue<void>>((ref) {
  return UserFormNotifier(repository: ref.watch(userRepositoryProvider));
}); 