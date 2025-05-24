class User {
  final String id;
  final String email;
  final String? displayName;
  final String role;
  final String? phoneNumber;
  final String? address;
  final String? profileImageUrl;
  final String? classId;
  final DateTime? dateOfBirth;
  final int? studentId;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? lastModifiedAt;

  const User({
    required this.id,
    required this.email,
    this.displayName,
    required this.role,
    this.phoneNumber,
    this.address,
    this.profileImageUrl,
    this.classId,
    this.dateOfBirth,
    this.studentId,
    required this.isActive,
    required this.createdAt,
    this.lastModifiedAt,
  });

  User copyWith({
    String? id,
    String? email,
    String? displayName,
    String? role,
    String? phoneNumber,
    String? address,
    String? profileImageUrl,
    String? classId,
    DateTime? dateOfBirth,
    int? studentId,
    bool? isActive,
    DateTime? createdAt,
    DateTime? lastModifiedAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      role: role ?? this.role,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      classId: classId ?? this.classId,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      studentId: studentId ?? this.studentId,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      lastModifiedAt: lastModifiedAt ?? this.lastModifiedAt,
    );
  }

  bool get isAdmin => role == 'admin';
  bool get isTeacher => role == 'teacher';
  bool get isStudent => role == 'student';
} 