# Checklist de Test - Système de Gestion des Absences

## 📱 Tests sur Android APK

**Version**: Debug APK installée avec succès  
**Émulateur**: Android x86_64  
**Date de test**: À compléter par le testeur

---

## 🔍 Tests de Navigation

### ✅ Test 1: Accès à la Liste des Absences
- [ ] Ouvrir l'application ESTM Digital
- [ ] Se connecter avec un compte (admin/teacher/student)
- [ ] Naviguer vers la section "Absences" ou "Liste des Absences"
- [ ] **Résultat attendu**: Affichage de la liste des absences (peut être vide)

### ✅ Test 2: FloatingActionButton
- [ ] Dans la liste des absences, localiser le bouton "+" (FloatingActionButton)
- [ ] Cliquer sur le bouton "+"
- [ ] **Résultat attendu**: Ouverture du formulaire "Nouvelle Absence"

---

## 📝 Tests du Formulaire d'Absence

### ✅ Test 3: Interface du Formulaire
- [ ] Vérifier la présence du titre "Nouvelle Absence"
- [ ] Vérifier la présence du switch "Statut de présence"
- [ ] Vérifier les champs :
  - [ ] Date (avec icône calendrier)
  - [ ] Heure de début (avec icône horloge)
  - [ ] Heure de fin (avec icône horloge)
  - [ ] ID Étudiant (champ numérique)
- [ ] Vérifier la présence du bouton "Afficher QR Code"
- [ ] Vérifier la présence du bouton "Ajouter"

### ✅ Test 4: Fonctionnalité des Champs
- [ ] **Switch Présence**: Basculer entre "Présent" et "Absent"
- [ ] **Sélecteur de Date**: Cliquer sur l'icône calendrier
  - [ ] Sélectionner une date
  - [ ] Vérifier l'affichage au format DD/MM/YYYY
- [ ] **Heure de Début**: Cliquer sur l'icône horloge
  - [ ] Sélectionner une heure
  - [ ] Vérifier l'affichage au format HH:MM
- [ ] **Heure de Fin**: Répéter pour l'heure de fin
- [ ] **ID Étudiant**: Saisir un nombre (ex: 123456)

### ✅ Test 5: Validation des Champs
- [ ] Laisser le champ "ID Étudiant" vide et tenter de sauvegarder
- [ ] **Résultat attendu**: Message d'erreur "Veuillez entrer l'ID de l'étudiant"
- [ ] Saisir du texte dans "ID Étudiant" et tenter de sauvegarder
- [ ] **Résultat attendu**: Message d'erreur "Veuillez entrer un nombre valide"

---

## 📱 Tests de la Fonctionnalité QR Code

### ✅ Test 6: Affichage du QR Code
- [ ] Remplir tous les champs du formulaire
- [ ] Cliquer sur "Afficher QR Code"
- [ ] **Résultat attendu**: 
  - [ ] Apparition d'une Card avec le titre "QR Code de l'absence"
  - [ ] Affichage d'un QR code noir et blanc
  - [ ] Présence de deux boutons : "Partager QR" et "Masquer"

### ✅ Test 7: Génération des Données QR
- [ ] Avec le QR code affiché, utiliser une app de scan QR pour lire le contenu
- [ ] **Résultat attendu**: Données JSON contenant :
  ```json
  {
    "type": "absence",
    "date": "DD/MM/YYYY",
    "startTime": "HH:MM" (si renseigné),
    "endTime": "HH:MM" (si renseigné),
    "etudiantId": "123456",
    "isPresent": true/false,
    "timestamp": "ISO8601"
  }
  ```

### ✅ Test 8: Partage du QR Code
- [ ] Cliquer sur le bouton "Partager QR"
- [ ] **Résultat attendu**: 
  - [ ] Ouverture du sélecteur de partage Android
  - [ ] Options de partage disponibles (Email, Messages, etc.)
  - [ ] Message de succès "QR Code partagé avec succès"

### ✅ Test 9: Masquer le QR Code
- [ ] Cliquer sur le bouton "Masquer"
- [ ] **Résultat attendu**: 
  - [ ] Disparition de la Card QR
  - [ ] Réapparition du bouton "Afficher QR Code"

---

## 💾 Tests de Sauvegarde

