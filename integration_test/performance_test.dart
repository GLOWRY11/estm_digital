import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:estm_digital/main.dart' as app;

/// Ce test est configuré pour mesurer la performance de l'application.
/// Pour l'activer complètement:
/// 1. Ajoutez le package integration_test dans pubspec.yaml
/// 2. Décommentez les lignes appropriées dans ce fichier
/// 3. Exécutez le avec: flutter drive --target=integration_test/performance_test.dart

void main() {
  // Initialize the integration test binding
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  // This function measures execution time
  Future<int> measurePerformance(Future<void> Function() action) async {
    final stopwatch = Stopwatch()..start();
    await action();
    stopwatch.stop();
    return stopwatch.elapsedMilliseconds;
  }

  group('Performance Tests', () {
    testWidgets('App startup time measurement', (WidgetTester tester) async {
      // Launch the app and measure startup time
      final startupTime = await measurePerformance(() async {
        app.main();
        await tester.pumpAndSettle();
      });
      
      print('Application loaded in $startupTime milliseconds');
      
      // Log the performance data
      reportPerformanceData('startup_time', startupTime);
    });

    testWidgets('Navigation should be smooth', (WidgetTester tester) async {
      // Launch the app
      app.main();
      await tester.pumpAndSettle();
      
      // Log in with a test account if needed
      await tester.enterText(find.byType(TextFormField).at(0), 'admin@estm.sn');
      await tester.enterText(find.byType(TextFormField).at(1), 'admin123');
      await tester.tap(find.text('SE CONNECTER').last);
      await tester.pumpAndSettle();
      
      // Measure navigation time to a different screen
      // First, open the drawer
      final drawerTime = await measurePerformance(() async {
        await tester.tap(find.byType(IconButton).first);
        await tester.pumpAndSettle();
      });
      
      print('Drawer opened in $drawerTime milliseconds');
      reportPerformanceData('drawer_open_time', drawerTime);
      
      // Navigate to another screen
      final navigationTime = await measurePerformance(() async {
        // Try to find a navigation item in the drawer
        final navTarget = find.text('Absences');
        if (navTarget.evaluate().isNotEmpty) {
          await tester.tap(navTarget.last);
          await tester.pumpAndSettle();
        } else {
          // If 'Absences' not found, try any text that might be a navigation item
          final anyMenuItem = find.descendant(
            of: find.byType(ListView),
            matching: find.byType(ListTile),
          ).first;
          await tester.tap(anyMenuItem);
          await tester.pumpAndSettle();
        }
      });
      
      print('Navigation completed in $navigationTime milliseconds');
      reportPerformanceData('navigation_time', navigationTime);
    });

    testWidgets('Scrolling should be smooth', (WidgetTester tester) async {
      // Launch the app and login
      app.main();
      await tester.pumpAndSettle();
      
      // Log in with a test account
      await tester.enterText(find.byType(TextFormField).at(0), 'admin@estm.sn');
      await tester.enterText(find.byType(TextFormField).at(1), 'admin123');
      await tester.tap(find.text('SE CONNECTER').last);
      await tester.pumpAndSettle();
      
      // Navigate to a screen with a scrollable list if needed
      await tester.tap(find.byType(IconButton).first); // Open drawer
      await tester.pumpAndSettle();
      
      // Try to find a list-related menu item
      final possibleMenuItems = ['Étudiants', 'Utilisateurs', 'Absences', 'Rapports'];
      for (final item in possibleMenuItems) {
        final menuItem = find.text(item);
        if (menuItem.evaluate().isNotEmpty) {
          await tester.tap(menuItem.last);
          await tester.pumpAndSettle();
          break;
        }
      }
      
      // Try to find a scrollable list
      final scrollable = find.byType(Scrollable);
      if (scrollable.evaluate().isNotEmpty) {
        // Measure scrolling performance
        final scrollTime = await measurePerformance(() async {
          await tester.fling(scrollable.first, const Offset(0, -500), 1000);
          await tester.pumpAndSettle();
        });
        
        print('Scrolling completed in $scrollTime milliseconds');
        reportPerformanceData('scroll_time', scrollTime);
      } else {
        print('No scrollable list found to test');
      }
    });
  });
}

// Helper function to report performance data
void reportPerformanceData(String metricName, int value) {
  final binding = IntegrationTestWidgetsFlutterBinding.instance;
  binding.reportData = <String, dynamic>{
    ...binding.reportData ?? <String, dynamic>{},
    metricName: value,
  };
} 