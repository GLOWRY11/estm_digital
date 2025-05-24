import 'package:estm_digital/core/local_database.dart';
import 'package:estm_digital/features/element/domain/element_model.dart';
import 'package:uuid/uuid.dart';
import 'dart:developer' as developer;

class ElementService {
  // Insérer un nouvel élément
  Future<int> insert(Element element) async {
    final db = await LocalDatabase.open();
    final map = element.toMap();
    
    // Générer un ID si non fourni
    if (!map.containsKey('id')) {
      map['id'] = int.parse(const Uuid().v4().substring(0, 8), radix: 16);
    }
    
    return await db.insert('Element', map);
  }

  // Mettre à jour un élément existant
  Future<int> update(Element element) async {
    final db = await LocalDatabase.open();
    return await db.update(
      'Element',
      element.toMap(),
      where: 'id = ?',
      whereArgs: [element.id],
    );
  }

  // Supprimer un élément
  Future<int> delete(int id) async {
    final db = await LocalDatabase.open();
    return await db.delete(
      'Element',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Récupérer tous les éléments
  Future<List<Element>> queryAll() async {
    final db = await LocalDatabase.open();
    final List<Map<String, dynamic>> maps = await db.query('Element');
    return List.generate(maps.length, (i) {
      return Element.fromMap(maps[i]);
    });
  }

  // Récupérer un élément par son ID
  Future<Element?> queryById(int id) async {
    final db = await LocalDatabase.open();
    final List<Map<String, dynamic>> maps = await db.query(
      'Element',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return Element.fromMap(maps.first);
    }
    return null;
  }

  // === MÉTHODES SPÉCIFIQUES DU MCD ===

  /// Méthode addElement() du MCD
  /// Ajoute un nouvel élément avec validation
  Future<int> addElement(String name, int moduleId) async {
    try {
      // Vérifier si l'élément existe déjà dans ce module
      final existing = await queryByNameAndModule(name, moduleId);
      if (existing != null) {
        throw Exception('Un élément avec ce nom existe déjà dans ce module');
      }

      final element = Element(
        name: name,
        moduleId: moduleId,
      );

      final result = await insert(element);
      developer.log('Élément ajouté avec succès: $name (Module: $moduleId)');
      return result;
    } catch (e) {
      developer.log('Erreur lors de l\'ajout de l\'élément: $e');
      throw Exception('Erreur lors de l\'ajout de l\'élément: $e');
    }
  }

  /// Méthode getElementsByModuleId() du MCD
  /// Récupère tous les éléments d'un module spécifique
  Future<List<Element>> getElementsByModuleId(int moduleId) async {
    try {
      final db = await LocalDatabase.open();
      final List<Map<String, dynamic>> maps = await db.query(
        'Element',
        where: 'moduleId = ?',
        whereArgs: [moduleId],
        orderBy: 'name ASC',
      );
      
      final elements = List.generate(maps.length, (i) {
        return Element.fromMap(maps[i]);
      });
      
      developer.log('${elements.length} éléments récupérés pour le module: $moduleId');
      return elements;
    } catch (e) {
      developer.log('Erreur lors de la récupération des éléments: $e');
      throw Exception('Erreur lors de la récupération des éléments: $e');
    }
  }

  // Rechercher des éléments par nom
  Future<List<Element>> searchByName(String query) async {
    final db = await LocalDatabase.open();
    final List<Map<String, dynamic>> maps = await db.query(
      'Element',
      where: 'name LIKE ?',
      whereArgs: ['%$query%'],
    );
    return List.generate(maps.length, (i) {
      return Element.fromMap(maps[i]);
    });
  }

  // Rechercher un élément par nom et module
  Future<Element?> queryByNameAndModule(String name, int moduleId) async {
    final db = await LocalDatabase.open();
    final List<Map<String, dynamic>> maps = await db.query(
      'Element',
      where: 'name = ? AND moduleId = ?',
      whereArgs: [name, moduleId],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return Element.fromMap(maps.first);
    }
    return null;
  }
} 