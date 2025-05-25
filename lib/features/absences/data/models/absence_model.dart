import '../../domain/entities/absence_entity.dart';

class AbsenceModel extends AbsenceEntity {
  const AbsenceModel({
    required super.id,
    required super.studentId,
    required super.date,
    required super.time,
    required super.status,
  });

  factory AbsenceModel.fromMap(Map<String, dynamic> map) {
    return AbsenceModel(
      id: map['id'] ?? '',
      studentId: map['studentId'] ?? '',
      date: map['date'] != null ? DateTime.parse(map['date']) : DateTime.now(),
      time: map['time'] ?? '',
      status: map['status'] ?? 'offline',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'studentId': studentId,
      'date': date.toIso8601String(),
      'time': time,
      'status': status,
    };
  }
} 