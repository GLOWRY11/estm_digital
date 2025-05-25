import '../../domain/entities/session_entity.dart';

class SessionModel extends SessionEntity {
  const SessionModel({
    required super.id,
    required super.course,
    required super.roomId,
    required super.classId,
    required super.start,
    required super.end,
  });

  factory SessionModel.fromMap(Map<String, dynamic> map) {
    return SessionModel(
      id: map['id'] ?? '',
      course: map['course'] ?? '',
      roomId: map['roomId'] ?? '',
      classId: map['classId'] ?? '',
      start: map['start'] != null 
          ? DateTime.parse(map['start']) 
          : DateTime.now(),
      end: map['end'] != null 
          ? DateTime.parse(map['end']) 
          : DateTime.now().add(const Duration(hours: 1)),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'course': course,
      'roomId': roomId,
      'classId': classId,
      'start': start.toIso8601String(),
      'end': end.toIso8601String(),
    };
  }
}