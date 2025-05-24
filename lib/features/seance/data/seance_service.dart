import 'package:estm_digital/core/local_database.dart';
import 'package:estm_digital/features/seance/domain/seance_model.dart';
import 'package:uuid/uuid.dart';
import 'dart:developer' as developer;

class SeanceService {
  // Insérer une nouvelle séance
  Future<int> insert(Seance seance) async {
    final db = await LocalDatabase.open();
    final map = seance.toMap();
    
    // Générer un ID si non fourni
    if (!map.containsKey('id')) {
      map['id'] = int.parse(const Uuid().v4().substring(0, 8), radix: 16);
    }
    
    return await db.insert('Seance', map);
  }

  // Mettre à jour une séance existante
  Future<int> update(Seance seance) async {
    final db = await LocalDatabase.open();
    return await db.update(
      'Seance',
      seance.toMap(),
      where: 'id = ?',
      whereArgs: [seance.id],
    );
  }

  // Supprimer une séance
  Future<int> delete(int id) async {
    final db = await LocalDatabase.open();
    return await db.delete(
      'Seance',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Récupérer toutes les séances
  Future<List<Seance>> queryAll() async {
    final db = await LocalDatabase.open();
    final List<Map<String, dynamic>> maps = await db.query('Seance', orderBy: 'date DESC, startTime ASC');
    return List.generate(maps.length, (i) {
      return Seance.fromMap(maps[i]);
    });
  }

  // Récupérer une séance par son ID
  Future<Seance?> queryById(int id) async {
    final db = await LocalDatabase.open();
    final List<Map<String, dynamic>> maps = await db.query(
      'Seance',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return Seance.fromMap(maps.first);
    }
    return null;
  }

  // === MÉTHODES SPÉCIFIQUES DU MCD ===

  /// Méthode addSeance() du MCD
  /// Ajoute une nouvelle séance avec validation des conflits
  Future<int> addSeance(String date, String startTime, String endTime, int enseignantId) async {
    try {
      // Vérifier les conflits d'horaires pour cet enseignant
      final conflicts = await checkTimeConflicts(date, startTime, endTime, enseignantId);
      if (conflicts.isNotEmpty) {
        throw Exception('Conflit d\'horaire détecté avec une séance existante');
      }

      final seance = Seance(
        date: date,
        startTime: startTime,
        endTime: endTime,
        enseignantId: enseignantId,
      );

      final result = await insert(seance);
      developer.log('Séance ajoutée avec succès: $date $startTime-$endTime (Enseignant: $enseignantId)');
      return result;
    } catch (e) {
      developer.log('Erreur lors de l\'ajout de la séance: $e');
      throw Exception('Erreur lors de l\'ajout de la séance: $e');
    }
  }

  /// Méthode deleteSeance() du MCD
  /// Supprime une séance spécifique
  Future<int> deleteSeance(int id) async {
    try {
      final result = await delete(id);
      
      if (result > 0) {
        developer.log('Séance supprimée avec succès: $id');
      } else {
        developer.log('Aucune séance trouvée avec l\'ID: $id');
      }
      
      return result;
    } catch (e) {
      developer.log('Erreur lors de la suppression de la séance: $e');
      throw Exception('Erreur lors de la suppression de la séance: $e');
    }
  }

  // Récupérer les séances d'un enseignant
  Future<List<Seance>> getSeancesByEnseignant(int enseignantId) async {
    final db = await LocalDatabase.open();
    final List<Map<String, dynamic>> maps = await db.query(
      'Seance',
      where: 'enseignantId = ?',
      whereArgs: [enseignantId],
      orderBy: 'date DESC, startTime ASC',
    );
    return List.generate(maps.length, (i) {
      return Seance.fromMap(maps[i]);
    });
  }

  // Récupérer les séances par date
  Future<List<Seance>> getSeancesByDate(String date) async {
    final db = await LocalDatabase.open();
    final List<Map<String, dynamic>> maps = await db.query(
      'Seance',
      where: 'date = ?',
      whereArgs: [date],
      orderBy: 'startTime ASC',
    );
    return List.generate(maps.length, (i) {
      return Seance.fromMap(maps[i]);
    });
  }

  // Vérifier les conflits d'horaires
  Future<List<Seance>> checkTimeConflicts(String date, String startTime, String endTime, int enseignantId, [int? excludeId]) async {
    final db = await LocalDatabase.open();
    
    String whereClause = 'date = ? AND enseignantId = ? AND ((startTime < ? AND endTime > ?) OR (startTime < ? AND endTime > ?) OR (startTime >= ? AND endTime <= ?))';
    List<dynamic> whereArgs = [date, enseignantId, endTime, startTime, endTime, startTime, startTime, endTime];
    
    if (excludeId != null) {
      whereClause += ' AND id != ?';
      whereArgs.add(excludeId);
    }
    
    final List<Map<String, dynamic>> maps = await db.query(
      'Seance',
      where: whereClause,
      whereArgs: whereArgs,
    );
    
    return List.generate(maps.length, (i) {
      return Seance.fromMap(maps[i]);
    });
  }

  // Récupérer les séances dans une plage de dates
  Future<List<Seance>> getSeancesByDateRange(String startDate, String endDate) async {
    final db = await LocalDatabase.open();
    final List<Map<String, dynamic>> maps = await db.query(
      'Seance',
      where: 'date >= ? AND date <= ?',
      whereArgs: [startDate, endDate],
      orderBy: 'date ASC, startTime ASC',
    );
    return List.generate(maps.length, (i) {
      return Seance.fromMap(maps[i]);
    });
  }

  // Supprimer toutes les séances d'un enseignant
  Future<int> deleteByEnseignant(int enseignantId) async {
    final db = await LocalDatabase.open();
    return await db.delete(
      'Seance',
      where: 'enseignantId = ?',
      whereArgs: [enseignantId],
    );
  }
} 