# Tests de l'application ESTM Digital

Ce document décrit les tests implémentés dans l'application ESTM Digital.

## Structure des tests

```
test/
├── unit_tests/              # Tests unitaires
│   ├── core/                # Tests des fonctionnalités de base
│   │   └── local_database_test.dart  # Tests de la base de données locale
│   └── complaints/          # Tests unitaires de la fonctionnalité réclamations
│       └── complaint_model_test.dart # Tests du modèle Complaint
├── widget_tests/            # Tests des widgets
│   └── complaints/          # Tests des widgets de la fonctionnalité réclamations
│       └── complaints_screen_test.dart  # Tests de l'écran de réclamations
├── integration_tests/       # Tests d'intégration
│   └── complaints_workflow_test.dart  # Test du flux complet de réclamations
└── all_tests.dart           # Fichier pour exécuter tous les tests
```

## Tests unitaires

### Modèle Complaint

Fichier : `test/unit_tests/complaints/complaint_model_test.dart`

Ce test vérifie :
- La création d'une instance Complaint avec les propriétés attendues
- La conversion d'un objet Complaint vers et depuis un Map
- La création d'une nouvelle réclamation via la méthode factory `Complaint.create`
- La copie d'une réclamation avec des valeurs modifiées via `copyWith`

Ces tests assurent que le modèle de données fonctionne correctement et qu'il est compatible avec la persistance des données dans la base de données SQLite.

### Base de données locale

Fichier : `test/unit_tests/core/local_database_test.dart`

Ce test vérifie :
- La présence de toutes les tables requises dans le schéma de la base de données
- La présence des champs requis dans la table des réclamations

Des tests plus avancés (actuellement commentés) montreraient :
- La création correcte des tables dans la base de données
- L'insertion et la récupération des données
- La mise à jour et la suppression des données

## Tests de widget

Fichier : `test/widget_tests/complaints/complaints_screen_test.dart`

Ce test vérifie (actuellement désactivé) :
- L'affichage correct de l'écran de réclamations
- La présence des éléments UI attendus (formulaire, liste)
- L'affichage correct des réclamations dans la liste
- L'affichage d'un message approprié quand aucune réclamation n'existe

## Tests d'intégration

Fichier : `test/integration_tests/complaints_workflow_test.dart`

Ce test vérifie (actuellement désactivé) :
- Le flux complet de soumission d'une réclamation
- La différence de comportement entre un utilisateur étudiant et un enseignant/admin

## Exécution des tests

Pour exécuter tous les tests unitaires :

```bash
flutter test test/all_tests.dart
```

Pour exécuter un test spécifique :

```bash
flutter test test/unit_tests/complaints/complaint_model_test.dart
```

## Couverture des tests

Les tests actuels couvrent principalement :
- Le modèle de données Complaint
- La structure de la base de données

À améliorer dans le futur :
- Ajouter des tests pour les autres modèles (users, classes, etc.)
- Compléter les tests d'intégration avec des mocks de base de données
- Ajouter des tests pour les providers Riverpod
- Ajouter des tests de performance et de stress 