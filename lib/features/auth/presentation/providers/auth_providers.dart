import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/local_database.dart';
import '../../domain/entities/user.dart';

// SQLite provider
final databaseProvider = FutureProvider<Database>((ref) async {
  developer.log('Ouverture de la base de données');
  final db = await LocalDatabase.open();
  developer.log('Base de données ouverte avec succès');
  return db;
});

// User state providers
final authStateChangesProvider = StreamProvider<User?>((ref) {
  developer.log('Configuration du stream d\'authentification');
  final controller = StreamController<User?>();
  ref.onDispose(() => controller.close());

  // Simuler l'état d'authentification
  Future<void> checkAuth() async {
    try {
      final db = await ref.read(databaseProvider.future);
      final currentUser = ref.read(currentUserProvider);
      developer.log('État actuel de l\'utilisateur: ${currentUser?.email ?? 'non connecté'}');
      controller.add(currentUser);
    } catch (e) {
      developer.log('Erreur lors de la vérification de l\'état d\'authentification: $e');
      controller.add(null);
    }
  }
  
  checkAuth();
  return controller.stream;
});

final currentUserProvider = StateProvider<User?>((ref) => null);

// Auth state notifier
class AuthNotifier extends StateNotifier<AsyncValue<User?>> {
  final Ref _ref;
  final _uuid = const Uuid();

  AuthNotifier({required Ref ref})
      : _ref = ref,
        super(const AsyncValue.data(null));

  Future<void> signIn(String email, String password) async {
    developer.log('Tentative de connexion avec email: $email');
    state = const AsyncValue.loading();
    try {
      final db = await _ref.read(databaseProvider.future);
      developer.log('Recherche de l\'utilisateur dans la base de données');
      
      final result = await db.query(
        'users',
        where: 'email = ? AND password = ?',
        whereArgs: [email, password],
      );
      
      developer.log('Résultat de la requête: ${result.length} utilisateurs trouvés');
      
      if (result.isEmpty) {
        developer.log('Aucun utilisateur trouvé avec ces identifiants');
        throw Exception('Email ou mot de passe invalide');
      }
      
      final userData = result.first;
      developer.log('Utilisateur trouvé: ${userData['email']}, rôle: ${userData['role']}');
      
      final now = DateTime.now();
      final user = User(
        id: userData['id'] as String,
        email: userData['email'] as String,
        displayName: userData['displayName'] as String?,
        role: userData['role'] as String,
        phoneNumber: userData['phoneNumber'] as String?,
        address: userData['address'] as String?,
        profileImageUrl: userData['profileImageUrl'] as String?,
        classId: userData['classId'] as String?,
        studentId: userData['studentId'] as int?,
        isActive: userData['isActive'] == 1,
        createdAt: userData['createdAt'] != null
            ? DateTime.parse(userData['createdAt'] as String)
            : now,
        lastModifiedAt: userData['lastModifiedAt'] != null
            ? DateTime.parse(userData['lastModifiedAt'] as String)
            : null,
      );
      
      developer.log('Mise à jour de l\'état utilisateur courant');
      _ref.read(currentUserProvider.notifier).state = user;
      state = AsyncValue.data(user);
      developer.log('Connexion réussie pour ${user.email}');
    } catch (e, stackTrace) {
      developer.log('Erreur lors de la connexion: $e');
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> register(String email, String password, String role) async {
    developer.log('Tentative d\'inscription avec email: $email, rôle: $role');
    state = const AsyncValue.loading();
    try {
      final db = await _ref.read(databaseProvider.future);
      
      // Vérifier si l'utilisateur existe déjà
      developer.log('Vérification si l\'utilisateur existe déjà');
      final existingUser = await db.query(
        'users',
        where: 'email = ?',
        whereArgs: [email],
      );
      
      if (existingUser.isNotEmpty) {
        developer.log('Un utilisateur avec cet email existe déjà');
        throw Exception('Un utilisateur avec cet email existe déjà');
      }
      
      // Créer un nouvel utilisateur
      final userId = _uuid.v4();
      final now = DateTime.now();
      developer.log('Création d\'un nouvel utilisateur avec ID: $userId');
      
      await db.insert('users', {
        'id': userId,
        'email': email,
        'password': password, // Idéalement, il faudrait hasher le mot de passe
        'role': role,
        'isActive': 1,
        'createdAt': now.toIso8601String(),
      });
      
      final user = User(
        id: userId,
        email: email,
        role: role,
        isActive: true,
        createdAt: now,
      );
      
      developer.log('Mise à jour de l\'état utilisateur courant');
      _ref.read(currentUserProvider.notifier).state = user;
      state = AsyncValue.data(user);
      developer.log('Inscription réussie pour ${user.email}');
    } catch (e, stackTrace) {
      developer.log('Erreur lors de l\'inscription: $e');
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> signOut() async {
    developer.log('Tentative de déconnexion');
    state = const AsyncValue.loading();
    try {
      developer.log('Mise à jour de l\'état utilisateur à null');
      _ref.read(currentUserProvider.notifier).state = null;
      state = const AsyncValue.data(null);
      developer.log('Déconnexion réussie');
    } catch (e, stackTrace) {
      developer.log('Erreur lors de la déconnexion: $e');
      state = AsyncValue.error(e, stackTrace);
    }
  }
}

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AsyncValue<User?>>((ref) {
  return AuthNotifier(ref: ref);
}); 