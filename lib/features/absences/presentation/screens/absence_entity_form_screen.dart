import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/absence_entity.dart';
import '../providers/absence_providers.dart';

class AbsenceEntityFormScreen extends ConsumerStatefulWidget {
  final AbsenceEntity? absence;

  const AbsenceEntityFormScreen({super.key, this.absence});

  @override
  ConsumerState<AbsenceEntityFormScreen> createState() => _AbsenceEntityFormScreenState();
}

class _AbsenceEntityFormScreenState extends ConsumerState<AbsenceEntityFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late DateTime _date;
  late String _time;
  late String _status;
  
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    
    if (widget.absence != null) {
      // Mode édition
      _date = widget.absence!.date;
      _time = widget.absence!.time;
      _status = widget.absence!.status;
      _dateController.text = DateFormat('dd/MM/yyyy').format(_date);
      _timeController.text = _time;
    } else {
      // Mode ajout
      _date = DateTime.now();
      _time = TimeOfDay.now().format(context);
      _status = 'offline';
      _dateController.text = DateFormat('dd/MM/yyyy').format(_date);
      _timeController.text = _time;
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.absence == null ? 'Nouvelle Absence' : 'Modifier Absence'),
        backgroundColor: theme.colorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // En-tête informatif
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.event_busy,
                        size: 48,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        widget.absence == null ? 'Créer une Absence' : 'Modifier l\'Absence',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Gérez les absences des étudiants avec précision',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Formulaire
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Informations de l\'absence',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Date
                      TextFormField(
                        controller: _dateController,
                        decoration: InputDecoration(
                          labelText: 'Date *',
                          hintText: 'Sélectionnez la date',
                          prefixIcon: const Icon(Icons.calendar_today),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        readOnly: true,
                        onTap: _selectDate,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'La date est requise';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Heure
                      TextFormField(
                        controller: _timeController,
                        decoration: InputDecoration(
                          labelText: 'Heure *',
                          hintText: 'Sélectionnez l\'heure',
                          prefixIcon: const Icon(Icons.access_time),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        readOnly: true,
                        onTap: _selectTime,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'L\'heure est requise';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Status
                      DropdownButtonFormField<String>(
                        value: _status,
                        decoration: InputDecoration(
                          labelText: 'Statut',
                          prefixIcon: const Icon(Icons.cloud_sync),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'offline',
                            child: Row(
                              children: [
                                Icon(Icons.cloud_off, color: Colors.orange),
                                SizedBox(width: 8),
                                Text('Hors ligne'),
                              ],
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'synced',
                            child: Row(
                              children: [
                                Icon(Icons.cloud_done, color: Colors.green),
                                SizedBox(width: 8),
                                Text('Synchronisé'),
                              ],
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _status = value;
                            });
                          }
                        },
                      ),

                      const SizedBox(height: 24),

                      // Bouton de sauvegarde
                      FilledButton(
                        onPressed: _saveAbsence,
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          widget.absence == null ? 'Créer l\'Absence' : 'Mettre à Jour',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    
    if (picked != null && picked != _date) {
      setState(() {
        _date = picked;
        _dateController.text = DateFormat('dd/MM/yyyy').format(_date);
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    
    if (picked != null) {
      setState(() {
        _time = picked.format(context);
        _timeController.text = _time;
      });
    }
  }

  Future<void> _saveAbsence() async {
    if (_formKey.currentState!.validate()) {
      try {
        if (widget.absence == null) {
          // Mode création - marquer une nouvelle absence
          await ref.read(markAbsenceUseCaseProvider)(
            studentId: 'current_student', // TODO: récupérer l'ID de l'étudiant actuel
            date: _date,
            time: _time,
            status: _status,
          );
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Absence créée avec succès'),
                backgroundColor: Colors.green,
              ),
            );
          }
                 } else {
           // Mode édition - mettre à jour le statut
           await ref.read(absenceRepositoryProvider).updateAbsenceStatus(
             widget.absence!.id,
             _status,
           );
           
           if (mounted) {
             ScaffoldMessenger.of(context).showSnackBar(
               const SnackBar(
                 content: Text('Absence mise à jour avec succès'),
                 backgroundColor: Colors.green,
               ),
             );
           }
         }
        
        // Invalider le cache pour recharger les données
        ref.invalidate(studentAbsencesProvider);
        
        // Retourner à l'écran précédent
        if (mounted) {
          Navigator.of(context).pop(true);
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
      }
    }
  }
} 