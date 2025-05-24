import 'dart:developer' as developer;
import '../../../../core/local_database.dart';
import '../models/class_model.dart';
import '../models/user_model.dart';
import 'package:sqflite/sqflite.dart';

class UserLocalDataSource {
  // User operations
  Future<void> saveUser(ExtendedUserModel user, {int syncStatus = 0}) async {
    try {
      final db = await LocalDatabase.open();
      final userData = user.toMap();
      userData['syncStatus'] = syncStatus;
      
      await db.insert(
        'users',
        userData,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      
      developer.log('Utilisateur enregistré: ${user.uid}');
    } catch (e) {
      developer.log('Erreur lors de l\'enregistrement de l\'utilisateur: $e');
      throw Exception('Échec de l\'enregistrement de l\'utilisateur: $e');
    }
  }

  Future<void> updateUser(ExtendedUserModel user, {int syncStatus = 1}) async {
    try {
      final db = await LocalDatabase.open();
      final userData = user.toMap();
      userData['syncStatus'] = syncStatus;
      
      await db.update(
        'users',
        userData,
        where: 'id = ?',
        whereArgs: [user.uid],
      );

      // Add to sync log
      if (syncStatus == 1) {
        await _addToSyncLog(
          entityType: 'user',
          entityId: user.uid,
          action: 'update',
          data: userData.toString(),
        );
      }
      
      developer.log('Utilisateur mis à jour: ${user.uid}');
    } catch (e) {
      developer.log('Erreur lors de la mise à jour de l\'utilisateur: $e');
      throw Exception('Échec de la mise à jour de l\'utilisateur: $e');
    }
  }

  Future<void> deleteUser(String uid, {bool softDelete = true}) async {
    try {
      final db = await LocalDatabase.open();
      
      if (softDelete) {
        await db.update(
          'users',
          {'isActive': 0, 'syncStatus': 1},
          where: 'id = ?',
          whereArgs: [uid],
        );

        // Add to sync log
        await _addToSyncLog(
          entityType: 'user',
          entityId: uid,
          action: 'deactivate',
        );
        
        developer.log('Utilisateur désactivé: $uid');
      } else {
        await db.delete(
          'users',
          where: 'id = ?',
          whereArgs: [uid],
        );

        // Add to sync log
        await _addToSyncLog(
          entityType: 'user',
          entityId: uid,
          action: 'delete',
        );
        
        developer.log('Utilisateur supprimé: $uid');
      }
    } catch (e) {
      developer.log('Erreur lors de la suppression de l\'utilisateur: $e');
      throw Exception('Échec de la suppression de l\'utilisateur: $e');
    }
  }

  Future<ExtendedUserModel?> getUserById(String uid) async {
    try {
      final db = await LocalDatabase.open();
      final List<Map<String, dynamic>> maps = await db.query(
        'users',
        where: 'id = ?',
        whereArgs: [uid],
      );

      if (maps.isEmpty) return null;
      developer.log('Utilisateur trouvé: $uid');
      return ExtendedUserModel.fromMap(maps.first);
    } catch (e) {
      developer.log('Erreur lors de la récupération de l\'utilisateur: $e');
      throw Exception('Échec de la récupération de l\'utilisateur: $e');
    }
  }

  Future<List<ExtendedUserModel>> getTeachers() async {
    try {
      final db = await LocalDatabase.open();
      final List<Map<String, dynamic>> maps = await db.query(
        'users',
        where: 'role = ?',
        whereArgs: ['teacher'],
      );

      final teachers = List.generate(maps.length, (i) {
        return ExtendedUserModel.fromMap(maps[i]);
      });
      
      developer.log('${teachers.length} enseignants récupérés');
      return teachers;
    } catch (e) {
      developer.log('Erreur lors de la récupération des enseignants: $e');
      throw Exception('Échec de la récupération des enseignants: $e');
    }
  }

  Future<List<ExtendedUserModel>> getStudents() async {
    try {
      final db = await LocalDatabase.open();
      final List<Map<String, dynamic>> maps = await db.query(
        'users',
        where: 'role = ?',
        whereArgs: ['student'],
      );

      final students = List.generate(maps.length, (i) {
        return ExtendedUserModel.fromMap(maps[i]);
      });
      
      developer.log('${students.length} étudiants récupérés');
      return students;
    } catch (e) {
      developer.log('Erreur lors de la récupération des étudiants: $e');
      throw Exception('Échec de la récupération des étudiants: $e');
    }
  }

  Future<List<ExtendedUserModel>> getStudentsByClass(String classId) async {
    try {
      final db = await LocalDatabase.open();
      final List<Map<String, dynamic>> maps = await db.query(
        'users',
        where: 'role = ? AND classId = ?',
        whereArgs: ['student', classId],
      );

      final students = List.generate(maps.length, (i) {
        return ExtendedUserModel.fromMap(maps[i]);
      });
      
      developer.log('${students.length} étudiants récupérés pour la classe: $classId');
      return students;
    } catch (e) {
      developer.log('Erreur lors de la récupération des étudiants par classe: $e');
      throw Exception('Échec de la récupération des étudiants par classe: $e');
    }
  }

  // Class operations
  Future<void> saveClass(ClassModel classModel, {int syncStatus = 0}) async {
    try {
      final db = await LocalDatabase.open();
      final classData = classModel.toMap();
      classData['syncStatus'] = syncStatus;
      
      await db.insert(
        'classes',
        classData,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      
      developer.log('Classe enregistrée: ${classModel.id}');
    } catch (e) {
      developer.log('Erreur lors de l\'enregistrement de la classe: $e');
      throw Exception('Échec de l\'enregistrement de la classe: $e');
    }
  }

  Future<void> updateClass(ClassModel classModel, {int syncStatus = 1}) async {
    try {
      final db = await LocalDatabase.open();
      final classData = classModel.toMap();
      classData['syncStatus'] = syncStatus;
      
      await db.update(
        'classes',
        classData,
        where: 'id = ?',
        whereArgs: [classModel.id],
      );

      // Add to sync log
      if (syncStatus == 1) {
        await _addToSyncLog(
          entityType: 'class',
          entityId: classModel.id,
          action: 'update',
          data: classData.toString(),
        );
      }
      
      developer.log('Classe mise à jour: ${classModel.id}');
    } catch (e) {
      developer.log('Erreur lors de la mise à jour de la classe: $e');
      throw Exception('Échec de la mise à jour de la classe: $e');
    }
  }

  Future<void> deleteClass(String classId) async {
    try {
      final db = await LocalDatabase.open();
      
      await db.delete(
        'classes',
        where: 'id = ?',
        whereArgs: [classId],
      );

      // Add to sync log
      await _addToSyncLog(
        entityType: 'class',
        entityId: classId,
        action: 'delete',
      );
      
      developer.log('Classe supprimée: $classId');
    } catch (e) {
      developer.log('Erreur lors de la suppression de la classe: $e');
      throw Exception('Échec de la suppression de la classe: $e');
    }
  }

  Future<ClassModel?> getClassById(String classId) async {
    try {
      final db = await LocalDatabase.open();
      final List<Map<String, dynamic>> maps = await db.query(
        'classes',
        where: 'id = ?',
        whereArgs: [classId],
      );

      if (maps.isEmpty) return null;
      
      developer.log('Classe trouvée: $classId');
      return ClassModel.fromMap(maps.first);
    } catch (e) {
      developer.log('Erreur lors de la récupération de la classe: $e');
      throw Exception('Échec de la récupération de la classe: $e');
    }
  }

  Future<List<ClassModel>> getClasses() async {
    try {
      final db = await LocalDatabase.open();
      final List<Map<String, dynamic>> maps = await db.query('classes');

      final classes = List.generate(maps.length, (i) {
        return ClassModel.fromMap(maps[i]);
      });
      
      developer.log('${classes.length} classes récupérées');
      return classes;
    } catch (e) {
      developer.log('Erreur lors de la récupération des classes: $e');
      throw Exception('Échec de la récupération des classes: $e');
    }
  }

  // Sync operations
  Future<List<Map<String, dynamic>>> getPendingSyncOperations() async {
    try {
      final db = await LocalDatabase.open();
      final results = await db.query(
        'sync_log',
        where: 'synced = ?',
        whereArgs: [0],
      );
      
      developer.log('${results.length} opérations de synchronisation en attente');
      return results;
    } catch (e) {
      developer.log('Erreur lors de la récupération des opérations de synchronisation: $e');
      throw Exception('Échec de la récupération des opérations de synchronisation: $e');
    }
  }

  Future<void> markSyncOperationCompleted(int id) async {
    try {
      final db = await LocalDatabase.open();
      await db.update(
        'sync_log',
        {'synced': 1},
        where: 'id = ?',
        whereArgs: [id],
      );
      
      developer.log('Opération de synchronisation marquée comme terminée: $id');
    } catch (e) {
      developer.log('Erreur lors du marquage de l\'opération de synchronisation: $e');
      throw Exception('Échec du marquage de l\'opération de synchronisation: $e');
    }
  }

  Future<void> _addToSyncLog({
    required String entityType,
    required String entityId,
    required String action,
    String? data,
  }) async {
    try {
      final db = await LocalDatabase.open();
      await db.insert('sync_log', {
        'entityType': entityType,
        'entityId': entityId,
        'action': action,
        'timestamp': DateTime.now().toIso8601String(),
        'data': data,
        'synced': 0,
      });
      
      developer.log('Entrée ajoutée au journal de synchronisation: $entityType $entityId $action');
    } catch (e) {
      developer.log('Erreur lors de l\'ajout au journal de synchronisation: $e');
      throw Exception('Échec de l\'ajout au journal de synchronisation: $e');
    }
  }
} 