import '../../domain/entities/session_entity.dart';

class SessionModel extends SessionEntity {
  const SessionModel({
    required String id,
    required String course,
    required String roomId,
    required String classId,
    required DateTime start,
    required DateTime end,
  }) : super(
          id: id,
          course: course,
          roomId: roomId,
          classId: classId,
          start: start,
          end: end,
        );

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