import '../entities/absence_entity.dart';

abstract class AbsenceRepository {
  Future<void> markAbsence({
    required String studentId,
    required DateTime date,
    required String time,
    String status = 'offline',
  });
  
  Future<List<AbsenceEntity>> getAbsencesByStudent(String studentId);
  
  Future<List<AbsenceEntity>> getAbsencesByDate(DateTime date);
  
  Future<void> updateAbsenceStatus(String id, String status);
  
  Future<void> syncAbsences();
} 