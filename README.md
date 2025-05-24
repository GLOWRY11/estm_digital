# ESTM Digital

Application mobile Flutter pour l'École Supérieure de Technologie et de Management (ESTM).

## Architecture

Ce projet utilise **Clean Architecture** combinée avec **Riverpod** pour la gestion d'état.

### Clean Architecture

L'application est structurée selon les principes de Clean Architecture, qui sépare le code en couches concentriques :

```
lib/
├── core/          # Utilitaires et services communs à toute l'application
├── features/      # Fonctionnalités de l'application organisées par domaine
│   └── feature_x/
│       ├── data/              # Couche Data (repositories, datasources)
│       │   ├── datasources/   # Sources de données (API, local)
│       │   ├── models/        # Modèles de données (DTOs)
│       │   └── repositories/  # Implémentations des repositories
│       ├── domain/            # Couche Domain (entités, use cases)
│       │   ├── entities/      # Modèles métier
│       │   ├── repositories/  # Interfaces des repositories
│       │   └── usecases/      # Cas d'utilisation
│       └── presentation/      # Couche Presentation (UI, controllers)
│           ├── providers/     # Providers Riverpod
│           ├── screens/       # Écrans
│           └── widgets/       # Widgets réutilisables
└── shared/        # Composants partagés entre features
```

#### Avantages de Clean Architecture

1. **Indépendance des frameworks** : La logique métier ne dépend pas de Flutter ou de bibliothèques externes
2. **Testabilité** : Chaque couche peut être testée indépendamment
3. **Maintenabilité** : La séparation des responsabilités facilite l'évolution de l'application
4. **Évolutivité** : Ajout de nouvelles fonctionnalités sans impacter le code existant

### Riverpod

[Riverpod](https://riverpod.dev/) est utilisé comme solution de gestion d'état. C'est une évolution de Provider qui offre une meilleure sécurité de type et facilite la gestion des dépendances.

#### Types de providers principaux

1. **Provider** : Expose une valeur en lecture seule
2. **StateProvider** : Gère un état simple modifiable
3. **StateNotifierProvider** : Gère un état complexe via une classe StateNotifier
4. **FutureProvider** : Gère des opérations asynchrones et leurs états
5. **StreamProvider** : Traite les flux de données asynchrones

#### Intégration avec Clean Architecture

```dart
// Domain - Use case
class GetUserUseCase {
  final UserRepository repository;
  
  GetUserUseCase(this.repository);
  
  Future<User> execute(String userId) => repository.getUser(userId);
}

// Presentation - Provider
final getUserProvider = Provider((ref) => GetUserUseCase(ref.watch(userRepositoryProvider)));

final userProvider = FutureProvider.family<User, String>((ref, userId) async {
  final useCase = ref.watch(getUserProvider);
  return useCase.execute(userId);
});

// Presentation - UI
Consumer(
  builder: (context, ref, child) {
    final userAsyncValue = ref.watch(userProvider(userId));
    
    return userAsyncValue.when(
      data: (user) => UserProfileWidget(user: user),
      loading: () => const CircularProgressIndicator(),
      error: (error, stackTrace) => Text('Error: $error'),
    );
  },
)
```

## Tests et Qualité du Code

L'application intègre différents types de tests pour assurer sa qualité et sa robustesse :

### Structure des tests

```
test/
├── unit_tests/              # Tests unitaires
│   ├── core/                # Tests des fonctionnalités de base
│   └── features/            # Tests unitaires par fonctionnalité
│       └── complaints/      # Tests unitaires de la fonctionnalité réclamations
├── widget_tests/            # Tests des widgets
│   └── complaints/          # Tests des widgets de la fonctionnalité réclamations
├── integration_tests/       # Tests d'intégration
│   └── complaints_workflow_test.dart  # Test du flux complet de réclamations
└── all_tests.dart           # Fichier pour exécuter tous les tests
```

### Types de tests

1. **Tests unitaires** : Testent les différentes parties du code en isolation
   - Tests des modèles (ex: Complaint)
   - Tests des repositories
   - Tests des providers

2. **Tests de widgets** : Testent le comportement des composants UI
   - Tests de rendu
   - Tests d'interaction

3. **Tests d'intégration** : Testent l'interaction entre différentes parties de l'application
   - Tests de flux complets (ex: soumission et gestion d'une réclamation)

### Exécution des tests

Pour exécuter tous les tests :

```bash
flutter test
```

Pour exécuter un test spécifique :

```bash
flutter test test/unit_tests/complaints/complaint_model_test.dart
```

Pour exécuter tous les tests avec couverture de code :

```bash
flutter test --coverage
```

## Dépendances principales

- **Firebase** : Authentication, Firestore
- **flutter_riverpod** : Gestion d'état
- **sqflite & path_provider** : Stockage local
- **qr_flutter & mobile_scanner** : Génération et scan de QR codes
- **flutter_local_notifications** : Notifications locales
- **intl** : Internationalisation
- **charts_flutter** : Visualisations graphiques
- **pdf & share_plus** : Génération et partage de PDF
- **uuid** : Génération d'identifiants uniques
- **table_calendar** : Affichage du calendrier

### Dépendances de développement

- **flutter_test** : Framework de test Flutter
- **sqflite_common_ffi** : Support de SQLite pour les tests
- **mockito** : Création de mocks pour les tests
- **build_runner** : Génération de code
- **flutter_lints** : Linting du code
