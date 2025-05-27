import 'package:uuid/uuid.dart';
import '../local_database.dart';

class ComplaintService {
  static const _uuid = Uuid();

  // Ajouter une nouvelle réclamation
  static Future<String> addComplaint({
    required String userId,
    required String text,
    String? category,
    String? priority,
  }) async {
    try {
      final db = await LocalDatabase.open();
      final complaintId = _uuid.v4();
      final now = DateTime.now().toIso8601String();

      await db.insert('complaints', {
        'id': complaintId,
        'userId': userId,
        'text': text,
        'category': category ?? 'general',
        'priority': priority ?? 'medium',
        'status': 'pending',
        'createdAt': now,
        'updatedAt': now,
      });

      return complaintId;
    } catch (e) {
      throw Exception('Erreur lors de la création de la réclamation: $e');
    }
  }

  // Mettre à jour une réclamation
  static Future<bool> updateComplaint({
    required String complaintId,
    String? text,
    String? status,
    String? adminComment,
    String? category,
    String? priority,
  }) async {
    try {
      final db = await LocalDatabase.open();
      final updates = <String, dynamic>{};

      if (text != null) updates['text'] = text;
      if (status != null) updates['status'] = status;
      if (adminComment != null) updates['adminComment'] = adminComment;
      if (category != null) updates['category'] = category;
      if (priority != null) updates['priority'] = priority;

      if (updates.isEmpty) return false;

      updates['updatedAt'] = DateTime.now().toIso8601String();

      final result = await db.update(
        'complaints',
        updates,
        where: 'id = ?',
        whereArgs: [complaintId],
      );

      return result > 0;
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour de la réclamation: $e');
    }
  }

  // Récupérer toutes les réclamations
  static Future<List<Map<String, dynamic>>> getAllComplaints({
    String? status,
    String? category,
    int? limit,
  }) async {
    try {
      final db = await LocalDatabase.open();
      
      String whereClause = '1=1';
      List<dynamic> whereArgs = [];

      if (status != null) {
        whereClause += ' AND status = ?';
        whereArgs.add(status);
      }

      if (category != null) {
        whereClause += ' AND category = ?';
        whereArgs.add(category);
      }

      return await db.query(
        'complaints',
        where: whereClause.length > 3 ? whereClause : null,
        whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
        orderBy: 'createdAt DESC',
        limit: limit,
      );
    } catch (e) {
      throw Exception('Erreur lors de la récupération des réclamations: $e');
    }
  }

  // Récupérer les réclamations d'un utilisateur
  static Future<List<Map<String, dynamic>>> getUserComplaints({
    required String userId,
    String? status,
  }) async {
    try {
      final db = await LocalDatabase.open();
      
      String whereClause = 'userId = ?';
      List<dynamic> whereArgs = [userId];

      if (status != null) {
        whereClause += ' AND status = ?';
        whereArgs.add(status);
      }

      return await db.query(
        'complaints',
        where: whereClause,
        whereArgs: whereArgs,
        orderBy: 'createdAt DESC',
      );
    } catch (e) {
      throw Exception('Erreur lors de la récupération des réclamations: $e');
    }
  }

  // Supprimer une réclamation
  static Future<bool> deleteComplaint(String complaintId) async {
    try {
      final db = await LocalDatabase.open();
      final result = await db.delete(
        'complaints',
        where: 'id = ?',
        whereArgs: [complaintId],
      );
      return result > 0;
    } catch (e) {
      throw Exception('Erreur lors de la suppression de la réclamation: $e');
    }
  }

  // Statistiques des réclamations
  static Future<Map<String, dynamic>> getComplaintStatistics() async {
    try {
      final db = await LocalDatabase.open();
      
      final totalResult = await db.rawQuery('SELECT COUNT(*) as count FROM complaints');
      final pendingResult = await db.rawQuery('SELECT COUNT(*) as count FROM complaints WHERE status = ?', ['pending']);
      final resolvedResult = await db.rawQuery('SELECT COUNT(*) as count FROM complaints WHERE status = ?', ['resolved']);
      final inProgressResult = await db.rawQuery('SELECT COUNT(*) as count FROM complaints WHERE status = ?', ['in_progress']);

      return {
        'total': totalResult.first['count'] as int,
        'pending': pendingResult.first['count'] as int,
        'resolved': resolvedResult.first['count'] as int,
        'inProgress': inProgressResult.first['count'] as int,
      };
    } catch (e) {
      throw Exception('Erreur lors du calcul des statistiques: $e');
    }
  }

  // Rechercher des réclamations
  static Future<List<Map<String, dynamic>>> searchComplaints({
    required String query,
    String? status,
    String? category,
  }) async {
    try {
      final db = await LocalDatabase.open();
      
      String whereClause = 'text LIKE ?';
      List<dynamic> whereArgs = ['%$query%'];

      if (status != null) {
        whereClause += ' AND status = ?';
        whereArgs.add(status);
      }

      if (category != null) {
        whereClause += ' AND category = ?';
        whereArgs.add(category);
      }

      return await db.query(
        'complaints',
        where: whereClause,
        whereArgs: whereArgs,
        orderBy: 'createdAt DESC',
      );
    } catch (e) {
      throw Exception('Erreur lors de la recherche: $e');
    }
  }

  // Marquer une réclamation comme lue
  static Future<bool> markAsRead(String complaintId) async {
    try {
      final db = await LocalDatabase.open();
      final result = await db.update(
        'complaints',
        {
          'isRead': 1,
          'updatedAt': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [complaintId],
      );
      return result > 0;
    } catch (e) {
      return false;
    }
  }

  // Récupérer une réclamation par ID
  static Future<Map<String, dynamic>?> getComplaintById(String complaintId) async {
    try {
      final db = await LocalDatabase.open();
      final result = await db.query(
        'complaints',
        where: 'id = ?',
        whereArgs: [complaintId],
        limit: 1,
      );
      
      return result.isNotEmpty ? result.first : null;
    } catch (e) {
      throw Exception('Erreur lors de la récupération de la réclamation: $e');
    }
  }
} 