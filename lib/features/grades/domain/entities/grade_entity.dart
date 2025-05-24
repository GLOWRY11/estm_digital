class GradeEntity {
  final String id;
  final String studentId;
  final String courseId;
  final String courseTitle;
  final String semester;
  final double midterm;
  final double final_;
  final double average;
  final String? comment;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const GradeEntity({
    required this.id,
    required this.studentId,
    required this.courseId,
    required this.courseTitle,
    required this.semester,
    required this.midterm,
    required this.final_,
    required this.average,
    this.comment,
    required this.createdAt,
    this.updatedAt,
  });

  GradeEntity copyWith({
    String? id,
    String? studentId,
    String? courseId,
    String? courseTitle,
    String? semester,
    double? midterm,
    double? final_,
    double? average,
    String? comment,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return GradeEntity(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      courseId: courseId ?? this.courseId,
      courseTitle: courseTitle ?? this.courseTitle,
      semester: semester ?? this.semester,
      midterm: midterm ?? this.midterm,
      final_: final_ ?? this.final_,
      average: average ?? this.average,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'studentId': studentId,
      'courseId': courseId,
      'courseTitle': courseTitle,
      'semester': semester,
      'midterm': midterm,
      'final': final_,
      'average': average,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory GradeEntity.fromMap(Map<String, dynamic> map) {
    return GradeEntity(
      id: map['id'] ?? '',
      studentId: map['studentId'] ?? '',
      courseId: map['courseId'] ?? '',
      courseTitle: map['courseTitle'] ?? '',
      semester: map['semester'] ?? '',
      midterm: (map['midterm'] ?? 0.0).toDouble(),
      final_: (map['final'] ?? 0.0).toDouble(),
      average: (map['average'] ?? 0.0).toDouble(),
      comment: map['comment'],
      createdAt: map['createdAt'] != null 
          ? DateTime.parse(map['createdAt']) 
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null 
          ? DateTime.parse(map['updatedAt']) 
          : null,
    );
  }
} 