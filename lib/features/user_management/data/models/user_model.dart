import '../../domain/entities/user_entity.dart';

class ExtendedUserModel extends ExtendedUserEntity {
  const ExtendedUserModel({
    required String uid,
    required String email,
    String? displayName,
    required String role,
    String? phoneNumber,
    String? address,
    String? profileImageUrl,
    String? classId,
    DateTime? dateOfBirth,
    int? studentId,
    bool isActive = true,
    required DateTime createdAt,
    DateTime? lastModifiedAt,
  }) : super(
          uid: uid,
          email: email,
          displayName: displayName,
          role: role,
          phoneNumber: phoneNumber,
          address: address,
          profileImageUrl: profileImageUrl,
          classId: classId,
          dateOfBirth: dateOfBirth,
          studentId: studentId,
          isActive: isActive,
          createdAt: createdAt,
          lastModifiedAt: lastModifiedAt,
        );

  factory ExtendedUserModel.fromMap(Map<String, dynamic> map) {
    return ExtendedUserModel(
      uid: map['uid'] ?? map['id'] ?? '',
      email: map['email'] ?? '',
      displayName: map['displayName'],
      role: map['role'] ?? 'student',
      phoneNumber: map['phoneNumber'],
      address: map['address'],
      profileImageUrl: map['profileImageUrl'],
      classId: map['classId'],
      dateOfBirth: map['dateOfBirth'] != null
          ? DateTime.parse(map['dateOfBirth'])
          : null,
      studentId: map['studentId'],
      isActive: map['isActive'] == 1 || map['isActive'] == true,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      lastModifiedAt: map['lastModifiedAt'] != null
          ? DateTime.parse(map['lastModifiedAt'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': uid,
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