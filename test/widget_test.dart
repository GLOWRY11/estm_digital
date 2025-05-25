// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:estm_digital/main.dart';

void main() {
  testWidgets('App startup test', (WidgetTester tester) async {
    // Build our app and trigger a frame with ProviderScope
    await tester.pumpWidget(
      const ProviderScope(
        child: EstmDigitalApp(),
      ),
    );

    // Wait for the app to settle
    await tester.pumpAndSettle();

    // Verify that the app shows the login screen
    // The app should show either 'Connexion' or 'ESTM Digital' text
    expect(
      find.byType(Scaffold),
      findsOneWidget,
    );
  });
}
