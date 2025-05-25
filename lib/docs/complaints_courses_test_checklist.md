# Checklist de Test - Réclamations & Cours ESTM Digital

## 📱 Tests sur Android APK

**Version**: APK Debug installée avec succès  
**Émulateur**: Android x86_64  
**Date de test**: À compléter par le testeur  
**Objectif**: Valider les corrections réclamations et permissions cours Student vs Teacher

---

## 🔴 **TESTS SYSTÈME RÉCLAMATIONS**

### Prérequis: Application Installée
- [ ] Vérifier que l'APK debug est installé sur l'émulateur
- [ ] Lancer l'application ESTM Digital
- [ ] Confirmer que l'application démarre sans erreur

### ✅ Test R1: Réclamations Student
- [ ] Se connecter avec les identifiants étudiant:
  - **Email**: `student@estm.sn`
  - **Password**: `student123`
- [ ] Naviguer vers l'écran "Réclamations"
- [ ] Remplir le formulaire de réclamation:
  - [ ] Saisir un texte de test (ex: "Test réclamation étudiant")
  - [ ] Cliquer sur "Soumettre"
- [ ] **VÉRIFICATION CRITIQUE**: Confirmer l'**ABSENCE** du message "Vous devez être connecté..."
- [ ] **Résultat attendu**: Message "Réclamation soumise avec succès"
- [ ] Vérifier que la réclamation apparaît dans la liste

### ✅ Test R2: Réclamations Teacher
- [ ] **DÉCONNEXION OBLIGATOIRE** de la session étudiant
- [ ] Se reconnecter avec les identifiants enseignant:
  - **Email**: `teacher@estm.sn`
  - **Password**: `teacher123`
- [ ] Naviguer vers l'écran "Réclamations"
- [ ] Remplir le formulaire de réclamation:
  - [ ] Saisir un texte de test (ex: "Test réclamation enseignant")
  - [ ] Cliquer sur "Soumettre"
- [ ] **VÉRIFICATION CRITIQUE**: Confirmer soumission sans blocage
- [ ] **Résultat attendu**: Message "Réclamation soumise avec succès"
- [ ] Vérifier que la réclamation apparaît dans la liste

### ✅ Test R3: Gestion des Réclamations
- [ ] En tant que Teacher ou Admin, vérifier l'affichage de toutes les réclamations
- [ ] Vérifier la possibilité de marquer comme "traitée"
- [ ] Tester la suppression d'une réclamation
- [ ] **Résultat attendu**: Fonctionnalités de gestion accessibles

---

## 📚 **TESTS SYSTÈME COURS - PERMISSIONS STUDENT**

### Prérequis: Connexion Student
- [ ] Se connecter avec les identifiants étudiant:
  - **Email**: `student@estm.sn`
  - **Password**: `student123`
- [ ] Naviguer vers "Mes Cours"

### ✅ Test C1: Interface Student AppBar
- [ ] Vérifier la présence du titre "Mes Cours"
- [ ] **VÉRIFICATION CRITIQUE**: Confirmer l'**ABSENCE** du bouton "+" dans l'AppBar
- [ ] **Résultat attendu**: AppBar propre sans bouton d'ajout

### ✅ Test C2: Liste des Cours Student
- [ ] Vérifier l'affichage de la liste des cours mockés:
  - [ ] "Mathématiques Avancées" (MATH301)
  - [ ] "Programmation Orientée Objet" (INFO201)
  - [ ] "Base de Données" (INFO301)
- [ ] Vérifier les informations affichées:
  - [ ] Nom du cours
  - [ ] Code du cours
  - [ ] Description
  - [ ] Nombre de crédits
  - [ ] Nombre d'étudiants
  - [ ] Badge du semestre

### ✅ Test C3: Boutons d'Action Student
- [ ] Pour chaque carte de cours, vérifier la section boutons:
- [ ] **VÉRIFICATION CRITIQUE**: Confirmer la présence **UNIQUEMENT** de:
  - [ ] Bouton "Absences" (OutlinedButton avec icône event_busy)
  - [ ] Bouton "Notes" (FilledButton avec icône grade)
- [ ] **VÉRIFICATION CRITIQUE**: Confirmer l'**ABSENCE** du bouton "Étudiants"
- [ ] Vérifier l'alignement correct des deux boutons (côte à côte)

