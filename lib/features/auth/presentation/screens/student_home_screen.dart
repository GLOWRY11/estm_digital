import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user.dart';
import '../widgets/auth_wrapper.dart';
import '../../../../core/routes/app_routes.dart';

class StudentHomeScreen extends ConsumerWidget {
  final User user;

  const StudentHomeScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Accueil Étudiant'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => AuthWrapper()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bienvenue, ${user.displayName ?? user.email}!',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildFeatureCard(
                    context,
                    'Mes Absences',
                    Icons.event_busy,
                    Colors.red,
                    () {
                      Navigator.of(context).pushNamed(AppRoutes.absenceList);
                    },
                  ),
                  _buildFeatureCard(
                    context,
                    'Mes Notes',
                    Icons.grade,
                    Colors.blue,
                    () {
                      Navigator.of(context).pushNamed(AppRoutes.gradesList);
                    },
                  ),
                  _buildFeatureCard(
                    context,
                    'Emploi du Temps',
                    Icons.schedule,
                    Colors.green,
                    () {
                      Navigator.of(context).pushNamed(AppRoutes.calendar);
                    },
                  ),
                  _buildFeatureCard(
                    context,
                    'Réclamations',
                    Icons.feedback,
                    Colors.orange,
                    () {
                      Navigator.of(context).pushNamed(AppRoutes.complaints);
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
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48,
                color: color,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
} 