class Enseignant {
  final int? id;
  final String name;
  final String email;

  Enseignant({
    this.id,
    required this.name,
    required this.email,
  });

  // Convertir une instance d'Enseignant en Map pour SQLite
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'email': email,
    };
  }

  // Créer une instance d'Enseignant à partir d'un Map SQLite
  factory Enseignant.fromMap(Map<String, dynamic> map) {
    return Enseignant(
      id: map['id'] as int,
      name: map['name'] as String,
      email: map['email'] as String,
    );
  }

  // Créer une copie modifiée de l'instance actuelle
  Enseignant copyWith({
    int? id,
    String? name,
    String? email,
  }) {
    return Enseignant(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
    );
  }

  @override
  String toString() {
    return '$name ($email)';
  }
} 