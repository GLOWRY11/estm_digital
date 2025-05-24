class Module {
  final int? id;
  final String name;

  Module({
    this.id,
    required this.name,
  });

  // Convertir une instance de Module en Map pour SQLite
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
    };
  }

  // Créer une instance de Module à partir d'un Map SQLite
  factory Module.fromMap(Map<String, dynamic> map) {
    return Module(
      id: map['id'] as int,
      name: map['name'] as String,
    );
  }

  // Créer une copie modifiée de l'instance actuelle
  Module copyWith({
    int? id,
    String? name,
  }) {
    return Module(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }

  @override
  String toString() {
    return name;
  }
} 