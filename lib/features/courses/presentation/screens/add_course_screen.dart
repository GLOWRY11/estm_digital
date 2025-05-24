import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/language_selector.dart';

class AddCourseScreen extends ConsumerStatefulWidget {
  static const routeName = '/add-course';

  const AddCourseScreen({super.key});

  @override
  ConsumerState<AddCourseScreen> createState() => _AddCourseScreenState();
}

class _AddCourseScreenState extends ConsumerState<AddCourseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(hours: 2));
  TimeOfDay _startTime = TimeOfDay.now();
  TimeOfDay _endTime = TimeOfDay(
    hour: TimeOfDay.now().hour + 2,
    minute: TimeOfDay.now().minute,
  );
  String _selectedClass = '';
  String _selectedRoom = '';
  bool _isLoading = false;

  // Pour le prototype, on utilise des données simulées
  final List<Map<String, String>> _classes = [
    {'id': '1', 'name': 'Licence 1'},
    {'id': '2', 'name': 'Licence 2'},
    {'id': '3', 'name': 'Licence 3'},
    {'id': '4', 'name': 'Master 1'},
  ];

  final List<Map<String, String>> _rooms = [
    {'id': '1', 'name': 'Salle A101'},
    {'id': '2', 'name': 'Salle B205'},
    {'id': '3', 'name': 'Labo Informatique'},
    {'id': '4', 'name': 'Amphithéâtre'},
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _startTime.hour,
          _startTime.minute,
        );
        
        // Mise à jour de la date de fin si nécessaire
        if (_startDate.isAfter(_endDate)) {
          _endDate = _startDate.add(const Duration(hours: 2));
          _endTime = TimeOfDay(
            hour: _startTime.hour + 2,
            minute: _startTime.minute,
          );
        }
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: _startDate,
      lastDate: _startDate.add(const Duration(days: 365)),
    );
    if (picked != null && picked != _endDate) {
      setState(() {
        _endDate = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _endTime.hour,
          _endTime.minute,
        );
      });
    }
  }

  Future<void> _selectStartTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
    );
    if (picked != null && picked != _startTime) {
      setState(() {
        _startTime = picked;
        _startDate = DateTime(
          _startDate.year,
          _startDate.month,
          _startDate.day,
          picked.hour,
          picked.minute,
        );
        
        // Mise à jour de l'heure de fin si nécessaire
        if (_startDate.isAfter(_endDate)) {
          _endTime = TimeOfDay(
            hour: picked.hour + 2,
            minute: picked.minute,
          );
          _endDate = DateTime(
            _endDate.year,
            _endDate.month,
            _endDate.day,
            _endTime.hour,
            _endTime.minute,
          );
        }
      });
    }
  }

  Future<void> _selectEndTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _endTime,
    );
    if (picked != null && picked != _endTime) {
      setState(() {
        _endTime = picked;
        _endDate = DateTime(
          _endDate.year,
          _endDate.month,
          _endDate.day,
          picked.hour,
          picked.minute,
        );
        
        // Vérifier que la fin est après le début
        if (_endDate.isBefore(_startDate)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('L\'heure de fin doit être après l\'heure de début')),
          );
          _endDate = _startDate.add(const Duration(hours: 1));
          _endTime = TimeOfDay(
            hour: _startDate.hour + 1,
            minute: _startDate.minute,
          );
        }
      });
    }
  }

  // Simuler la sauvegarde du cours
  Future<void> _saveCourse() async {
    if (_formKey.currentState?.validate() != true) {
      return;
    }
    
    if (_selectedClass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner une classe')),
      );
      return;
    }
    
    if (_selectedRoom.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner une salle')),
      );
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    // Simuler un délai réseau
    await Future.delayed(const Duration(seconds: 1));
    
    // Dans une vraie application, nous appellerions un service
    // pour enregistrer le cours dans la base de données
    
    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });
    
    // Afficher un message de réussite
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cours ajouté avec succès')),
    );
    
    // Retourner à l'écran précédent
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter une session'),
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
                  labelText: 'Titre du cours',
                  prefixIcon: Icon(Icons.book),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Veuillez entrer un titre';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Date de début',
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      child: InkWell(
                        onTap: () => _selectStartDate(context),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${_startDate.day}/${_startDate.month}/${_startDate.year}',
                              style: theme.textTheme.bodyLarge,
                            ),
                            const Icon(Icons.calendar_today),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Date de fin',
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      child: InkWell(
                        onTap: () => _selectEndDate(context),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${_endDate.day}/${_endDate.month}/${_endDate.year}',
                              style: theme.textTheme.bodyLarge,
                            ),
                            const Icon(Icons.calendar_today),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Heure de début',
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      child: InkWell(
                        onTap: () => _selectStartTime(context),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${_startTime.hour}:${_startTime.minute.toString().padLeft(2, '0')}',
                              style: theme.textTheme.bodyLarge,
                            ),
                            const Icon(Icons.access_time),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Heure de fin',
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      child: InkWell(
                        onTap: () => _selectEndTime(context),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${_endTime.hour}:${_endTime.minute.toString().padLeft(2, '0')}',
                              style: theme.textTheme.bodyLarge,
                            ),
                            const Icon(Icons.access_time),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Classe',
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
              
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Salle',
                  prefixIcon: Icon(Icons.room),
                ),
                value: _selectedRoom.isEmpty ? null : _selectedRoom,
                items: _rooms.map((room) {
                  return DropdownMenuItem<String>(
                    value: room['id'],
                    child: Text(room['name']!),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedRoom = value ?? '';
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
                    : const Text('Ajouter la session'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 