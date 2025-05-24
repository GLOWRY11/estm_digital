import '../entities/session_entity.dart';
import '../repositories/scheduling_repository.dart';

class GetWeeklySessionsUseCase {
  final SchedulingRepository repository;

  GetWeeklySessionsUseCase(this.repository);

  /// Récupère toutes les sessions pour une semaine donnée
  /// Si aucune date n'est fournie, utilise la semaine en cours
  Future<List<SessionEntity>> call({DateTime? date}) async {
    // Si aucune date n'est fournie, utiliser la date du jour
    final currentDate = date ?? DateTime.now();
    
    // Trouver le début de la semaine (lundi)
    final startOfWeek = _findFirstDayOfWeek(currentDate);
    
    // Fin de la semaine (dimanche à 23:59:59)
    final endOfWeek = startOfWeek.add(const Duration(days: 7)).subtract(const Duration(seconds: 1));
    
    // Récupérer les sessions pour cette période
    return repository.getSessionsByDateRange(startOfWeek, endOfWeek);
  }
  
  /// Trouve le premier jour (lundi) de la semaine contenant la date donnée
  DateTime _findFirstDayOfWeek(DateTime date) {
    // Le jour de la semaine: lundi = 1, dimanche = 7
    final weekday = date.weekday;
    
    // Nombre de jours à soustraire pour obtenir le lundi
    final daysToSubtract = weekday - 1;
    
    // Retourner le lundi à 00:00:00
    return DateTime(date.year, date.month, date.day - daysToSubtract);
  }
} 