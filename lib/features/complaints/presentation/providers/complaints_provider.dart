import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/complaint.dart';
import '../../data/repositories/complaints_repository.dart';

class ComplaintsNotifier extends StateNotifier<List<Complaint>> {
  final ComplaintsRepository _repository;

  ComplaintsNotifier(this._repository) : super([]);

  Future<void> loadComplaints({String? userId}) async {
    try {
      final complaints = await _repository.getComplaints(userId: userId);
      state = complaints;
    } catch (e) {
      // Handle error
    }
  }

  Future<void> addComplaint(String userId, String text) async {
    try {
      final complaint = Complaint.create(userId: userId, text: text);
      await _repository.addComplaint(complaint);
      state = [...state, complaint];
    } catch (e) {
      // Handle error
      rethrow;
    }
  }

  Future<void> updateComplaint(Complaint complaint) async {
    try {
      await _repository.updateComplaint(complaint);
      state = state.map((c) => c.id == complaint.id ? complaint : c).toList();
    } catch (e) {
      // Handle error
      rethrow;
    }
  }

  Future<void> markAsHandled(String complaintId, String userId) async {
    try {
      await _repository.updateComplaintStatus(complaintId, 'handled');
      state = state.map((c) => 
        c.id == complaintId ? c.copyWith(status: 'handled') : c
      ).toList();
    } catch (e) {
      // Handle error
      rethrow;
    }
  }

  Future<void> deleteComplaint(String id) async {
    try {
      await _repository.deleteComplaint(id);
      state = state.where((c) => c.id != id).toList();
    } catch (e) {
      // Handle error
      rethrow;
    }
  }
}

// Provider principal pour les complaints
final complaintsNotifierProvider = StateNotifierProvider<ComplaintsNotifier, List<Complaint>>((ref) {
  return ComplaintsNotifier(ComplaintsRepository());
});

// Provider pour charger les complaints avec filtre optionnel
final complaintsProvider = FutureProvider.family<List<Complaint>, String?>((ref, userId) async {
  final repository = ComplaintsRepository();
  return repository.getComplaints(userId: userId);
}); 