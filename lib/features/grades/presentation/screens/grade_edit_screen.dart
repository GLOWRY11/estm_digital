import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/grade_service.dart';
import 'dart:developer' as developer;

class GradeEditScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> initialGrade;
  final String studentName;

  const GradeEditScreen({
    super.key,
    required this.initialGrade,
    required this.studentName,
  });

  @override
  _GradeEditScreenState createState() => _GradeEditScreenState();
}

class _GradeEditScreenState extends ConsumerState<GradeEditScreen> {
  late TextEditingController _midtermController;
  late TextEditingController _finalController;
  late TextEditingController _commentController;
  double _average = 0;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _midtermController = TextEditingController(
      text: widget.initialGrade['midterm'].toString(),
    );
    _finalController = TextEditingController(
      text: widget.initialGrade['final'].toString(),
    );
    _commentController = TextEditingController(
      text: widget.initialGrade['comment'] as String? ?? '',
    );
    _calculateAverage();
  }

  @override
  void dispose() {
    _midtermController.dispose();
    _finalController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  void _calculateAverage() {
    try {
      final midterm = double.parse(_midtermController.text);
      final final_ = double.parse(_finalController.text);
      setState(() {
        _average = (midterm + final_) / 2;
      });
    } catch (e) {
      setState(() {
        _average = 0;
      });
    }
  }

  Future<void> _saveGrade() async {
    setState(() {
      _isSaving = true;
    });

    try {
      final midterm = double.parse(_midtermController.text);
      final final_ = double.parse(_finalController.text);
      final comment = _commentController.text.trim();

      // Validation des notes
      if (midterm < 0 || midterm > 20) {
        throw Exception('La note partiel doit être entre 0 et 20');
      }
      if (final_ < 0 || final_ > 20) {
        throw Exception('La note finale doit être entre 0 et 20');
      }

      // Rechercher l'ID de la note avec différentes clés possibles
      final gradeId = widget.initialGrade['id'] ?? 
                     widget.initialGrade['gradeId'] ?? 
                     widget.initialGrade['evaluationId'] ??
                     widget.initialGrade['uuid'];
      
      if (gradeId == null) {
        // Si aucun ID n'est trouvé, créer un nouvel ID
        final now = DateTime.now().millisecondsSinceEpoch.toString();
        final tempId = 'grade_${now}_${widget.studentName.replaceAll(' ', '_')}';
        developer.log('Aucun ID trouvé, création d\'un ID temporaire: $tempId');
        
        // Essayer de créer une nouvelle note au lieu de la mettre à jour
        final studentId = widget.initialGrade['studentId']?.toString() ?? 
                         widget.initialGrade['etudiantId']?.toString() ?? 
                         'unknown_student';
        
        final success = await GradeService.insertGrade(
          studentId: studentId,
          courseId: widget.initialGrade['courseId']?.toString() ?? 'unknown',
          courseTitle: widget.initialGrade['courseTitle']?.toString() ?? 'Cours',
          semester: widget.initialGrade['semester']?.toString() ?? 'S1',
          midterm: midterm,
          final_: final_,
          comment: comment.isEmpty ? null : comment,
        );
        
        if (success.isNotEmpty) {
          // Mise à jour réussie via insertion
          final updatedGrade = Map<String, dynamic>.from(widget.initialGrade);
          updatedGrade['id'] = success;
          updatedGrade['midterm'] = midterm;
          updatedGrade['final'] = final_;
          updatedGrade['average'] = _average;
          updatedGrade['comment'] = comment;
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Note créée avec succès'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pop(updatedGrade);
          }
          return;
        } else {
          throw Exception('Impossible de créer la note');
        }
      }

      // Mettre à jour la note via le service
      final success = await GradeService.updateGrade(
        gradeId: gradeId.toString(),
        midterm: midterm,
        final_: final_,
        comment: comment.isEmpty ? null : comment,
      );

      if (!success) {
        throw Exception('Aucune modification détectée');
      }

      // Créer les nouvelles données à retourner
      final updatedGrade = Map<String, dynamic>.from(widget.initialGrade);
      updatedGrade['midterm'] = midterm;
      updatedGrade['final'] = final_;
      updatedGrade['average'] = _average;
      updatedGrade['comment'] = comment;

      if (mounted) {
        // Afficher un message de succès
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Note mise à jour avec succès'),
            backgroundColor: Colors.green,
          ),
        );

        // Retourner les données mises à jour
        Navigator.of(context).pop(updatedGrade);
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
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Éditer les notes - ${widget.studentName}'),
        backgroundColor: theme.colorScheme.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.initialGrade['courseTitle'] as String,
                      style: theme.textTheme.titleLarge,
                    ),
                    Text(
                      widget.initialGrade['semester'] as String,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Notes',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _midtermController,
                    decoration: const InputDecoration(
                      labelText: 'Note partiel',
                      helperText: 'Sur 20',
                    ),
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    onChanged: (_) => _calculateAverage(),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _finalController,
                    decoration: const InputDecoration(
                      labelText: 'Note finale',
                      helperText: 'Sur 20',
                    ),
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    onChanged: (_) => _calculateAverage(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Card(
              color: theme.colorScheme.primary.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Moyenne calculée:'),
                    Text(
                      _average.toStringAsFixed(2),
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: _getGradeColor(_average),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Commentaire',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _commentController,
              decoration: const InputDecoration(
                hintText: 'Saisir un commentaire pour l\'étudiant',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveGrade,
                child: _isSaving
                    ? const CircularProgressIndicator()
                    : const Text('Enregistrer les modifications'),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Color _getGradeColor(double grade) {
    if (grade >= 16) {
      return Colors.green;
    } else if (grade >= 14) {
      return Colors.lightGreen;
    } else if (grade >= 12) {
      return Colors.orange;
    } else if (grade >= 10) {
      return Colors.amber;
    } else {
      return Colors.red;
    }
  }
} 