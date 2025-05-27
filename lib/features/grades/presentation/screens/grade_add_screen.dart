import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/services/grade_service.dart';

class GradeAddScreen extends StatefulWidget {
  final String? subjectFilter; // Matière pré-sélectionnée (optionnel)
  
  const GradeAddScreen({super.key, this.subjectFilter});

  @override
  State<GradeAddScreen> createState() => _GradeAddScreenState();
}

class _GradeAddScreenState extends State<GradeAddScreen> {
  final _formKey = GlobalKey<FormState>();
  final _midtermController = TextEditingController();
  final _finalController = TextEditingController();
  final _commentController = TextEditingController();
  
  String _selectedStudent = '';
  String _selectedCourse = '';
  String _selectedSemester = 'Semestre 1';
  String _selectedType = 'Contrôle';
  double _calculatedAverage = 0.0;
  bool _isLoading = false;

  // Données simulées - dans un vrai projet, cela viendrait de la base de données
  final List<Map<String, String>> _students = [
    {'id': 'student1', 'name': 'Fatou Diop'},
    {'id': 'student2', 'name': 'Amadou Sow'},
    {'id': 'student3', 'name': 'Aissatou Ba'},
    {'id': 'student4', 'name': 'Ousmane Fall'},
  ];

  final List<Map<String, String>> _courses = [
    {'id': 'course1', 'name': 'Mathématiques', 'code': 'MATH301'},
    {'id': 'course2', 'name': 'Informatique', 'code': 'INFO201'},
    {'id': 'course3', 'name': 'Physique', 'code': 'PHYS201'},
    {'id': 'course4', 'name': 'Anglais', 'code': 'LANG101'},
  ];

  final List<String> _semesters = ['Semestre 1', 'Semestre 2', 'Semestre 3', 'Semestre 4'];
  final List<String> _gradeTypes = ['Contrôle', 'TP', 'Projet', 'Examen Final', 'Devoir'];

  @override
  void initState() {
    super.initState();
    
    // Si une matière est pré-sélectionnée
    if (widget.subjectFilter != null) {
      final course = _courses.firstWhere(
        (c) => c['name'] == widget.subjectFilter,
        orElse: () => _courses.first,
      );
      _selectedCourse = course['id']!;
    }
  }

  @override
  void dispose() {
    _midtermController.dispose();
    _finalController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  void _calculateAverage() {
    final midterm = double.tryParse(_midtermController.text) ?? 0.0;
    final final_ = double.tryParse(_finalController.text) ?? 0.0;
    setState(() {
      _calculatedAverage = (midterm + final_) / 2;
    });
  }

  Future<void> _saveGrade() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedStudent.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner un étudiant'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedCourse.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner un cours'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final midterm = double.parse(_midtermController.text);
      final final_ = double.parse(_finalController.text);
      final comment = _commentController.text.trim();

      // Récupérer les informations du cours sélectionné
      final courseInfo = _courses.firstWhere((c) => c['id'] == _selectedCourse);

      await GradeService.insertGrade(
        studentId: _selectedStudent,
        courseId: _selectedCourse,
        courseTitle: courseInfo['name']!,
        semester: _selectedSemester,
        midterm: midterm,
        final_: final_,
        comment: comment.isEmpty ? null : comment,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Note ajoutée avec succès'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true); // Retourner true pour indiquer le succès
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
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

  Color _getGradeColor(double grade) {
    if (grade >= 16) return Colors.green;
    if (grade >= 14) return Colors.lightGreen;
    if (grade >= 12) return Colors.orange;
    if (grade >= 10) return Colors.deepOrange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          widget.subjectFilter != null 
              ? 'Ajouter note - ${widget.subjectFilter}'
              : 'Ajouter une note',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: colorScheme.primary,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // En-tête informatif
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.grade,
                        size: 48,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Nouvelle Évaluation',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Ajouter une note pour un étudiant',
                        style: GoogleFonts.roboto(
                          fontSize: 14,
                          color: colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Sélection de l'étudiant
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sélection de l\'étudiant',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _selectedStudent.isEmpty ? null : _selectedStudent,
                        decoration: InputDecoration(
                          labelText: 'Étudiant *',
                          prefixIcon: const Icon(Icons.person),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: _students.map((student) {
                          return DropdownMenuItem<String>(
                            value: student['id'],
                            child: Text(student['name']!),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedStudent = value ?? '';
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez sélectionner un étudiant';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Sélection du cours et semestre
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Détails du cours',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      // Cours
                      DropdownButtonFormField<String>(
                        value: _selectedCourse.isEmpty ? null : _selectedCourse,
                        decoration: InputDecoration(
                          labelText: 'Cours *',
                          prefixIcon: const Icon(Icons.book),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: _courses.map((course) {
                          return DropdownMenuItem<String>(
                            value: course['id'],
                            child: Text('${course['name']} (${course['code']})'),
                          );
                        }).toList(),
                        onChanged: widget.subjectFilter == null ? (value) {
                          setState(() {
                            _selectedCourse = value ?? '';
                          });
                        } : null, // Désactiver si pre-sélectionné
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez sélectionner un cours';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Semestre et Type
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedSemester,
                              decoration: InputDecoration(
                                labelText: 'Semestre',
                                prefixIcon: const Icon(Icons.calendar_month),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              items: _semesters.map((semester) {
                                return DropdownMenuItem<String>(
                                  value: semester,
                                  child: Text(semester),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedSemester = value!;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedType,
                              decoration: InputDecoration(
                                labelText: 'Type d\'évaluation',
                                prefixIcon: const Icon(Icons.assignment),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              items: _gradeTypes.map((type) {
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
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Notes
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Saisie des notes',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _midtermController,
                              decoration: InputDecoration(
                                labelText: 'Note partiel *',
                                hintText: 'Sur 20',
                                prefixIcon: const Icon(Icons.edit),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              onChanged: (_) => _calculateAverage(),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Note requise';
                                }
                                final grade = double.tryParse(value);
                                if (grade == null || grade < 0 || grade > 20) {
                                  return 'Note entre 0 et 20';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _finalController,
                              decoration: InputDecoration(
                                labelText: 'Note finale *',
                                hintText: 'Sur 20',
                                prefixIcon: const Icon(Icons.grade),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              onChanged: (_) => _calculateAverage(),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Note requise';
                                }
                                final grade = double.tryParse(value);
                                if (grade == null || grade < 0 || grade > 20) {
                                  return 'Note entre 0 et 20';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Moyenne calculée
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: _getGradeColor(_calculatedAverage).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _getGradeColor(_calculatedAverage),
                            width: 2,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Moyenne calculée:',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '${_calculatedAverage.toStringAsFixed(2)}/20',
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: _getGradeColor(_calculatedAverage),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Commentaire
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Commentaire (optionnel)',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _commentController,
                        decoration: InputDecoration(
                          hintText: 'Ajouter un commentaire pour l\'étudiant...',
                          prefixIcon: const Icon(Icons.comment),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Bouton de sauvegarde
              SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _saveGrade,
                  icon: _isLoading 
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.save),
                  label: Text(
                    _isLoading ? 'Enregistrement...' : 'Enregistrer la note',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 