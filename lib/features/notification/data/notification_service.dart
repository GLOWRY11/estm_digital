import 'package:estm_digital/core/local_database.dart';
import 'package:estm_digital/features/notification/domain/notification_model.dart';
import 'dart:developer' as developer;

class NotificationService {
  // Insérer une nouvelle notification
  Future<int> insert(Notification notification) async {
    final db = await LocalDatabase.open();
    return await db.insert('Notification', notification.toMap());
  }

  // === MÉTHODES SPÉCIFIQUES DU MCD ===

  /// Méthode addNotification() du MCD
  /// Ajoute une nouvelle notification avec validation
  Future<int> addNotification({
    required String content,
    required String date,
    bool isRead = false,
    int? etudiantId,
    int? enseignantId,
  }) async {
    try {
      // Validation : au moins un destinataire doit être spécifié
      if (etudiantId == null && enseignantId == null) {
        throw Exception('Au moins un destinataire (étudiant ou enseignant) doit être spécifié');
      }

      final notification = Notification(
        content: content,
        date: date,
        isRead: isRead,
        etudiantId: etudiantId,
        enseignantId: enseignantId,
      );

      final result = await insert(notification);
      developer.log('Notification ajoutée: "$content" pour ${etudiantId != null ? "Étudiant $etudiantId" : "Enseignant $enseignantId"}');
      return result;
    } catch (e) {
      developer.log('Erreur lors de l\'ajout de la notification: $e');
      throw Exception('Erreur lors de l\'ajout de la notification: $e');
    }
  }

  /// Méthode deleteNotification() du MCD
  /// Supprime une notification spécifique
  Future<int> deleteNotification(int id) async {
    try {
      final result = await delete(id);
      
      if (result > 0) {
        developer.log('Notification supprimée avec succès: $id');
      } else {
        developer.log('Aucune notification trouvée avec l\'ID: $id');
      }
      
      return result;
    } catch (e) {
      developer.log('Erreur lors de la suppression de la notification: $e');
      throw Exception('Erreur lors de la suppression de la notification: $e');
    }
  }

  // Mettre à jour une notification existante
  Future<int> update(Notification notification) async {
    final db = await LocalDatabase.open();
    return await db.update(
      'Notification',
      notification.toMap(),
      where: 'id = ?',
      whereArgs: [notification.id],
    );
  }

  // Supprimer une notification
  Future<int> delete(int id) async {
    final db = await LocalDatabase.open();
    return await db.delete(
      'Notification',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Récupérer toutes les notifications
  Future<List<Notification>> queryAll() async {
    final db = await LocalDatabase.open();
    final List<Map<String, dynamic>> maps = await db.query('Notification');
    return List.generate(maps.length, (i) {
      return Notification.fromMap(maps[i]);
    });
  }

  // Récupérer une notification par son ID
  Future<Notification?> queryById(int id) async {
    final db = await LocalDatabase.open();
    final List<Map<String, dynamic>> maps = await db.query(
      'Notification',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return Notification.fromMap(maps.first);
    }
    return null;
  }

  // Récupérer les notifications d'un étudiant
  Future<List<Notification>> queryByEtudiantId(int etudiantId) async {
    final db = await LocalDatabase.open();
    final List<Map<String, dynamic>> maps = await db.query(
      'Notification',
      where: 'etudiantId = ?',
      whereArgs: [etudiantId],
    );
    return List.generate(maps.length, (i) {
      return Notification.fromMap(maps[i]);
    });
  }

  // Récupérer les notifications d'un enseignant
  Future<List<Notification>> queryByEnseignantId(int enseignantId) async {
    final db = await LocalDatabase.open();
    final List<Map<String, dynamic>> maps = await db.query(
      'Notification',
      where: 'enseignantId = ?',
      whereArgs: [enseignantId],
    );
    return List.generate(maps.length, (i) {
      return Notification.fromMap(maps[i]);
    });
  }

  // Marquer une notification comme lue
  Future<int> markAsRead(int id) async {
    final db = await LocalDatabase.open();
    return await db.update(
      'Notification',
      {'isRead': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Récupérer les notifications non lues
  Future<List<Notification>> queryUnread() async {
    final db = await LocalDatabase.open();
    final List<Map<String, dynamic>> maps = await db.query(
      'Notification',
      where: 'isRead = ?',
      whereArgs: [0],
    );
    return List.generate(maps.length, (i) {
      return Notification.fromMap(maps[i]);
    });
  }
} 