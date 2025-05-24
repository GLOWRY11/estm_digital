import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/user_management_providers.dart';

class StudentDetailScreen extends ConsumerWidget {
  final String studentId;

  const StudentDetailScreen({
    super.key,
    required this.studentId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentAsync = ref.watch(FutureProvider((ref) {
      final repository = ref.watch(userRepositoryProvider);
      return repository.getUserById(studentId);
    }));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Détail de l\'étudiant'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // TODO: Navigate to Edit Student screen
            },
          ),
        ],
      ),
      body: studentAsync.when(
        data: (student) {
          if (student == null) {
            return const Center(
              child: Text('Étudiant non trouvé'),
            );
          }
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.blue.shade100,
                    backgroundImage: student.profileImageUrl != null
                        ? NetworkImage(student.profileImageUrl!)
                        : null,
                    child: student.profileImageUrl == null
                        ? Text(
                            student.displayName?.substring(0, 1).toUpperCase() ??
                                student.email.substring(0, 1).toUpperCase(),
                            style: const TextStyle(fontSize: 40),
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 24),
                _buildInfoCard(
                  context,
                  'Informations personnelles',
                  [
                    _buildInfoRow('Nom', student.displayName ?? 'Non spécifié'),
                    _buildInfoRow('Email', student.email),
                    _buildInfoRow('Téléphone', student.phoneNumber ?? 'Non spécifié'),
                    _buildInfoRow('Adresse', student.address ?? 'Non spécifiée'),
                    _buildInfoRow(
                      'Date de naissance',
                      student.dateOfBirth != null
                          ? '${student.dateOfBirth!.day}/${student.dateOfBirth!.month}/${student.dateOfBirth!.year}'
                          : 'Non spécifiée',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildInfoCard(
                  context,
                  'Informations académiques',
                  [
                    _buildInfoRow('Matricule', student.studentId?.toString() ?? 'Non spécifié'),
                    _buildInfoRow('Statut', student.isActive ? 'Actif' : 'Inactif'),
                    _buildFutureClassInfo(context, ref, student.classId),
                  ],
                ),
                const SizedBox(height: 16),
                _buildInfoCard(
                  context,
                  'Informations système',
                  [
                    _buildInfoRow('ID', student.uid),
                    _buildInfoRow(
                      'Créé le',
                      '${student.createdAt.day}/${student.createdAt.month}/${student.createdAt.year}',
                    ),
                    if (student.lastModifiedAt != null)
                      _buildInfoRow(
                        'Dernière modification',
                        '${student.lastModifiedAt!.day}/${student.lastModifiedAt!.month}/${student.lastModifiedAt!.year}',
                      ),
                  ],
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Text('Erreur: $error'),
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, String title, List<Widget> children) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildFutureClassInfo(BuildContext context, WidgetRef ref, String? classId) {
    if (classId == null) {
      return _buildInfoRow('Classe', 'Non spécifiée');
    }

    final classAsync = ref.watch(FutureProvider((ref) {
      final repository = ref.watch(userRepositoryProvider);
      return repository.getClasses().then(
            (classes) => classes.firstWhere(
              (c) => c.id == classId,
              orElse: () => throw Exception('Classe non trouvée'),
            ),
          );
    }));

    return classAsync.when(
      data: (classEntity) => _buildInfoRow('Classe', classEntity.name),
      loading: () => _buildInfoRow('Classe', 'Chargement...'),
      error: (_, __) => _buildInfoRow('Classe', 'Non trouvée'),
    );
  }
} 