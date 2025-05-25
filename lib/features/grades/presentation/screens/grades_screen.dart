import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../auth/providers/auth_provider.dart';

class GradesScreen extends ConsumerStatefulWidget {
  const GradesScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<GradesScreen> createState() => _GradesScreenState();
}

class _GradesScreenState extends ConsumerState<GradesScreen> {
  final List<Map<String, dynamic>> _mockGrades = [
    {
      'subject': 'Mathématiques',
      'grades': [
        {'type': 'Contrôle 1', 'grade': 15.5, 'coefficient': 1, 'date': '2024-01-15'},
        {'type': 'Contrôle 2', 'grade': 12.0, 'coefficient': 1, 'date': '2024-02-20'},
        {'type': 'Examen Final', 'grade': 14.0, 'coefficient': 2, 'date': '2024-03-15'},
      ],
    },
    {
      'subject': 'Informatique',
      'grades': [
        {'type': 'TP 1', 'grade': 16.0, 'coefficient': 1, 'date': '2024-01-10'},
        {'type': 'Projet', 'grade': 18.0, 'coefficient': 2, 'date': '2024-02-25'},
        {'type': 'Examen', 'grade': 13.5, 'coefficient': 2, 'date': '2024-03-20'},
      ],
    },
    {
      'subject': 'Physique',
      'grades': [
        {'type': 'Contrôle', 'grade': 11.0, 'coefficient': 1, 'date': '2024-01-25'},
        {'type': 'TP', 'grade': 14.5, 'coefficient': 1, 'date': '2024-02-15'},
        {'type': 'Examen', 'grade': 12.5, 'coefficient': 2, 'date': '2024-03-10'},
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final currentUser = ref.watch(currentUserProvider);
    final isTeacher = currentUser?.role == 'teacher';

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Notes & Évaluations',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: isTeacher ? [
          IconButton(
            onPressed: () {
              // TODO: Ajouter une note
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Formulaire d\'ajout de notes - À implémenter')),
              );
            },
            icon: const Icon(Icons.add),
            tooltip: 'Ajouter une note',
          ),
        ] : null,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _mockGrades.length,
        itemBuilder: (context, index) {
          final subject = _mockGrades[index];
          final average = _calculateAverage(subject['grades']);
          
          return Card(
            margin: const EdgeInsets.only(bottom: 16.0),
            child: ExpansionTile(
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      subject['subject'],
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getGradeColor(average).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '${average.toStringAsFixed(1)}/20',
                      style: GoogleFonts.roboto(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _getGradeColor(average),
                      ),
                    ),
                  ),
                ],
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      ...subject['grades'].map<Widget>((grade) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12.0),
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      grade['type'],
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _formatDate(grade['date']),
                                      style: GoogleFonts.roboto(
                                        fontSize: 12,
                                        color: colorScheme.onSurface.withValues(alpha: 0.7),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '${grade['grade']}/20',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: _getGradeColor(grade['grade']),
                                    ),
                                  ),
                                  Text(
                                    'Coef. ${grade['coefficient']}',
                                    style: GoogleFonts.roboto(
                                      fontSize: 11,
                                      color: colorScheme.onSurface.withValues(alpha: 0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      
                      const Divider(),
                      
                      if (isTeacher) ...[
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  // TODO: Voir statistiques
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Statistiques de ${subject['subject']} - À implémenter')),
                                  );
                                },
                                icon: const Icon(Icons.analytics, size: 18),
                                label: const Text('Statistiques'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: FilledButton.icon(
                                onPressed: () {
                                  // TODO: Ajouter note
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Ajouter note pour ${subject['subject']} - À implémenter')),
                                  );
                                },
                                icon: const Icon(Icons.add, size: 18),
                                label: const Text('Ajouter'),
                              ),
                            ),
                          ],
                        ),
                      ] else ...[
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              // TODO: Voir statistiques (lecture seule)
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Mes statistiques en ${subject['subject']} - À implémenter')),
                              );
                            },
                            icon: const Icon(Icons.analytics, size: 18),
                            label: const Text('Statistiques'),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          border: Border(
            top: BorderSide(color: colorScheme.outline.withValues(alpha: 0.2)),
          ),
        ),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(Icons.calculate, color: colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Moyenne Générale',
                        style: GoogleFonts.roboto(
                          fontSize: 14,
                          color: colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                      Text(
                        '${_calculateOverallAverage().toStringAsFixed(2)}/20',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: _getGradeColor(_calculateOverallAverage()),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: _getGradeColor(_calculateOverallAverage()).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _getGradeStatus(_calculateOverallAverage()),
                    style: GoogleFonts.roboto(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: _getGradeColor(_calculateOverallAverage()),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  double _calculateAverage(List<dynamic> grades) {
    if (grades.isEmpty) return 0.0;
    
    double totalPoints = 0.0;
    int totalCoefficients = 0;
    
    for (var grade in grades) {
      totalPoints += grade['grade'] * grade['coefficient'];
      totalCoefficients += grade['coefficient'] as int;
    }
    
    return totalCoefficients > 0 ? totalPoints / totalCoefficients : 0.0;
  }

  double _calculateOverallAverage() {
    if (_mockGrades.isEmpty) return 0.0;
    
    double totalAverage = 0.0;
    for (var subject in _mockGrades) {
      totalAverage += _calculateAverage(subject['grades']);
    }
    
    return totalAverage / _mockGrades.length;
  }

  Color _getGradeColor(double grade) {
    if (grade >= 16) return Colors.green;
    if (grade >= 14) return Colors.lightGreen;
    if (grade >= 12) return Colors.orange;
    if (grade >= 10) return Colors.deepOrange;
    return Colors.red;
  }

  String _getGradeStatus(double grade) {
    if (grade >= 16) return 'Excellent';
    if (grade >= 14) return 'Bien';
    if (grade >= 12) return 'Assez Bien';
    if (grade >= 10) return 'Passable';
    return 'Insuffisant';
  }

  String _formatDate(String dateStr) {
    final date = DateTime.parse(dateStr);
    return '${date.day}/${date.month}/${date.year}';
  }
} 