import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/get_current_user.dart';
import '../../domain/usecases/register.dart';
import '../../domain/usecases/sign_in.dart';
import '../../domain/usecases/sign_out.dart';

// Firebase providers
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);
final firebaseFirestoreProvider = Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);

// Repository providers
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    firebaseAuth: ref.watch(firebaseAuthProvider),
    firestore: ref.watch(firebaseFirestoreProvider),
  );
});

// Use case providers
final getCurrentUserUseCaseProvider = Provider<GetCurrentUserUseCase>((ref) {
  return GetCurrentUserUseCase(ref.watch(authRepositoryProvider));
});

final signInUseCaseProvider = Provider<SignInUseCase>((ref) {
  return SignInUseCase(ref.watch(authRepositoryProvider));
});

final registerUseCaseProvider = Provider<RegisterUseCase>((ref) {
  return RegisterUseCase(ref.watch(authRepositoryProvider));
});

final signOutUseCaseProvider = Provider<SignOutUseCase>((ref) {
  return SignOutUseCase(ref.watch(authRepositoryProvider));
});

// User state providers
final authStateChangesProvider = StreamProvider<UserEntity?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

final currentUserProvider = FutureProvider<UserEntity?>((ref) async {
  return ref.watch(getCurrentUserUseCaseProvider).call();
});

// Auth state notifier
class AuthNotifier extends StateNotifier<AsyncValue<UserEntity?>> {
  final SignInUseCase _signInUseCase;
  final RegisterUseCase _registerUseCase;
  final SignOutUseCase _signOutUseCase;

  AuthNotifier({
    required SignInUseCase signInUseCase,
    required RegisterUseCase registerUseCase,
    required SignOutUseCase signOutUseCase,
  })  : _signInUseCase = signInUseCase,
        _registerUseCase = registerUseCase,
        _signOutUseCase = signOutUseCase,
        super(const AsyncValue.loading());

  Future<void> signIn(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final user = await _signInUseCase(email, password);
      state = AsyncValue.data(user);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> register(String email, String password, String role) async {
    state = const AsyncValue.loading();
    try {
      final user = await _registerUseCase(email, password, role);
      state = AsyncValue.data(user);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    try {
      await _signOutUseCase();
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AsyncValue<UserEntity?>>((ref) {
  return AuthNotifier(
    signInUseCase: ref.watch(signInUseCaseProvider),
    registerUseCase: ref.watch(registerUseCaseProvider),
    signOutUseCase: ref.watch(signOutUseCaseProvider),
  );
}); 