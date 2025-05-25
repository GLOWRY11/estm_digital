import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/entities/user.dart';
import '../../../core/services/user_service.dart';

// États d'authentification
enum AuthStatus { loading, authenticated, unauthenticated }

class AuthState {
  final AuthStatus status;
  final User? user;
  final String? errorMessage;

  const AuthState({
    required this.status,
    this.user,
    this.errorMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// Notifier pour l'authentification
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState(status: AuthStatus.unauthenticated));

  // Connexion
  Future<bool> login(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading);
    
    try {
      final user = await UserService.getUserByEmailAndPassword(email, password);
      
      if (user != null) {
        await UserService.updateLastLogin(user.id);
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
          errorMessage: null,
        );
        return true;
      } else {
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          errorMessage: 'Email ou mot de passe incorrect',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: 'Erreur de connexion: ${e.toString()}',
      );
      return false;
    }
  }

  // Inscription
  Future<bool> register({
    required String email,
    required String password,
    required String role,
    String? displayName,
    String? phoneNumber,
    String? address,
    String? classId,
    int? studentId,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);
    
    try {
      final success = await UserService.insertUser(
        email: email,
        password: password,
        role: role,
        displayName: displayName,
        phoneNumber: phoneNumber,
        address: address,
        classId: classId,
        studentId: studentId,
      );

      if (success) {
        // Connecter automatiquement après inscription
        return await login(email, password);
      } else {
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          errorMessage: 'Erreur lors de l\'inscription',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: 'Erreur d\'inscription: ${e.toString()}',
      );
      return false;
    }
  }

  // Déconnexion
  void logout() {
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  // Mettre à jour l'utilisateur connecté
  void setUser(User user) {
    state = state.copyWith(
      status: AuthStatus.authenticated,
      user: user,
      errorMessage: null,
    );
  }

  // Actualiser les données utilisateur
  Future<void> refreshUser() async {
    if (state.user == null) return;
    
    try {
      final updatedUser = await UserService.getUserById(state.user!.id);
      if (updatedUser != null) {
        state = state.copyWith(user: updatedUser);
      }
    } catch (e) {
      // Log error but don't change state
      print('Erreur lors du refresh utilisateur: $e');
    }
  }

  // Effacer les erreurs
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

// Provider principal
final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

// Providers de commodité
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authStateProvider).user;
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authStateProvider).status == AuthStatus.authenticated;
});

final isLoadingProvider = Provider<bool>((ref) {
  return ref.watch(authStateProvider).status == AuthStatus.loading;
});

final authErrorProvider = Provider<String?>((ref) {
  return ref.watch(authStateProvider).errorMessage;
});

// Provider pour vérifier les permissions
final hasPermissionProvider = Provider.family<bool, String>((ref, permission) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return false;

  switch (permission) {
    case 'admin':
      return user.role == 'admin';
    case 'teacher':
      return user.role == 'admin' || user.role == 'teacher';
    case 'student':
      return user.role == 'student';
    case 'manage_users':
      return user.role == 'admin';
    case 'manage_classes':
      return user.role == 'admin' || user.role == 'teacher';
    case 'view_reports':
      return user.role == 'admin' || user.role == 'teacher';
    default:
      return false;
  }
});

// Provider pour les statistiques utilisateur (pour admin)
final userStatsProvider = FutureProvider<Map<String, int>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user?.role != 'admin') {
    throw Exception('Accès non autorisé');
  }
  
  return await UserService.getUserStats();
});

// Provider pour les utilisateurs par rôle
final usersByRoleProvider = FutureProvider.family<List<User>, String>((ref, role) async {
  return await UserService.getUsersByRole(role);
});

// Provider pour rechercher des utilisateurs
final searchUsersProvider = FutureProvider.family<List<User>, String>((ref, query) async {
  if (query.isEmpty) {
    return await UserService.getActiveUsers();
  }
  return await UserService.searchUsers(query);
}); 