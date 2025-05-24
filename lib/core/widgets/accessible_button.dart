import 'package:flutter/material.dart';
import '../utils/accessibility_helper.dart';

/// Un bouton accessible qui respecte les standards d'accessibilité
/// en incluant automatiquement tooltip et semantic labels
class AccessibleButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final String? tooltip;
  final String? semanticLabel;
  final ButtonStyle? style;
  final bool isElevated;
  final FocusNode? focusNode;
  final bool autofocus;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final EdgeInsetsGeometry? padding;

  /// Constructeur pour un bouton accessible
  const AccessibleButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.tooltip,
    this.semanticLabel,
    this.style,
    this.isElevated = true,
    this.focusNode,
    this.autofocus = false,
    this.backgroundColor,
    this.foregroundColor,
    this.padding,
  });

  /// Constructeur pour un bouton avec une icône
  factory AccessibleButton.icon({
    Key? key,
    required VoidCallback? onPressed,
    required IconData icon,
    required String tooltip,
    String? semanticLabel,
    ButtonStyle? style,
    bool isElevated = true,
    FocusNode? focusNode,
    bool autofocus = false,
    Color? backgroundColor,
    Color? foregroundColor,
    double? iconSize,
    EdgeInsetsGeometry? padding,
  }) {
    return AccessibleButton(
      key: key,
      onPressed: onPressed,
      tooltip: tooltip,
      semanticLabel: semanticLabel ?? tooltip,
      style: style,
      isElevated: isElevated,
      focusNode: focusNode,
      autofocus: autofocus,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      padding: padding,
      child: Icon(
        icon,
        semanticLabel: semanticLabel ?? tooltip,
        size: iconSize,
      ),
    );
  }

  /// Constructeur pour un bouton avec texte et icône
  factory AccessibleButton.iconText({
    Key? key,
    required VoidCallback? onPressed,
    required IconData icon,
    required String text,
    required String tooltip,
    String? semanticLabel,
    ButtonStyle? style,
    bool isElevated = true,
    FocusNode? focusNode,
    bool autofocus = false,
    Color? backgroundColor,
    Color? foregroundColor,
    double? iconSize,
    EdgeInsetsGeometry? padding,
    TextStyle? textStyle,
    double gap = 8.0,
    bool iconFirst = true,
  }) {
    final textWidget = Text(text, style: textStyle);
    final iconWidget = Icon(
      icon,
      semanticLabel: null, // Nous utilisons un seul semanticLabel pour tout le bouton
      size: iconSize,
    );
    
    final rowChildren = iconFirst
        ? <Widget>[iconWidget, SizedBox(width: gap), textWidget]
        : <Widget>[textWidget, SizedBox(width: gap), iconWidget];
    
    return AccessibleButton(
      key: key,
      onPressed: onPressed,
      tooltip: tooltip,
      semanticLabel: semanticLabel ?? tooltip,
      style: style,
      isElevated: isElevated,
      focusNode: focusNode,
      autofocus: autofocus,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      padding: padding,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: rowChildren,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // On utilise AccessibilityHelper pour ajouter les propriétés d'accessibilité
    final buttonWithAccessibility = AccessibilityHelper.enhanceAccessibility(
      semanticLabel: semanticLabel,
      tooltip: tooltip,
      child: _buildButton(context),
    );
    
    // Augmenter la taille minimale pour faciliter l'appui tactile
    return SizedBox(
      height: 48.0, // Taille minimale recommandée pour l'accessibilité
      child: buttonWithAccessibility,
    );
  }

  /// Construit le bouton avec le style approprié
  Widget _buildButton(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveBackgroundColor = backgroundColor ?? (isElevated ? theme.colorScheme.primary : null);
    final effectiveForegroundColor = foregroundColor ?? 
        (isElevated ? theme.colorScheme.onPrimary : theme.colorScheme.primary);
    
    // Vérifier le contraste entre le texte et le fond
    Color finalForegroundColor = effectiveForegroundColor;
    if (effectiveBackgroundColor != null) {
      // S'assurer que le contraste est suffisant
      if (!AccessibilityHelper.hasGoodContrast(
        effectiveForegroundColor, 
        effectiveBackgroundColor
      )) {
        finalForegroundColor = AccessibilityHelper.improveTextContrast(
          effectiveForegroundColor, 
          effectiveBackgroundColor
        );
      }
    }
    
    // Fusionner le style personnalisé avec le style par défaut
    final effectiveStyle = style ?? const ButtonStyle();
    final mergedStyle = ButtonStyle(
      backgroundColor: effectiveBackgroundColor != null 
          ? MaterialStateProperty.all(effectiveBackgroundColor)
          : null,
      foregroundColor: MaterialStateProperty.all(finalForegroundColor),
      padding: padding != null 
          ? MaterialStateProperty.all(padding)
          : null,
      minimumSize: MaterialStateProperty.all(const Size(48.0, 48.0)),
    ).copyWith(
      backgroundColor: effectiveStyle.backgroundColor,
      foregroundColor: effectiveStyle.foregroundColor,
      padding: effectiveStyle.padding,
      minimumSize: effectiveStyle.minimumSize,
    );
    
    // Créer le bouton approprié
    if (isElevated) {
      return ElevatedButton(
        onPressed: onPressed,
        style: mergedStyle,
        focusNode: focusNode,
        autofocus: autofocus,
        child: child,
      );
    } else {
      return TextButton(
        onPressed: onPressed,
        style: mergedStyle,
        focusNode: focusNode,
        autofocus: autofocus,
        child: child,
      );
    }
  }
} 