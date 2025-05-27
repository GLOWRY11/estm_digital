import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class CourseAddScreen extends ConsumerStatefulWidget {
  const CourseAddScreen({super.key});

  @override
  ConsumerState<CourseAddScreen> createState() => _CourseAddScreenState();
}

class _CourseAddScreenState extends ConsumerState<CourseAddScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _subjectController = TextEditingController();
  final _teacherController = TextEditingController();
  final _roomController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  // Form values
  String _selectedType = 'Cours';
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _startTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 10, minute: 0);
  
  bool _isLoading = false;
  
  final List<String> _courseTypes = ['Cours', 'TD', 'TP', 'Conférence', 'Examen'];
  
  @override
  void dispose() {
    _subjectController.dispose();
    _teacherController.dispose();
    _roomController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Ajouter un Cours',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Titre de la section
              Text(
                'Informations du cours',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 24),

              // Matière
              Text(
                'Matière *',
                style: GoogleFonts.roboto(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _subjectController,
                decoration: InputDecoration(
                  hintText: 'Ex: Mathématiques, Physique...',
                  prefixIcon: const Icon(Icons.book),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'La matière est obligatoire';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Type de cours
              Text(
                'Type de cours *',
                style: GoogleFonts.roboto(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.category),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: _courseTypes.map((type) {
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

              // Enseignant
              Text(
                'Enseignant *',
                style: GoogleFonts.roboto(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _teacherController,
                decoration: InputDecoration(
                  hintText: 'Ex: Prof. Martin',
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'L\'enseignant est obligatoire';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Salle
              Text(
                'Salle *',
                style: GoogleFonts.roboto(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _roomController,
                decoration: InputDecoration(
                  hintText: 'Ex: Salle A101, Lab B205...',
                  prefixIcon: const Icon(Icons.location_on),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'La salle est obligatoire';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Section Planification
              Text(
                'Planification',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),

              // Date
              Card(
                child: ListTile(
                  leading: Icon(Icons.calendar_today, color: colorScheme.primary),
                  title: Text(
                    'Date du cours',
                    style: GoogleFonts.roboto(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(
                    _formatDate(_selectedDate),
                    style: GoogleFonts.roboto(color: colorScheme.onSurface.withValues(alpha: 0.7)),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setState(() {
                        _selectedDate = date;
                      });
                    }
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Horaires
              Row(
                children: [
                  Expanded(
                    child: Card(
                      child: ListTile(
                        leading: Icon(Icons.access_time, color: colorScheme.primary),
                        title: Text(
                          'Heure de début',
                          style: GoogleFonts.roboto(fontWeight: FontWeight.w500),
                        ),
                        subtitle: Text(
                          _startTime.format(context),
                          style: GoogleFonts.roboto(color: colorScheme.onSurface.withValues(alpha: 0.7)),
                        ),
                        onTap: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: _startTime,
                          );
                          if (time != null) {
                            setState(() {
                              _startTime = time;
                              // Ajuster automatiquement l'heure de fin
                              final endMinutes = time.hour * 60 + time.minute + 120; // +2h
                              _endTime = TimeOfDay(
                                hour: (endMinutes ~/ 60) % 24,
                                minute: endMinutes % 60,
                              );
                            });
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Card(
                      child: ListTile(
                        leading: Icon(Icons.access_time_filled, color: colorScheme.primary),
                        title: Text(
                          'Heure de fin',
                          style: GoogleFonts.roboto(fontWeight: FontWeight.w500),
                        ),
                        subtitle: Text(
                          _endTime.format(context),
                          style: GoogleFonts.roboto(color: colorScheme.onSurface.withValues(alpha: 0.7)),
                        ),
                        onTap: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: _endTime,
                          );
                          if (time != null) {
                            setState(() {
                              _endTime = time;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Description (optionnelle)
              Text(
                'Description (optionnel)',
                style: GoogleFonts.roboto(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Détails supplémentaires sur le cours...',
                  prefixIcon: const Icon(Icons.description),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Aperçu du créneau
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colorScheme.primary.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.preview, color: colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          'Aperçu du cours',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${_startTime.format(context)} - ${_endTime.format(context)}',
                      style: GoogleFonts.roboto(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _subjectController.text.isNotEmpty ? _subjectController.text : 'Matière',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getTypeColor(_selectedType).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _selectedType,
                            style: GoogleFonts.roboto(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: _getTypeColor(_selectedType),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          _roomController.text.isNotEmpty ? _roomController.text : 'Salle',
                          style: GoogleFonts.roboto(
                            fontSize: 14,
                            color: colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Boutons d'action
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
                      onPressed: _isLoading ? null : _saveCourse,
                      icon: _isLoading 
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(colorScheme.onPrimary),
                            ),
                          )
                        : const Icon(Icons.save),
                      label: Text(
                        _isLoading ? 'Enregistrement...' : 'Enregistrer le cours',
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

  Color _getTypeColor(String type) {
    switch (type) {
      case 'Cours':
        return Colors.blue;
      case 'TD':
        return Colors.green;
      case 'TP':
        return Colors.orange;
      case 'Conférence':
        return Colors.purple;
      case 'Examen':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    final weekdays = [
      'Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'
    ];
    final months = [
      'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
      'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'
    ];
    
    return '${weekdays[date.weekday - 1]} ${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Duration get _courseDuration {
    final startMinutes = _startTime.hour * 60 + _startTime.minute;
    final endMinutes = _endTime.hour * 60 + _endTime.minute;
    return Duration(minutes: endMinutes - startMinutes);
  }

  bool get _isValidTimeRange {
    final startMinutes = _startTime.hour * 60 + _startTime.minute;
    final endMinutes = _endTime.hour * 60 + _endTime.minute;
    return endMinutes > startMinutes;
  }

  Future<void> _saveCourse() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_isValidTimeRange) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('L\'heure de fin doit être après l\'heure de début'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final duration = _courseDuration;
    if (duration.inMinutes < 30) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('La durée minimale d\'un cours est de 30 minutes'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Simulation de sauvegarde
      await Future.delayed(const Duration(seconds: 2));

      final courseData = {
        'subject': _subjectController.text.trim(),
        'type': _selectedType,
        'teacher': _teacherController.text.trim(),
        'room': _roomController.text.trim(),
        'date': _selectedDate,
        'startTime': _startTime,
        'endTime': _endTime,
        'description': _descriptionController.text.trim(),
        'duration': duration,
      };

      // TODO: Intégrer avec le service de planification
      // await ScheduleService.addCourse(courseData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Cours "${_subjectController.text}" ajouté au planning',
              style: GoogleFonts.roboto(fontWeight: FontWeight.w500),
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );

        Navigator.pop(context, courseData);
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