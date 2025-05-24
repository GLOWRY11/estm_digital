import '../entities/user.dart';

abstract class AuthRepository {
  Stream<User?> get authStateChanges;
  Future<User?> getCurrentUser();
  Future<User> signInWithEmailAndPassword(String email, String password);
  Future<User> registerWithEmailAndPassword(String email, String password, String role);
  Future<void> signOut();
  Future<void> updateUserRole(String uid, String role);
} 