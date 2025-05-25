import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/language_selector.dart';
import '../../../../core/services/course_service.dart';
import '../../../auth/providers/auth_provider.dart';

class AddCourseScreen extends ConsumerStatefulWidget {
  static const routeName = '/add-course';

  const AddCourseScreen({super.key});

  @override
  ConsumerState<AddCourseScreen> createState() => _AddCourseScreenState();
}

class _AddCourseScreenState extends ConsumerState<AddCourseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _codeController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _creditsController = TextEditingController();
  final _maxStudentsController = TextEditingController();
  
  String _selectedClass = '';
  String _selectedSemester = '';
  bool _isLoading = false;

  // Pour le prototype, on utilise des données simulées
  final List<Map<String, String>> _classes = [
    {'id': '1', 'name': 'Licence 1'},
    {'id': '2', 'name': 'Licence 2'},
    {'id': '3', 'name': 'Licence 3'},
    {'id': '4', 'name': 'Master 1'},
  ];

  final List<Map<String, String>> _semesters = [
    {'id': 'S1', 'name': 'Semestre 1'},
    {'id': 'S2', 'name': 'Semestre 2'},
    {'id': 'S3', 'name': 'Semestre 3'},
    {'id': 'S4', 'name': 'Semestre 4'},
    {'id': 'S5', 'name': 'Semestre 5'},
    {'id': 'S6', 'name': 'Semestre 6'},
  ];

  @override
  void initState() {
    super.initState();
    _creditsController.text = '3'; // Valeur par défaut
    _maxStudentsController.text = '50'; // Valeur par défaut
  }

  @override
  void dispose() {
    _titleController.dispose();
    _codeController.dispose();
    _descriptionController.dispose();
    _creditsController.dispose();
    _maxStudentsController.dispose();
    super.dispose();
  }

  Future<void> _saveCourse() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Utilisateur non connecté')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final courseId = await CourseService.insertCourse(
        name: _titleController.text.trim(),
        code: _codeController.text.trim(),
        description: _descriptionController.text.trim(),
        teacherId: currentUser.id,
        credits: int.parse(_creditsController.text),
        semester: _selectedSemester,
        classId: _selectedClass.isEmpty ? null : _selectedClass,
        maxStudents: int.parse(_maxStudentsController.text),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cours créé avec succès'),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter un cours'),
        backgroundColor: theme.colorScheme.primary,
        actions: const [
          LanguageSelector(),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Nom du cours',
                  prefixIcon: Icon(Icons.book),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Veuillez entrer un nom de cours';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _codeController,
                decoration: const InputDecoration(
                  labelText: 'Code du cours',
                  prefixIcon: Icon(Icons.code),
                  hintText: 'Ex: MATH301, INFO201',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Veuillez entrer un code de cours';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _creditsController,
                      decoration: const InputDecoration(
                        labelText: 'Crédits',
                        prefixIcon: Icon(Icons.credit_card),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Requis';
                        }
                        final credits = int.tryParse(value);
                        if (credits == null || credits < 1 || credits > 10) {
                          return 'Entre 1 et 10';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _maxStudentsController,
                      decoration: const InputDecoration(
                        labelText: 'Max étudiants',
                        prefixIcon: Icon(Icons.people),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Requis';
                        }
                        final max = int.tryParse(value);
                        if (max == null || max < 1 || max > 200) {
                          return 'Entre 1 et 200';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Semestre',
                  prefixIcon: Icon(Icons.schedule),
                ),
                value: _selectedSemester.isEmpty ? null : _selectedSemester,
                items: _semesters.map((semester) {
                  return DropdownMenuItem<String>(
                    value: semester['id'],
                    child: Text(semester['name']!),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedSemester = value ?? '';
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez sélectionner un semestre';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Classe (optionnel)',
                  prefixIcon: Icon(Icons.class_),
                ),
                value: _selectedClass.isEmpty ? null : _selectedClass,
                items: _classes.map((classItem) {
                  return DropdownMenuItem<String>(
                    value: classItem['id'],
                    child: Text(classItem['name']!),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedClass = value ?? '';
                  });
                },
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Veuillez entrer une description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveCourse,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading 
                    ? const CircularProgressIndicator()
                    : const Text('Créer le cours'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 