# Guide de test de performance pour ESTM Digital

Ce document explique comment exécuter des tests de performance et analyser les résultats pour l'application ESTM Digital.

## Prérequis

- Flutter SDK installé
- Un appareil Android connecté ou un émulateur en cours d'exécution
- Dépendances du projet installées (`flutter pub get`)

## Tests de performance

### 1. Tests de performance avec integration_test

Pour exécuter les tests de performance intégrés:

```bash
flutter test integration_test/performance_test.dart
```

### 2. Mesure des FPS et du temps de démarrage

Pour analyser la performance de l'application en détail:

```bash
# Construire l'application en mode profil
flutter build apk --profile

# Exécuter avec traçage activé
flutter drive --profile --target=integration_test/performance_test.dart --driver=integration_test/driver.dart --trace-startup --trace-skia
```

### 3. Génération d'un rapport de performance

```bash
# Exécuter avec dump de profil (crée un rapport HTML)
flutter drive --profile --target=integration_test/performance_test.dart --driver=integration_test/driver.dart --profile-dump
```

Le rapport HTML sera généré dans le répertoire `build/`.

### 4. Observer les métriques en temps réel

Vous pouvez également observer les performances en temps réel avec l'outil DevTools de Flutter:

```bash
# Démarrer l'application en mode profile
flutter run --profile

# Puis connecter DevTools dans votre navigateur à l'URL indiquée
```

## Analyse des résultats

### Métriques importantes à surveiller

1. **Temps de démarrage**: Idéalement inférieur à 300ms
2. **Jank (saccades)**: Moins de frames qui prennent > 16ms
3. **Utilisation mémoire**: Pas de fuites mémoire, croissance stable
4. **Taille de l'APK**: Avec les optimisations R8/ProGuard

### Optimisation recommandées

Si les performances ne sont pas optimales:

1. Réduire le nombre de widgets reconstruits
2. Utiliser `const` pour les widgets immuables
3. Implémenter la virtualisation des listes avec `ListView.builder`
4. Optimiser les assets (images, polices)
5. Différer le chargement du code non essentiel

## Interprétation du rapport d'obfuscation

Après avoir construit l'APK obfusquée, un fichier mapping sera généré dans:
`build/app/outputs/mapping/release/mapping.txt`

Ce fichier est essentiel pour déboguer les rapports de plantage d'une version obfusquée. 