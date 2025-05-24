import 'package:estm_digital/core/local_database.dart';
import 'package:estm_digital/features/filiere/domain/filiere_model.dart';
import 'package:uuid/uuid.dart';
import 'dart:developer' as developer;

class FiliereService {
  // Insérer une nouvelle filière
  Future<int> insert(Filiere filiere) async {
    final db = await LocalDatabase.open();
    final map = filiere.toMap();
    
    // Générer un ID si non fourni
    if (!map.containsKey('id')) {
      map['id'] = int.parse(const Uuid().v4().substring(0, 8), radix: 16);
    }
    
    return await db.insert('Filiere', map);
  }

  // === MÉTHODES SPÉCIFIQUES DU MCD ===

  /// Méthode addFiliere() du MCD
  /// Ajoute une nouvelle filière avec validation
  Future<int> addFiliere(String name, {String? annee}) async {
    try {
      // Vérifier si la filière existe déjà
      final existing = await queryByName(name);
      if (existing != null) {
        throw Exception('Une filière avec ce nom existe déjà');
      }

      final filiere = Filiere(
        name: name,
        annee: annee,
      );

      final result = await insert(filiere);
      developer.log('Filière ajoutée avec succès: $name ${annee != null ? "($annee)" : ""}');
      return result;
    } catch (e) {
      developer.log('Erreur lors de l\'ajout de la filière: $e');
      throw Exception('Erreur lors de l\'ajout de la filière: $e');
    }
  }

  /// Méthode updateFiliere() du MCD
  /// Met à jour une filière existante avec validation
  Future<int> updateFiliere(int id, {String? name, String? annee}) async {
    try {
      // Vérifier que la filière existe
      final existing = await queryById(id);
      if (existing == null) {
        throw Exception('Filière non trouvée avec l\'ID: $id');
      }

      // Si le nom est modifié, vérifier qu'il n'existe pas déjà pour une autre filière
      if (name != null && name != existing.name) {
        final nameExists = await queryByName(name);
        if (nameExists != null && nameExists.id != id) {
          throw Exception('Une autre filière utilise déjà ce nom');
        }
      }

      // Créer la filière mise à jour
      final updatedFiliere = existing.copyWith(
        name: name,
        annee: annee,
      );

      final result = await update(updatedFiliere);
      developer.log('Filière mise à jour avec succès: ${updatedFiliere.name} ${updatedFiliere.annee != null ? "(${updatedFiliere.annee})" : ""}');
      return result;
    } catch (e) {
      developer.log('Erreur lors de la mise à jour de la filière: $e');
      throw Exception('Erreur lors de la mise à jour de la filière: $e');
    }
  }

  // Mettre à jour une filière existante
  Future<int> update(Filiere filiere) async {
    final db = await LocalDatabase.open();
    return await db.update(
      'Filiere',
      filiere.toMap(),
      where: 'id = ?',
      whereArgs: [filiere.id],
    );
  }

  // Supprimer une filière
  Future<int> delete(int id) async {
    final db = await LocalDatabase.open();
    return await db.delete(
      'Filiere',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Récupérer toutes les filières
  Future<List<Filiere>> queryAll() async {
    final db = await LocalDatabase.open();
    final List<Map<String, dynamic>> maps = await db.query('Filiere');
    return List.generate(maps.length, (i) {
      return Filiere.fromMap(maps[i]);
    });
  }

  // Récupérer une filière par son ID
  Future<Filiere?> queryById(int id) async {
    final db = await LocalDatabase.open();
    final List<Map<String, dynamic>> maps = await db.query(
      'Filiere',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return Filiere.fromMap(maps.first);
    }
    return null;
  }

  // Récupérer les filières par année
  Future<List<Filiere>> queryByAnnee(String annee) async {
    final db = await LocalDatabase.open();
    final List<Map<String, dynamic>> maps = await db.query(
      'Filiere',
      where: 'annee = ?',
      whereArgs: [annee],
    );
    return List.generate(maps.length, (i) {
      return Filiere.fromMap(maps[i]);
    });
  }

  // Rechercher une filière par nom exact
  Future<Filiere?> queryByName(String name) async {
    final db = await LocalDatabase.open();
    final List<Map<String, dynamic>> maps = await db.query(
      'Filiere',
      where: 'name = ?',
      whereArgs: [name],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return Filiere.fromMap(maps.first);
    }
    return null;
  }
} 