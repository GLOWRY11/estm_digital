import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/user_management_providers.dart';
import 'student_detail_screen.dart';

class StudentListScreen extends ConsumerWidget {
  final String classId;
  final String className;

  const StudentListScreen({
    super.key,
    required this.classId,
    required this.className,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentsAsync = ref.watch(studentsByClassProvider(classId));

    return Scaffold(
      appBar: AppBar(
        title: Text('Étudiants - $className'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // TODO: Navigate to Add Student screen
            },
          ),
        ],
      ),
      body: studentsAsync.when(
        data: (students) {
          if (students.isEmpty) {
            return const Center(
              child: Text('Aucun étudiant dans cette classe'),
            );
          }
          
          return ListView.builder(
            itemCount: students.length,
            itemBuilder: (context, index) {
              final student = students[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.shade100,
                    child: Text(
                      student.displayName?.substring(0, 1).toUpperCase() ?? 
                      student.email.substring(0, 1).toUpperCase(),
                    ),
                  ),
                  title: Text(student.displayName ?? student.email),
                  subtitle: Text(student.email),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          // TODO: Navigate to Edit Student screen
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          student.isActive ? Icons.delete : Icons.restore,
                          color: student.isActive ? Colors.red : Colors.green,
                        ),
                        onPressed: () {
                          _confirmActionDialog(
                            context,
                            student.isActive ? 'Désactiver' : 'Réactiver',
                            'Voulez-vous ${student.isActive ? 'désactiver' : 'réactiver'} cet étudiant?',
                            () {
                              if (student.isActive) {
                                ref.read(userFormNotifierProvider.notifier).deleteUser(student.uid);
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
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => StudentDetailScreen(
                          studentId: student.uid,
                        ),
                      ),
                    );
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
          // TODO: Navigate to Add Student screen
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