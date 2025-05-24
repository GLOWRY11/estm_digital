class AbsenceEntity {
  final String id;
  final String studentId;
  final DateTime date;
  final String time;
  final String status; // 'offline', 'synced'

  const AbsenceEntity({
    required this.id,
    required this.studentId,
    required this.date,
    required this.time,
    required this.status,
  });
} 