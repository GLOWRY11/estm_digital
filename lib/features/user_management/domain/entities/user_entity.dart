class ExtendedUserEntity {
  final String uid;
  final String email;
  final String? displayName;
  final String role; // 'admin', 'teacher', 'student'
  final String? phoneNumber;
  final String? address;
  final String? profileImageUrl;
  final String? classId;
  final DateTime? dateOfBirth;
  final int? studentId;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? lastModifiedAt;

  const ExtendedUserEntity({
    required this.uid,
    required this.email,
    this.displayName,
    required this.role,
    this.phoneNumber,
    this.address,
    this.profileImageUrl,
    this.classId,
    this.dateOfBirth,
    this.studentId,
    this.isActive = true,
    required this.createdAt,
    this.lastModifiedAt,
  });
  
  bool get isAdmin => role == 'admin';
  bool get isTeacher => role == 'teacher';
  bool get isStudent => role == 'student';
} 