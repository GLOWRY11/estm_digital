import 'package:uuid/uuid.dart';
import '../local_database.dart';

class GradeService {
  static const _uuid = Uuid();

  // Insérer une nouvelle note
  static Future<String> insertGrade({
    required String studentId,
    required String courseId,
    required String courseTitle,
    required String semester,
    required double midterm,
    required double final_,
    String? comment,
  }) async {
    try {
      final db = await LocalDatabase.open();
      final gradeId = _uuid.v4();
      final now = DateTime.now().toIso8601String();
      final average = (midterm + final_) / 2;

      await db.insert('grades', {
        'id': gradeId,
        'studentId': studentId,
        'courseId': courseId,
        'courseTitle': courseTitle,
        'semester': semester,
        'midterm': midterm,
        'final': final_,
        'average': average,
        'comment': comment,
        'createdAt': now,
      });

      return gradeId;
    } catch (e) {
      throw Exception('Erreur lors de la création de la note: $e');
    }
  }

  // Mettre à jour une note existante
  static Future<bool> updateGrade({
    required String gradeId,
    double? midterm,
    double? final_,
    String? comment,
  }) async {
    try {
      final db = await LocalDatabase.open();
      final updates = <String, dynamic>{};

      if (midterm != null) updates['midterm'] = midterm;
      if (final_ != null) updates['final'] = final_;
      if (comment != null) updates['comment'] = comment;

      if (updates.isEmpty) return false;

      // Recalculer la moyenne si les notes ont changé
      if (midterm != null || final_ != null) {
        // Récupérer les notes actuelles
        final currentGrade = await db.query(
          'grades',
          where: 'id = ?',
          whereArgs: [gradeId],
        );

        if (currentGrade.isNotEmpty) {
          final currentMidterm = midterm ?? (currentGrade.first['midterm'] as double);
          final currentFinal = final_ ?? (currentGrade.first['final'] as double);
          updates['average'] = (currentMidterm + currentFinal) / 2;
        }
      }

      updates['updatedAt'] = DateTime.now().toIso8601String();

      final result = await db.update(
        'grades',
        updates,
        where: 'id = ?',
        whereArgs: [gradeId],
      );

      return result > 0;
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour de la note: $e');
    }
  }

  // Récupérer toutes les notes
  static Future<List<Map<String, dynamic>>> getAllGrades() async {
    try {
      final db = await LocalDatabase.open();
      return await db.query(
        'grades',
        orderBy: 'createdAt DESC',
      );
    } catch (e) {
      throw Exception('Erreur lors de la récupération des notes: $e');
    }
  }

  // Récupérer les notes d'un étudiant
  static Future<List<Map<String, dynamic>>> getStudentGrades({
    required String studentId,
  }) async {
    try {
      final db = await LocalDatabase.open();
      return await db.query(
        'grades',
        where: 'studentId = ?',
        whereArgs: [studentId],
        orderBy: 'semester ASC, courseTitle ASC',
      );
    } catch (e) {
      throw Exception('Erreur lors de la récupération des notes: $e');
    }
  }

  // Récupérer les notes par cours
  static Future<List<Map<String, dynamic>>> getCourseGrades({
    required String courseId,
  }) async {
    try {
      final db = await LocalDatabase.open();
      return await db.query(
        'grades',
        where: 'courseId = ?',
        whereArgs: [courseId],
        orderBy: 'average DESC',
      );
    } catch (e) {
      throw Exception('Erreur lors de la récupération des notes du cours: $e');
    }
  }

  // Récupérer les notes par semestre
  static Future<List<Map<String, dynamic>>> getSemesterGrades({
    required String studentId,
    required String semester,
  }) async {
    try {
      final db = await LocalDatabase.open();
      return await db.query(
        'grades',
        where: 'studentId = ? AND semester = ?',
        whereArgs: [studentId, semester],
        orderBy: 'courseTitle ASC',
      );
    } catch (e) {
      throw Exception('Erreur lors de la récupération des notes du semestre: $e');
    }
  }

  // Calculer la moyenne générale d'un étudiant
  static Future<double> calculateStudentAverage({
    required String studentId,
    String? semester,
  }) async {
    try {
      final db = await LocalDatabase.open();
      
      String whereClause = 'studentId = ?';
      List<dynamic> whereArgs = [studentId];

      if (semester != null) {
        whereClause += ' AND semester = ?';
        whereArgs.add(semester);
      }

      final result = await db.query(
        'grades',
        columns: ['average'],
        where: whereClause,
        whereArgs: whereArgs,
      );

      if (result.isEmpty) return 0.0;

      double totalAverage = 0.0;
      for (var grade in result) {
        totalAverage += grade['average'] as double;
      }

      return totalAverage / result.length;
    } catch (e) {
      throw Exception('Erreur lors du calcul de la moyenne: $e');
    }
  }

  // Supprimer une note
  static Future<bool> deleteGrade(String gradeId) async {
    try {
      final db = await LocalDatabase.open();
      final result = await db.delete(
        'grades',
        where: 'id = ?',
        whereArgs: [gradeId],
      );
      return result > 0;
    } catch (e) {
      throw Exception('Erreur lors de la suppression de la note: $e');
    }
  }

  // Statistiques des notes d'une classe
  static Future<Map<String, dynamic>> getClassStatistics({
    required String courseId,
  }) async {
    try {
      final db = await LocalDatabase.open();
      final result = await db.rawQuery('''
        SELECT 
          COUNT(*) as totalStudents,
          AVG(average) as classAverage,
          MIN(average) as minGrade,
          MAX(average) as maxGrade,
          COUNT(CASE WHEN average >= 10 THEN 1 END) as passedStudents,
          COUNT(CASE WHEN average < 10 THEN 1 END) as failedStudents
        FROM grades 
        WHERE courseId = ?
      ''', [courseId]);

      if (result.isEmpty) {
        return {
          'totalStudents': 0,
          'classAverage': 0.0,
          'minGrade': 0.0,
          'maxGrade': 0.0,
          'passedStudents': 0,
          'failedStudents': 0,
          'passRate': 0.0,
        };
      }

      final stats = result.first;
      final totalStudents = stats['totalStudents'] as int;
      final passedStudents = stats['passedStudents'] as int;

      return {
        'totalStudents': totalStudents,
        'classAverage': (stats['classAverage'] as double?) ?? 0.0,
        'minGrade': (stats['minGrade'] as double?) ?? 0.0,
        'maxGrade': (stats['maxGrade'] as double?) ?? 0.0,
        'passedStudents': passedStudents,
        'failedStudents': stats['failedStudents'] as int,
        'passRate': totalStudents > 0 ? (passedStudents / totalStudents) * 100 : 0.0,
      };
    } catch (e) {
      throw Exception('Erreur lors du calcul des statistiques: $e');
    }
  }

  // Vérifier si une note existe déjà
  static Future<bool> gradeExists({
    required String studentId,
    required String courseId,
    required String semester,
  }) async {
    try {
      final db = await LocalDatabase.open();
      final result = await db.query(
        'grades',
        where: 'studentId = ? AND courseId = ? AND semester = ?',
        whereArgs: [studentId, courseId, semester],
      );
      return result.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
} 