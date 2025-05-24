import '../entities/room_entity.dart';
import '../entities/session_entity.dart';

abstract class SchedulingRepository {
  // Méthodes pour les salles
  Future<List<RoomEntity>> getRooms();
  Future<RoomEntity> getRoomById(String id);
  Future<RoomEntity> createRoom({required String name, required int capacity});
  Future<void> updateRoom(RoomEntity room);
  Future<void> deleteRoom(String id);
  
  // Méthodes pour les sessions
  Future<List<SessionEntity>> getSessions();
  Future<List<SessionEntity>> getSessionsByRoom(String roomId);
  Future<List<SessionEntity>> getSessionsByClass(String classId);
  Future<List<SessionEntity>> getSessionsByDateRange(DateTime start, DateTime end);
  Future<SessionEntity> createSession({
    required String course,
    required String roomId,
    required String classId,
    required DateTime start,
    required DateTime end,
  });
  Future<void> updateSession(SessionEntity session);
  Future<void> deleteSession(String id);
  
  // Vérification des conflits
  Future<bool> hasOverlappingSessions(SessionEntity newSession);
} 