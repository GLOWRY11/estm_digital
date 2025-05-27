import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/entities/absence_entity.dart';
import '../providers/absence_providers.dart';
import '../../../../core/routes/app_routes.dart';
import 'absence_entity_form_screen.dart';

class AbsencesListScreen extends ConsumerWidget {
  static const routeName = '/absences-list';

  const AbsencesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final theme = Theme.of(context);
    final isTeacher = currentUser?.role == 'teacher';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Liste des absences'),
        backgroundColor: theme.colorScheme.primary,
        actions: isTeacher ? [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(studentAbsencesProvider);
            },
          ),
        ] : [],
      ),
      body: currentUser == null
          ? const Center(
              child: Text('Vous devez être connecté pour voir les absences'),
            )
          : _buildAbsencesList(context, ref, currentUser, theme),
      floatingActionButton: isTeacher
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
      data: (absencesList) {
        if (absencesList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.event_busy,
                  size: 80,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'Aucune absence enregistrée',
                  style: theme.textTheme.titleLarge,
                ),
                if (user.role == 'teacher') ...[
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pushNamed(AppRoutes.qrScanner);
                    },
                    icon: const Icon(Icons.qr_code_scanner),
                    label: const Text('Scanner QR Code'),
                  ),
                ],
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: absencesList.length,
          itemBuilder: (context, index) {
            final absence = absencesList[index];
            return _buildAbsenceCard(context, ref, absence, theme, user.role == 'teacher');
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 80, color: Colors.red),
            const SizedBox(height: 16),
            Text('Erreur: ${error.toString()}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.refresh(studentAbsencesProvider(user.id)),
              child: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAbsenceCard(BuildContext context, WidgetRef ref, AbsenceEntity absence, ThemeData theme, bool isTeacher) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final isPresent = absence.status == 'synced';
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isPresent ? Colors.green : Colors.orange,
          child: Icon(
            isPresent ? Icons.check : Icons.cloud_off,
            color: Colors.white,
          ),
        ),
        title: Text(
          isPresent ? 'Présence Synchronisée' : 'En attente de synchronisation',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isPresent ? Colors.green : Colors.orange,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Date: ${dateFormat.format(absence.date)}'),
            Text('Heure: ${absence.time}'),
            Text('Statut: ${absence.status}'),
          ],
        ),
        trailing: isTeacher
            ? PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      _editAbsence(context, ref, absence);
                      break;
                    case 'delete':
                      _deleteAbsence(context, ref, absence);
                      break;
                    case 'sync':
                      _syncAbsence(context, ref, absence);
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit),
                        SizedBox(width: 8),
                        Text('Éditer'),
                      ],
                    ),
                  ),
                  if (!isPresent)
                    const PopupMenuItem(
                      value: 'sync',
                      child: Row(
                        children: [
                          Icon(Icons.cloud_upload),
                          SizedBox(width: 8),
                          Text('Synchroniser'),
                        ],
                      ),
                    ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete),
                        SizedBox(width: 8),
                        Text('Supprimer'),
                      ],
                    ),
                  ),
                ],
              )
            : null,
      ),
    );
  }

  // Méthodes d'action pour les absences
  void _editAbsence(BuildContext context, WidgetRef ref, AbsenceEntity absence) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => AbsenceEntityFormScreen(absence: absence),
      ),
    );
    
    if (result == true) {
      // Rafraîchir la liste des absences
      ref.invalidate(studentAbsencesProvider);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Absence modifiée avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  void _deleteAbsence(BuildContext context, WidgetRef ref, AbsenceEntity absence) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: const Text(
          'Êtes-vous sûr de vouloir supprimer cette absence ?\n\n'
          'Cette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        // Note: Implémenter deleteAbsence dans AbsenceDataSource si nécessaire
        await ref.read(absenceRepositoryProvider).updateAbsenceStatus(
          absence.id,
          'deleted',
        );
        
        // Rafraîchir la liste
        ref.invalidate(studentAbsencesProvider);
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Absence supprimée avec succès'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur lors de la suppression: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _syncAbsence(BuildContext context, WidgetRef ref, AbsenceEntity absence) async {
    if (absence.status == 'synced') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cette absence est déjà synchronisée'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      // Mettre à jour le statut à 'synced'
      await ref.read(absenceRepositoryProvider).updateAbsenceStatus(
        absence.id,
        'synced',
      );
      
      // Rafraîchir la liste
      ref.invalidate(studentAbsencesProvider);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Absence synchronisée avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la synchronisation: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
} 