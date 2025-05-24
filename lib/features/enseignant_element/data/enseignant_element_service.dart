import 'package:estm_digital/core/local_database.dart';
import 'package:estm_digital/features/enseignant_element/domain/enseignant_element_model.dart';
import 'package:uuid/uuid.dart';
import 'dart:developer' as developer;

class EnseignantElementService {
  // Insérer une nouvelle association enseignant-élément
  Future<int> insert(EnseignantElement enseignantElement) async {
    final db = await LocalDatabase.open();
    final map = enseignantElement.toMap();
    
    // Générer un ID si non fourni
    if (!map.containsKey('id')) {
      map['id'] = int.parse(const Uuid().v4().substring(0, 8), radix: 16);
    }
    
    return await db.insert('Enseignant_Element', map);
  }

  // Mettre à jour une association existante
  Future<int> update(EnseignantElement enseignantElement) async {
    final db = await LocalDatabase.open();
    return await db.update(
      'Enseignant_Element',
      enseignantElement.toMap(),
      where: 'id = ?',
      whereArgs: [enseignantElement.id],
    );
  }

  // Supprimer une association
  Future<int> delete(int id) async {
    final db = await LocalDatabase.open();
    return await db.delete(
      'Enseignant_Element',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Récupérer toutes les associations
  Future<List<EnseignantElement>> queryAll() async {
    final db = await LocalDatabase.open();
    final List<Map<String, dynamic>> maps = await db.query('Enseignant_Element');
    return List.generate(maps.length, (i) {
      return EnseignantElement.fromMap(maps[i]);
    });
  }

  // Récupérer une association par son ID
  Future<EnseignantElement?> queryById(int id) async {
    final db = await LocalDatabase.open();
    final List<Map<String, dynamic>> maps = await db.query(
      'Enseignant_Element',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return EnseignantElement.fromMap(maps.first);
    }
    return null;
  }

  // === MÉTHODES SPÉCIFIQUES DU MCD ===

  /// Méthode addEnseignantElement() du MCD
  /// Ajoute une nouvelle association enseignant-élément avec validation
  Future<int> addEnseignantElement(int enseignantId, int elementId) async {
    try {
      // Vérifier si l'association existe déjà
      final existing = await queryByEnseignantAndElement(enseignantId, elementId);
      if (existing != null) {
        throw Exception('Cette association enseignant-élément existe déjà');
      }

      final enseignantElement = EnseignantElement(
        enseignantId: enseignantId,
        elementId: elementId,
      );

      final result = await insert(enseignantElement);
      developer.log('Association enseignant-élément ajoutée: $enseignantId -> $elementId');
      return result;
    } catch (e) {
      developer.log('Erreur lors de l\'ajout de l\'association: $e');
      throw Exception('Erreur lors de l\'ajout de l\'association: $e');
    }
  }

  /// Méthode deleteEnseignantElement() du MCD
  /// Supprime une association enseignant-élément
  Future<int> deleteEnseignantElement(int enseignantId, int elementId) async {
    try {
      final db = await LocalDatabase.open();
      final result = await db.delete(
        'Enseignant_Element',
        where: 'enseignantId = ? AND elementId = ?',
        whereArgs: [enseignantId, elementId],
      );
      
      if (result > 0) {
        developer.log('Association enseignant-élément supprimée: $enseignantId -> $elementId');
      } else {
        developer.log('Aucune association trouvée pour: $enseignantId -> $elementId');
      }
      
      return result;
    } catch (e) {
      developer.log('Erreur lors de la suppression de l\'association: $e');
      throw Exception('Erreur lors de la suppression de l\'association: $e');
    }
  }

  // Récupérer les éléments d'un enseignant
  Future<List<EnseignantElement>> getElementsByEnseignant(int enseignantId) async {
    final db = await LocalDatabase.open();
    final List<Map<String, dynamic>> maps = await db.query(
      'Enseignant_Element',
      where: 'enseignantId = ?',
      whereArgs: [enseignantId],
    );
    return List.generate(maps.length, (i) {
      return EnseignantElement.fromMap(maps[i]);
    });
  }

  // Récupérer les enseignants d'un élément
  Future<List<EnseignantElement>> getEnseignantsByElement(int elementId) async {
    final db = await LocalDatabase.open();
    final List<Map<String, dynamic>> maps = await db.query(
      'Enseignant_Element',
      where: 'elementId = ?',
      whereArgs: [elementId],
    );
    return List.generate(maps.length, (i) {
      return EnseignantElement.fromMap(maps[i]);
    });
  }

  // Rechercher une association spécifique
  Future<EnseignantElement?> queryByEnseignantAndElement(int enseignantId, int elementId) async {
    final db = await LocalDatabase.open();
    final List<Map<String, dynamic>> maps = await db.query(
      'Enseignant_Element',
      where: 'enseignantId = ? AND elementId = ?',
      whereArgs: [enseignantId, elementId],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return EnseignantElement.fromMap(maps.first);
    }
    return null;
  }

  // Supprimer toutes les associations d'un enseignant
  Future<int> deleteByEnseignant(int enseignantId) async {
    final db = await LocalDatabase.open();
    return await db.delete(
      'Enseignant_Element',
      where: 'enseignantId = ?',
      whereArgs: [enseignantId],
    );
  }

  // Supprimer toutes les associations d'un élément
  Future<int> deleteByElement(int elementId) async {
    final db = await LocalDatabase.open();
    return await db.delete(
      'Enseignant_Element',
      where: 'elementId = ?',
      whereArgs: [elementId],
    );
  }
} 