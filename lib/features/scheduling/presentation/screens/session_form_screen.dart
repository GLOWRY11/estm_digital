import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/room_entity.dart';
import '../providers/scheduling_providers.dart';

class SessionFormScreen extends ConsumerStatefulWidget {
  final DateTime initialDate;
  final String? sessionId; // Si non null, on est en mode édition

  const SessionFormScreen({
    Key? key,
    required this.initialDate,
    this.sessionId,
  }) : super(key: key);

  @override
  ConsumerState<SessionFormScreen> createState() => _SessionFormScreenState();
}

class _SessionFormScreenState extends ConsumerState<SessionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late DateTime _startDate;
  late DateTime _endDate;
  TimeOfDay _startTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 10, minute: 0);
  String _course = '';
  String? _selectedRoomId;
  String? _selectedClassId;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _startDate = widget.initialDate;
    _endDate = widget.initialDate;
    
    // Si on est en mode édition, charger les données existantes
    if (widget.sessionId != null) {
      _loadSessionData();
    }
  }

  Future<void> _loadSessionData() async {
    // Cette méthode serait implémentée pour charger les données d'une session existante
  }

  @override
  Widget build(BuildContext context) {
    final roomsAsync = ref.watch(roomsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.sessionId == null ? 'Ajouter une session' : 'Modifier la session'),
        backgroundColor: theme.colorScheme.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildErrorMessage(),
              _buildCourseTitleField(),
              const SizedBox(height: 16),
              _buildDateSelectionFields(context),
              const SizedBox(height: 16),
              _buildTimeSelectionFields(context),
              const SizedBox(height: 24),
              _buildRoomSelector(roomsAsync),
              const SizedBox(height: 16),
              _buildClassSelector(),
              const SizedBox(height: 32),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildErrorMessage() {
    if (_errorMessage == null) return const SizedBox.shrink();
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.red[100],
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.red),
      ),
      child: Text(
        _errorMessage!,
        style: const TextStyle(color: Colors.red),
      ),
    );
  }

  Widget _buildCourseTitleField() {
    return TextFormField(
      decoration: const InputDecoration(
        labelText: 'Titre du cours',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.book),
      ),
      initialValue: _course,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Veuillez entrer le titre du cours';
        }
        return null;
      },
      onSaved: (value) {
        _course = value!;
      },
    );
  }

  Widget _buildDateSelectionFields(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            decoration: const InputDecoration(
              labelText: 'Date de début',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.calendar_today),
            ),
            readOnly: true,
            controller: TextEditingController(text: dateFormat.format(_startDate)),
            onTap: () => _selectDate(context, true),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: TextFormField(
            decoration: const InputDecoration(
              labelText: 'Date de fin',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.calendar_today),
            ),
            readOnly: true,
            controller: TextEditingController(text: dateFormat.format(_endDate)),
            onTap: () => _selectDate(context, false),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSelectionFields(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            decoration: const InputDecoration(
              labelText: 'Heure de début',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.access_time),
            ),
            readOnly: true,
            controller: TextEditingController(text: _startTime.format(context)),
            onTap: () => _selectTime(context, true),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: TextFormField(
            decoration: const InputDecoration(
              labelText: 'Heure de fin',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.access_time),
            ),
            readOnly: true,
            controller: TextEditingController(text: _endTime.format(context)),
            onTap: () => _selectTime(context, false),
          ),
        ),
      ],
    );
  }

  Widget _buildRoomSelector(AsyncValue<List<RoomEntity>> roomsAsync) {
    return roomsAsync.when(
      data: (rooms) {
        if (rooms.isEmpty) {
          return const Text('Aucune salle disponible');
        }
        
        return DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            labelText: 'Salle',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.room),
          ),
          value: _selectedRoomId,
          hint: const Text('Sélectionnez une salle'),
          items: rooms.map((room) {
            return DropdownMenuItem<String>(
              value: room.id,
              child: Text('${room.name} (${room.capacity} places)'),
            );
          }).toList(),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Veuillez sélectionner une salle';
            }
            return null;
          },
          onChanged: (value) {
            setState(() {
              _selectedRoomId = value;
            });
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Text('Erreur de chargement des salles'),
    );
  }

  Widget _buildClassSelector() {
    // Implémentation simplifiée, normalement il faudrait charger les classes
    // à partir d'un provider
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: 'Classe',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.people),
      ),
      value: _selectedClassId,
      hint: const Text('Sélectionnez une classe'),
      items: const [
        DropdownMenuItem<String>(
          value: 'class1',
          child: Text('Licence 1'),
        ),
        DropdownMenuItem<String>(
          value: 'class2',
          child: Text('Licence 2'),
        ),
        DropdownMenuItem<String>(
          value: 'class3',
          child: Text('Licence 3'),
        ),
      ],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Veuillez sélectionner une classe';
        }
        return null;
      },
      onChanged: (value) {
        setState(() {
          _selectedClassId = value;
        });
      },
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
        ),
        onPressed: _isLoading ? null : _submitForm,
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(
                widget.sessionId == null ? 'Ajouter la session' : 'Mettre à jour',
                style: const TextStyle(fontSize: 16),
              ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          // Si la date de fin est avant la date de début, mettre à jour la date de fin
          if (_endDate.isBefore(_startDate)) {
            _endDate = _startDate;
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _selectTime(BuildContext context, bool isStart) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
    );
    
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
          
          // Si le début et la fin sont le même jour et que l'heure de fin est avant l'heure de début
          if (_startDate.year == _endDate.year && 
              _startDate.month == _endDate.month && 
              _startDate.day == _endDate.day &&
              _endTime.hour < _startTime.hour || 
              (_endTime.hour == _startTime.hour && _endTime.minute < _startTime.minute)) {
            
            // Ajouter 1h à l'heure de début pour l'heure de fin
            _endTime = TimeOfDay(
              hour: (_startTime.hour + 1) % 24,
              minute: _startTime.minute,
            );
          }
        } else {
          _endTime = picked;
        }
      });
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      
      try {
        // Créer les objets DateTime combinés pour le début et la fin
        final startDateTime = DateTime(
          _startDate.year,
          _startDate.month,
          _startDate.day,
          _startTime.hour,
          _startTime.minute,
        );
        
        final endDateTime = DateTime(
          _endDate.year,
          _endDate.month,
          _endDate.day,
          _endTime.hour,
          _endTime.minute,
        );
        
        // Vérifier que l'heure de fin est après l'heure de début
        if (endDateTime.isBefore(startDateTime) || endDateTime.isAtSameMomentAs(startDateTime)) {
          throw Exception('L\'heure de fin doit être après l\'heure de début');
        }
        
        // Créer ou mettre à jour la session
        final createSessionUseCase = ref.read(createSessionUseCaseProvider);
        
        await createSessionUseCase(
          course: _course,
          roomId: _selectedRoomId!,
          classId: _selectedClassId!,
          start: startDateTime,
          end: endDateTime,
        );
        
        // Si tout va bien, revenir à l'écran précédent
        if (mounted) {
          Navigator.of(context).pop();
          
          // Recharger les sessions
          ref.invalidate(weeklySessionsProvider);
        }
      } catch (e) {
        setState(() {
          _errorMessage = 'Erreur: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }
} 