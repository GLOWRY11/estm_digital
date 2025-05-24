import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GradeEditScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> initialGrade;
  final String studentName;

  const GradeEditScreen({
    Key? key,
    required this.initialGrade,
    required this.studentName,
  }) : super(key: key);

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
      text: widget.initialGrade['comment'] as String,
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
      // Simuler un délai de sauvegarde
      await Future.delayed(const Duration(seconds: 1));
      
      // En situation réelle, nous enregistrerions les modifications dans la base de données
      
      // Retourner les données modifiées
      Navigator.pop(context, {
        ...widget.initialGrade,
        'midterm': double.parse(_midtermController.text),
        'final': double.parse(_finalController.text),
        'average': _average,
        'comment': _commentController.text,
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
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