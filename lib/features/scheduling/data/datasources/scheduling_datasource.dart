import 'dart:developer' as developer;
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/local_database.dart';
import '../models/room_model.dart';
import '../models/session_model.dart';

class SchedulingDataSource {
  final _uuid = const Uuid();
  
  // Méthodes pour les salles
  Future<List<RoomModel>> getRooms() async {
    try {
      final db = await LocalDatabase.open();
      final List<Map<String, dynamic>> maps = await db.query('rooms');
      
      final rooms = List.generate(maps.length, (i) {
        return RoomModel.fromMap(maps[i]);
      });
      
      developer.log('${rooms.length} salles récupérées');
      return rooms;
    } catch (e) {
      developer.log('Erreur lors de la récupération des salles: $e');
      throw Exception('Échec de la récupération des salles: $e');
    }
  }
  
  Future<RoomModel> getRoomById(String id) async {
    try {
      final db = await LocalDatabase.open();
      final List<Map<String, dynamic>> maps = await db.query(
        'rooms',
        where: 'id = ?',
        whereArgs: [id],
      );
      
      if (maps.isEmpty) {
        throw Exception('Salle non trouvée avec l\'ID: $id');
      }
      
      return RoomModel.fromMap(maps.first);
    } catch (e) {
      developer.log('Erreur lors de la récupération de la salle: $e');
      throw Exception('Échec de la récupération de la salle: $e');
    }
  }
  
