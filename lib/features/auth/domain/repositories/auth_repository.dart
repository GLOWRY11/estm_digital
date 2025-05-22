import '../entities/user.dart';

abstract class AuthRepository {
  Stream<UserEntity?> get authStateChanges;
  Future<UserEntity?> getCurrentUser();
  Future<UserEntity> signInWithEmailAndPassword(String email, String password);
  Future<UserEntity> registerWithEmailAndPassword(String email, String password, String role);
  Future<void> signOut();
  Future<void> updateUserRole(String uid, String role);
} 