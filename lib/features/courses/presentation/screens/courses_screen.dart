import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../../core/routes/app_routes.dart';

class CoursesScreen extends ConsumerStatefulWidget {
  const CoursesScreen({super.key});

  @override
  ConsumerState<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends ConsumerState<CoursesScreen> {
  final List<Map<String, dynamic>> _mockCourses = [
    {
      'id': '1',
      'name': 'Mathématiques Avancées',
      'code': 'MATH301',
      'credits': 6,
      'semester': 'S5',
      'students': 45,
      'description': 'Algèbre linéaire et analyse complexe',
    },
    {
      'id': '2',
      'name': 'Programmation Orientée Objet',
      'code': 'INFO201',
      'credits': 4,
      'semester': 'S3',
      'students': 38,
      'description': 'Concepts avancés de POO en Java',
    },
    {
      'id': '3',
      'name': 'Base de Données',
      'code': 'INFO301',
      'credits': 5,
      'semester': 'S5',
      'students': 42,
      'description': 'Conception et gestion de bases de données',
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
          'Mes Cours',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: isTeacher ? [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(AppRoutes.addCourse);
            },
            icon: const Icon(Icons.add),
            tooltip: 'Ajouter un cours',
          ),
        ] : null,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _mockCourses.length,
        itemBuilder: (context, index) {
          final course = _mockCourses[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16.0),
            child: InkWell(
              onTap: () {
                // TODO: Voir détails du cours
              },
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                course['name'],
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                course['code'],
                                style: GoogleFonts.roboto(
                                  fontSize: 14,
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            course['semester'],
                            style: GoogleFonts.roboto(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 12),
                    
                    Text(
                      course['description'],
                      style: GoogleFonts.roboto(
                        fontSize: 14,
                        color: colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    Row(
                      children: [
                        _buildInfoChip(
                          Icons.credit_card,
                          '${course['credits']} crédits',
                          colorScheme,
                        ),
                        const SizedBox(width: 12),
                        _buildInfoChip(
                          Icons.people,
                          '${course['students']} étudiants',
                          colorScheme,
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Boutons d'action selon le rôle
                    if (isTeacher) ...[
                      // Interface Teacher : boutons complets
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                _navigateToStudentsList(context, course);
                              },
                              icon: const Icon(Icons.people, size: 18),
                              label: const Text('Étudiants'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                _navigateToAbsencesList(context, course);
                              },
                              icon: const Icon(Icons.event_busy, size: 18),
                              label: const Text('Absences'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: () {
                                _navigateToGradesList(context, course);
                              },
                              icon: const Icon(Icons.grade, size: 18),
                              label: const Text('Notes'),
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      // Interface Student : boutons lecture seule (2 boutons seulement)
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                _navigateToStudentAbsences(context, course);
                              },
                              icon: const Icon(Icons.event_busy, size: 18),
                              label: const Text('Absences'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: () {
                                _navigateToStudentGrades(context, course);
                              },
                              icon: const Icon(Icons.grade, size: 18),
                              label: const Text('Notes'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.roboto(
              fontSize: 12,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  // Méthodes de navigation pour les boutons d'action des cours
  
  void _navigateToStudentsList(BuildContext context, Map<String, dynamic> course) {
    Navigator.of(context).pushNamed(
      AppRoutes.usersList,
      arguments: {
        'courseId': course['id'],
        'courseName': course['name'],
        'filterByRole': 'student', // Filtrer pour afficher uniquement les étudiants
      },
    );
    
    // Feedback utilisateur
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Liste des étudiants pour ${course['name']}'),
        backgroundColor: Colors.blue,
        action: SnackBarAction(
          label: 'Fermer',
          textColor: Colors.white,
          onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
        ),
      ),
    );
  }

  void _navigateToAbsencesList(BuildContext context, Map<String, dynamic> course) {
    Navigator.of(context).pushNamed(
      AppRoutes.absenceList,
      arguments: {
        'courseId': course['id'],
        'courseName': course['name'],
        'mode': 'teacher', // Mode enseignant pour gestion complète
      },
    );
    
    // Feedback utilisateur
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Gestion des absences pour ${course['name']}'),
        backgroundColor: Colors.red,
        action: SnackBarAction(
          label: 'Fermer',
          textColor: Colors.white,
          onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
        ),
      ),
    );
  }

  void _navigateToGradesList(BuildContext context, Map<String, dynamic> course) {
    Navigator.of(context).pushNamed(
      AppRoutes.teacherGrades,
      arguments: {
        'courseId': course['id'],
        'courseName': course['name'],
        'courseCode': course['code'],
      },
    );
    
    // Feedback utilisateur
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Gestion des notes pour ${course['name']}'),
        backgroundColor: Colors.purple,
        action: SnackBarAction(
          label: 'Fermer',
          textColor: Colors.white,
          onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
        ),
      ),
    );
  }

  // Méthodes de navigation pour les étudiants (mode lecture seule)
  
  void _navigateToStudentAbsences(BuildContext context, Map<String, dynamic> course) {
    Navigator.of(context).pushNamed(
      AppRoutes.absenceList,
      arguments: {
        'courseId': course['id'],
        'courseName': course['name'],
        'mode': 'student', // Mode étudiant pour consultation seulement
      },
    );
    
    // Feedback utilisateur
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Mes absences pour ${course['name']}'),
        backgroundColor: Colors.orange,
        action: SnackBarAction(
          label: 'Fermer',
          textColor: Colors.white,
          onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
        ),
      ),
    );
  }

  void _navigateToStudentGrades(BuildContext context, Map<String, dynamic> course) {
    Navigator.of(context).pushNamed(
      AppRoutes.grades,
      arguments: {
        'courseId': course['id'],
        'courseName': course['name'],
        'courseCode': course['code'],
        'mode': 'student', // Mode étudiant pour consultation seulement
      },
    );
    
    // Feedback utilisateur
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Mes notes pour ${course['name']}'),
        backgroundColor: Colors.green,
        action: SnackBarAction(
          label: 'Fermer',
          textColor: Colors.white,
          onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
        ),
      ),
    );
  }
} 