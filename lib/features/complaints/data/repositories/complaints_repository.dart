import 'package:sqflite/sqflite.dart';
import '../../../../core/local_database.dart';
import '../../domain/models/complaint.dart';

class ComplaintsRepository {
  Future<List<Complaint>> getComplaints({String? userId}) async {
    final Database db = await LocalDatabase.open();
    
    final List<Map<String, dynamic>> maps;
    
    if (userId != null) {
      // Si userId est fourni, filtrer par utilisateur
      maps = await db.query(
        'complaints',
        where: 'userId = ?',
        whereArgs: [userId],
        orderBy: 'createdAt DESC',
      );
    } else {
      // Sinon récupérer toutes les réclamations
      maps = await db.query(
        'complaints',
        orderBy: 'createdAt DESC',
      );
    }
    
    return List.generate(maps.length, (i) {
      return Complaint.fromMap(maps[i]);
    });
  }
  
  // Alias pour compatibilité avec le provider
  Future<List<Complaint>> getAllComplaints() async {
    return getComplaints();
  }
  
  Future<Complaint> addComplaint(Complaint complaint) async {
    final Database db = await LocalDatabase.open();
    
    await db.insert('complaints', complaint.toMap());
    
    return complaint;
  }
  
  Future<void> updateComplaintStatus(String complaintId, String status) async {
    final Database db = await LocalDatabase.open();
    
    await db.update(
      'complaints',
      {'status': status},
      where: 'id = ?',
      whereArgs: [complaintId],
    );
  }
  
  // Méthode pour mettre à jour une réclamation complète
  Future<void> updateComplaint(Complaint complaint) async {
    final Database db = await LocalDatabase.open();
    
    await db.update(
      'complaints',
      complaint.toMap(),
      where: 'id = ?',
      whereArgs: [complaint.id],
    );
  }
  
  Future<void> deleteComplaint(String complaintId) async {
    final Database db = await LocalDatabase.open();
    
    await db.delete(
      'complaints',
      where: 'id = ?',
      whereArgs: [complaintId],
    );
  }
} 