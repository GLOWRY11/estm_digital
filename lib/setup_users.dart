import 'package:uuid/uuid.dart';
import 'core/local_database.dart';

Future<void> setupDefaultUsers() async {
  final db = await LocalDatabase.open();
  
  // Vérifier si des utilisateurs existent déjà
  final users = await db.query('users');
  if (users.isNotEmpty) {
    print('Des utilisateurs existent déjà dans la base de données');
    return;
  }
  
  // Créer un utilisateur admin
  await db.insert('users', {
    'id': const Uuid().v4(),
    'email': 'admin@estm.sn',
    'password': 'admin123',
    'role': 'admin',
  });
  
  // Créer un utilisateur enseignant
  await db.insert('users', {
    'id': const Uuid().v4(),
    'email': 'prof@estm.sn',
    'password': 'prof123',
    'role': 'teacher',
  });
  
  // Créer un utilisateur étudiant
  await db.insert('users', {
    'id': const Uuid().v4(),
    'email': 'etudiant@estm.sn',
    'password': 'etudiant123',
    'role': 'student',
  });
  
  print('Utilisateurs par défaut créés avec succès');
} 