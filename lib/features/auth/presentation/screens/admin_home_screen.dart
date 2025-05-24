import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_providers.dart';
import '../../domain/entities/user.dart';
import '../../../../core/routes/app_routes.dart';

class AdminHomeScreen extends ConsumerWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Administration ESTM'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authNotifierProvider.notifier).signOut();
            },
          ),
        ],
      ),
      body: currentUser == null 
        ? const Center(child: Text('Utilisateur non connecté'))
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bienvenue, Admin ${currentUser.displayName ?? currentUser.email}',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text('Email: ${currentUser.email}'),
                        Text('Rôle: ${currentUser.role}'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Fonctionnalités Administration',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                _buildFeatureCard(
                  context,
                  title: 'Gestion des utilisateurs',
                  icon: Icons.people,
                  onTap: () {
                    Navigator.of(context).pushNamed(AppRoutes.usersList);
                  },
                ),
                _buildFeatureCard(
                  context,
                  title: 'Gestion des cours',
                  icon: Icons.class_,
                  onTap: () {
                    Navigator.of(context).pushNamed(AppRoutes.coursesList);
                  },
                ),
                _buildFeatureCard(
                  context,
                  title: 'Gestion des notes',
                  icon: Icons.grading,
                  onTap: () {
                    Navigator.of(context).pushNamed(AppRoutes.teacherGrades);
                  },
                ),
                _buildFeatureCard(
                  context,
                  title: 'Réclamations',
                  icon: Icons.feedback,
                  onTap: () {
                    Navigator.of(context).pushNamed(AppRoutes.complaints);
                  },
                ),
                _buildFeatureCard(
                  context,
                  title: 'Gestion des filières',
                  icon: Icons.school,
                  onTap: () {
                    Navigator.of(context).pushNamed(AppRoutes.filiereList);
                  },
                ),
                _buildFeatureCard(
                  context,
                  title: 'Gestion des absences',
                  icon: Icons.event_busy,
                  onTap: () {
                    Navigator.of(context).pushNamed(AppRoutes.absenceList);
                  },
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).primaryColor),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
} 