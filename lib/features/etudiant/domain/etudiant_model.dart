class Etudiant {
  final int? id;
  final String name;
  final String email;
  final int filiereId;

  Etudiant({
    this.id,
    required this.name,
    required this.email,
    required this.filiereId,
  });

  // Convertir une instance d'Etudiant en Map pour SQLite
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'email': email,
      'filiereId': filiereId,
    };
  }

  // Créer une instance d'Etudiant à partir d'un Map SQLite
  factory Etudiant.fromMap(Map<String, dynamic> map) {
    return Etudiant(
      id: map['id'] as int,
      name: map['name'] as String,
      email: map['email'] as String,
      filiereId: map['filiereId'] as int,
    );
  }

  // Créer une copie modifiée de l'instance actuelle
  Etudiant copyWith({
    int? id,
    String? name,
    String? email,
    int? filiereId,
  }) {
    return Etudiant(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      filiereId: filiereId ?? this.filiereId,
    );
  }
} 