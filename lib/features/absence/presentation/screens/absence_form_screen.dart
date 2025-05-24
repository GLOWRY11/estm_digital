import 'package:flutter/material.dart';
import 'package:estm_digital/features/absence/domain/absence_model.dart';
import 'package:estm_digital/features/absence/data/absence_service.dart';
import 'package:intl/intl.dart';

class AbsenceFormScreen extends StatefulWidget {
  final Absence? absence;

  const AbsenceFormScreen({Key? key, this.absence}) : super(key: key);

  @override
  _AbsenceFormScreenState createState() => _AbsenceFormScreenState();
}

class _AbsenceFormScreenState extends State<AbsenceFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _absenceService = AbsenceService();
  
  bool _isPresent = true;
  late DateTime _date;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  
  final TextEditingController _etudiantIdController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    
    if (widget.absence != null) {
      // Mode édition
      _isPresent = widget.absence!.isPresent;
      _date = DateTime.parse(widget.absence!.date);
      _dateController.text = DateFormat('dd/MM/yyyy').format(_date);
      _etudiantIdController.text = widget.absence!.etudiantId.toString();
      
      if (widget.absence!.startTime != null) {
        _startTime = TimeOfDay.fromDateTime(DateTime.parse(widget.absence!.startTime!));
        _startTimeController.text = DateFormat('HH:mm').format(DateTime.parse(widget.absence!.startTime!));
      }
      
      if (widget.absence!.endTime != null) {
        _endTime = TimeOfDay.fromDateTime(DateTime.parse(widget.absence!.endTime!));
        _endTimeController.text = DateFormat('HH:mm').format(DateTime.parse(widget.absence!.endTime!));
      }
    } else {
      // Mode ajout
      _date = DateTime.now();
      _dateController.text = DateFormat('dd/MM/yyyy').format(_date);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.absence == null ? 'Nouvelle Absence' : 'Modifier Absence'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Statut de présence
              SwitchListTile(
                title: const Text('Statut de présence'),
                subtitle: Text(_isPresent ? 'Présent' : 'Absent'),
                value: _isPresent,
                activeColor: Colors.green,
                inactiveTrackColor: Colors.red.shade200,
                onChanged: (value) {
                  setState(() {
                    _isPresent = value;
                  });
                },
              ),
              
              const SizedBox(height: 16),
              
              // Date
              TextFormField(
                controller: _dateController,
                decoration: InputDecoration(
                  labelText: 'Date',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_month),
                    onPressed: _selectDate,
                  ),
                ),
                readOnly: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez sélectionner une date';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Heure de début
              TextFormField(
                controller: _startTimeController,
                decoration: InputDecoration(
                  labelText: 'Heure de début',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.access_time),
                    onPressed: () => _selectTime(true),
                  ),
                ),
                readOnly: true,
              ),
              
              const SizedBox(height: 16),
              
              // Heure de fin
              TextFormField(
                controller: _endTimeController,
                decoration: InputDecoration(
                  labelText: 'Heure de fin',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.access_time),
                    onPressed: () => _selectTime(false),
                  ),
                ),
                readOnly: true,
              ),
              
              const SizedBox(height: 16),
              
              // ID Étudiant
              TextFormField(
                controller: _etudiantIdController,
                decoration: const InputDecoration(
                  labelText: 'ID Étudiant',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer l\'ID de l\'étudiant';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Veuillez entrer un nombre valide';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 24),
              
              // Bouton de sauvegarde
              ElevatedButton(
                onPressed: _saveAbsence,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  widget.absence == null ? 'Ajouter' : 'Mettre à jour',
                  style: const TextStyle(fontSize: 16),
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
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    
    if (picked != null && picked != _date) {
      setState(() {
        _date = picked;
        _dateController.text = DateFormat('dd/MM/yyyy').format(_date);
      });
    }
  }

  Future<void> _selectTime(bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime 
          ? _startTime ?? TimeOfDay.now()
          : _endTime ?? TimeOfDay.now(),
    );
    
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _startTime = picked;
          // Convertir TimeOfDay en String
          final DateTime tempDate = DateTime(
            _date.year,
            _date.month,
            _date.day,
            picked.hour,
            picked.minute,
          );
          _startTimeController.text = DateFormat('HH:mm').format(tempDate);
        } else {
          _endTime = picked;
          // Convertir TimeOfDay en String
          final DateTime tempDate = DateTime(
            _date.year,
            _date.month,
            _date.day,
            picked.hour,
            picked.minute,
          );
          _endTimeController.text = DateFormat('HH:mm').format(tempDate);
        }
      });
    }
  }

  String? _getFormattedDateTime(DateTime date, TimeOfDay? time) {
    if (time == null) return null;
    
    final datetime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    
    return datetime.toIso8601String();
  }

  Future<void> _saveAbsence() async {
    if (_formKey.currentState!.validate()) {
      // Construire l'objet absence
      final absence = Absence(
        id: widget.absence?.id,
        isPresent: _isPresent,
        date: _date.toIso8601String(),
        startTime: _startTime != null ? _getFormattedDateTime(_date, _startTime) : null,
        endTime: _endTime != null ? _getFormattedDateTime(_date, _endTime) : null,
        etudiantId: int.parse(_etudiantIdController.text),
      );
      
      try {
        if (widget.absence == null) {
          // Ajouter une nouvelle absence
          await _absenceService.insert(absence);
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Absence ajoutée avec succès')),
          );
        } else {
          // Mettre à jour une absence existante
          await _absenceService.update(absence);
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Absence mise à jour avec succès')),
          );
        }
        // Retourner à l'écran précédent
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${e.toString()}')),
        );
      }
    }
  }

  @override
  void dispose() {
    _etudiantIdController.dispose();
    _dateController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    super.dispose();
  }
} 