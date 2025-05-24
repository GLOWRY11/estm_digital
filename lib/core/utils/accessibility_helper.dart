import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Classe utilitaire pour l'accessibilité, permettant de vérifier
/// et d'améliorer l'accessibilité des interfaces utilisateur
class AccessibilityHelper {
  /// Vérifie si le contraste entre deux couleurs est suffisant (WCAG 2.1)
  /// Retourne true si le ratio est >= 4.5:1 (standard AA)
  static bool hasGoodContrast(Color foreground, Color background) {
    return calculateContrastRatio(foreground, background) >= 4.5;
  }

  /// Calcule le ratio de contraste entre deux couleurs selon WCAG 2.1
  static double calculateContrastRatio(Color foreground, Color background) {
    final foregroundLuminance = _calculateRelativeLuminance(foreground);
    final backgroundLuminance = _calculateRelativeLuminance(background);
    
    final lighter = math.max(foregroundLuminance, backgroundLuminance);
    final darker = math.min(foregroundLuminance, backgroundLuminance);
    
    return (lighter + 0.05) / (darker + 0.05);
  }

  /// Calcule la luminance relative d'une couleur selon WCAG
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

  /// Convertit un composant de couleur en valeur linéarisée pour le calcul de luminance
  static double _linearizeColorComponent(double value) {
    return value <= 0.03928
        ? value / 12.92
        : math.pow((value + 0.055) / 1.055, 2.4).toDouble();
  }
  
  /// Améliore le contraste d'une couleur de texte par rapport à un fond
  /// en ajustant la luminosité si nécessaire
  static Color improveTextContrast(Color textColor, Color backgroundColor) {
    double ratio = calculateContrastRatio(textColor, backgroundColor);
    
    if (ratio >= 4.5) return textColor; // Le contraste est déjà bon
    
    // On ajuste la luminosité du texte pour améliorer le contraste
    final bgLuminance = _calculateRelativeLuminance(backgroundColor);
    
    // Si le fond est sombre, on éclaircit le texte
    if (bgLuminance < 0.5) {
      // Éclaircir progressivement jusqu'à obtenir un bon contraste
      HSLColor hslColor = HSLColor.fromColor(textColor);
      double lightness = hslColor.lightness;
      
      while (ratio < 4.5 && lightness < 1.0) {
        lightness = math.min(1.0, lightness + 0.05);
        final newColor = hslColor.withLightness(lightness).toColor();
        ratio = calculateContrastRatio(newColor, backgroundColor);
        if (ratio >= 4.5) return newColor;
      }
      
      // Si on ne peut pas atteindre le contraste désiré, on renvoie blanc
      return Colors.white;
    } 
    // Si le fond est clair, on assombrit le texte
    else {
      // Assombrir progressivement jusqu'à obtenir un bon contraste
      HSLColor hslColor = HSLColor.fromColor(textColor);
      double lightness = hslColor.lightness;
      
      while (ratio < 4.5 && lightness > 0.0) {
        lightness = math.max(0.0, lightness - 0.05);
        final newColor = hslColor.withLightness(lightness).toColor();
        ratio = calculateContrastRatio(newColor, backgroundColor);
        if (ratio >= 4.5) return newColor;
      }
      
      // Si on ne peut pas atteindre le contraste désiré, on renvoie noir
      return Colors.black;
    }
  }
  
  /// Wrap un widget avec des propriétés d'accessibilité améliorées
  static Widget enhanceAccessibility({
    required Widget child,
    String? semanticLabel,
    String? tooltip,
    bool excludeSemantics = false,
  }) {
    Widget result = child;
    
    if (tooltip != null) {
      result = Tooltip(
        message: tooltip,
        child: result,
      );
    }
    
    if (semanticLabel != null || excludeSemantics) {
      result = Semantics(
        label: semanticLabel,
        excludeSemantics: excludeSemantics,
        child: result,
      );
    }
    
    return result;
  }
  
  /// Wrap une icône avec des propriétés d'accessibilité
  static Widget accessibleIcon(
    IconData icon, {
    Color? color,
    double? size,
    String? semanticLabel,
    String? tooltip,
  }) {
    return enhanceAccessibility(
      semanticLabel: semanticLabel ?? tooltip,
      tooltip: tooltip,
      child: Icon(
        icon,
        color: color,
        size: size,
        semanticLabel: semanticLabel,
      ),
    );
  }
} 