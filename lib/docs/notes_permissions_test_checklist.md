# Checklist de Test - Permissions Notes & Évaluations

## 📱 Tests sur Android APK

**Version**: APK Debug installée avec succès  
**Émulateur**: Android x86_64  
**Date de test**: À compléter par le testeur  
**Objectif**: Valider les permissions différentielles Student vs Teacher

---

## 👨‍🎓 **TESTS PERMISSIONS ÉTUDIANT**

### Prérequis: Connexion Student
- [ ] Ouvrir l'application ESTM Digital
- [ ] Se connecter avec les identifiants étudiant:
  - **Email**: `student@estm.sn`
  - **Password**: `student123`
- [ ] Vérifier la connexion réussie (redirection vers StudentHomeScreen)

### ✅ Test 1: Interface AppBar Étudiant
- [ ] Naviguer vers "Mes Notes" ou "Notes & Évaluations"
- [ ] Vérifier la présence du titre "Notes & Évaluations"
- [ ] **VÉRIFICATION CRITIQUE**: Confirmer l'**ABSENCE** du bouton "+" dans l'AppBar
- [ ] **Résultat attendu**: AppBar sans actions (pas de bouton d'ajout)

### ✅ Test 2: Fonctionnalités Lecture Seule
- [ ] Observer la liste des matières (Mathématiques, Informatique, Physique)
- [ ] Vérifier l'affichage des moyennes par matière
- [ ] Cliquer pour développer une matière (ExpansionTile)
- [ ] **Vérifications dans chaque matière**:
  - [ ] Affichage des notes individuelles ✅
  - [ ] Affichage des coefficients ✅
  - [ ] Affichage des dates d'évaluation ✅
  - [ ] Moyennes colorées selon le barème ✅

### ✅ Test 3: Boutons d'Action Étudiant
- [ ] Dans chaque matière développée, observer la section boutons
- [ ] **VÉRIFICATION CRITIQUE**: Confirmer la présence **UNIQUEMENT** du bouton "Statistiques"
- [ ] **VÉRIFICATION CRITIQUE**: Confirmer l'**ABSENCE** du bouton "Ajouter"
- [ ] Cliquer sur le bouton "Statistiques"
- [ ] **Résultat attendu**: Fonctionnalité statistiques accessible (même si TODO)

### ✅ Test 4: Moyenne Générale Student
- [ ] Faire défiler vers le bas de l'écran
- [ ] Vérifier la présence de la section "Moyenne Générale"
- [ ] Confirmer l'affichage de la moyenne calculée automatiquement
- [ ] Vérifier le code couleur selon la performance
- [ ] Vérifier le statut (Excellent, Bien, Assez Bien, etc.)

---

## 👨‍🏫 **TESTS PERMISSIONS ENSEIGNANT**

### Prérequis: Connexion Teacher
- [ ] **DÉCONNEXION OBLIGATOIRE** de la session étudiant
- [ ] Se reconnecter avec les identifiants enseignant:
  - **Email**: `teacher@estm.sn`
  - **Password**: `teacher123`
- [ ] Vérifier la connexion réussie (redirection vers TeacherHomeScreen)

### ✅ Test 5: Interface AppBar Enseignant
- [ ] Naviguer vers "Gestion Notes" ou "Notes & Évaluations"
- [ ] Vérifier la présence du titre "Notes & Évaluations"
- [ ] **VÉRIFICATION CRITIQUE**: Confirmer la **PRÉSENCE** du bouton "+" dans l'AppBar
- [ ] Vérifier le tooltip "Ajouter une note" au survol/press
- [ ] **Résultat attendu**: AppBar avec bouton d'ajout visible

### ✅ Test 6: Fonctionnalités Complètes Teacher
- [ ] Observer la même liste des matières
- [ ] Vérifier que toutes les données Student sont visibles
- [ ] Développer chaque matière pour voir les détails
- [ ] Confirmer l'accès complet aux données existantes

### ✅ Test 7: Boutons d'Action Enseignant
- [ ] Dans chaque matière développée, observer la section boutons
- [ ] **VÉRIFICATION CRITIQUE**: Confirmer la présence du bouton "Statistiques"
- [ ] **VÉRIFICATION CRITIQUE**: Confirmer la **PRÉSENCE** du bouton "Ajouter"
- [ ] Vérifier l'alignement et l'espacement des deux boutons
- [ ] **Layout attendu**: [Statistiques] [Ajouter] côte à côte

### ✅ Test 8: Fonctionnalités d'Ajout Teacher
- [ ] Cliquer sur le bouton "+" dans l'AppBar
- [ ] **Résultat attendu**: Action d'ajout (même si TODO actuellement)
- [ ] Cliquer sur le bouton "Ajouter" dans une matière
- [ ] **Résultat attendu**: Action d'ajout spécifique à la matière
- [ ] Vérifier l'accessibilité des deux points d'entrée

### ✅ Test 9: Consistance Interface Teacher
- [ ] Vérifier que l'affichage des moyennes est identique au mode Student
- [ ] Confirmer que les couleurs et le design sont préservés
- [ ] Valider que seuls les boutons d'action diffèrent
- [ ] **Résultat attendu**: Interface cohérente avec fonctionnalités étendues

---

## 🔄 **TESTS DE CHANGEMENT DE RÔLE**

### ✅ Test 10: Réactivité des Permissions
- [ ] Avec un compte Teacher connecté, noter la présence des boutons
- [ ] Se déconnecter et se reconnecter avec un compte Student
- [ ] **VÉRIFICATION CRITIQUE**: Confirmer la mise à jour immédiate de l'interface
- [ ] Répéter l'opération inverse (Student → Teacher)
- [ ] **Résultat attendu**: Interface réactive sans redémarrage

### ✅ Test 11: Persistence des Permissions
- [ ] Se connecter en tant que Student
- [ ] Naviguer vers Notes & Évaluations
- [ ] Sortir de l'écran et y revenir
- [ ] **Vérification**: Permissions Student maintenues
- [ ] Répéter avec compte Teacher
- [ ] **Résultat attendu**: Permissions stables en navigation

---

## 🎨 **TESTS DESIGN ET UX**

### ✅ Test 12: Préservation du Design
- [ ] Comparer l'interface Student et Teacher
- [ ] **Vérifications identiques**:
  - [ ] Couleurs des cards ✅
  - [ ] Espacement et paddings ✅
  - [ ] Typographies (Poppins/Roboto) ✅
  - [ ] Tailles d'icônes ✅
  - [ ] Style des boutons ✅

### ✅ Test 13: Responsive Layout
- [ ] En mode Student: vérifier que le bouton "Statistiques" prend toute la largeur
- [ ] En mode Teacher: vérifier l'alignement équilibré des deux boutons
- [ ] Tester sur différentes orientations si possible
- [ ] **Résultat attendu**: Layout adaptatif selon les permissions

### ✅ Test 14: Feedback Utilisateur
- [ ] En tant que Student, vérifier l'absence d'éléments "cassés" ou manquants
- [ ] Interface intuitive sans impression de fonctionnalités cachées
- [ ] En tant que Teacher, vérifier la discoverabilité des nouvelles options
- [ ] **Résultat attendu**: UX fluide et naturelle pour chaque rôle

---

## 🚨 **TESTS D'ERREUR ET EDGE CASES**

### ✅ Test 15: Gestion des Erreurs
- [ ] Tenter d'accéder aux Notes avec une session expirée
- [ ] Vérifier le comportement avec un utilisateur null
- [ ] Tester avec un rôle non standard (si possible)
- [ ] **Résultat attendu**: Gestion gracieuse des cas limites

### ✅ Test 16: Performance et Réactivité
- [ ] Mesurer le temps de chargement de l'écran Notes
- [ ] Vérifier la fluidité lors du changement de rôle
- [ ] Observer la mémoire et CPU lors des transitions
- [ ] **Résultat attendu**: Performance maintenue avec les nouvelles conditions

---

## 📊 **SYNTHÈSE DES RÉSULTATS**

### Comparatif Permissions

| Fonctionnalité | Student | Teacher | Validation |
|----------------|---------|---------|------------|
| Bouton "+" AppBar | ❌ | ✅ | [ ] |
| Bouton "Statistiques" | ✅ | ✅ | [ ] |
| Bouton "Ajouter" | ❌ | ✅ | [ ] |
| Consultation notes | ✅ | ✅ | [ ] |
| Moyennes | ✅ | ✅ | [ ] |
| Design préservé | ✅ | ✅ | [ ] |

### Résumé Tests
- **Tests Student (4 sections)**: ___/4 passés
- **Tests Teacher (5 sections)**: ___/5 passés  
- **Tests Changement Rôle (2 sections)**: ___/2 passés
- **Tests Design (3 sections)**: ___/3 passés
- **Tests Edge Cases (2 sections)**: ___/2 passés

**TOTAL**: ___/16 sections validées

---

## ✅ **VALIDATION FINALE**

### Critères de Réussite
- [ ] **Student**: Interface lecture seule fonctionnelle
- [ ] **Teacher**: Interface complète avec ajout/modification
- [ ] **Design**: Aucune dégradation visuelle
- [ ] **Performance**: Pas d'impact négatif
- [ ] **Sécurité**: Permissions respectées

### Statut Global
- [ ] ✅ **TOUTES PERMISSIONS VALIDÉES**
- [ ] ⚠️ **PROBLÈMES MINEURS DÉTECTÉS**
- [ ] ❌ **PROBLÈMES MAJEURS NÉCESSITANT CORRECTION**

### Notes du Testeur
```
[Espace pour observations détaillées]
```

### Problèmes Identifiés
```
[Liste des problèmes avec priorités]
```

---

**Testeur**: ________________  
**Date**: ________________  
**Durée des tests**: ________________  
**Signature**: ________________ 