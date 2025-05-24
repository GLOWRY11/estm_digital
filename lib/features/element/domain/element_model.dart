class Element {
  final int? id;
  final String name;
  final int moduleId;

  Element({
    this.id,
    required this.name,
    required this.moduleId,
  });

  // Convertir une instance d'Element en Map pour SQLite
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'moduleId': moduleId,
    };
  }

  // Créer une instance d'Element à partir d'un Map SQLite
  factory Element.fromMap(Map<String, dynamic> map) {
    return Element(
      id: map['id'] as int,
      name: map['name'] as String,
      moduleId: map['moduleId'] as int,
    );
  }

  // Créer une copie modifiée de l'instance actuelle
  Element copyWith({
    int? id,
    String? name,
    int? moduleId,
  }) {
    return Element(
      id: id ?? this.id,
      name: name ?? this.name,
      moduleId: moduleId ?? this.moduleId,
    );
  }

  @override
  String toString() {
    return '$name (Module: $moduleId)';
  }
} 