import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/grade_entity.dart';

// Note: Ce fichier est actuellement simplifié car nous utilisons des données simulées.
// Dans une implémentation complète, il y aurait des providers connectés à un repository
// qui interagirait avec la base de données.

// Provider pour stocker les notes (pas encore implémenté avec la base de données)
final gradesProvider = FutureProvider<List<GradeEntity>>((ref) async {
  // Ceci serait remplacé par un appel à un repository
  await Future.delayed(const Duration(milliseconds: 500)); // Simulation d'un délai
  return [];
});

// Provider pour filtrer les notes par cours
final courseGradesProvider = FutureProvider.family<List<GradeEntity>, String>((ref, courseId) async {
  // Ceci serait remplacé par un appel à un repository avec filtrage
  await Future.delayed(const Duration(milliseconds: 500)); // Simulation d'un délai
  return [];
});

// Provider pour filtrer les notes par étudiant
final studentGradesProvider = FutureProvider.family<List<GradeEntity>, String>((ref, studentId) async {
  // Ceci serait remplacé par un appel à un repository avec filtrage
  await Future.delayed(const Duration(milliseconds: 500)); // Simulation d'un délai
  return [];
}); 