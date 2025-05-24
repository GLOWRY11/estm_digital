class Fonctionnaire {
  final int? id;
  final String name;
  final String email;
  final String password;

  Fonctionnaire({
    this.id,
    required this.name,
    required this.email,
    required this.password,
  });

  // Convertir une instance de Fonctionnaire en Map pour SQLite
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'email': email,
      'password': password,
    };
  }

  // Créer une instance de Fonctionnaire à partir d'un Map SQLite
  factory Fonctionnaire.fromMap(Map<String, dynamic> map) {
    return Fonctionnaire(
      id: map['id'] as int,
      name: map['name'] as String,
      email: map['email'] as String,
      password: map['password'] as String,
    );
  }

  // Créer une copie modifiée de l'instance actuelle
  Fonctionnaire copyWith({
    int? id,
    String? name,
    String? email,
    String? password,
  }) {
    return Fonctionnaire(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
    );
  }

  @override
  String toString() {
    return '$name ($email)';
  }
} 