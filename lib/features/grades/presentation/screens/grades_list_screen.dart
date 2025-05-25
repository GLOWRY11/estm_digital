import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GradesListScreen extends ConsumerWidget {
  static const routeName = '/grades-list';

  const GradesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    // Données de test pour les notes
    final grades = [
      {
        'courseTitle': 'Introduction à la programmation',
        'semester': 'Semestre 1',
        'midterm': 16.5,
        'final': 18.0,
        'average': 17.25,
        'comment': 'Excellent travail',
      },
      {
        'courseTitle': 'Algorithmes et structures de données',
        'semester': 'Semestre 1',
        'midterm': 14.0,
        'final': 15.5,
        'average': 14.75,
        'comment': 'Bon travail',
      },
      {
        'courseTitle': 'Bases de données',
        'semester': 'Semestre 2',
        'midterm': 12.5,
        'final': 15.0,
        'average': 13.75,
        'comment': 'Amélioration notable en fin de semestre',
      },
      {
        'courseTitle': 'Réseaux informatiques',
        'semester': 'Semestre 2',
        'midterm': 11.0,
        'final': 13.5,
        'average': 12.25,
        'comment': 'Efforts à poursuivre',
      },
    ];

    // Calcul de la moyenne générale
    double overallAverage = 0;
    for (var grade in grades) {
      overallAverage += grade['average'] as double;
    }
    overallAverage /= grades.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Notes & Résultats'),
        backgroundColor: theme.colorScheme.primary,
      ),
      body: Column(
        children: [
          // En-tête avec la moyenne générale
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            color: theme.colorScheme.primary.withOpacity(0.1),
            child: Column(
              children: [
                Text(
                  'Moyenne générale',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  overallAverage.toStringAsFixed(2),
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _getGradeColor(overallAverage),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _getGradeComment(overallAverage),
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          // Liste des notes par matière
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: grades.length,
              itemBuilder: (context, index) {
                final grade = grades[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16.0),
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
                                grade['courseTitle']!.toString(),
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Chip(
                              label: Text(
                                grade['semester']!.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                              backgroundColor: theme.colorScheme.primary,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildGradeItem(
                              context,
                              'Examen partiel',
                              grade['midterm'] as double,
                            ),
                            _buildGradeItem(
                              context,
                              'Examen final',
                              grade['final'] as double,
                            ),
                            _buildGradeItem(
                              context,
                              'Moyenne',
                              grade['average'] as double,
                              isAverage: true,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Commentaire: ${grade['comment']}',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradeItem(
    BuildContext context,
    String label,
    double value, {
    bool isAverage = false,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value.toStringAsFixed(1),
          style: TextStyle(
            fontSize: isAverage ? 18 : 16,
            fontWeight: isAverage ? FontWeight.bold : FontWeight.normal,
            color: isAverage ? _getGradeColor(value) : null,
          ),
        ),
      ],
    );
  }

  Color _getGradeColor(double grade) {
    if (grade >= 16) {
      return Colors.green;
    } else if (grade >= 14) {
      return Colors.lightGreen;
    } else if (grade >= 12) {
      return Colors.orange;
    } else if (grade >= 10) {
      return Colors.amber;
    } else {
      return Colors.red;
    }
  }

  String _getGradeComment(double grade) {
    if (grade >= 16) {
      return 'Très bien';
    } else if (grade >= 14) {
      return 'Bien';
    } else if (grade >= 12) {
      return 'Assez bien';
    } else if (grade >= 10) {
      return 'Passable';
    } else {
      return 'Insuffisant';
    }
  }
} 