import '../../domain/entities/user.dart';

class UserModel extends User {
  UserModel({
    required super.id,
    required super.email,
    super.displayName,
    required super.role,
    super.phoneNumber,
    super.address,
    super.profileImageUrl,
    super.classId,
    super.dateOfBirth,
    super.studentId,
    super.isActive = true,
    DateTime? createdAt,
    super.lastModifiedAt,
  }) : super(
          createdAt: createdAt ?? DateTime.now(),
        );

  factory UserModel.fromMap(Map<String, dynamic> map, {String? docId}) {
    return UserModel(
      id: docId ?? map['id'] ?? '',
      email: map['email'] ?? '',
      displayName: map['displayName'],
      role: map['role'] ?? 'student', // Default role is student
      phoneNumber: map['phoneNumber'],
      address: map['address'],
      profileImageUrl: map['profileImageUrl'],
      classId: map['classId'],
      dateOfBirth: map['dateOfBirth'] != null 
          ? DateTime.parse(map['dateOfBirth']) 
          : null,
      studentId: map['studentId'],
      isActive: map['isActive'] == 1,
      createdAt: map['createdAt'] != null 
          ? DateTime.parse(map['createdAt']) 
          : DateTime.now(),
      lastModifiedAt: map['lastModifiedAt'] != null 
          ? DateTime.parse(map['lastModifiedAt']) 
          : null,
    );
  }

  factory UserModel.fromEntity(User entity) {
    return UserModel(
      id: entity.id,
      email: entity.email,
      displayName: entity.displayName,
      role: entity.role,
      phoneNumber: entity.phoneNumber,
      address: entity.address,
      profileImageUrl: entity.profileImageUrl,
      classId: entity.classId,
      dateOfBirth: entity.dateOfBirth,
      studentId: entity.studentId,
      isActive: entity.isActive,
      createdAt: entity.createdAt,
      lastModifiedAt: entity.lastModifiedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'role': role,
      'phoneNumber': phoneNumber,
      'address': address,
      'profileImageUrl': profileImageUrl,
      'classId': classId,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'studentId': studentId,
      'isActive': isActive ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'lastModifiedAt': lastModifiedAt?.toIso8601String(),
    };
  }
} 