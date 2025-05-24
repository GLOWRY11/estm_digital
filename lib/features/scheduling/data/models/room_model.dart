import '../../domain/entities/room_entity.dart';

class RoomModel extends RoomEntity {
  const RoomModel({
    required String id,
    required String name,
    required int capacity,
  }) : super(
          id: id,
          name: name,
          capacity: capacity,
        );

  factory RoomModel.fromMap(Map<String, dynamic> map) {
    return RoomModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      capacity: map['capacity'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'capacity': capacity,
    };
  }
} 