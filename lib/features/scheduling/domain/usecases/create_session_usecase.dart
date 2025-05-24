import '../entities/session_entity.dart';
import '../repositories/scheduling_repository.dart';

class CreateSessionUseCase {
  final SchedulingRepository repository;

  CreateSessionUseCase(this.repository);

  /// Crée une session de cours si elle ne chevauche pas d'autres sessions dans la même salle
  /// Retourne la session créée si succès, sinon lance une exception
  Future<SessionEntity> call({
    required String course,
    required String roomId,
    required String classId,
    required DateTime start,
    required DateTime end,
  }) async {
    // Validation de base
    if (start.isAfter(end)) {
      throw Exception('L\'heure de début doit être antérieure à l\'heure de fin');
    }
    
    // Créer un objet session temporaire pour vérifier les chevauchements
    final tempSession = SessionEntity(
      id: '', // ID temporaire vide
      course: course,
      roomId: roomId,
      classId: classId,
      start: start,
      end: end,
    );
    
    // Vérifier s'il y a des chevauchements
    final hasOverlaps = await repository.hasOverlappingSessions(tempSession);
    if (hasOverlaps) {
      throw Exception('La salle est déjà réservée pendant cette période');
    }
    
    // Si pas de chevauchement, créer la session
    return repository.createSession(
      course: course,
      roomId: roomId,
      classId: classId,
      start: start,
      end: end,
    );
  }
} 