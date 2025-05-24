import 'package:estm_digital/core/local_database.dart';
import 'package:estm_digital/features/etudiant/domain/etudiant_model.dart';
import 'package:uuid/uuid.dart';
import 'dart:developer' as developer;

class EtudiantService {
  // Insérer un nouvel étudiant
  Future<int> insert(Etudiant etudiant) async {
    final db = await LocalDatabase.open();
    final map = etudiant.toMap();
    
    // Générer un ID si non fourni
    if (!map.containsKey('id')) {
      map['id'] = int.parse(const Uuid().v4().substring(0, 8), radix: 16);
    }
    
    return await db.insert('Etudiant', map);
  }

  // === MÉTHODES SPÉCIFIQUES DU MCD ===

  /// Méthode addEtudiant() du MCD
  /// Ajoute un nouvel étudiant avec validation
  Future<int> addEtudiant(String name, String email, int filiereId) async {
    try {
      // Vérifier si l'email existe déjà
      final existing = await queryByEmail(email);
      if (existing != null) {
        throw Exception('Un étudiant avec cet email existe déjà');
      }

      final etudiant = Etudiant(
        name: name,
        email: email,
        filiereId: filiereId,
      );

      final result = await insert(etudiant);
      developer.log('Étudiant ajouté avec succès: $name ($email) - Filière: $filiereId');
      return result;
    } catch (e) {
      developer.log('Erreur lors de l\'ajout de l\'étudiant: $e');
      throw Exception('Erreur lors de l\'ajout de l\'étudiant: $e');
    }
  }

  /// Méthode updateEtudiant() du MCD
  /// Met à jour un étudiant existant avec validation
  Future<int> updateEtudiant(int id, {String? name, String? email, int? filiereId}) async {
    try {
      // Vérifier que l'étudiant existe
      final existing = await queryById(id);
      if (existing == null) {
        throw Exception('Étudiant non trouvé avec l\'ID: $id');
      }

      // Si l'email est modifié, vérifier qu'il n'existe pas déjà pour un autre étudiant
      if (email != null && email != existing.email) {
        final emailExists = await queryByEmail(email);
        if (emailExists != null && emailExists.id != id) {
          throw Exception('Un autre étudiant utilise déjà cet email');
        }
      }

      // Créer l'étudiant mis à jour
      final updatedEtudiant = existing.copyWith(
        name: name,
        email: email,
        filiereId: filiereId,
      );

      final result = await update(updatedEtudiant);
      developer.log('Étudiant mis à jour avec succès: ${updatedEtudiant.name} (${updatedEtudiant.email})');
      return result;
    } catch (e) {
      developer.log('Erreur lors de la mise à jour de l\'étudiant: $e');
      throw Exception('Erreur lors de la mise à jour de l\'étudiant: $e');
    }
  }

  // Mettre à jour un étudiant existant
  Future<int> update(Etudiant etudiant) async {
    final db = await LocalDatabase.open();
    return await db.update(
      'Etudiant',
      etudiant.toMap(),
      where: 'id = ?',
      whereArgs: [etudiant.id],
    );
  }

  // Supprimer un étudiant
  Future<int> delete(int id) async {
    final db = await LocalDatabase.open();
    return await db.delete(
      'Etudiant',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Récupérer tous les étudiants
  Future<List<Etudiant>> queryAll() async {
    final db = await LocalDatabase.open();
    final List<Map<String, dynamic>> maps = await db.query('Etudiant');
    return List.generate(maps.length, (i) {
      return Etudiant.fromMap(maps[i]);
    });
  }

  // Récupérer un étudiant par son ID
  Future<Etudiant?> queryById(int id) async {
    final db = await LocalDatabase.open();
    final List<Map<String, dynamic>> maps = await db.query(
      'Etudiant',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return Etudiant.fromMap(maps.first);
    }
    return null;
  }

  // Récupérer les étudiants par filière
  Future<List<Etudiant>> queryByFiliereId(int filiereId) async {
    final db = await LocalDatabase.open();
    final List<Map<String, dynamic>> maps = await db.query(
      'Etudiant',
      where: 'filiereId = ?',
      whereArgs: [filiereId],
    );
    return List.generate(maps.length, (i) {
      return Etudiant.fromMap(maps[i]);
    });
  }

  // Rechercher des étudiants par nom
  Future<List<Etudiant>> searchByName(String query) async {
    final db = await LocalDatabase.open();
    final List<Map<String, dynamic>> maps = await db.query(
      'Etudiant',
      where: 'name LIKE ?',
      whereArgs: ['%$query%'],
    );
    return List.generate(maps.length, (i) {
      return Etudiant.fromMap(maps[i]);
    });
  }

  // Rechercher un étudiant par email
  Future<Etudiant?> queryByEmail(String email) async {
    final db = await LocalDatabase.open();
    final List<Map<String, dynamic>> maps = await db.query(
      'Etudiant',
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return Etudiant.fromMap(maps.first);
    }
    return null;
  }
} 