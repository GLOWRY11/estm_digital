import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/entities/absence_entity.dart';
import '../providers/absence_providers.dart';
import '../../../../core/routes/app_routes.dart';

class AbsencesListScreen extends ConsumerWidget {
  static const routeName = '/absences-list';

  const AbsencesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Liste des absences'),
        backgroundColor: theme.colorScheme.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(studentAbsencesProvider);
            },
          ),
        ],
      ),
      body: currentUser == null
          ? const Center(
              child: Text('Vous devez être connecté pour voir les absences'),
            )
          : _buildAbsencesList(context, ref, currentUser, theme),
      floatingActionButton: currentUser?.role == 'teacher'
          ? FloatingActionButton(
              onPressed: () {
                Navigator.of(context).pushNamed(AppRoutes.qrScanner);
              },
              tooltip: 'Scanner QR Code',
              child: const Icon(Icons.qr_code_scanner),
            )
          : null,
    );
  }

  Widget _buildAbsencesList(BuildContext context, WidgetRef ref, User user, ThemeData theme) {
    final absences = ref.watch(studentAbsencesProvider(user.id));

    return absences.when(
      data: (List<AbsenceEntity> absencesList) {
        if (absencesList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  size: 64,
                  color: Colors.green,
                ),
                const SizedBox(height: 16),
                Text(
                  'Aucune absence enregistrée',
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  user.role == 'student'
                      ? 'Vous êtes à jour dans vos présences'
                      : 'Aucun étudiant absent pour le moment',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: absencesList.length,
          itemBuilder: (context, index) {
            final absence = absencesList[index];
            final date = DateFormat('dd/MM/yyyy').format(absence.date);
            
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: absence.status == 'synced'
                      ? Colors.green
                      : Colors.orange,
                  child: Icon(
                    absence.status == 'synced'
                        ? Icons.cloud_done
                        : Icons.cloud_off,
                    color: Colors.white,
                  ),
                ),
                title: Text('Présence enregistrée'),
                subtitle: Text('Date: $date à ${absence.time}'),
                trailing: Chip(
                  label: Text(
                    absence.status == 'synced' ? 'Synchronisé' : 'Hors ligne',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                  backgroundColor: absence.status == 'synced'
                      ? Colors.green
                      : Colors.orange,
                ),
                onTap: () {
                  // Afficher les détails de l'absence
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Détails de la présence'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Date: $date'),
                          Text('Heure: ${absence.time}'),
                          Text('Statut: ${absence.status == 'synced' ? 'Synchronisé' : 'Hors ligne'}'),
                          Text('ID Étudiant: ${absence.studentId}'),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Fermer'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Erreur: $error'),
      ),
    );
  }
} 