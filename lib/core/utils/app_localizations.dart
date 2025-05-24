import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider pour la locale actuelle
final localeProvider = StateProvider<Locale>((ref) => const Locale('fr', 'FR'));

class AppLocalizations {
  final Locale locale;
  
  AppLocalizations(this.locale);
  
  static AppLocalizations of(BuildContext context) {
    return AppLocalizations(Localizations.localeOf(context));
  }
  
  static AppLocalizations watch(WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    return AppLocalizations(locale);
  }
  
  // Course feature translations
  String get myCourses => locale.languageCode == 'fr' ? 'Mes Cours' : 'My Courses';
  String get addCourse => locale.languageCode == 'fr' ? 'Ajouter un cours' : 'Add Course';
  String get courseDetails => locale.languageCode == 'fr' ? 'Détails du cours' : 'Course Details';
  String get editCourse => locale.languageCode == 'fr' ? 'Modifier le cours' : 'Edit Course';
  String get courseTitle => locale.languageCode == 'fr' ? 'Titre du cours' : 'Course Title';
  String get teacher => locale.languageCode == 'fr' ? 'Enseignant' : 'Teacher';
  String get classRoom => locale.languageCode == 'fr' ? 'Salle' : 'Classroom';
  String get startDate => locale.languageCode == 'fr' ? 'Date de début' : 'Start Date';
  String get endDate => locale.languageCode == 'fr' ? 'Date de fin' : 'End Date';
  String get startTime => locale.languageCode == 'fr' ? 'Heure de début' : 'Start Time';
  String get endTime => locale.languageCode == 'fr' ? 'Heure de fin' : 'End Time';
  String get description => locale.languageCode == 'fr' ? 'Description' : 'Description';
  String get save => locale.languageCode == 'fr' ? 'Enregistrer' : 'Save';
  String get cancel => locale.languageCode == 'fr' ? 'Annuler' : 'Cancel';
  
  // Status translations
  String get inProgress => locale.languageCode == 'fr' ? 'En cours' : 'In Progress';
  String get upcoming => locale.languageCode == 'fr' ? 'À venir' : 'Upcoming';
  String get completed => locale.languageCode == 'fr' ? 'Terminé' : 'Completed';
  
  // Dashboard translations
  String get studentDashboard => locale.languageCode == 'fr' ? 'Espace Étudiant' : 'Student Dashboard';
  String get teacherDashboard => locale.languageCode == 'fr' ? 'Espace Enseignant' : 'Teacher Dashboard';
  String get welcome => locale.languageCode == 'fr' ? 'Bienvenue' : 'Welcome';
  String get features => locale.languageCode == 'fr' ? 'Fonctionnalités' : 'Features';
  
  // Common translations
  String get details => locale.languageCode == 'fr' ? 'Détails' : 'Details';
  String get edit => locale.languageCode == 'fr' ? 'Modifier' : 'Edit';
  String get delete => locale.languageCode == 'fr' ? 'Supprimer' : 'Delete';
  String get add => locale.languageCode == 'fr' ? 'Ajouter' : 'Add';
  String get logout => locale.languageCode == 'fr' ? 'Déconnexion' : 'Logout';
  
  // Validation messages
  String get pleaseEnterTitle => locale.languageCode == 'fr' 
      ? 'Veuillez entrer un titre' 
      : 'Please enter a title';
  String get pleaseSelectClass => locale.languageCode == 'fr'
      ? 'Veuillez sélectionner une classe'
      : 'Please select a class';
  String get pleaseSelectRoom => locale.languageCode == 'fr'
      ? 'Veuillez sélectionner une salle'
      : 'Please select a room';
  String get endTimeAfterStartTime => locale.languageCode == 'fr'
      ? 'L\'heure de fin doit être après l\'heure de début'
      : 'End time must be after start time';
}

// Provider for easy access to localizations
final appLocalizationsProvider = Provider<AppLocalizations>((ref) {
  final locale = ref.watch(localeProvider);
  return AppLocalizations(locale);
}); 