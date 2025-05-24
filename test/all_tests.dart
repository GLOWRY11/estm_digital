import 'package:flutter_test/flutter_test.dart';

// Tests unitaires
import 'unit_tests/complaints/complaint_model_test.dart' as complaint_model_test;

// Tests de widget
// import 'widget_tests/complaints/complaints_screen_test.dart' as complaints_screen_test;

// Tests d'intégration
// import 'integration_tests/complaints_workflow_test.dart' as complaints_workflow_test;

void main() {
  group('Unit Tests', () {
    complaint_model_test.main();
  });

  /*
  group('Widget Tests', () {
    complaints_screen_test.main();
  });

  group('Integration Tests', () {
    complaints_workflow_test.main();
  });
  */
} 