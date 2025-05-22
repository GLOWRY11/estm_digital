class UserEntity {
  final String uid;
  final String email;
  final String? displayName;
  final String role; // 'admin', 'teacher', 'student'

  const UserEntity({
    required this.uid,
    required this.email,
    this.displayName,
    required this.role,
  });
  
  bool get isAdmin => role == 'admin';
  bool get isTeacher => role == 'teacher';
  bool get isStudent => role == 'student';
} 