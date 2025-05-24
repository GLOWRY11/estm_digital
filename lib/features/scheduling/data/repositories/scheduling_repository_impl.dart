import 'dart:developer' as developer;
import '../../domain/entities/room_entity.dart';
import '../../domain/entities/session_entity.dart';
import '../../domain/repositories/scheduling_repository.dart';
import '../datasources/scheduling_datasource.dart';
import '../models/room_model.dart';
import '../models/session_model.dart';

class SchedulingRepositoryImpl implements SchedulingRepository {
  final SchedulingDataSource _dataSource;

  SchedulingRepositoryImpl({
    required SchedulingDataSource dataSource,
  }) : _dataSource = dataSource;

  // Implémentation pour les salles
  @override
  Future<List<RoomEntity>> getRooms() async {
    try {
      return await _dataSource.getRooms();
    } catch (e) {
      developer.log('Erreur dans le repository lors de la récupération des salles: $e');
      throw Exception('Échec de la récupération des salles: $e');
    }
  }

  @override
  Future<RoomEntity> getRoomById(String id) async {
    try {
      return await _dataSource.getRoomById(id);
    } catch (e) {
      developer.log('Erreur dans le repository lors de la récupération de la salle: $e');
      throw Exception('Échec de la récupération de la salle: $e');
    }
  }

  @override
  Future<RoomEntity> createRoom({
    required String name,
    required int capacity,
  }) async {
    try {
      return await _dataSource.createRoom(
        name: name,
        capacity: capacity,
      );
    } catch (e) {
      developer.log('Erreur dans le repository lors de la création de la salle: $e');
      throw Exception('Échec de la création de la salle: $e');
    }
  }

  @override
  Future<void> updateRoom(RoomEntity room) async {
    try {
      await _dataSource.updateRoom(room as RoomModel);
    } catch (e) {
      developer.log('Erreur dans le repository lors de la mise à jour de la salle: $e');
      throw Exception('Échec de la mise à jour de la salle: $e');
    }
  }

  @override
  Future<void> deleteRoom(String id) async {
    try {
      await _dataSource.deleteRoom(id);
    } catch (e) {
      developer.log('Erreur dans le repository lors de la suppression de la salle: $e');
      throw Exception('Échec de la suppression de la salle: $e');
    }
  }

  // Implémentation pour les sessions
  @override
  Future<List<SessionEntity>> getSessions() async {
    try {
      return await _dataSource.getSessions();
    } catch (e) {
      developer.log('Erreur dans le repository lors de la récupération des sessions: $e');
      throw Exception('Échec de la récupération des sessions: $e');
    }
  }

  @override
  Future<List<SessionEntity>> getSessionsByRoom(String roomId) async {
    try {
      return await _dataSource.getSessionsByRoom(roomId);
    } catch (e) {
      developer.log('Erreur dans le repository lors de la récupération des sessions par salle: $e');
      throw Exception('Échec de la récupération des sessions par salle: $e');
    }
  }

  @override
  Future<List<SessionEntity>> getSessionsByClass(String classId) async {
    try {
      return await _dataSource.getSessionsByClass(classId);
    } catch (e) {
      developer.log('Erreur dans le repository lors de la récupération des sessions par classe: $e');
      throw Exception('Échec de la récupération des sessions par classe: $e');
    }
  }

  @override
  Future<List<SessionEntity>> getSessionsByDateRange(DateTime start, DateTime end) async {
    try {
      return await _dataSource.getSessionsByDateRange(start, end);
    } catch (e) {
      developer.log('Erreur dans le repository lors de la récupération des sessions par période: $e');
      throw Exception('Échec de la récupération des sessions par période: $e');
    }
  }

  @override
  Future<SessionEntity> createSession({
    required String course,
    required String roomId,
    required String classId,
    required DateTime start,
    required DateTime end,
  }) async {
    try {
      return await _dataSource.createSession(
        course: course,
        roomId: roomId,
        classId: classId,
        start: start,
        end: end,
      );
    } catch (e) {
      developer.log('Erreur dans le repository lors de la création de la session: $e');
      throw Exception('Échec de la création de la session: $e');
    }
  }

  @override
  Future<void> updateSession(SessionEntity session) async {
    try {
      await _dataSource.updateSession(session as SessionModel);
    } catch (e) {
      developer.log('Erreur dans le repository lors de la mise à jour de la session: $e');
      throw Exception('Échec de la mise à jour de la session: $e');
    }
  }

  @override
  Future<void> deleteSession(String id) async {
    try {
      await _dataSource.deleteSession(id);
    } catch (e) {
      developer.log('Erreur dans le repository lors de la suppression de la session: $e');
      throw Exception('Échec de la suppression de la session: $e');
    }
  }

  @override
  Future<bool> hasOverlappingSessions(SessionEntity newSession) async {
    try {
      return await _dataSource.hasOverlappingSessions(newSession as SessionModel);
    } catch (e) {
      developer.log('Erreur dans le repository lors de la vérification des chevauchements: $e');
      throw Exception('Échec de la vérification des chevauchements: $e');
    }
  }
} 