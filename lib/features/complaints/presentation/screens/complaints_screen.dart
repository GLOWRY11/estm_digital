import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/complaints_provider.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/models/complaint.dart';

class ComplaintsScreen extends ConsumerStatefulWidget {
  static const String routeName = '/complaints';

  const ComplaintsScreen({super.key});

  @override
  ConsumerState<ComplaintsScreen> createState() => _ComplaintsScreenState();
}

class _ComplaintsScreenState extends ConsumerState<ComplaintsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _complaintController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _complaintController.dispose();
    super.dispose();
  }

  Future<void> _submitComplaint() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      final currentUser = ref.read(currentUserProvider);
      
      try {
        await ref.read(complaintsNotifierProvider.notifier).addComplaint(
          currentUser!.id,
          _complaintController.text,
        );

        _complaintController.clear();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Réclamation soumise avec succès')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur: ${e.toString()}')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final theme = Theme.of(context);
    
    // Si l'utilisateur est un administrateur ou un enseignant, il voit toutes les réclamations
    // Sinon, il ne voit que ses propres réclamations
    final isAdmin = currentUser?.role == 'admin' || currentUser?.role == 'teacher';
    final complaintsAsyncValue = ref.watch(complaintsProvider(isAdmin ? null : currentUser?.id));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Réclamations'),
        backgroundColor: theme.colorScheme.primary,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _complaintController,
                    decoration: const InputDecoration(
                      labelText: 'Votre réclamation',
                      hintText: 'Décrivez votre problème ou votre demande...',
                    ),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez saisir votre réclamation';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitComplaint,
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Soumettre'),
                  ),
                ],
              ),
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'Liste des réclamations',
              style: theme.textTheme.titleMedium,
            ),
          ),
          Expanded(
            child: complaintsAsyncValue.when(
              data: (complaints) {
                if (complaints.isEmpty) {
                  return const Center(
                    child: Text('Aucune réclamation trouvée'),
                  );
                }
                
                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: complaints.length,
                  itemBuilder: (context, index) {
                    final complaint = complaints[index];
                    return _buildComplaintCard(context, complaint, isAdmin);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text('Erreur: ${error.toString()}'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComplaintCard(BuildContext context, Complaint complaint, bool isAdmin) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  complaint.status == 'open' ? Icons.warning_amber : Icons.check_circle,
                  color: complaint.status == 'open' ? Colors.orange : Colors.green,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Statut: ${complaint.status == 'open' ? 'En attente' : 'Traitée'}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: complaint.status == 'open' ? Colors.orange : Colors.green,
                    ),
                  ),
                ),
                Text(
                  dateFormat.format(complaint.createdAt),
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
            const Divider(),
            Text(
              complaint.text,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (complaint.status == 'open' && isAdmin)
                  TextButton.icon(
                    icon: const Icon(Icons.check),
                    label: const Text('Marquer comme traité'),
                    onPressed: () async {
                      try {
                        await ref
                            .read(complaintsNotifierProvider.notifier)
                            .markAsHandled(complaint.id, complaint.userId);
                            
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Réclamation marquée comme traitée')),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Erreur: ${e.toString()}')),
                          );
                        }
                      }
                    },
                  ),
                const SizedBox(width: 8),
                TextButton.icon(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  label: const Text('Supprimer', style: TextStyle(color: Colors.red)),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Confirmer la suppression'),
                        content: const Text('Êtes-vous sûr de vouloir supprimer cette réclamation ?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Annuler'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text('Supprimer'),
                          ),
                        ],
                      ),
                    );
                    
                    if (confirm == true) {
                      try {
                        await ref
                            .read(complaintsNotifierProvider.notifier)
                            .deleteComplaint(complaint.id);
                            
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Réclamation supprimée')),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Erreur: ${e.toString()}')),
                          );
                        }
                      }
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 