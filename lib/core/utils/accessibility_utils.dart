import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Classe d'utilitaires pour l'accessibilité
class AccessibilityUtils {
  // Vérifie si le contraste entre deux couleurs est suffisant (WCAG 2.1)
  // Retourne true si le ratio est >= 4.5:1
  static bool hasGoodContrast(Color foreground, Color background) {
    return calculateContrastRatio(foreground, background) >= 4.5;
  }

  // Calcule le ratio de contraste entre deux couleurs selon WCAG 2.1
  static double calculateContrastRatio(Color foreground, Color background) {
    final foregroundLuminance = _calculateRelativeLuminance(foreground);
    final backgroundLuminance = _calculateRelativeLuminance(background);
    
    final lighter = math.max(foregroundLuminance, backgroundLuminance);
    final darker = math.min(foregroundLuminance, backgroundLuminance);
    
    return (lighter + 0.05) / (darker + 0.05);
  }

  // Calcule la luminance relative d'une couleur selon WCAG
  static double _calculateRelativeLuminance(Color color) {
    // Convertir RGB en valeurs linéaires
    final List<double> rgbValues = [
      _linearizeColorComponent(color.red / 255),
      _linearizeColorComponent(color.green / 255),
      _linearizeColorComponent(color.blue / 255),
    ];
    
    // Calculer la luminance relative
    return 0.2126 * rgbValues[0] + 0.7152 * rgbValues[1] + 0.0722 * rgbValues[2];
  }

  // Linéarise une composante de couleur selon WCAG
  static double _linearizeColorComponent(double colorComponent) {
    return colorComponent <= 0.03928
        ? colorComponent / 12.92
        : math.pow((colorComponent + 0.055) / 1.055, 2.4).toDouble();
  }
  
  // Suggère une couleur de texte (noir ou blanc) qui a un bon contraste avec la couleur de fond
  static Color suggestTextColor(Color backgroundColor) {
    // Calcule la luminance relative
    final luminance = _calculateRelativeLuminance(backgroundColor);
    
    // Si la luminance est élevée (couleur claire), utiliser du texte foncé
    // Sinon, utiliser du texte clair
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
  
  // Ajuste la couleur pour assurer un contraste suffisant avec la couleur de fond
  static Color ensureContrastRatio(Color foreground, Color background, double targetRatio) {
    final currentRatio = calculateContrastRatio(foreground, background);
    
    if (currentRatio >= targetRatio) {
      return foreground;
    }
    
    // Ajuster la luminosité pour atteindre le ratio cible
    double luminance = _calculateRelativeLuminance(background);
    
    // Calculer la luminance cible du texte pour atteindre le ratio
    double targetLuminance;
    if (luminance > 0.5) {
      // Fond clair, texte plus sombre
      targetLuminance = (luminance + 0.05) / targetRatio - 0.05;
      return _adjustColorLuminance(foreground, targetLuminance, darker: true);
    } else {
      // Fond foncé, texte plus clair
      targetLuminance = targetRatio * (luminance + 0.05) - 0.05;
      return _adjustColorLuminance(foreground, targetLuminance, darker: false);
    }
  }
  
  // Ajuste la luminance d'une couleur
  static Color _adjustColorLuminance(Color color, double targetLuminance, {bool darker = false}) {
    // Si on ne peut pas ajuster correctement, revenir à blanc ou noir pour un contraste maximal
    if (targetLuminance < 0 || targetLuminance > 1) {
      return darker ? Colors.black : Colors.white;
    }
    
    // Approche simplifiée: ajuster l'opacité avec du noir ou du blanc
    if (darker) {
      // Assombrir avec du noir
      double opacity = 1.0;
      Color result = color;
      while (_calculateRelativeLuminance(result) > targetLuminance && opacity > 0) {
        opacity -= 0.05;
        result = Color.alphaBlend(Colors.black.withOpacity(1 - opacity), color);
      }
      return result;
    } else {
      // Éclaircir avec du blanc
      double opacity = 1.0;
      Color result = color;
      while (_calculateRelativeLuminance(result) < targetLuminance && opacity > 0) {
        opacity -= 0.05;
        result = Color.alphaBlend(Colors.white.withOpacity(1 - opacity), color);
      }
      return result;
    }
  }
} 