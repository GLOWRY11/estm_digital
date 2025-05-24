import 'package:estm_digital/core/local_database.dart';
import 'package:estm_digital/features/enseignant/domain/enseignant_model.dart';
import 'package:uuid/uuid.dart';
import 'dart:developer' as developer;

class EnseignantService {
  // Insérer un nouvel enseignant
  Future<int> insert(Enseignant enseignant) async {
    final db = await LocalDatabase.open();
    final map = enseignant.toMap();
    
    // Générer un ID si non fourni
    if (!map.containsKey('id')) {
      map['id'] = int.parse(const Uuid().v4().substring(0, 8), radix: 16);
    }
    
    return await db.insert('Enseignant', map);
  }

  // Mettre à jour un enseignant existant
  Future<int> update(Enseignant enseignant) async {
    final db = await LocalDatabase.open();
    return await db.update(
      'Enseignant',
      enseignant.toMap(),
      where: 'id = ?',
      whereArgs: [enseignant.id],
    );
  }

  // Supprimer un enseignant
  Future<int> delete(int id) async {
    final db = await LocalDatabase.open();
    return await db.delete(
      'Enseignant',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Récupérer tous les enseignants
  Future<List<Enseignant>> queryAll() async {
    final db = await LocalDatabase.open();
    final List<Map<String, dynamic>> maps = await db.query('Enseignant');
    return List.generate(maps.length, (i) {
      return Enseignant.fromMap(maps[i]);
    });
  }

  // Récupérer un enseignant par son ID
  Future<Enseignant?> queryById(int id) async {
    final db = await LocalDatabase.open();
    final List<Map<String, dynamic>> maps = await db.query(
      'Enseignant',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return Enseignant.fromMap(maps.first);
    }
    return null;
  }

  // === MÉTHODES SPÉCIFIQUES DU MCD ===

  /// Méthode addEnseignant() du MCD
  /// Ajoute un nouvel enseignant avec validation
  Future<int> addEnseignant(String name, String email) async {
    try {
      // Vérifier si l'email existe déjà
      final existing = await queryByEmail(email);
      if (existing != null) {
        throw Exception('Un enseignant avec cet email existe déjà');
      }

      final enseignant = Enseignant(
        name: name,
        email: email,
      );

      final result = await insert(enseignant);
      developer.log('Enseignant ajouté avec succès: $name ($email)');
      return result;
    } catch (e) {
      developer.log('Erreur lors de l\'ajout de l\'enseignant: $e');
      throw Exception('Erreur lors de l\'ajout de l\'enseignant: $e');
    }
  }

  /// Méthode getEnseignantDetails() du MCD
  /// Récupère les détails complets d'un enseignant
  Future<Enseignant?> getEnseignantDetails(int id) async {
    try {
      final db = await LocalDatabase.open();
      final List<Map<String, dynamic>> maps = await db.query(
        'Enseignant',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );
      
      if (maps.isNotEmpty) {
        developer.log('Détails de l\'enseignant récupérés: $id');
        return Enseignant.fromMap(maps.first);
      } else {
        developer.log('Enseignant non trouvé: $id');
        return null;
      }
    } catch (e) {
      developer.log('Erreur lors de la récupération des détails: $e');
      throw Exception('Erreur lors de la récupération des détails: $e');
    }
  }

  // Rechercher des enseignants par nom
  Future<List<Enseignant>> searchByName(String query) async {
    final db = await LocalDatabase.open();
    final List<Map<String, dynamic>> maps = await db.query(
      'Enseignant',
      where: 'name LIKE ?',
      whereArgs: ['%$query%'],
    );
    return List.generate(maps.length, (i) {
      return Enseignant.fromMap(maps[i]);
    });
  }

  // Rechercher un enseignant par email
  Future<Enseignant?> queryByEmail(String email) async {
    final db = await LocalDatabase.open();
    final List<Map<String, dynamic>> maps = await db.query(
      'Enseignant',
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return Enseignant.fromMap(maps.first);
    }
    return null;
  }
} 