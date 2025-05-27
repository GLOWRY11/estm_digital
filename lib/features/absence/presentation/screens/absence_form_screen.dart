import 'package:flutter/material.dart';
import 'package:estm_digital/features/absence/domain/absence_model.dart';
import 'package:estm_digital/features/absence/data/absence_service.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';

class AbsenceFormScreen extends StatefulWidget {
  final Absence? absence;

  const AbsenceFormScreen({super.key, this.absence});

  @override
  _AbsenceFormScreenState createState() => _AbsenceFormScreenState();
}

class _AbsenceFormScreenState extends State<AbsenceFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _qrKey = GlobalKey();
  final _absenceService = AbsenceService();
  
  bool _isPresent = true;
  late DateTime _date;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  bool _showQrOption = false;
  
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
              
              // Option pour afficher/masquer le QR code
              if (!_showQrOption)
                OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      _showQrOption = true;
                    });
                  },
                  icon: const Icon(Icons.qr_code),
                  label: const Text('Afficher QR Code'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              
              // QR Code et bouton de partage
              if (_showQrOption) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Text(
                          'QR Code de l\'absence',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        RepaintBoundary(
                          key: _qrKey,
                          child: Container(
                            color: Colors.white,
                            padding: const EdgeInsets.all(16),
                            child: QrImageView(
                              data: _generateQrData(),
                              version: QrVersions.auto,
                              size: 200.0,
                              backgroundColor: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _shareQrCode,
                                icon: const Icon(Icons.share),
                                label: const Text('Partager QR'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  setState(() {
                                    _showQrOption = false;
                                  });
                                },
                                icon: const Icon(Icons.close),
                                label: const Text('Masquer'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              
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

  String _generateQrData() {
    return jsonEncode({
      'type': 'absence_record',
      'etudiantId': int.tryParse(_etudiantIdController.text) ?? 0,
      'date': _dateController.text,
      'startTime': _startTimeController.text,
      'endTime': _endTimeController.text,
      'isPresent': _isPresent,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<void> _shareQrCode() async {
    try {
      // Capturer le widget QR en image
      RenderRepaintBoundary? boundary = _qrKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        throw Exception('QR Code non trouvé pour la capture');
      }

      // Convertir en image
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        throw Exception('Erreur lors de la conversion de l\'image');
      }

      Uint8List pngBytes = byteData.buffer.asUint8List();

      // Créer un fichier temporaire
      final Directory tempDir = await getTemporaryDirectory();
      final String fileName = 'qr_absence_${DateTime.now().millisecondsSinceEpoch}.png';
      final File tempFile = File('${tempDir.path}/$fileName');
      await tempFile.writeAsBytes(pngBytes);

      // Partager le fichier
      await Share.shareXFiles([XFile(tempFile.path)], 
        text: 'QR Code - Enregistrement d\'absence\nDate: ${_dateController.text}\nÉtudiant: ${_etudiantIdController.text}');

      // Afficher un message de succès
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('QR Code partagé avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du partage: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
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