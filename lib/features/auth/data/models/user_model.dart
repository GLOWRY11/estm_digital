import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user.dart';

class UserModel extends UserEntity {
  const UserModel({
    required String uid,
    required String email,
    String? displayName,
    required String role,
  }) : super(
          uid: uid,
          email: email,
          displayName: displayName,
          role: role,
        );

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'],
      role: data['role'] ?? 'student', // Default role is student
    );
  }

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      uid: entity.uid,
      email: entity.email,
      displayName: entity.displayName,
      role: entity.role,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'role': role,
    };
  }
} 