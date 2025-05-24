import 'package:flutter/material.dart';
import 'package:estm_digital/features/absence/domain/absence_model.dart';
import 'package:estm_digital/features/absence/data/absence_service.dart';
import 'package:intl/intl.dart';
import 'package:estm_digital/features/absence/presentation/screens/absence_form_screen.dart';

class AbsenceListScreen extends StatefulWidget {
  const AbsenceListScreen({Key? key}) : super(key: key);

  @override
  _AbsenceListScreenState createState() => _AbsenceListScreenState();
}

class _AbsenceListScreenState extends State<AbsenceListScreen> {
  final AbsenceService _absenceService = AbsenceService();
  late Future<List<Absence>> _absencesFuture;

  @override
  void initState() {
    super.initState();
    _refreshAbsences();
  }

  void _refreshAbsences() {
    setState(() {
      _absencesFuture = _absenceService.queryAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Liste des Absences'),
      ),
      body: FutureBuilder<List<Absence>>(
        future: _absencesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Erreur: ${snapshot.error}'),
            );
          }

          final absences = snapshot.data ?? [];

          if (absences.isEmpty) {
            return const Center(
              child: Text('Aucune absence enregistrée'),
            );
          }

          return ListView.builder(
            itemCount: absences.length,
            itemBuilder: (context, index) {
              final absence = absences[index];
              return AbsenceListItem(
                absence: absence,
                onEdit: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AbsenceFormScreen(absence: absence),
                    ),
                  );
                  _refreshAbsences();
                },
                onDelete: () async {
                  await _showDeleteConfirmation(absence);
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AbsenceFormScreen(),
            ),
          );
          _refreshAbsences();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _showDeleteConfirmation(Absence absence) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation'),
          content: const Text('Voulez-vous vraiment supprimer cette absence?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _absenceService.delete(absence.id!);
                _refreshAbsences();
              },
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );
  }
}

class AbsenceListItem extends StatelessWidget {
  final Absence absence;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const AbsenceListItem({
    Key? key,
    required this.absence,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final timeFormat = DateFormat('HH:mm');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Date: ${dateFormat.format(DateTime.parse(absence.date))}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: absence.isPresent ? Colors.green.shade100 : Colors.red.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    absence.isPresent ? 'Présent' : 'Absent',
                    style: TextStyle(
                      color: absence.isPresent ? Colors.green.shade800 : Colors.red.shade800,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (absence.startTime != null)
              Text('Heure de début: ${timeFormat.format(DateTime.parse(absence.startTime!))}'),
            if (absence.endTime != null)
              Text('Heure de fin: ${timeFormat.format(DateTime.parse(absence.endTime!))}'),
            Text('ID Étudiant: ${absence.etudiantId}'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: onEdit,
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: onDelete,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 