### ✅ Test C4: Fonctionnalités Student
- [ ] Cliquer sur le bouton "Absences" d'un cours
- [ ] **Résultat attendu**: Accès en lecture seule aux absences (TODO actuel)
- [ ] Cliquer sur le bouton "Notes" d'un cours
- [ ] **Résultat attendu**: Accès en lecture seule aux notes (TODO actuel)

---

## 👨‍🏫 **TESTS SYSTÈME COURS - PERMISSIONS TEACHER**

### Prérequis: Connexion Teacher
- [ ] **DÉCONNEXION OBLIGATOIRE** de la session étudiant
- [ ] Se reconnecter avec les identifiants enseignant:
  - **Email**: `teacher@estm.sn`
  - **Password**: `teacher123`
- [ ] Naviguer vers "Mes Cours"

### ✅ Test C5: Interface Teacher AppBar
- [ ] Vérifier la présence du titre "Mes Cours"
- [ ] **VÉRIFICATION CRITIQUE**: Confirmer la **PRÉSENCE** du bouton "+" dans l'AppBar
- [ ] Vérifier le tooltip "Ajouter un cours" au survol/press
- [ ] **Résultat attendu**: AppBar avec bouton d'ajout visible

### ✅ Test C6: Boutons d'Action Teacher
- [ ] Pour chaque carte de cours, vérifier la section boutons:
- [ ] **VÉRIFICATION CRITIQUE**: Confirmer la présence de **TROIS** boutons:
  - [ ] Bouton "Étudiants" (OutlinedButton avec icône people)
  - [ ] Bouton "Absences" (OutlinedButton avec icône event_busy)
  - [ ] Bouton "Notes" (FilledButton avec icône grade)
- [ ] Vérifier l'alignement correct des trois boutons
- [ ] Vérifier l'espacement entre les boutons (SizedBox width: 8)

### ✅ Test C7: Fonctionnalités Teacher
- [ ] Cliquer sur le bouton "+" dans l'AppBar
- [ ] **Résultat attendu**: Action d'ajout de cours (TODO actuel)
- [ ] Cliquer sur le bouton "Étudiants" d'un cours
- [ ] **Résultat attendu**: Accès à StudentListForCourseScreen (TODO actuel)
- [ ] Cliquer sur le bouton "Absences" d'un cours
- [ ] **Résultat attendu**: Gestion des absences (QR ou formulaire) (TODO actuel)
- [ ] Cliquer sur le bouton "Notes" d'un cours
- [ ] **Résultat attendu**: Accès à GradeFormScreen (TODO actuel)

---

## 🔄 **TESTS DE CHANGEMENT DE RÔLE**

### ✅ Test C8: Réactivité des Permissions
- [ ] Avec un compte Teacher connecté, noter la présence des trois boutons
- [ ] Se déconnecter et se reconnecter avec un compte Student
- [ ] **VÉRIFICATION CRITIQUE**: Confirmer la mise à jour immédiate de l'interface
- [ ] Répéter l'opération inverse (Student → Teacher)
- [ ] **Résultat attendu**: Interface réactive sans redémarrage

### ✅ Test C9: Persistence des Permissions
- [ ] Se connecter en tant que Student
- [ ] Naviguer vers "Mes Cours"
- [ ] Sortir de l'écran et y revenir
- [ ] **Vérification**: Permissions Student maintenues
- [ ] Répéter avec compte Teacher
- [ ] **Résultat attendu**: Permissions stables en navigation

---

## 🎨 **TESTS DESIGN ET UX**

### ✅ Test D1: Préservation du Design Cours
- [ ] Comparer l'interface Student et Teacher
- [ ] **Vérifications identiques**:
  - [ ] Couleurs des cartes ✅
  - [ ] Typography Google Fonts ✅
  - [ ] Paddings et margins ✅
  - [ ] Tailles d'icônes ✅
  - [ ] Style des boutons ✅
  - [ ] Layout des informations cours ✅

### ✅ Test D2: Layout Adaptatif
- [ ] En mode Student: vérifier l'alignement des 2 boutons
- [ ] En mode Teacher: vérifier l'alignement des 3 boutons
- [ ] Tester sur différentes orientations si possible
- [ ] **Résultat attendu**: Layout propre selon les permissions

