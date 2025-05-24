import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../features/auth/presentation/providers/auth_providers.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../../core/widgets/language_selector.dart';
import '../../../../core/routes/app_routes.dart';

class CoursesListScreen extends ConsumerWidget {
  static const routeName = '/courses-list';

  const CoursesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currentUser = ref.watch(currentUserProvider);
    final isTeacher = currentUser?.isTeacher ?? false;

    // Données de test pour les cours
    final courses = [
      {
        'title': 'Introduction à la programmation',
        'teacher': 'Dr. Diop',
        'description': 'Fondamentaux de la programmation avec Python',
        'status': 'En cours',
      },
      {
        'title': 'Algorithmes et structures de données',
        'teacher': 'Prof. Sow',
        'description': 'Étude des algorithmes fondamentaux et des structures de données',
        'status': 'À venir',
      },
      {
        'title': 'Bases de données',
        'teacher': 'Dr. Ndiaye',
        'description': 'Conception et implémentation de bases de données relationnelles',
        'status': 'Terminé',
      },
      {
        'title': 'Réseaux informatiques',
        'teacher': 'M. Fall',
        'description': 'Principes fondamentaux des réseaux informatiques',
        'status': 'En cours',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Cours'),
        backgroundColor: theme.colorScheme.primary,
        actions: const [
          LanguageSelector(),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: courses.length,
        itemBuilder: (context, index) {
          final course = courses[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16.0),
            child: InkWell(
              onTap: () {
                // Navigation vers les détails du cours
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Détails du cours "${course['title']}"'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            course['title']!,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        _buildStatusChip(course['status']!),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Enseignant: ${course['teacher']}',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      course['description']!,
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          icon: const Icon(Icons.info_outline),
                          label: const Text('Détails'),
                          onPressed: () {
                            // Navigation vers les détails du cours
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Détails du cours "${course['title']}"'),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                        ),
                        if (isTeacher) ...[
                          TextButton.icon(
                            icon: const Icon(Icons.edit),
                            label: const Text('Modifier'),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Modification du cours "${course['title']}"'),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: isTeacher
          ? FloatingActionButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.addCourse);
              },
              tooltip: 'Ajouter un cours',
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildStatusChip(String status) {
    Color chipColor;
    Color textColor = Colors.white;

    switch (status) {
      case 'En cours':
        chipColor = Colors.blue;
        break;
      case 'À venir':
        chipColor = Colors.orange;
        break;
      case 'Terminé':
        chipColor = Colors.green;
        break;
      default:
        chipColor = Colors.grey;
    }

    return Chip(
      label: Text(
        status,
        style: TextStyle(color: textColor, fontSize: 12),
      ),
      backgroundColor: chipColor,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
    );
  }
} 