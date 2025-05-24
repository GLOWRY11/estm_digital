class Notification {
  final int? id;
  final String content;
  final String date;
  final bool isRead;
  final int? etudiantId;
  final int? enseignantId;

  Notification({
    this.id,
    required this.content,
    required this.date,
    required this.isRead,
    this.etudiantId,
    this.enseignantId,
  });

  // Convertir une instance de Notification en Map pour SQLite
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'content': content,
      'date': date,
      'isRead': isRead ? 1 : 0, // Convertir bool en int pour SQLite
      'etudiantId': etudiantId,
      'enseignantId': enseignantId,
    };
  }

  // Créer une instance de Notification à partir d'un Map SQLite
  factory Notification.fromMap(Map<String, dynamic> map) {
    return Notification(
      id: map['id'] as int,
      content: map['content'] as String,
      date: map['date'] as String,
      isRead: map['isRead'] == 1, // Convertir int en bool
      etudiantId: map['etudiantId'] as int?,
      enseignantId: map['enseignantId'] as int?,
    );
  }

  // Créer une copie modifiée de l'instance actuelle
  Notification copyWith({
    int? id,
    String? content,
    String? date,
    bool? isRead,
    int? etudiantId,
    int? enseignantId,
  }) {
    return Notification(
      id: id ?? this.id,
      content: content ?? this.content,
      date: date ?? this.date,
      isRead: isRead ?? this.isRead,
      etudiantId: etudiantId ?? this.etudiantId,
      enseignantId: enseignantId ?? this.enseignantId,
    );
  }
} 