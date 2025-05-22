import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_providers.dart';
import '../screens/admin_home_screen.dart';
import '../screens/auth_screen.dart';
import '../screens/student_home_screen.dart';
import '../screens/teacher_home_screen.dart';
import '../../domain/entities/user.dart';

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateChangesProvider);

    return authState.when(
      data: (UserEntity? user) {
        if (user == null) {
          return const AuthScreen();
        }

        // Redirection basée sur le rôle
        if (user.isAdmin) {
          return const AdminHomeScreen();
        } else if (user.isTeacher) {
          return const TeacherHomeScreen();
        } else {
          return const StudentHomeScreen();
        }
      },
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stackTrace) => Scaffold(
        body: Center(
          child: Text('Erreur d\'authentification: $error'),
        ),
      ),
    );
  }
} 