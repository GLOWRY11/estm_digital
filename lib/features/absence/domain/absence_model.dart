class Absence {
  final int? id;
  final bool isPresent;
  final String date;
  final String? startTime;
  final String? endTime;
  final int? attendanceHistoryId;
  final int etudiantId;

  Absence({
    this.id,
    required this.isPresent,
    required this.date,
    this.startTime,
    this.endTime,
    this.attendanceHistoryId,
    required this.etudiantId,
  });

  // Convertir une instance d'Absence en Map pour SQLite
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'isPresent': isPresent ? 1 : 0, // Convertir bool en int pour SQLite
      'date': date,
      'startTime': startTime,
      'endTime': endTime,
      'attendanceHistoryId': attendanceHistoryId,
      'etudiantId': etudiantId,
    };
  }

  // Créer une instance d'Absence à partir d'un Map SQLite
  factory Absence.fromMap(Map<String, dynamic> map) {
    return Absence(
      id: map['id'] as int,
      isPresent: map['isPresent'] == 1, // Convertir int en bool
      date: map['date'] as String,
      startTime: map['startTime'] as String?,
      endTime: map['endTime'] as String?,
      attendanceHistoryId: map['attendanceHistoryId'] as int?,
      etudiantId: map['etudiantId'] as int,
    );
  }

  // Créer une copie modifiée de l'instance actuelle
  Absence copyWith({
    int? id,
    bool? isPresent,
    String? date,
    String? startTime,
    String? endTime,
    int? attendanceHistoryId,
    int? etudiantId,
  }) {
    return Absence(
      id: id ?? this.id,
      isPresent: isPresent ?? this.isPresent,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      attendanceHistoryId: attendanceHistoryId ?? this.attendanceHistoryId,
      etudiantId: etudiantId ?? this.etudiantId,
    );
  }
} 