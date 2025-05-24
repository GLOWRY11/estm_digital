import 'dart:developer' as developer;
import '../../domain/entities/absence_entity.dart';
import '../../domain/repositories/absence_repository.dart';
import '../datasources/absence_datasource.dart';

class AbsenceRepositoryImpl implements AbsenceRepository {
  final AbsenceDataSource _dataSource;

  AbsenceRepositoryImpl({
    required AbsenceDataSource dataSource,
  }) : _dataSource = dataSource;

  @override
  Future<void> markAbsence({
    required String studentId,
    required DateTime date,
    required String time,
    String status = 'offline',
  }) async {
    try {
      await _dataSource.markAbsence(
        studentId: studentId,
        date: date,
        time: time,
        status: status,
      );
    } catch (e) {
      developer.log('Erreur lors de l\'enregistrement de l\'absence: $e');
      throw Exception('Échec de l\'enregistrement de l\'absence: $e');
    }
  }

  @override
  Future<List<AbsenceEntity>> getAbsencesByStudent(String studentId) async {
    try {
      return await _dataSource.getAbsencesByStudent(studentId);
    } catch (e) {
      developer.log('Erreur lors de la récupération des absences: $e');
      throw Exception('Échec de la récupération des absences: $e');
    }
  }

  @override
  Future<List<AbsenceEntity>> getAbsencesByDate(DateTime date) async {
    try {
      return await _dataSource.getAbsencesByDate(date);
    } catch (e) {
      developer.log('Erreur lors de la récupération des absences: $e');
      throw Exception('Échec de la récupération des absences: $e');
    }
  }

  @override
  Future<void> updateAbsenceStatus(String id, String status) async {
    try {
      await _dataSource.updateAbsenceStatus(id, status);
    } catch (e) {
      developer.log('Erreur lors de la mise à jour du statut de l\'absence: $e');
      throw Exception('Échec de la mise à jour du statut de l\'absence: $e');
    }
  }

  @override
  Future<void> syncAbsences() async {
    try {
      await _dataSource.syncAbsences();
    } catch (e) {
      developer.log('Erreur lors de la synchronisation des absences: $e');
      throw Exception('Échec de la synchronisation des absences: $e');
    }
  }
} 