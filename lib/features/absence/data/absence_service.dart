import 'package:estm_digital/core/local_database.dart';
import 'package:estm_digital/features/absence/domain/absence_model.dart';
import 'dart:developer' as developer;

class AbsenceService {
  // Insérer une nouvelle absence
  Future<int> insert(Absence absence) async {
    final db = await LocalDatabase.open();
    return await db.insert('Absence', absence.toMap());
  }

  // === MÉTHODE SPÉCIFIQUE DU MCD ===

  /// Méthode insertAbsenceRecord() du MCD
  /// Enregistre une nouvelle absence avec validation
  Future<int> insertAbsenceRecord({
    required bool isPresent,
    required String date,
    String? startTime,
    String? endTime,
    int? attendanceHistoryId,
    required int etudiantId,
  }) async {
    try {
      // Vérifier si un enregistrement existe déjà pour cet étudiant à cette date
      final existing = await queryByEtudiantAndDate(etudiantId, date);
      if (existing != null) {
        throw Exception('Un enregistrement d\'absence existe déjà pour cet étudiant à cette date');
      }

      final absence = Absence(
        isPresent: isPresent,
        date: date,
        startTime: startTime,
        endTime: endTime,
        attendanceHistoryId: attendanceHistoryId,
        etudiantId: etudiantId,
      );

      final result = await insert(absence);
      developer.log('Enregistrement d\'absence inséré: Étudiant $etudiantId, Date $date, Présent: $isPresent');
      return result;
    } catch (e) {
      developer.log('Erreur lors de l\'insertion de l\'enregistrement d\'absence: $e');
      throw Exception('Erreur lors de l\'insertion de l\'enregistrement d\'absence: $e');
    }
  }

  // Mettre à jour une absence existante
  Future<int> update(Absence absence) async {
    final db = await LocalDatabase.open();
    return await db.update(
      'Absence',
      absence.toMap(),
      where: 'id = ?',
      whereArgs: [absence.id],
    );
  }

  // Supprimer une absence
  Future<int> delete(int id) async {
    final db = await LocalDatabase.open();
    return await db.delete(
      'Absence',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Récupérer toutes les absences
  Future<List<Absence>> queryAll() async {
    final db = await LocalDatabase.open();
    final List<Map<String, dynamic>> maps = await db.query('Absence');
    return List.generate(maps.length, (i) {
      return Absence.fromMap(maps[i]);
    });
  }

  // Récupérer une absence par son ID
  Future<Absence?> queryById(int id) async {
    final db = await LocalDatabase.open();
    final List<Map<String, dynamic>> maps = await db.query(
      'Absence',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return Absence.fromMap(maps.first);
    }
    return null;
  }

  // Récupérer les absences d'un étudiant
  Future<List<Absence>> queryByEtudiantId(int etudiantId) async {
    final db = await LocalDatabase.open();
    final List<Map<String, dynamic>> maps = await db.query(
      'Absence',
      where: 'etudiantId = ?',
      whereArgs: [etudiantId],
    );
    return List.generate(maps.length, (i) {
      return Absence.fromMap(maps[i]);
    });
  }

  // Récupérer les absences par date
  Future<List<Absence>> queryByDate(String date) async {
    final db = await LocalDatabase.open();
    final List<Map<String, dynamic>> maps = await db.query(
      'Absence',
      where: 'date = ?',
      whereArgs: [date],
    );
    return List.generate(maps.length, (i) {
      return Absence.fromMap(maps[i]);
    });
  }

  // Rechercher une absence par étudiant et date
  Future<Absence?> queryByEtudiantAndDate(int etudiantId, String date) async {
    final db = await LocalDatabase.open();
    final List<Map<String, dynamic>> maps = await db.query(
      'Absence',
      where: 'etudiantId = ? AND date = ?',
      whereArgs: [etudiantId, date],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return Absence.fromMap(maps.first);
    }
    return null;
  }
} 