### ✅ Test 10: Sauvegarde d'une Absence
- [ ] Remplir tous les champs obligatoires
- [ ] Cliquer sur "Ajouter"
- [ ] **Résultat attendu**: 
  - [ ] Message "Absence ajoutée avec succès"
  - [ ] Retour à la liste des absences
  - [ ] Nouvelle absence visible dans la liste

### ✅ Test 11: Affichage dans la Liste
- [ ] Vérifier que l'absence apparaît dans la liste avec :
  - [ ] Date correcte (format DD/MM/YYYY)
  - [ ] Statut correct (badge vert "Présent" ou rouge "Absent")
  - [ ] Heures affichées si renseignées
  - [ ] ID étudiant correct
  - [ ] Boutons d'édition et suppression présents

---

## ✏️ Tests d'Édition

### ✅ Test 12: Édition d'une Absence
- [ ] Dans la liste, cliquer sur l'icône d'édition (crayon bleu)
- [ ] **Résultat attendu**: 
  - [ ] Ouverture du formulaire avec titre "Modifier Absence"
  - [ ] Champs pré-remplis avec les données existantes
  - [ ] Bouton "Mettre à jour" au lieu de "Ajouter"

### ✅ Test 13: Modification et Sauvegarde
- [ ] Modifier le statut de présence
- [ ] Modifier l'heure de début
- [ ] Cliquer sur "Mettre à jour"
- [ ] **Résultat attendu**: 
  - [ ] Message "Absence mise à jour avec succès"
  - [ ] Retour à la liste avec modifications visibles

---

## 🗑️ Tests de Suppression

### ✅ Test 14: Suppression d'une Absence
- [ ] Dans la liste, cliquer sur l'icône de suppression (poubelle rouge)
- [ ] **Résultat attendu**: 
  - [ ] Popup de confirmation "Voulez-vous vraiment supprimer cette absence?"
  - [ ] Boutons "Annuler" et "Supprimer"

### ✅ Test 15: Confirmation de Suppression
- [ ] Cliquer sur "Supprimer" dans le popup
- [ ] **Résultat attendu**: 
  - [ ] Fermeture du popup
  - [ ] Disparition de l'absence de la liste
  - [ ] Mise à jour automatique de la liste

---

## 🔄 Tests de Persistance

### ✅ Test 16: Persistance des Données
- [ ] Ajouter plusieurs absences
- [ ] Fermer complètement l'application
- [ ] Rouvrir l'application
- [ ] Naviguer vers la liste des absences
- [ ] **Résultat attendu**: Toutes les absences sont toujours présentes

### ✅ Test 17: Migration de Base de Données
- [ ] Si l'app était déjà installée avec une version antérieure :
  - [ ] Vérifier que l'upgrade s'est bien passé
  - [ ] Vérifier que les anciennes données sont préservées
  - [ ] Vérifier que les nouvelles fonctionnalités sont disponibles

---

## 🚨 Tests d'Erreur

### ✅ Test 18: Gestion des Erreurs QR
- [ ] Essayer de partager le QR sans connexion internet
- [ ] Essayer de partager sans applications de partage disponibles
- [ ] **Résultat attendu**: Messages d'erreur appropriés sans crash

### ✅ Test 19: Gestion des Erreurs de Base
- [ ] Essayer de sauvegarder avec des données invalides
- [ ] Tester avec des caractères spéciaux dans l'ID étudiant
- [ ] **Résultat attendu**: Validation appropriée et messages d'erreur

---

## 📊 Résultats des Tests

### Résumé
- **Tests Passés**: ___/19
- **Tests Échoués**: ___/19
- **Problèmes Identifiés**: 

### Notes du Testeur
```
[Espace pour notes et observations]
```

### Recommandations
```
[Espace pour recommandations d'amélioration]
```

---

## ✅ Validation Finale

- [ ] **Toutes les fonctionnalités de base fonctionnent**
- [ ] **Le QR Code se génère et se partage correctement**
- [ ] **La navigation est fluide**
- [ ] **Les données persistent correctement**
- [ ] **L'interface est intuitive et responsive**

**Statut Global**: [ ] ✅ VALIDÉ | [ ] ❌ PROBLÈMES DÉTECTÉS

---

**Testeur**: ________________  
**Date**: ________________  
**Signature**: ________________ 