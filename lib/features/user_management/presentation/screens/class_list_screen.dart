import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/user_management_providers.dart';
import 'student_list_screen.dart';

class ClassListScreen extends ConsumerWidget {
  const ClassListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final classesAsync = ref.watch(classesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Classes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // TODO: Navigate to Add Class screen
            },
          ),
        ],
      ),
      body: classesAsync.when(
        data: (classes) {
          if (classes.isEmpty) {
            return const Center(
              child: Text('Aucune classe trouvée'),
            );
          }
          
          return ListView.builder(
            itemCount: classes.length,
            itemBuilder: (context, index) {
              final classEntity = classes[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(classEntity.name),
                  subtitle: Text('${classEntity.description} - ${classEntity.year}'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    ref.read(selectedClassIdProvider.notifier).state = classEntity.id;
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => StudentListScreen(
                          classId: classEntity.id,
                          className: classEntity.name,
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
          // TODO: Navigate to Add Class screen
        },
        child: const Icon(Icons.add),
      ),
    );
  }
} 