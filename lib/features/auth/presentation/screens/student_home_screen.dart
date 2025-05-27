import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';

class StudentHomeScreen extends ConsumerWidget {
  const StudentHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Espace Étudiant',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              ref.read(authStateProvider.notifier).logout();
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/',
                (route) => false,
              );
            },
            icon: const Icon(Icons.logout),
            tooltip: 'Se déconnecter',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête de bienvenue
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bienvenue, ${user?.displayName ?? user?.email ?? 'Étudiant'}',
                      style: theme.textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text('Email: ${user?.email ?? 'Non disponible'}'),
                    Text('Rôle: ${user?.role ?? 'Étudiant'}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Fonctionnalités Étudiant',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildFeatureCard(
              context,
              title: 'Mes Absences',
              icon: Icons.event_busy,
              onTap: () => Navigator.of(context).pushNamed('/absences'),
            ),
            _buildFeatureCard(
              context,
              title: 'Mes Notes',
              icon: Icons.grade,
              onTap: () => Navigator.of(context).pushNamed('/grades'),
            ),
            _buildFeatureCard(
              context,
              title: 'Emploi du Temps',
              icon: Icons.schedule,
              onTap: () => Navigator.of(context).pushNamed('/schedule'),
            ),
            _buildFeatureCard(
              context,
              title: 'Réclamations',
              icon: Icons.feedback,
              onTap: () => Navigator.of(context).pushNamed('/complaints'),
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