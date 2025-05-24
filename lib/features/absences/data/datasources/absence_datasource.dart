import 'dart:developer' as developer;
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/local_database.dart';
import '../models/absence_model.dart';

class AbsenceDataSource {
  final _uuid = const Uuid();

  Future<void> markAbsence({
    required String studentId,
    required DateTime date,
    required String time,
    String status = 'offline',
  }) async {
    try {
      final db = await LocalDatabase.open();
      final id = _uuid.v4();
      
      final absence = AbsenceModel(
        id: id,
        studentId: studentId,
        date: date,
        time: time,
        status: status,
      );
      
      await db.insert(
        'absences',
        absence.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      
      developer.log('Absence enregistrée: $id pour l\'étudiant $studentId');
    } catch (e) {
      developer.log('Erreur lors de l\'enregistrement de l\'absence: $e');
      throw Exception('Échec de l\'enregistrement de l\'absence: $e');
    }
  }

  Future<List<AbsenceModel>> getAbsencesByStudent(String studentId) async {
    try {
      final db = await LocalDatabase.open();
      final List<Map<String, dynamic>> maps = await db.query(
        'absences',
        where: 'studentId = ?',
        whereArgs: [studentId],
        orderBy: 'date DESC, time DESC',
      );

      final absences = List.generate(maps.length, (i) {
        return AbsenceModel.fromMap(maps[i]);
      });
      
      developer.log('${absences.length} absences récupérées pour l\'étudiant: $studentId');
      return absences;
    } catch (e) {
      developer.log('Erreur lors de la récupération des absences: $e');
      throw Exception('Échec de la récupération des absences: $e');
    }
  }

  Future<List<AbsenceModel>> getAbsencesByDate(DateTime date) async {
    try {
      final db = await LocalDatabase.open();
      final dateStr = date.toIso8601String().split('T')[0];
      
      final List<Map<String, dynamic>> maps = await db.query(
        'absences',
        where: 'date LIKE ?',
        whereArgs: ['$dateStr%'],
        orderBy: 'time DESC',
      );

      final absences = List.generate(maps.length, (i) {
        return AbsenceModel.fromMap(maps[i]);
      });
      
      developer.log('${absences.length} absences récupérées pour la date: $dateStr');
      return absences;
    } catch (e) {
      developer.log('Erreur lors de la récupération des absences: $e');
      throw Exception('Échec de la récupération des absences: $e');
    }
  }
  
  Future<void> updateAbsenceStatus(String id, String status) async {
    try {
      final db = await LocalDatabase.open();
      
      await db.update(
        'absences',
        {'status': status},
        where: 'id = ?',
        whereArgs: [id],
      );
      
      developer.log('Statut de l\'absence mis à jour: $id -> $status');
    } catch (e) {
      developer.log('Erreur lors de la mise à jour du statut de l\'absence: $e');
      throw Exception('Échec de la mise à jour du statut de l\'absence: $e');
    }
  }
  
  Future<void> syncAbsences() async {
    try {
      final db = await LocalDatabase.open();
      
      await db.update(
        'absences',
        {'status': 'synced'},
        where: 'status = ?',
        whereArgs: ['offline'],
      );
      
      developer.log('Synchronisation des absences terminée');
    } catch (e) {
      developer.log('Erreur lors de la synchronisation des absences: $e');
      throw Exception('Échec de la synchronisation des absences: $e');
    }
  }
} 