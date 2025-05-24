import 'package:flutter/material.dart';

// Écrans d'Absence
import 'package:estm_digital/features/absence/presentation/screens/absence_list_screen.dart';
// Écrans de Filière
import 'package:estm_digital/features/filiere/presentation/screens/filiere_list_screen.dart';
// Écrans de Cours
import 'package:estm_digital/features/courses/presentation/screens/courses_list_screen.dart';
import 'package:estm_digital/features/courses/presentation/screens/add_course_screen.dart';
// Écrans de Notes
import 'package:estm_digital/features/grades/presentation/screens/teacher_grades_screen.dart';
import 'package:estm_digital/features/grades/presentation/screens/grades_list_screen.dart';
// Écrans d'Authentification (commenté car non utilisé dans les routes actuelles)// import 'package:estm_digital/features/auth/presentation/screens/auth_screen.dart';
// Écrans de Gestion des Utilisateurs
import 'package:estm_digital/features/user_management/presentation/screens/users_list_screen.dart';
// Écrans de Gestion des Réclamations
import 'package:estm_digital/features/complaints/presentation/screens/complaints_list_screen.dart';
// Écrans Temporaires
import 'package:estm_digital/core/widgets/temp_screen.dart';

class AppRoutes {
  // Routes générales
  static const String home = '/';
  
  // Routes d'authentification
  static const String login = '/login';
  static const String register = '/register';
  
  // Routes pour les absences
  static const String absenceList = '/absences';
  static const String absenceForm = '/absences/form';
  
  // Routes pour les filières
  static const String filiereList = '/filieres';
  static const String filiereForm = '/filieres/form';
  
  // Routes pour les cours
  static const String coursesList = '/courses-list';
  static const String addCourse = '/add-course';
  
  // Routes pour les notes
  static const String gradesList = '/grades-list';
  static const String teacherGrades = '/teacher-grades';
  
  // Routes pour la gestion des utilisateurs et réclamations
  static const String usersList = '/users-list';
  static const String complaints = '/complaints';
  static const String qrScanner = '/qr-scanner';
  static const String qrGenerator = '/qr-generator';
  static const String userProfile = '/user-profile';
  
  // Routes existantes
  static const String reports = '/reports';
  static const String calendar = '/calendar';
  
  // Routes pour la base de données locale
  static const String testDatabase = '/test-database';
  
  // Définir les routes de l'application
  static Map<String, Widget Function(BuildContext)> getRoutes() {
    return {
      // Routes pour les absences
      absenceList: (context) => const AbsenceListScreen(),
      
      // Routes pour les filières
      filiereList: (context) => const FiliereListScreen(),
      filiereForm: (context) => const TempScreen(title: 'Formulaire Filière'),
      
      // Routes pour les cours
      coursesList: (context) => const CoursesListScreen(),
      addCourse: (context) => const AddCourseScreen(),
      
      // Routes pour les notes
      gradesList: (context) => const GradesListScreen(),
      teacherGrades: (context) => const TeacherGradesScreen(),
      
      // Routes pour la gestion des utilisateurs
      usersList: (context) => const UsersListScreen(),
      
      // Routes pour les réclamations
      complaints: (context) => const ComplaintsListScreen(),
      
      // Routes temporaires
      qrScanner: (context) => const TempScreen(title: 'Scanner QR'),
      qrGenerator: (context) => const TempScreen(title: 'Générateur QR'),
      userProfile: (context) => const TempScreen(title: 'Profil Utilisateur'),
      reports: (context) => const TempScreen(title: 'Rapports'),
      calendar: (context) => const TempScreen(title: 'Calendrier'),
    };
  }
} 