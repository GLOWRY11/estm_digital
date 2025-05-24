import '../../domain/entities/class_entity.dart';

class ClassModel extends ClassEntity {
  const ClassModel({
    required String id,
    required String name,
    required String description,
    required int year,
    required String department,
  }) : super(
          id: id,
          name: name,
          description: description,
          year: year,
          department: department,
        );

  factory ClassModel.fromMap(Map<String, dynamic> map) {
    return ClassModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      year: map['year'] ?? DateTime.now().year,
      department: map['department'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'year': year,
      'department': department,
    };
  }
} 