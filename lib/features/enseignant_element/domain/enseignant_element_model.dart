class EnseignantElement {
  final int? id;
  final int enseignantId;
  final int elementId;

  EnseignantElement({
    this.id,
    required this.enseignantId,
    required this.elementId,
  });

  // Convertir une instance d'EnseignantElement en Map pour SQLite
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'enseignantId': enseignantId,
      'elementId': elementId,
    };
  }

  // Créer une instance d'EnseignantElement à partir d'un Map SQLite
  factory EnseignantElement.fromMap(Map<String, dynamic> map) {
    return EnseignantElement(
      id: map['id'] as int,
      enseignantId: map['enseignantId'] as int,
      elementId: map['elementId'] as int,
    );
  }

  // Créer une copie modifiée de l'instance actuelle
  EnseignantElement copyWith({
    int? id,
    int? enseignantId,
    int? elementId,
  }) {
    return EnseignantElement(
      id: id ?? this.id,
      enseignantId: enseignantId ?? this.enseignantId,
      elementId: elementId ?? this.elementId,
    );
  }

  @override
  String toString() {
    return 'Enseignant: $enseignantId -> Element: $elementId';
  }
} 