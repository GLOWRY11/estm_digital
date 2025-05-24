import 'package:flutter_test/flutter_test.dart';
import 'package:estm_digital/features/complaints/domain/models/complaint.dart';

void main() {
  group('Complaint Model', () {
    test('should create a complaint with correct properties', () {
      final now = DateTime.now();
      final complaint = Complaint(
        id: 'test_id',
        userId: 'user_id',
        text: 'Test complaint',
        status: 'open',
        createdAt: now,
      );

      expect(complaint.id, 'test_id');
      expect(complaint.userId, 'user_id');
      expect(complaint.text, 'Test complaint');
      expect(complaint.status, 'open');
      expect(complaint.createdAt, now);
    });

    test('should create a complaint from map', () {
      final now = DateTime.now();
      final map = {
        'id': 'test_id',
        'userId': 'user_id',
        'text': 'Test complaint',
        'status': 'open',
        'createdAt': now.toIso8601String(),
      };

      final complaint = Complaint.fromMap(map);

      expect(complaint.id, 'test_id');
      expect(complaint.userId, 'user_id');
      expect(complaint.text, 'Test complaint');
      expect(complaint.status, 'open');
      expect(complaint.createdAt.year, now.year);
      expect(complaint.createdAt.month, now.month);
      expect(complaint.createdAt.day, now.day);
    });

    test('should convert complaint to map', () {
      final now = DateTime.now();
      final complaint = Complaint(
        id: 'test_id',
        userId: 'user_id',
        text: 'Test complaint',
        status: 'open',
        createdAt: now,
      );

      final map = complaint.toMap();

      expect(map['id'], 'test_id');
      expect(map['userId'], 'user_id');
      expect(map['text'], 'Test complaint');
      expect(map['status'], 'open');
      expect(map['createdAt'], now.toIso8601String());
    });

    test('should create complaint with factory method', () {
      final complaint = Complaint.create(
        userId: 'user_id',
        text: 'Test complaint',
      );

      expect(complaint.userId, 'user_id');
      expect(complaint.text, 'Test complaint');
      expect(complaint.status, 'open');
      
      // Vérifier que l'ID a été généré
      expect(complaint.id, isNotEmpty);
      expect(complaint.id.length, greaterThan(10));
      
      // Vérifier que la date de création est récente
      final now = DateTime.now();
      final difference = now.difference(complaint.createdAt).inSeconds;
      expect(difference, lessThan(5)); // La date de création ne devrait pas être plus ancienne que 5 secondes
    });

    test('should create a copy with new values', () {
      final now = DateTime.now();
      final complaint = Complaint(
        id: 'test_id',
        userId: 'user_id',
        text: 'Test complaint',
        status: 'open',
        createdAt: now,
      );

      final copiedComplaint = complaint.copyWith(
        status: 'handled',
        text: 'Updated complaint',
      );

      // Les valeurs modifiées doivent être mises à jour
      expect(copiedComplaint.status, 'handled');
      expect(copiedComplaint.text, 'Updated complaint');
      
      // Les autres valeurs doivent rester inchangées
      expect(copiedComplaint.id, 'test_id');
      expect(copiedComplaint.userId, 'user_id');
      expect(copiedComplaint.createdAt, now);
    });
  });
} 