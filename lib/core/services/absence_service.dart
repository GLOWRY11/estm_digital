import 'dart:convert';
import 'package:uuid/uuid.dart';
import '../local_database.dart';

class AbsenceService {
  static const _uuid = Uuid();

  // Insérer un enregistrement d'absence
  static Future<String> insertAbsenceRecord({
    required String etudiantId,
    required String teacherId,
    String? courseId,
    required bool isPresent,
    required DateTime date,
    required String startTime,
    required String endTime,
    String? qrCodeData,
    String? notes,
  }) async {
    try {
      final db = await LocalDatabase.open();
      final absenceId = DateTime.now().millisecondsSinceEpoch;
      final now = DateTime.now().toIso8601String();

      await db.insert('absences', {
        'id': absenceId,
        'etudiantId': etudiantId,
        'teacherId': teacherId,
        'courseId': courseId,
        'isPresent': isPresent ? 1 : 0,
        'date': date.toIso8601String().substring(0, 10), // YYYY-MM-DD
        'startTime': startTime,
        'endTime': endTime,
        'qrCodeData': qrCodeData,
        'notes': notes,
        'createdAt': now,
      });

      return absenceId.toString();
    } catch (e) {
      throw Exception('Erreur lors de l\'enregistrement d\'absence: $e');
    }
  }