  Future<RoomModel> createRoom({
    required String name,
    required int capacity,
  }) async {
    try {
      final db = await LocalDatabase.open();
      final id = _uuid.v4();
      
      final room = RoomModel(
        id: id,
        name: name,
        capacity: capacity,
      );
      
      await db.insert(
        'rooms',
        room.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      
      developer.log('Salle créée: $id');
      return room;
    } catch (e) {
      developer.log('Erreur lors de la création de la salle: $e');
      throw Exception('Échec de la création de la salle: $e');
    }
  }
  
  Future<void> updateRoom(RoomModel room) async {
    try {
      final db = await LocalDatabase.open();
      
      await db.update(
        'rooms',
        room.toMap(),
        where: 'id = ?',
        whereArgs: [room.id],
      );
      
      developer.log('Salle mise à jour: ${room.id}');
    } catch (e) {
      developer.log('Erreur lors de la mise à jour de la salle: $e');
      throw Exception('Échec de la mise à jour de la salle: $e');
    }
  }
  
  Future<void> deleteRoom(String id) async {
    try {
      final db = await LocalDatabase.open();
      
      await db.delete(
        'rooms',
        where: 'id = ?',
        whereArgs: [id],
      );
      
      developer.log('Salle supprimée: $id');
    } catch (e) {
      developer.log('Erreur lors de la suppression de la salle: $e');
      throw Exception('Échec de la suppression de la salle: $e');
    }
  }
  
  // Méthodes pour les sessions
  Future<List<SessionModel>> getSessions() async {
    try {
      final db = await LocalDatabase.open();
      final List<Map<String, dynamic>> maps = await db.query('sessions');
      
      final sessions = List.generate(maps.length, (i) {
        return SessionModel.fromMap(maps[i]);
      });
      
      developer.log('${sessions.length} sessions récupérées');
      return sessions;
    } catch (e) {
      developer.log('Erreur lors de la récupération des sessions: $e');
      throw Exception('Échec de la récupération des sessions: $e');
    }
  }
  
  Future<List<SessionModel>> getSessionsByRoom(String roomId) async {
    try {
      final db = await LocalDatabase.open();
      final List<Map<String, dynamic>> maps = await db.query(
        'sessions',
        where: 'roomId = ?',
        whereArgs: [roomId],
      );
      
      final sessions = List.generate(maps.length, (i) {
        return SessionModel.fromMap(maps[i]);
      });
      
      developer.log('${sessions.length} sessions récupérées pour la salle: $roomId');
      return sessions;
    } catch (e) {
      developer.log('Erreur lors de la récupération des sessions: $e');
      throw Exception('Échec de la récupération des sessions: $e');
    }
  }
  
  Future<List<SessionModel>> getSessionsByClass(String classId) async {
    try {
      final db = await LocalDatabase.open();
      final List<Map<String, dynamic>> maps = await db.query(
        'sessions',
        where: 'classId = ?',
        whereArgs: [classId],
      );
      
      final sessions = List.generate(maps.length, (i) {
        return SessionModel.fromMap(maps[i]);
      });
      
      developer.log('${sessions.length} sessions récupérées pour la classe: $classId');
      return sessions;
    } catch (e) {
      developer.log('Erreur lors de la récupération des sessions: $e');
      throw Exception('Échec de la récupération des sessions: $e');
    }
  }
  
  Future<List<SessionModel>> getSessionsByDateRange(DateTime start, DateTime end) async {
    try {
      final db = await LocalDatabase.open();
      final startStr = start.toIso8601String();
      final endStr = end.toIso8601String();
      
      // Récupérer les sessions qui chevauchent l'intervalle donné
      // Une session chevauche si elle commence avant la fin de l'intervalle et finit après le début
      final List<Map<String, dynamic>> maps = await db.rawQuery('''
        SELECT * FROM sessions 
        WHERE start < ? AND end > ?
      ''', [endStr, startStr]);
      
      final sessions = List.generate(maps.length, (i) {
        return SessionModel.fromMap(maps[i]);
      });
      
      developer.log('${sessions.length} sessions récupérées pour la période du ${start.day}/${start.month} au ${end.day}/${end.month}');
      return sessions;
    } catch (e) {
      developer.log('Erreur lors de la récupération des sessions: $e');
      throw Exception('Échec de la récupération des sessions: $e');
    }
  }
  
  Future<SessionModel> createSession({
    required String course,
    required String roomId,
    required String classId,
    required DateTime start,
    required DateTime end,
  }) async {
    try {
      final db = await LocalDatabase.open();
      final id = _uuid.v4();
      
      final session = SessionModel(
        id: id,
        course: course,
        roomId: roomId,
        classId: classId,
        start: start,
        end: end,
      );
      
      await db.insert(
        'sessions',
        session.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      
      developer.log('Session créée: $id');
      return session;
    } catch (e) {
      developer.log('Erreur lors de la création de la session: $e');
      throw Exception('Échec de la création de la session: $e');
    }
  }
  
  Future<void> updateSession(SessionModel session) async {
    try {
      final db = await LocalDatabase.open();
      
      await db.update(
        'sessions',
        session.toMap(),
        where: 'id = ?',
        whereArgs: [session.id],
      );
      
      developer.log('Session mise à jour: ${session.id}');
    } catch (e) {
      developer.log('Erreur lors de la mise à jour de la session: $e');
      throw Exception('Échec de la mise à jour de la session: $e');
    }
  }
  
  Future<void> deleteSession(String id) async {
    try {
      final db = await LocalDatabase.open();
      
      await db.delete(
        'sessions',
        where: 'id = ?',
        whereArgs: [id],
      );
      
      developer.log('Session supprimée: $id');
    } catch (e) {
      developer.log('Erreur lors de la suppression de la session: $e');
      throw Exception('Échec de la suppression de la session: $e');
    }
  }
  
  // Vérifier si une session chevauche d'autres sessions dans la même salle
  Future<bool> hasOverlappingSessions(SessionModel newSession) async {
    try {
      final db = await LocalDatabase.open();
      final startStr = newSession.start.toIso8601String();
      final endStr = newSession.end.toIso8601String();
      
      // Exclure la session elle-même si elle a déjà un ID (mise à jour)
      String whereClause = 'roomId = ? AND start < ? AND end > ?';
      List<dynamic> whereArgs = [newSession.roomId, endStr, startStr];
      
      if (newSession.id.isNotEmpty) {
        whereClause += ' AND id != ?';
        whereArgs.add(newSession.id);
      }
      
      final List<Map<String, dynamic>> maps = await db.rawQuery(
        'SELECT COUNT(*) as count FROM sessions WHERE $whereClause',
        whereArgs,
      );
      
      final count = maps.first['count'] as int;
      developer.log('Vérification des chevauchements: $count sessions en conflit trouvées');
      
      return count > 0;
    } catch (e) {
      developer.log('Erreur lors de la vérification des chevauchements: $e');
      throw Exception('Échec de la vérification des chevauchements: $e');
    }
  }
} 