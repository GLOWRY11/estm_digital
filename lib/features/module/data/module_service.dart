import 'package:estm_digital/core/local_database.dart';
import 'package:estm_digital/features/module/domain/module_model.dart';
import 'package:uuid/uuid.dart';
import 'dart:developer' as developer;

class ModuleService {
  // Insérer un nouveau module
  Future<int> insert(Module module) async {
    final db = await LocalDatabase.open();
    final map = module.toMap();
    
    // Générer un ID si non fourni
    if (!map.containsKey('id')) {
      map['id'] = int.parse(const Uuid().v4().substring(0, 8), radix: 16);
    }
    
    return await db.insert('Module', map);
  }

  // Mettre à jour un module existant
  Future<int> update(Module module) async {
    final db = await LocalDatabase.open();
    return await db.update(
      'Module',
      module.toMap(),
      where: 'id = ?',
      whereArgs: [module.id],
    );
  }

  // Supprimer un module
  Future<int> delete(int id) async {
    final db = await LocalDatabase.open();
    return await db.delete(
      'Module',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Récupérer tous les modules
  Future<List<Module>> queryAll() async {
    final db = await LocalDatabase.open();
    final List<Map<String, dynamic>> maps = await db.query('Module');
    return List.generate(maps.length, (i) {
      return Module.fromMap(maps[i]);
    });
  }

  // Récupérer un module par son ID
  Future<Module?> queryById(int id) async {
    final db = await LocalDatabase.open();
    final List<Map<String, dynamic>> maps = await db.query(
      'Module',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return Module.fromMap(maps.first);
    }
    return null;
  }

  // === MÉTHODES SPÉCIFIQUES DU MCD ===

  /// Méthode addModule() du MCD
  /// Ajoute un nouveau module avec validation
  Future<int> addModule(String name) async {
    try {
      // Vérifier si le module existe déjà
      final existing = await queryByName(name);
      if (existing != null) {
        throw Exception('Un module avec ce nom existe déjà');
      }

      final module = Module(name: name);
      final result = await insert(module);
      developer.log('Module ajouté avec succès: $name');
      return result;
    } catch (e) {
      developer.log('Erreur lors de l\'ajout du module: $e');
      throw Exception('Erreur lors de l\'ajout du module: $e');
    }
  }

  /// Méthode getModuleById() du MCD
  /// Récupère un module par son ID
  Future<Module?> getModuleById(int id) async {
    try {
      final db = await LocalDatabase.open();
      final List<Map<String, dynamic>> maps = await db.query(
        'Module',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );
      
      if (maps.isNotEmpty) {
        developer.log('Module récupéré: $id');
        return Module.fromMap(maps.first);
      } else {
        developer.log('Module non trouvé: $id');
        return null;
      }
    } catch (e) {
      developer.log('Erreur lors de la récupération du module: $e');
      throw Exception('Erreur lors de la récupération du module: $e');
    }
  }

  // Rechercher des modules par nom
  Future<List<Module>> searchByName(String query) async {
    final db = await LocalDatabase.open();
    final List<Map<String, dynamic>> maps = await db.query(
      'Module',
      where: 'name LIKE ?',
      whereArgs: ['%$query%'],
    );
    return List.generate(maps.length, (i) {
      return Module.fromMap(maps[i]);
    });
  }

  // Rechercher un module par nom exact
  Future<Module?> queryByName(String name) async {
    final db = await LocalDatabase.open();
    final List<Map<String, dynamic>> maps = await db.query(
      'Module',
      where: 'name = ?',
      whereArgs: [name],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return Module.fromMap(maps.first);
    }
    return null;
  }
} 