class AbsenceHistorique {
  final int? id;
  final String date;
  final int? presentCount;
  final int? absentCount;
  final int enseignantId;

  AbsenceHistorique({
    this.id,
    required this.date,
    this.presentCount,
    this.absentCount,
    required this.enseignantId,
  });

  // Convertir une instance d'AbsenceHistorique en Map pour SQLite
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'date': date,
      'presentCount': presentCount,
      'absentCount': absentCount,
      'enseignantId': enseignantId,
    };
  }

  // Créer une instance d'AbsenceHistorique à partir d'un Map SQLite
  factory AbsenceHistorique.fromMap(Map<String, dynamic> map) {
    return AbsenceHistorique(
      id: map['id'] as int,
      date: map['date'] as String,
      presentCount: map['presentCount'] as int?,
      absentCount: map['absentCount'] as int?,
      enseignantId: map['enseignantId'] as int,
    );
  }

  // Créer une copie modifiée de l'instance actuelle
  AbsenceHistorique copyWith({
    int? id,
    String? date,
    int? presentCount,
    int? absentCount,
    int? enseignantId,
  }) {
    return AbsenceHistorique(
      id: id ?? this.id,
      date: date ?? this.date,
      presentCount: presentCount ?? this.presentCount,
      absentCount: absentCount ?? this.absentCount,
      enseignantId: enseignantId ?? this.enseignantId,
    );
  }
} 