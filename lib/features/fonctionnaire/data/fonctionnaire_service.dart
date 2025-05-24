import 'package:estm_digital/core/local_database.dart';
import 'package:estm_digital/features/fonctionnaire/domain/fonctionnaire_model.dart';
import 'package:uuid/uuid.dart';
import 'dart:developer' as developer;

class FonctionnaireService {
  // Insérer un nouveau fonctionnaire
  Future<int> insert(Fonctionnaire fonctionnaire) async {
    final db = await LocalDatabase.open();
    final map = fonctionnaire.toMap();
    
    // Générer un ID si non fourni
    if (!map.containsKey('id')) {
      map['id'] = int.parse(const Uuid().v4().substring(0, 8), radix: 16);
    }
    
    return await db.insert('Fonctionnaire', map);
  }

  // Mettre à jour un fonctionnaire existant
  Future<int> update(Fonctionnaire fonctionnaire) async {
    final db = await LocalDatabase.open();
    return await db.update(
      'Fonctionnaire',
      fonctionnaire.toMap(),
      where: 'id = ?',
      whereArgs: [fonctionnaire.id],
    );
  }

  // Supprimer un fonctionnaire
  Future<int> delete(int id) async {
    final db = await LocalDatabase.open();
    return await db.delete(
      'Fonctionnaire',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Récupérer tous les fonctionnaires
  Future<List<Fonctionnaire>> queryAll() async {
    final db = await LocalDatabase.open();
    final List<Map<String, dynamic>> maps = await db.query('Fonctionnaire');
    return List.generate(maps.length, (i) {
      return Fonctionnaire.fromMap(maps[i]);
    });
  }

  // Récupérer un fonctionnaire par son ID
  Future<Fonctionnaire?> queryById(int id) async {
    final db = await LocalDatabase.open();
    final List<Map<String, dynamic>> maps = await db.query(
      'Fonctionnaire',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return Fonctionnaire.fromMap(maps.first);
    }
    return null;
  }

  // === MÉTHODES SPÉCIFIQUES DU MCD ===

  /// Méthode seConnecter() du MCD
  /// Authentifie un fonctionnaire avec email et mot de passe
  Future<Fonctionnaire?> seConnecter(String email, String password) async {
    try {
      final db = await LocalDatabase.open();
      final List<Map<String, dynamic>> maps = await db.query(
        'Fonctionnaire',
        where: 'email = ? AND password = ?',
        whereArgs: [email, password],
        limit: 1,
      );
      
      if (maps.isNotEmpty) {
        developer.log('Connexion réussie pour le fonctionnaire: $email');
        return Fonctionnaire.fromMap(maps.first);
      } else {
        developer.log('Échec de connexion pour: $email');
        return null;
      }
    } catch (e) {
      developer.log('Erreur lors de la connexion: $e');
      throw Exception('Erreur lors de la connexion: $e');
    }
  }

  /// Méthode getFonctionnaireDetails() du MCD
  /// Récupère les détails complets d'un fonctionnaire
  Future<Fonctionnaire?> getFonctionnaireDetails(int id) async {
    try {
      final db = await LocalDatabase.open();
      final List<Map<String, dynamic>> maps = await db.query(
        'Fonctionnaire',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );
      
      if (maps.isNotEmpty) {
        developer.log('Détails du fonctionnaire récupérés: $id');
        return Fonctionnaire.fromMap(maps.first);
      } else {
        developer.log('Fonctionnaire non trouvé: $id');
        return null;
      }
    } catch (e) {
      developer.log('Erreur lors de la récupération des détails: $e');
      throw Exception('Erreur lors de la récupération des détails: $e');
    }
  }

  // Rechercher des fonctionnaires par nom
  Future<List<Fonctionnaire>> searchByName(String query) async {
    final db = await LocalDatabase.open();
    final List<Map<String, dynamic>> maps = await db.query(
      'Fonctionnaire',
      where: 'name LIKE ?',
      whereArgs: ['%$query%'],
    );
    return List.generate(maps.length, (i) {
      return Fonctionnaire.fromMap(maps[i]);
    });
  }

  // Rechercher un fonctionnaire par email
  Future<Fonctionnaire?> queryByEmail(String email) async {
    final db = await LocalDatabase.open();
    final List<Map<String, dynamic>> maps = await db.query(
      'Fonctionnaire',
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return Fonctionnaire.fromMap(maps.first);
    }
    return null;
  }
} 