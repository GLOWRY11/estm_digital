import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../../core/widgets/language_selector.dart';
import '../../../../core/routes/app_routes.dart';

class StudentDashboardScreen extends ConsumerWidget {
  const StudentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Espace Étudiant'),
        backgroundColor: theme.colorScheme.primary,
        actions: [
          const LanguageSelector(),
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
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bienvenue, ${currentUser.displayName ?? currentUser.email}',
                            style: theme.textTheme.headlineSmall,
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
                    'Fonctionnalités',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      children: [
                        _buildFeatureCard(
                          context,
                          title: 'Mon QR Code',
                          icon: Icons.qr_code,
                          onTap: () {
                            Navigator.of(context).pushNamed(AppRoutes.qrGenerator);
                          },
                        ),
                        _buildFeatureCard(
                          context,
                          title: 'Mes Présences',
                          icon: Icons.calendar_today,
                          onTap: () {
                            Navigator.of(context).pushNamed(AppRoutes.absenceList);
                          },
                        ),
                        _buildFeatureCard(
                          context,
                          title: 'Mon Profil',
                          icon: Icons.person,
                          onTap: () {
                            Navigator.of(context).pushNamed(AppRoutes.userProfile, arguments: currentUser.id);
                          },
                        ),
                        _buildFeatureCard(
                          context,
                          title: 'Ma Classe',
                          icon: Icons.class_,
                          onTap: () {
                            // Note: UserEntity de base n'a pas de classId
                            // On pourrait l'obtenir via un appel API, mais pour simplifier:
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Information de classe non disponible'),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
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
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 