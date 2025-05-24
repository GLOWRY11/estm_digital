// NOTE: Pour utiliser ce driver, vous devez ajouter le package integration_test
// à votre pubspec.yaml dans la section dev_dependencies comme suit:
//
// dev_dependencies:
//   integration_test:
//     sdk: flutter

// Décommenter ces lignes quand vous ajoutez le package integration_test:
// import 'package:integration_test/integration_test_driver.dart';
// Future<void> main() => integrationDriver(); 

// This file is used by the integration_test package to drive tests on a real device
import 'package:integration_test/integration_test_driver.dart';

Future<void> main() => integrationDriver(); 