  // Générer un QR code pour une session
  static String generateQRCodeData({
    required String sessionId,
    required DateTime date,
    required String teacherId,
    String? courseId,
  }) {
    final qrData = {
      'sessionId': sessionId,
      'date': date.toIso8601String().substring(0, 10),
      'teacherId': teacherId,
      'courseId': courseId,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    return jsonEncode(qrData);
  }

  // Traiter un scan de QR code
  static Future<Map<String, dynamic>> processQRCodeScan({
    required String qrCodeData,
    required String etudiantId,
  }) async {
    try {
      final data = jsonDecode(qrCodeData) as Map<String, dynamic>;
      final sessionId = data['sessionId'] as String;
      final teacherId = data['teacherId'] as String;
      final date = DateTime.parse(data['date'] as String);
      final courseId = data['courseId'] as String?;
      final qrTimestamp = data['timestamp'] as int;

      // Vérifier si le QR code est encore valide (1 heure max)
      final now = DateTime.now().millisecondsSinceEpoch;
      final hourInMs = 60 * 60 * 1000;
      
      if (now - qrTimestamp > hourInMs) {
        return {
          'success': false,
          'message': 'QR Code expiré',
        };
      }

      // Vérifier si l'étudiant n'a pas déjà scanné pour cette session
      final db = await LocalDatabase.open();
      final existing = await db.query(
        'absences',
        where: 'etudiantId = ? AND teacherId = ? AND date = ? AND qrCodeData = ?',
        whereArgs: [etudiantId, teacherId, date.toIso8601String().substring(0, 10), qrCodeData],
      );

      if (existing.isNotEmpty) {
        return {
          'success': false,
          'message': 'Présence déjà enregistrée pour cette session',
        };
      }

      // Enregistrer la présence
      final absenceId = await insertAbsenceRecord(
        etudiantId: etudiantId,
        teacherId: teacherId,
        courseId: courseId,
        isPresent: true,
        date: date,
        startTime: '08:00', // À adapter selon le QR code
        endTime: '10:00',   // À adapter selon le QR code
        qrCodeData: qrCodeData,
        notes: 'Présence enregistrée via QR Code',
      );

      return {
        'success': true,
        'message': 'Présence enregistrée avec succès',
        'absenceId': absenceId,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur lors du traitement du QR Code: $e',
      };
    }
  }

  // Récupérer les absences d'un étudiant
  static Future<List<Map<String, dynamic>>> getStudentAbsences({
    required String etudiantId,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    try {
      final db = await LocalDatabase.open();
      
      String whereClause = 'etudiantId = ?';
      List<dynamic> whereArgs = [etudiantId];

      if (startDate != null) {
        whereClause += ' AND date >= ?';
        whereArgs.add(startDate.toIso8601String().substring(0, 10));
      }

      if (endDate != null) {
        whereClause += ' AND date <= ?';
        whereArgs.add(endDate.toIso8601String().substring(0, 10));
      }

      final result = await db.query(
        'absences',
        where: whereClause,
        whereArgs: whereArgs,
        orderBy: 'date DESC, startTime DESC',
        limit: limit,
      );

      return result;
    } catch (e) {
      throw Exception('Erreur lors de la récupération des absences: $e');
    }
  }

  // Récupérer les absences pour un enseignant
  static Future<List<Map<String, dynamic>>> getTeacherAbsences({
    required String teacherId,
    DateTime? date,
    String? courseId,
  }) async {
    try {
      final db = await LocalDatabase.open();
      
      String whereClause = 'teacherId = ?';
      List<dynamic> whereArgs = [teacherId];

      if (date != null) {
        whereClause += ' AND date = ?';
        whereArgs.add(date.toIso8601String().substring(0, 10));
      }

      if (courseId != null) {
        whereClause += ' AND courseId = ?';
        whereArgs.add(courseId);
      }

      final result = await db.query(
        'absences',
        where: whereClause,
        whereArgs: whereArgs,
        orderBy: 'date DESC, startTime ASC',
      );

      return result;
    } catch (e) {
      throw Exception('Erreur lors de la récupération des absences: $e');
    }
  }

  // Statistiques d'absence pour un étudiant
  static Future<Map<String, dynamic>> getStudentAbsenceStats(String etudiantId) async {
    try {
      final db = await LocalDatabase.open();
      
      final total = await db.rawQuery(
        'SELECT COUNT(*) as count FROM absences WHERE etudiantId = ?',
        [etudiantId],
      );
      
      final present = await db.rawQuery(
        'SELECT COUNT(*) as count FROM absences WHERE etudiantId = ? AND isPresent = 1',
        [etudiantId],
      );
      
      final absent = await db.rawQuery(
        'SELECT COUNT(*) as count FROM absences WHERE etudiantId = ? AND isPresent = 0',
        [etudiantId],
      );

      final totalCount = total.first['count'] as int;
      final presentCount = present.first['count'] as int;
      final absentCount = absent.first['count'] as int;

      return {
        'total': totalCount,
        'present': presentCount,
        'absent': absentCount,
        'attendanceRate': totalCount > 0 ? (presentCount / totalCount * 100) : 0.0,
      };
    } catch (e) {
      throw Exception('Erreur lors du calcul des statistiques: $e');
    }
  }

  // Marquer manuellement l'absence/présence
  static Future<bool> markAttendance({
    required String etudiantId,
    required String teacherId,
    required DateTime date,
    required bool isPresent,
    String? courseId,
    String? notes,
  }) async {
    try {
      await insertAbsenceRecord(
        etudiantId: etudiantId,
        teacherId: teacherId,
        courseId: courseId,
        isPresent: isPresent,
        date: date,
        startTime: DateTime.now().toIso8601String().substring(11, 16), // HH:MM
        endTime: DateTime.now().add(const Duration(hours: 2)).toIso8601String().substring(11, 16),
        notes: notes ?? (isPresent ? 'Présent (manuel)' : 'Absent (manuel)'),
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  // Mettre à jour un enregistrement d'absence
  static Future<bool> updateAbsence({
    required int absenceId,
    bool? isPresent,
    String? notes,
  }) async {
    try {
      final db = await LocalDatabase.open();
      final updates = <String, dynamic>{};

      if (isPresent != null) {
        updates['isPresent'] = isPresent ? 1 : 0;
      }

      if (notes != null) {
        updates['notes'] = notes;
      }

      if (updates.isEmpty) return false;

      final result = await db.update(
        'absences',
        updates,
        where: 'id = ?',
        whereArgs: [absenceId],
      );

      return result > 0;
    } catch (e) {
      return false;
    }
  }

  // Supprimer un enregistrement d'absence
  static Future<bool> deleteAbsence(int absenceId) async {
    try {
      final db = await LocalDatabase.open();
      final result = await db.delete(
        'absences',
        where: 'id = ?',
        whereArgs: [absenceId],
      );
      return result > 0;
    } catch (e) {
      return false;
    }
  }

  // Récupérer les absences par plage de dates
  static Future<List<Map<String, dynamic>>> getAbsencesByDateRange({
    required DateTime startDate,
    required DateTime endDate,
    String? teacherId,
    String? etudiantId,
  }) async {
    try {
      final db = await LocalDatabase.open();
      
      String whereClause = 'date >= ? AND date <= ?';
      List<dynamic> whereArgs = [
        startDate.toIso8601String().substring(0, 10),
        endDate.toIso8601String().substring(0, 10),
      ];

      if (teacherId != null) {
        whereClause += ' AND teacherId = ?';
        whereArgs.add(teacherId);
      }

      if (etudiantId != null) {
        whereClause += ' AND etudiantId = ?';
        whereArgs.add(etudiantId);
      }

      final result = await db.query(
        'absences',
        where: whereClause,
        whereArgs: whereArgs,
        orderBy: 'date ASC, startTime ASC',
      );

      return result;
    } catch (e) {
      throw Exception('Erreur lors de la récupération par dates: $e');
    }
  }
} 