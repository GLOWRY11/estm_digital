import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class StudentGradesManagementScreen extends ConsumerStatefulWidget {
  final String studentId;
  final String studentName;
  final String? courseFilter; // Optionnel : filtrer par cours

  const StudentGradesManagementScreen({
    super.key,
    required this.studentId,
    required this.studentName,
    this.courseFilter,
  });

  @override
  ConsumerState<StudentGradesManagementScreen> createState() => _StudentGradesManagementScreenState();
}

class _StudentGradesManagementScreenState extends ConsumerState<StudentGradesManagementScreen> {
  // Données simulées des notes de l'étudiant
  List<Map<String, dynamic>> _studentGrades = [];
  final bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadStudentGrades();
  }

  void _loadStudentGrades() {
    // Simulation des données de notes pour l'étudiant
    setState(() {
      _studentGrades = [
        {
          'id': 'grade1',
          'courseId': 'course1',
          'courseName': 'Mathématiques',
          'courseCode': 'MATH301',
          'evaluations': [
            {
              'id': 'eval1',
              'type': 'Contrôle 1',
              'grade': 15.5,
              'coefficient': 1,
              'date': DateTime(2024, 1, 15),
              'comment': 'Bon travail',
            },
            {
              'id': 'eval2',
              'type': 'Contrôle 2',
              'grade': 12.0,
              'coefficient': 1,
              'date': DateTime(2024, 2, 20),
              'comment': 'Peut mieux faire',
            },
            {
              'id': 'eval3',
              'type': 'Examen Final',
              'grade': 14.0,
              'coefficient': 2,
              'date': DateTime(2024, 3, 15),
              'comment': 'Résultat correct',
            },
          ],
        },
        {
          'id': 'grade2',
          'courseId': 'course2',
          'courseName': 'Informatique',
          'courseCode': 'INFO201',
          'evaluations': [
            {
              'id': 'eval4',
              'type': 'TP 1',
              'grade': 16.0,
              'coefficient': 1,
              'date': DateTime(2024, 1, 10),
              'comment': 'Excellent',
            },
            {
              'id': 'eval5',
              'type': 'Projet',
              'grade': 18.0,
              'coefficient': 2,
              'date': DateTime(2024, 2, 25),
              'comment': 'Très bon travail',
            },
          ],
        },
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Notes de ${widget.studentName}',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => _showAddGradeDialog(),
            icon: const Icon(Icons.add),
            tooltip: 'Ajouter une note',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // En-tête étudiant
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: colorScheme.primaryContainer,
                            child: Text(
                              widget.studentName.substring(0, 1).toUpperCase(),
                              style: GoogleFonts.poppins(
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.studentName,
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  'ID: ${widget.studentId}',
                                  style: GoogleFonts.roboto(
                                    fontSize: 14,
                                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                                  ),
                                ),
                                Text(
                                  'Moyenne générale: ${_calculateOverallAverage().toStringAsFixed(2)}',
                                  style: GoogleFonts.roboto(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: _getGradeColor(_calculateOverallAverage()),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  Text(
                    'Notes par matière',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Liste des matières et notes
                  ..._studentGrades.map((courseGrade) => _buildCourseGradeCard(courseGrade)),
                ],
              ),
            ),
    );
  }

  Widget _buildCourseGradeCard(Map<String, dynamic> courseGrade) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final evaluations = List<Map<String, dynamic>>.from(courseGrade['evaluations']);
    final courseAverage = _calculateCourseAverage(evaluations);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        title: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    courseGrade['courseName'],
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    courseGrade['courseCode'],
                    style: GoogleFonts.roboto(
                      fontSize: 12,
                      color: colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getGradeColor(courseAverage).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _getGradeColor(courseAverage)),
              ),
              child: Text(
                courseAverage.toStringAsFixed(2),
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _getGradeColor(courseAverage),
                ),
              ),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Évaluations',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => _showAddEvaluationDialog(courseGrade),
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Ajouter'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...evaluations.map((evaluation) => _buildEvaluationTile(evaluation, courseGrade)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEvaluationTile(Map<String, dynamic> evaluation, Map<String, dynamic> courseGrade) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      evaluation['type'],
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Coef. ${evaluation['coefficient']}',
                        style: GoogleFonts.roboto(
                          fontSize: 10,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(evaluation['date']),
                  style: GoogleFonts.roboto(
                    fontSize: 12,
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                if (evaluation['comment'] != null && evaluation['comment'].isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    evaluation['comment'],
                    style: GoogleFonts.roboto(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: colorScheme.onSurface.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Column(
            children: [
              Text(
                evaluation['grade'].toString(),
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: _getGradeColor(evaluation['grade'].toDouble()),
                ),
              ),
              Text(
                '/ 20',
                style: GoogleFonts.roboto(
                  fontSize: 10,
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: colorScheme.onSurface.withValues(alpha: 0.6)),
            onSelected: (value) {
              if (value == 'edit') {
                _showEditEvaluationDialog(evaluation, courseGrade);
              } else if (value == 'delete') {
                _showDeleteEvaluationDialog(evaluation, courseGrade);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 16),
                    SizedBox(width: 8),
                    Text('Modifier'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 16, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Supprimer', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getGradeColor(double grade) {
    if (grade >= 16) return Colors.green;
    if (grade >= 12) return Colors.orange;
    return Colors.red;
  }

  double _calculateCourseAverage(List<Map<String, dynamic>> evaluations) {
    if (evaluations.isEmpty) return 0.0;
    
    double totalPoints = 0.0;
    double totalCoefficients = 0.0;
    
    for (final evaluation in evaluations) {
      totalPoints += evaluation['grade'] * evaluation['coefficient'];
      totalCoefficients += evaluation['coefficient'];
    }
    
    return totalCoefficients > 0 ? totalPoints / totalCoefficients : 0.0;
  }

  double _calculateOverallAverage() {
    if (_studentGrades.isEmpty) return 0.0;
    
    double totalAverage = 0.0;
    int courseCount = 0;
    
    for (final courseGrade in _studentGrades) {
      final evaluations = List<Map<String, dynamic>>.from(courseGrade['evaluations']);
      if (evaluations.isNotEmpty) {
        totalAverage += _calculateCourseAverage(evaluations);
        courseCount++;
      }
    }
    
    return courseCount > 0 ? totalAverage / courseCount : 0.0;
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  void _showAddGradeDialog() {
    // Navigation vers l'écran d'ajout de note avec filtre étudiant
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEvaluationDialog(
          studentId: widget.studentId,
          studentName: widget.studentName,
          onGradeAdded: () {
            _loadStudentGrades();
          },
        ),
      ),
    );
  }

  void _showAddEvaluationDialog(Map<String, dynamic> courseGrade) {
    // Dialogue pour ajouter une évaluation à une matière spécifique
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEvaluationDialog(
          studentId: widget.studentId,
          studentName: widget.studentName,
          courseFilter: courseGrade['courseId'],
          courseName: courseGrade['courseName'],
          onGradeAdded: () {
            _loadStudentGrades();
          },
        ),
      ),
    );
  }

  void _showEditEvaluationDialog(Map<String, dynamic> evaluation, Map<String, dynamic> courseGrade) {
    // TODO: Implémenter l'édition d'évaluation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Modification de l\'évaluation ${evaluation['type']}'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _showDeleteEvaluationDialog(Map<String, dynamic> evaluation, Map<String, dynamic> courseGrade) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer l\'évaluation'),
        content: Text('Voulez-vous vraiment supprimer l\'évaluation "${evaluation['type']}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Supprimer l'évaluation
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Évaluation "${evaluation['type']}" supprimée'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// Widget séparé pour l'ajout d'évaluation
class AddEvaluationDialog extends StatefulWidget {
  final String studentId;
  final String studentName;
  final String? courseFilter;
  final String? courseName;
  final VoidCallback onGradeAdded;

  const AddEvaluationDialog({
    super.key,
    required this.studentId,
    required this.studentName,
    this.courseFilter,
    this.courseName,
    required this.onGradeAdded,
  });

  @override
  State<AddEvaluationDialog> createState() => _AddEvaluationDialogState();
}

class _AddEvaluationDialogState extends State<AddEvaluationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _gradeController = TextEditingController();
  final _commentController = TextEditingController();
  
  String _selectedCourse = '';
  String _selectedType = 'Contrôle';
  int _coefficient = 1;
  bool _isLoading = false;

  final List<String> _evaluationTypes = ['Contrôle', 'TP', 'Projet', 'Examen Final', 'Devoir'];
  final List<Map<String, String>> _courses = [
    {'id': 'course1', 'name': 'Mathématiques'},
    {'id': 'course2', 'name': 'Informatique'},
    {'id': 'course3', 'name': 'Physique'},
    {'id': 'course4', 'name': 'Anglais'},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.courseFilter != null) {
      _selectedCourse = widget.courseFilter!;
    }
  }

  @override
  void dispose() {
    _gradeController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.courseName != null 
            ? 'Ajouter note - ${widget.courseName}' 
            : 'Ajouter une note',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Informations étudiant
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(Icons.person, color: colorScheme.primary),
                      const SizedBox(width: 12),
                      Text(
                        'Étudiant: ${widget.studentName}',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Sélection du cours (si pas de filtre)
              if (widget.courseFilter == null) ...[
                Text(
                  'Matière *',
                  style: GoogleFonts.roboto(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedCourse.isEmpty ? null : _selectedCourse,
                  decoration: InputDecoration(
                    hintText: 'Sélectionnez une matière',
                    prefixIcon: const Icon(Icons.school),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: _courses.map((course) {
                    return DropdownMenuItem<String>(
                      value: course['id'],
                      child: Text(course['name']!),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCourse = value!;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez sélectionner une matière';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
              ],

              // Type d'évaluation
              Text(
                'Type d\'évaluation *',
                style: GoogleFonts.roboto(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.quiz),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: _evaluationTypes.map((type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedType = value!;
                  });
                },
              ),

              const SizedBox(height: 20),

              // Note et coefficient
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Note * (sur 20)',
                          style: GoogleFonts.roboto(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _gradeController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: 'Ex: 15.5',
                            prefixIcon: const Icon(Icons.grade),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Note requise';
                            }
                            final grade = double.tryParse(value);
                            if (grade == null) {
                              return 'Note invalide';
                            }
                            if (grade < 0 || grade > 20) {
                              return 'Note entre 0 et 20';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Coefficient *',
                          style: GoogleFonts.roboto(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<int>(
                          value: _coefficient,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.linear_scale),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          items: [1, 2, 3, 4, 5].map((coef) {
                            return DropdownMenuItem<int>(
                              value: coef,
                              child: Text(coef.toString()),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _coefficient = value!;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Commentaire
              Text(
                'Commentaire',
                style: GoogleFonts.roboto(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _commentController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Commentaire sur la performance...',
                  prefixIcon: const Icon(Icons.comment),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Boutons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : () => Navigator.pop(context),
                      child: Text(
                        'Annuler',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: FilledButton.icon(
                      onPressed: _isLoading ? null : _saveEvaluation,
                      icon: _isLoading 
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save),
                      label: Text(
                        _isLoading ? 'Enregistrement...' : 'Enregistrer',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveEvaluation() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Simulation de sauvegarde
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Note ajoutée pour ${widget.studentName}',
              style: GoogleFonts.roboto(fontWeight: FontWeight.w500),
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );

        widget.onGradeAdded();
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'enregistrement: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
} 