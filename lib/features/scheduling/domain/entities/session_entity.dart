class SessionEntity {
  final String id;
  final String course;
  final String roomId;
  final String classId;
  final DateTime start;
  final DateTime end;

  const SessionEntity({
    required this.id,
    required this.course,
    required this.roomId,
    required this.classId,
    required this.start,
    required this.end,
  });

  bool overlapsWith(SessionEntity other) {
    // Vérifier si la session chevauche une autre
    if (roomId != other.roomId) return false; // Pas dans la même salle = pas de chevauchement
    
    // Chevauchement si:
    // (start1 <= end2) ET (end1 >= start2)
    return start.isBefore(other.end) && end.isAfter(other.start);
  }
} 