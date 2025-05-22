import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  AuthRepositoryImpl({
    required FirebaseAuth firebaseAuth,
    required FirebaseFirestore firestore,
  })  : _firebaseAuth = firebaseAuth,
        _firestore = firestore;

  @override
  Stream<UserEntity?> get authStateChanges => _firebaseAuth.authStateChanges().asyncMap((User? firebaseUser) async {
        if (firebaseUser == null) {
          return null;
        }
        
        try {
          final userDoc = await _firestore.collection('users').doc(firebaseUser.uid).get();
          if (userDoc.exists) {
            return UserModel.fromFirestore(userDoc);
          } else {
            // Si l'utilisateur existe dans Auth mais pas dans Firestore,
            // on crée un document par défaut
            final newUser = UserModel(
              uid: firebaseUser.uid,
              email: firebaseUser.email ?? '',
              displayName: firebaseUser.displayName,
              role: 'student', // Rôle par défaut
            );
            
            await _firestore.collection('users').doc(firebaseUser.uid).set(newUser.toMap());
            return newUser;
          }
        } catch (e) {
          print('Error in authStateChanges: $e');
          return null;
        }
      });

  @override
  Future<UserEntity?> getCurrentUser() async {
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser == null) {
      return null;
    }

    try {
      final userDoc = await _firestore.collection('users').doc(firebaseUser.uid).get();
      if (userDoc.exists) {
        return UserModel.fromFirestore(userDoc);
      }
      return null;
    } catch (e) {
      print('Error in getCurrentUser: $e');
      return null;
    }
  }

  @override
  Future<UserEntity> signInWithEmailAndPassword(String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw Exception('Authentication failed: User is null');
      }

      final userDoc = await _firestore.collection('users').doc(userCredential.user!.uid).get();
      if (userDoc.exists) {
        return UserModel.fromFirestore(userDoc);
      } else {
        throw Exception('User data not found in Firestore');
      }
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw Exception('Authentication failed: $e');
    }
  }

  @override
  Future<UserEntity> registerWithEmailAndPassword(String email, String password, String role) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw Exception('Registration failed: User is null');
      }

      final user = UserModel(
        uid: userCredential.user!.uid,
        email: email,
        displayName: null,
        role: role,
      );

      await _firestore.collection('users').doc(user.uid).set(user.toMap());
      return user;
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  @override
  Future<void> updateUserRole(String uid, String role) async {
    await _firestore.collection('users').doc(uid).update({'role': role});
  }

  Exception _handleFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return Exception('No user found with this email');
      case 'wrong-password':
        return Exception('Incorrect password');
      case 'email-already-in-use':
        return Exception('This email is already registered');
      case 'weak-password':
        return Exception('Password is too weak');
      case 'invalid-email':
        return Exception('Invalid email format');
      default:
        return Exception('Authentication error: ${e.message}');
    }
  }
} 