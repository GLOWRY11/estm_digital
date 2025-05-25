import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Écrans d'authentification
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';

// Écrans principaux par rôle
import '../../features/auth/presentation/screens/admin_home_screen.dart';
import '../../features/teacher/presentation/screens/teacher_home_screen.dart';
import '../../features/auth/presentation/screens/student_home_screen.dart';

// QR Code
import '../../features/qr_scanner/qr_scanner_screen.dart';
import '../../features/qr_generator/qr_generator_screen.dart';

// Gestion des utilisateurs
import '../../features/user_management/presentation/screens/users_list_screen.dart';
import '../../features/user_management/presentation/screens/user_form_screen.dart';
import '../../features/user_management/presentation/screens/user_detail_screen.dart';

// Réclamations
import '../../features/complaints/presentation/screens/complaints_list_screen.dart';
import '../../features/complaints/presentation/screens/complaint_form_screen.dart';

// Absences
import '../../features/absence/presentation/screens/absence_list_screen.dart';
import '../../features/absence/presentation/screens/absence_form_screen.dart';

// Autres modules
import '../../features/courses/presentation/screens/courses_list_screen.dart';
import '../../features/grades/presentation/screens/grades_list_screen.dart';
import '../../features/scheduling/presentation/screens/schedule_screen.dart';
import '../../features/reporting/presentation/screens/reports_screen.dart';

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
  
  // Routes principales par rôle
  static const String adminHome = '/admin_home';
  static const String teacherHome = '/teacher_home';
  static const String studentHome = '/student_home';
  
  // Routes pour la gestion des utilisateurs
  static const String userForm = '/users/form';
  static const String userDetail = '/users/detail';
  
  // Routes pour les réclamations
  static const String complaintForm = '/complaints/form';
  
  // Routes pour les absences
  static const String absences = '/absences';
  
  // Autres modules
  static const String courses = '/courses';
  static const String grades = '/grades';
  static const String schedule = '/schedule';
  
  static final GoRouter router = GoRouter(
    initialLocation: login,
    routes: [
      // Authentification
      GoRoute(
        path: login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: register,
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),

      // Écrans d'accueil par rôle
      GoRoute(
        path: adminHome,
        name: 'admin_home',
        builder: (context, state) => const AdminHomeScreen(),
      ),
      GoRoute(
        path: teacherHome,
        name: 'teacher_home',
        builder: (context, state) => const TeacherHomeScreen(),
      ),
      GoRoute(
        path: studentHome,
        name: 'student_home',
        builder: (context, state) => const StudentHomeScreen(),
      ),

      // QR Code
      GoRoute(
        path: qrScanner,
        name: 'qr_scanner',
        builder: (context, state) => const QRScannerScreen(),
      ),
      GoRoute(
        path: qrGenerator,
        name: 'qr_generator',
        builder: (context, state) => const QRGeneratorScreen(),
      ),

      // Gestion des utilisateurs
      GoRoute(
        path: usersList,
        name: 'users_list',
        builder: (context, state) => const UsersListScreen(),
      ),
      GoRoute(
        path: userForm,
        name: 'user_form',
        builder: (context, state) {
          final userId = state.pathParameters['id'];
          return UserFormScreen(userId: userId);
        },
      ),
      GoRoute(
        path: '/users/detail/:id',
        name: 'user_detail',
        builder: (context, state) {
          final userId = state.pathParameters['id']!;
          return UserDetailScreen(userId: userId);
        },
      ),

      // Réclamations
      GoRoute(
        path: complaints,
        name: 'complaints',
        builder: (context, state) => const ComplaintsListScreen(),
      ),
      GoRoute(
        path: complaintForm,
        name: 'complaint_form',
        builder: (context, state) {
          final complaintId = state.pathParameters['id'];
          return ComplaintFormScreen(complaintId: complaintId);
        },
      ),

      // Absences
      GoRoute(
        path: absences,
        name: 'absences',
        builder: (context, state) => const AbsenceListScreen(),
      ),
      GoRoute(
        path: absenceForm,
        name: 'absence_form',
        builder: (context, state) => const AbsenceFormScreen(),
      ),

      // Autres modules
      GoRoute(
        path: courses,
        name: 'courses',
        builder: (context, state) => const CoursesListScreen(),
      ),
      GoRoute(
        path: grades,
        name: 'grades',
        builder: (context, state) => const GradesListScreen(),
      ),
      GoRoute(
        path: schedule,
        name: 'schedule',
        builder: (context, state) => const ScheduleScreen(),
      ),
      GoRoute(
        path: reports,
        name: 'reports',
        builder: (context, state) => const ReportsScreen(),
      ),
    ],

    // Gestion des erreurs
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Erreur')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Page non trouvée',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'La page demandée n\'existe pas ou a été déplacée.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(login),
              child: const Text('Retour à l\'accueil'),
            ),
          ],
        ),
      ),
    ),
  );
} 