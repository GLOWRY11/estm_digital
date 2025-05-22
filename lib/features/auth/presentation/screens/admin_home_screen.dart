import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_providers.dart';
import '../../domain/entities/user.dart';

class AdminHomeScreen extends ConsumerWidget {
  const AdminHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserAsync = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authNotifierProvider.notifier).signOut();
            },
          ),
        ],
      ),
      body: currentUserAsync.when(
        data: (UserEntity? user) {
          if (user == null) return const Center(child: Text('Utilisateur non connecté'));

          return SingleChildScrollView(
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
                          'Bienvenue, Admin ${user.displayName ?? user.email}',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text('Email: ${user.email}'),
                        Text('Rôle: ${user.role}'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Fonctionnalités Administrateur',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                _buildFeatureCard(
                  context,
                  title: 'Gestion des utilisateurs',
                  icon: Icons.people,
                  onTap: () {
                    // Navigation vers la gestion des utilisateurs
                  },
                ),
                _buildFeatureCard(
                  context,
                  title: 'Rapports',
                  icon: Icons.analytics,
                  onTap: () {
                    // Navigation vers les rapports
                  },
                ),
                _buildFeatureCard(
                  context,
                  title: 'Paramètres',
                  icon: Icons.settings,
                  onTap: () {
                    // Navigation vers les paramètres
                  },
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Text('Erreur: $error'),
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