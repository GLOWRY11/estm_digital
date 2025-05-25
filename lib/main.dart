import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

// Base de données locale
import 'core/local_database.dart';
import 'core/theme/app_theme.dart';

// Navigation
import 'features/auth/presentation/login_screen.dart';
import 'features/auth/presentation/register_screen.dart';
import 'features/auth/presentation/screens/admin_home_screen.dart';
import 'features/teacher/presentation/screens/teacher_home_screen.dart';
import 'features/auth/presentation/screens/student_home_screen.dart';

// QR Code
import 'features/qr_scanner/qr_scanner_screen.dart';
import 'features/qr_generator/qr_generator_screen.dart';

// User Management
import 'features/user_management/presentation/screens/users_list_screen.dart';
import 'features/user_management/presentation/screens/user_form_screen.dart';
import 'features/user_management/presentation/screens/user_detail_screen.dart';

// Complaints
import 'features/complaints/presentation/screens/complaints_list_screen.dart';
import 'features/complaints/presentation/screens/complaint_form_screen.dart';

// Absences
import 'features/absence/presentation/screens/absence_list_screen.dart';

// Other modules
import 'features/courses/presentation/screens/courses_screen.dart';
import 'features/grades/presentation/screens/grades_screen.dart';
import 'features/scheduling/presentation/screens/schedule_screen.dart';
import 'features/reporting/presentation/screens/reports_screen.dart';

// Configuration
const String appName = 'ESTM Digital';
const String appVersion = '2.0.0';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialiser la base de données SQLite
  try {
    final db = await LocalDatabase.open();
    print('✅ Base de données SQLite initialisée avec succès');
    print('📊 Tables créées et données par défaut insérées');
  } catch (e) {
    print('❌ Erreur d\'initialisation de la base de données: $e');
  }

  runApp(
    const ProviderScope(
      child: EstmDigitalApp(),
    ),
  );
}

class EstmDigitalApp extends ConsumerWidget {
  const EstmDigitalApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: appName,
      debugShowCheckedModeBanner: false,
      
      // Thème Material Design 3
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      
      // Localisation
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('fr', 'FR'), // Français
        Locale('en', 'US'), // Anglais
      ],
      locale: const Locale('fr', 'FR'),
      
      // Configuration de base
      home: const AuthenticationWrapper(),
      
      // Routes nommées pour compatibilité
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/admin_home': (context) => const AdminHomeScreen(),
        '/teacher_home': (context) => const TeacherHomeScreen(),
        '/student_home': (context) => const StudentHomeScreen(),
        '/qr_scanner': (context) => const QRScannerScreen(),
        '/qr_generator': (context) => const QRGeneratorScreen(),
        '/users': (context) => const UsersListScreen(),
        '/user_form': (context) => const UserFormScreen(),
        '/complaints': (context) => const ComplaintsListScreen(),
        '/complaint_form': (context) => const ComplaintFormScreen(),
        '/absences': (context) => const AbsenceListScreen(),
        '/courses': (context) => const CoursesScreen(),
        '/grades': (context) => const GradesScreen(),
        '/schedule': (context) => const ScheduleScreen(),
        '/reports': (context) => const ReportsScreen(),
      },
      onGenerateRoute: (settings) {
        // Gestion des routes avec paramètres
        if (settings.name?.startsWith('/user_detail/') == true) {
          final userId = settings.name!.split('/').last;
          return MaterialPageRoute(
            builder: (context) => UserDetailScreen(userId: userId),
          );
        }
        
        if (settings.name?.startsWith('/user_form/') == true) {
          final userId = settings.name!.split('/').last;
          return MaterialPageRoute(
            builder: (context) => UserFormScreen(userId: userId),
          );
        }
        
        if (settings.name?.startsWith('/complaint_form/') == true) {
          final complaintId = settings.name!.split('/').last;
          return MaterialPageRoute(
            builder: (context) => ComplaintFormScreen(complaintId: complaintId),
          );
        }
        
        return null;
      },
    );
  }
}

// Wrapper d'authentification qui gère l'état de connexion
class AuthenticationWrapper extends ConsumerWidget {
  const AuthenticationWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Pour l'instant, on va directement à l'écran de connexion
    // Plus tard, on vérifiera l'état d'authentification depuis SQLite
    return const LoginScreen();
  }
}

// Écran temporaire pour les fonctionnalités en développement
class _ComingSoonScreen extends StatelessWidget {
  final String title;
  
  const _ComingSoonScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.construction,
                size: 80,
                color: colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'Fonctionnalité en développement',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Cette section de $title sera bientôt disponible.',
                style: TextStyle(
                  fontSize: 16,
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Retour'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
