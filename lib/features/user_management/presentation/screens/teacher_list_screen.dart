import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/user_management_providers.dart';

class TeacherListScreen extends ConsumerWidget {
  const TeacherListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teachersAsync = ref.watch(teachersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Enseignants'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // TODO: Navigate to Add Teacher screen
            },
          ),
        ],
      ),
      body: teachersAsync.when(
        data: (teachers) {
          if (teachers.isEmpty) {
            return const Center(
              child: Text('Aucun enseignant trouvé'),
            );
          }
          
          return ListView.builder(
            itemCount: teachers.length,
            itemBuilder: (context, index) {
              final teacher = teachers[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.shade100,
                    child: Text(
                      teacher.displayName?.substring(0, 1).toUpperCase() ?? 
                      teacher.email.substring(0, 1).toUpperCase(),
                    ),
                  ),
                  title: Text(teacher.displayName ?? teacher.email),
                  subtitle: Row(
                    children: [
                      Expanded(child: Text(teacher.email)),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: teacher.isActive ? Colors.green.shade100 : Colors.red.shade100,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          teacher.isActive ? 'Actif' : 'Inactif',
                          style: TextStyle(
                            color: teacher.isActive ? Colors.green.shade800 : Colors.red.shade800,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          // TODO: Navigate to Edit Teacher screen
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          teacher.isActive ? Icons.delete : Icons.restore,
                          color: teacher.isActive ? Colors.red : Colors.green,
                        ),
                        onPressed: () {
                          _confirmActionDialog(
                            context,
                            teacher.isActive ? 'Désactiver' : 'Réactiver',
                            'Voulez-vous ${teacher.isActive ? 'désactiver' : 'réactiver'} cet enseignant?',
                            () {
                              if (teacher.isActive) {
                                ref.read(userFormNotifierProvider.notifier).deleteUser(teacher.uid);
                              } else {
                                // TODO: Implement reactivate user
                              }
                              Navigator.of(context).pop();
                            },
                          );
                        },
                      ),
                    ],
                  ),
                  onTap: () {
                    // TODO: Navigate to Teacher Detail screen
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Text('Erreur: $error'),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to Add Teacher screen
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _confirmActionDialog(
    BuildContext context,
    String title,
    String content,
    VoidCallback onConfirm,
  ) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: onConfirm,
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
  }
} 