### ✅ Test D3: Consistance Réclamations
- [ ] Vérifier que l'interface réclamations n'a pas été altérée
- [ ] Confirmer le fonctionnement du formulaire
- [ ] Vérifier l'affichage de la liste des réclamations
- [ ] **Résultat attendu**: Interface réclamations intacte

---

## 🚨 **TESTS D'ERREUR ET EDGE CASES**

### ✅ Test E1: Gestion des Erreurs Réclamations
- [ ] Tenter de soumettre une réclamation vide
- [ ] **Résultat attendu**: Message de validation approprié
- [ ] Tester avec du texte très long (>500 caractères)
- [ ] Vérifier la gestion d'erreur réseau (si applicable)

### ✅ Test E2: Sessions et Authentification
- [ ] Tester l'accès aux cours avec une session expirée
- [ ] Vérifier le comportement avec un utilisateur null
- [ ] **Résultat attendu**: Gestion gracieuse des cas limites

### ✅ Test E3: Performance Interface
- [ ] Mesurer le temps de chargement de l'écran "Mes Cours"
- [ ] Vérifier la fluidité lors du changement de rôle
- [ ] Observer la réactivité des boutons
- [ ] **Résultat attendu**: Performance maintenue

---

## 📊 **SYNTHÈSE DES RÉSULTATS**

### Comparatif Fonctionnalités

| Fonctionnalité | Student | Teacher | Test Status |
|----------------|---------|---------|-------------|
| **Réclamations** |
| Soumettre réclamation | ✅ | ✅ | [ ] |
| Gérer réclamations | ❌ | ✅ | [ ] |
| **Cours** |
| Bouton "+" AppBar | ❌ | ✅ | [ ] |
| Bouton "Étudiants" | ❌ | ✅ | [ ] |
| Bouton "Absences" | ✅ (lecture) | ✅ (gestion) | [ ] |
| Bouton "Notes" | ✅ (lecture) | ✅ (gestion) | [ ] |
| Consultation cours | ✅ | ✅ | [ ] |
| Design préservé | ✅ | ✅ | [ ] |

### Résumé Tests
- **Tests Réclamations (3 sections)**: ___/3 passés
- **Tests Student (4 sections)**: ___/4 passés  
- **Tests Teacher (3 sections)**: ___/3 passés
- **Tests Changement Rôle (2 sections)**: ___/2 passés
- **Tests Design (3 sections)**: ___/3 passés
- **Tests Edge Cases (3 sections)**: ___/3 passés

**TOTAL**: ___/18 sections validées

---

## ✅ **VALIDATION FINALE**

### Critères de Réussite
- [ ] **Réclamations**: Soumission fonctionnelle pour tous les rôles
- [ ] **Student**: Interface cours lecture seule
- [ ] **Teacher**: Interface cours complète avec gestion
- [ ] **Design**: Aucune dégradation visuelle
- [ ] **Performance**: Pas d'impact négatif
- [ ] **Permissions**: Contrôles d'accès respectés

### Statut Global
- [ ] ✅ **TOUS LES SYSTÈMES VALIDÉS**
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

## 🔧 **INSTRUCTIONS DE TEST**

### Environnement Requis
- **Émulateur**: Android x86_64 configuré
- **APK**: Version debug installée
- **Comptes**: Accès aux comptes student et teacher

### Ordre de Test Recommandé
1. **Réclamations** → Tests R1, R2, R3
2. **Cours Student** → Tests C1, C2, C3, C4
3. **Cours Teacher** → Tests C5, C6, C7
4. **Changements Rôle** → Tests C8, C9
5. **Design & UX** → Tests D1, D2, D3
6. **Edge Cases** → Tests E1, E2, E3

### Conseils de Test
- **Redémarrer l'app** entre changements majeurs de rôle
- **Noter les temps** de réponse pour évaluer les performances
- **Documenter** tous les comportements inattendus
- **Tester plusieurs fois** les actions critiques

---

**Testeur**: ________________  
**Date**: ________________  
**Durée des tests**: ________________  
**Version APK**: Debug (27.3s build time)  
**Signature**: ________________ 