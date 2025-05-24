import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'dart:developer' as developer;
import '../../../../core/local_database.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';
import 'package:uuid/uuid.dart';

class AuthRepositoryImpl implements AuthRepository {
  final _streamController = StreamController<User?>.broadcast();
  User? _currentUser;
  
  AuthRepositoryImpl() {
    _init();
  }

  Future<void> _init() async {
    developer.log('Initialisation du AuthRepositoryImpl');
  }

  @override
  Stream<User?> get authStateChanges => _streamController.stream;

  @override
  Future<User?> getCurrentUser() async {
    return _currentUser;
  }

  @override
  Future<User> signInWithEmailAndPassword(String email, String password) async {
    developer.log('Tentative de connexion avec $email');
    try {
      final db = await LocalDatabase.open();
      
      final result = await db.query(
        'users',
        where: 'email = ? AND password = ?',
        whereArgs: [email, password],
      );
      
      if (result.isEmpty) {
        throw Exception('Email ou mot de passe invalide');
      }
      
      final userData = result.first;
      final user = UserModel.fromMap(userData);
      
      // Mettre à jour l'utilisateur courant
      _currentUser = user;
      _streamController.add(user);
      
      developer.log('Connexion réussie pour $email');
      return user;
    } catch (e) {
      developer.log('Erreur lors de la connexion: $e');
      throw Exception('Échec de l\'authentification: $e');
    }
  }

  @override
  Future<User> registerWithEmailAndPassword(String email, String password, String role) async {
    developer.log('Tentative d\'inscription avec $email, rôle: $role');
    try {
      final db = await LocalDatabase.open();
      
      // Vérifier si l'utilisateur existe déjà
      final existingUser = await db.query(
        'users',
        where: 'email = ?',
        whereArgs: [email],
      );
      
      if (existingUser.isNotEmpty) {
        throw Exception('Un utilisateur avec cet email existe déjà');
      }
      
      // Créer un nouvel utilisateur
      final userId = const Uuid().v4();
      final now = DateTime.now();
      
      final user = UserModel(
        id: userId,
        email: email,
        displayName: null,
        role: role,
        isActive: true,
        createdAt: now,
      );
      
      await db.insert('users', {
        'id': user.id,
        'email': user.email,
        'password': password, // Idéalement, hasher le mot de passe
        'displayName': user.displayName,
        'role': user.role,
        'isActive': 1,
        'createdAt': now.toIso8601String(),
      });
      
      // Mettre à jour l'utilisateur courant
      _currentUser = user;
      _streamController.add(user);
      
      developer.log('Inscription réussie pour $email');
      return user;
    } catch (e) {
      developer.log('Erreur lors de l\'inscription: $e');
      throw Exception('Échec de l\'inscription: $e');
    }
  }

  @override
  Future<void> signOut() async {
    developer.log('Déconnexion...');
    _currentUser = null;
    _streamController.add(null);
  }

  @override
  Future<void> updateUserRole(String uid, String role) async {
    developer.log('Mise à jour du rôle utilisateur $uid vers $role');
    try {
      final db = await LocalDatabase.open();
      
      await db.update(
        'users',
        {'role': role},
        where: 'id = ?',
        whereArgs: [uid],
      );
      
      if (_currentUser != null && _currentUser!.id == uid) {
        final updatedUser = UserModel(
          id: _currentUser!.id,
          email: _currentUser!.email,
          displayName: _currentUser!.displayName,
          role: role,
          phoneNumber: _currentUser!.phoneNumber,
          address: _currentUser!.address,
          profileImageUrl: _currentUser!.profileImageUrl,
          classId: _currentUser!.classId,
          dateOfBirth: _currentUser!.dateOfBirth,
          studentId: _currentUser!.studentId,
          isActive: _currentUser!.isActive,
          createdAt: _currentUser!.createdAt,
          lastModifiedAt: DateTime.now(),
        );
        _currentUser = updatedUser;
        _streamController.add(_currentUser);
      }
    } catch (e) {
      developer.log('Erreur lors de la mise à jour du rôle utilisateur: $e');
      throw Exception('Échec de la mise à jour du rôle: $e');
    }
  }
} 