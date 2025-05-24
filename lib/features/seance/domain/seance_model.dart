class Seance {
  final int? id;
  final String date;
  final String startTime;
  final String endTime;
  final int enseignantId;

  Seance({
    this.id,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.enseignantId,
  });

  // Convertir une instance de Seance en Map pour SQLite
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'date': date,
      'startTime': startTime,
      'endTime': endTime,
      'enseignantId': enseignantId,
    };
  }

  // Créer une instance de Seance à partir d'un Map SQLite
  factory Seance.fromMap(Map<String, dynamic> map) {
    return Seance(
      id: map['id'] as int,
      date: map['date'] as String,
      startTime: map['startTime'] as String,
      endTime: map['endTime'] as String,
      enseignantId: map['enseignantId'] as int,
    );
  }

  // Créer une copie modifiée de l'instance actuelle
  Seance copyWith({
    int? id,
    String? date,
    String? startTime,
    String? endTime,
    int? enseignantId,
  }) {
    return Seance(
      id: id ?? this.id,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      enseignantId: enseignantId ?? this.enseignantId,
    );
  }

  @override
  String toString() {
    return 'Séance $date $startTime-$endTime (Enseignant: $enseignantId)';
  }
} 