import 'package:estm_digital/core/local_database.dart';
import 'package:estm_digital/features/absence_historique/domain/absence_historique_model.dart';
import 'dart:developer' as developer;

class AbsenceHistoriqueService {
  // Insérer un nouveau historique d'absence
  Future<int> insert(AbsenceHistorique absenceHistorique) async {
    final db = await LocalDatabase.open();
    return await db.insert('AbsenceHistorique', absenceHistorique.toMap());
  }

  // === MÉTHODE SPÉCIFIQUE DU MCD ===

  /// Méthode insertAttendanceRecord() du MCD
  /// Enregistre un historique de présence avec calcul automatique des compteurs
  Future<int> insertAttendanceRecord({
    required String date,
    required int enseignantId,
    int? presentCount,
    int? absentCount,
  }) async {
    try {
      // Si les compteurs ne sont pas fournis, les calculer automatiquement
      int finalPresentCount = presentCount ?? 0;
      int finalAbsentCount = absentCount ?? 0;

      if (presentCount == null || absentCount == null) {
        // Calculer les compteurs en interrogeant la table Absence
        final counters = await calculateAttendanceCounts(date, enseignantId);
        finalPresentCount = counters['presentCount'] ?? 0;
        finalAbsentCount = counters['absentCount'] ?? 0;
      }

      // Vérifier si un historique existe déjà pour cette date et cet enseignant
      final existing = await queryByDateAndEnseignant(date, enseignantId);
      if (existing != null) {
        // Mettre à jour l'enregistrement existant
        final updated = existing.copyWith(
          presentCount: finalPresentCount,
          absentCount: finalAbsentCount,
        );
        final result = await update(updated);
        developer.log('Historique de présence mis à jour: Date $date, Enseignant $enseignantId, Présents: $finalPresentCount, Absents: $finalAbsentCount');
        return result;
      } else {
        // Créer un nouvel enregistrement
        final absenceHistorique = AbsenceHistorique(
          date: date,
          presentCount: finalPresentCount,
          absentCount: finalAbsentCount,
          enseignantId: enseignantId,
        );

        final result = await insert(absenceHistorique);
        developer.log('Historique de présence inséré: Date $date, Enseignant $enseignantId, Présents: $finalPresentCount, Absents: $finalAbsentCount');
        return result;
      }
    } catch (e) {
      developer.log('Erreur lors de l\'insertion de l\'historique de présence: $e');
      throw Exception('Erreur lors de l\'insertion de l\'historique de présence: $e');
    }
  }

  // Mettre à jour un historique d'absence existant
  Future<int> update(AbsenceHistorique absenceHistorique) async {
    final db = await LocalDatabase.open();
    return await db.update(
      'AbsenceHistorique',
      absenceHistorique.toMap(),
      where: 'id = ?',
      whereArgs: [absenceHistorique.id],
    );
  }

  // Supprimer un historique d'absence
  Future<int> delete(int id) async {
    final db = await LocalDatabase.open();
    return await db.delete(
      'AbsenceHistorique',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Récupérer tous les historiques d'absence
  Future<List<AbsenceHistorique>> queryAll() async {
    final db = await LocalDatabase.open();
    final List<Map<String, dynamic>> maps = await db.query('AbsenceHistorique');
    return List.generate(maps.length, (i) {
      return AbsenceHistorique.fromMap(maps[i]);
    });
  }

  // Récupérer un historique d'absence par son ID
  Future<AbsenceHistorique?> queryById(int id) async {
    final db = await LocalDatabase.open();
    final List<Map<String, dynamic>> maps = await db.query(
      'AbsenceHistorique',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return AbsenceHistorique.fromMap(maps.first);
    }
    return null;
  }

  // Récupérer les historiques d'absence d'un enseignant
  Future<List<AbsenceHistorique>> queryByEnseignantId(int enseignantId) async {
    final db = await LocalDatabase.open();
    final List<Map<String, dynamic>> maps = await db.query(
      'AbsenceHistorique',
      where: 'enseignantId = ?',
      whereArgs: [enseignantId],
    );
    return List.generate(maps.length, (i) {
      return AbsenceHistorique.fromMap(maps[i]);
    });
  }

  // Récupérer les historiques d'absence par date
  Future<List<AbsenceHistorique>> queryByDate(String date) async {
    final db = await LocalDatabase.open();
    final List<Map<String, dynamic>> maps = await db.query(
      'AbsenceHistorique',
      where: 'date = ?',
      whereArgs: [date],
    );
    return List.generate(maps.length, (i) {
      return AbsenceHistorique.fromMap(maps[i]);
    });
  }

  // Rechercher un historique par date et enseignant
  Future<AbsenceHistorique?> queryByDateAndEnseignant(String date, int enseignantId) async {
    final db = await LocalDatabase.open();
    final List<Map<String, dynamic>> maps = await db.query(
      'AbsenceHistorique',
      where: 'date = ? AND enseignantId = ?',
      whereArgs: [date, enseignantId],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return AbsenceHistorique.fromMap(maps.first);
    }
    return null;
  }

  // Calculer les compteurs de présence pour une date et un enseignant
  Future<Map<String, int>> calculateAttendanceCounts(String date, int enseignantId) async {
    final db = await LocalDatabase.open();
    
    // Compter les présents
    final presentResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM Absence WHERE date = ? AND isPresent = 1',
      [date]
    );
    final presentCount = presentResult.first['count'] as int;
    
    // Compter les absents
    final absentResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM Absence WHERE date = ? AND isPresent = 0',
      [date]
    );
    final absentCount = absentResult.first['count'] as int;
    
    return {
      'presentCount': presentCount,
      'absentCount': absentCount,
    };
  }
} 