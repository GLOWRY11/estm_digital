import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends StateNotifier<ThemeMode> {
  ThemeController() : super(ThemeMode.system) {
    _loadTheme();
  }

  static const _themePrefsKey = 'theme_mode';

  /// Charge le thème depuis les préférences
  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeIndex = prefs.getInt(_themePrefsKey);
      if (themeIndex != null) {
        state = ThemeMode.values[themeIndex];
      }
    } catch (e) {
      // En cas d'erreur, on garde le thème système par défaut
      print('Erreur lors du chargement du thème: $e');
    }
  }

  /// Définit le thème et l'enregistre dans les préférences
  Future<void> setTheme(ThemeMode themeMode) async {
    state = themeMode;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themePrefsKey, themeMode.index);
    } catch (e) {
      print('Erreur lors de l\'enregistrement du thème: $e');
    }
  }

  /// Toggle entre thème clair et sombre
  Future<void> toggleTheme() async {
    if (state == ThemeMode.dark) {
      await setTheme(ThemeMode.light);
    } else {
      await setTheme(ThemeMode.dark);
    }
  }
  
  /// Anime la transition entre thèmes
  Widget animatedBuilder({required Widget Function(ThemeMode mode) builder}) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      child: builder(state),
    );
  }
} 