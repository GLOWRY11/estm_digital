import 'package:uuid/uuid.dart';
import '../local_database.dart';

class CourseService {
  static const _uuid = Uuid();

  // Insérer un nouveau cours
  static Future<String> insertCourse({
    required String name,
    required String code,
    required String description,
    required String teacherId,
    required int credits,
    required String semester,
    String? classId,
    int maxStudents = 50,
  }) async {
    try {
      final db = await LocalDatabase.open();
      final courseId = _uuid.v4();
      final now = DateTime.now().toIso8601String();

      await db.insert('courses', {
        'id': courseId,
        'name': name,
        'code': code,
        'description': description,
        'teacherId': teacherId,
        'credits': credits,
        'semester': semester,
        'classId': classId,
        'maxStudents': maxStudents,
        'currentStudents': 0,
        'isActive': 1,
        'createdAt': now,
      });

      return courseId;
    } catch (e) {
      throw Exception('Erreur lors de la création du cours: $e');
    }
  }

  // Mettre à jour un cours existant
  static Future<bool> updateCourse({
    required String courseId,
    String? name,
    String? code,
    String? description,
    int? credits,
    String? semester,
    String? classId,
    int? maxStudents,
    bool? isActive,
  }) async {
    try {
      final db = await LocalDatabase.open();
      final updates = <String, dynamic>{};

      if (name != null) updates['name'] = name;
      if (code != null) updates['code'] = code;
      if (description != null) updates['description'] = description;
      if (credits != null) updates['credits'] = credits;
      if (semester != null) updates['semester'] = semester;
      if (classId != null) updates['classId'] = classId;
      if (maxStudents != null) updates['maxStudents'] = maxStudents;
      if (isActive != null) updates['isActive'] = isActive ? 1 : 0;

      if (updates.isEmpty) return false;

      updates['updatedAt'] = DateTime.now().toIso8601String();

      final result = await db.update(
        'courses',
        updates,
        where: 'id = ?',
        whereArgs: [courseId],
      );

      return result > 0;
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du cours: $e');
    }
  }

  // Récupérer tous les cours
  static Future<List<Map<String, dynamic>>> getAllCourses() async {
    try {
      final db = await LocalDatabase.open();
      return await db.query(
        'courses',
        orderBy: 'name ASC',
      );
    } catch (e) {
      throw Exception('Erreur lors de la récupération des cours: $e');
    }
  }

  // Récupérer les cours d'un enseignant
  static Future<List<Map<String, dynamic>>> getTeacherCourses({
    required String teacherId,
  }) async {
    try {
      final db = await LocalDatabase.open();
      return await db.query(
        'courses',
        where: 'teacherId = ? AND isActive = 1',
        whereArgs: [teacherId],
        orderBy: 'name ASC',
      );
    } catch (e) {
      throw Exception('Erreur lors de la récupération des cours: $e');
    }
  }

  // Récupérer les cours d'un étudiant (via enrollment)
  static Future<List<Map<String, dynamic>>> getStudentCourses({
    required String studentId,
  }) async {
    try {
      final db = await LocalDatabase.open();
      return await db.rawQuery('''
        SELECT c.* FROM courses c
        INNER JOIN enrollments e ON c.id = e.courseId
        WHERE e.studentId = ? AND c.isActive = 1
        ORDER BY c.name ASC
      ''', [studentId]);
    } catch (e) {
      throw Exception('Erreur lors de la récupération des cours: $e');
    }
  }

  // Supprimer un cours (soft delete)
  static Future<bool> deleteCourse(String courseId) async {
    try {
      final db = await LocalDatabase.open();
      final result = await db.update(
        'courses',
        {
          'isActive': 0,
          'deletedAt': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [courseId],
      );
      return result > 0;
    } catch (e) {
      throw Exception('Erreur lors de la suppression du cours: $e');
    }
  }

  // Inscrire un étudiant à un cours
  static Future<bool> enrollStudent({
    required String courseId,
    required String studentId,
  }) async {
    try {
      final db = await LocalDatabase.open();
      
      // Vérifier si l'étudiant n'est pas déjà inscrit
      final existing = await db.query(
        'enrollments',
        where: 'courseId = ? AND studentId = ?',
        whereArgs: [courseId, studentId],
      );

      if (existing.isNotEmpty) {
        throw Exception('L\'étudiant est déjà inscrit à ce cours');
      }

      // Vérifier la capacité du cours
      final course = await db.query(
        'courses',
        where: 'id = ?',
        whereArgs: [courseId],
      );

      if (course.isEmpty) {
        throw Exception('Cours non trouvé');
      }

      final maxStudents = course.first['maxStudents'] as int;
      final currentStudents = course.first['currentStudents'] as int;

      if (currentStudents >= maxStudents) {
        throw Exception('Le cours a atteint sa capacité maximale');
      }

      // Inscrire l'étudiant
      await db.insert('enrollments', {
        'id': _uuid.v4(),
        'courseId': courseId,
        'studentId': studentId,
        'enrolledAt': DateTime.now().toIso8601String(),
        'isActive': 1,
      });

      // Mettre à jour le nombre d'étudiants
      await db.update(
        'courses',
        {'currentStudents': currentStudents + 1},
        where: 'id = ?',
        whereArgs: [courseId],
      );

      return true;
    } catch (e) {
      throw Exception('Erreur lors de l\'inscription: $e');
    }
  }
} 