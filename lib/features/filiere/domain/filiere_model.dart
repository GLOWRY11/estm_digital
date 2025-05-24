class Filiere {
  final int? id;
  final String name;
  final String? annee;

  Filiere({
    this.id,
    required this.name,
    this.annee,
  });

  // Convertir une instance de Filiere en Map pour SQLite
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'annee': annee,
    };
  }

  // Créer une instance de Filiere à partir d'un Map SQLite
  factory Filiere.fromMap(Map<String, dynamic> map) {
    return Filiere(
      id: map['id'] as int,
      name: map['name'] as String,
      annee: map['annee'] as String?,
    );
  }

  // Créer une copie modifiée de l'instance actuelle
  Filiere copyWith({
    int? id,
    String? name,
    String? annee,
  }) {
    return Filiere(
      id: id ?? this.id,
      name: name ?? this.name,
      annee: annee ?? this.annee,
    );
  }

  @override
  String toString() {
    return '$name (${annee ?? "Non spécifié"})';
  }
} 