import 'package:uuid/uuid.dart';

class Complaint {
  final String id;
  final String userId;
  final String text;
  final String status;
  final DateTime createdAt;

  Complaint({
    required this.id,
    required this.userId,
    required this.text,
    required this.status,
    required this.createdAt,
  });

  factory Complaint.create({
    required String userId,
    required String text,
  }) {
    return Complaint(
      id: const Uuid().v4(),
      userId: userId,
      text: text,
      status: 'open',
      createdAt: DateTime.now(),
    );
  }

  factory Complaint.fromMap(Map<String, dynamic> map) {
    return Complaint(
      id: map['id'],
      userId: map['userId'],
      text: map['text'],
      status: map['status'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'text': text,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  Complaint copyWith({
    String? id,
    String? userId,
    String? text,
    String? status,
    DateTime? createdAt,
  }) {
    return Complaint(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      text: text ?? this.text,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
} 