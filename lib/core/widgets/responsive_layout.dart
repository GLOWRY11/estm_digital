import 'package:flutter/material.dart';

/// Widget qui adapte la mise en page en fonction de la taille de l'écran
class ResponsiveLayout extends StatelessWidget {
  final Widget mobileLayout;
  final Widget? tabletLayout;
  final Widget? desktopLayout;
  
  // Seuils de largeur pour les différents layouts
  static const mobileBreakpoint = 600;
  static const tabletBreakpoint = 900;

  const ResponsiveLayout({
    super.key,
    required this.mobileLayout,
    this.tabletLayout,
    this.desktopLayout,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        
        // Layout mobile (< 600dp)
        if (width < mobileBreakpoint) {
          return mobileLayout;
        }
        
        // Layout tablette (600dp - 900dp)
        if (width < tabletBreakpoint) {
          return tabletLayout ?? _buildTabletLayout(context);
        }
        
        // Layout desktop (> 900dp)
        return desktopLayout ?? _buildDesktopLayout(context);
      },
    );
  }

  // Layout par défaut pour les tablettes si aucun n'est fourni
  Widget _buildTabletLayout(BuildContext context) {
    // Si aucun layout tablette n'est spécifié, on utilise le layout mobile
    // avec des marges plus grandes pour améliorer la lisibilité
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: mobileLayout,
    );
  }

  // Layout par défaut pour les desktops si aucun n'est fourni
  Widget _buildDesktopLayout(BuildContext context) {
    // Si aucun layout desktop n'est spécifié, on centre le contenu
    // avec une largeur maximale pour éviter que le contenu ne s'étale trop
    return Center(
      child: SizedBox(
        width: tabletBreakpoint.toDouble(),
        child: mobileLayout,
      ),
    );
  }
}

/// Extension utilitaire pour vérifier facilement la taille de l'écran
extension ResponsiveExtension on BuildContext {
  bool get isMobile => MediaQuery.of(this).size.width < ResponsiveLayout.mobileBreakpoint;
  bool get isTablet => 
      MediaQuery.of(this).size.width >= ResponsiveLayout.mobileBreakpoint && 
      MediaQuery.of(this).size.width < ResponsiveLayout.tabletBreakpoint;
  bool get isDesktop => MediaQuery.of(this).size.width >= ResponsiveLayout.tabletBreakpoint;
}

/// Widget pour afficher le contenu en deux colonnes sur les écrans larges
class TwoColumnLayout extends StatelessWidget {
  final Widget leftColumn;
  final Widget rightColumn;
  final double leftFlex;
  final double rightFlex;
  final double spacing;

  const TwoColumnLayout({
    super.key,
    required this.leftColumn,
    required this.rightColumn,
    this.leftFlex = 1,
    this.rightFlex = 1,
    this.spacing = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    // Si on est sur mobile, on affiche en colonnes superposées
    if (context.isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          leftColumn,
          SizedBox(height: spacing),
          rightColumn,
        ],
      );
    }
    
    // Sinon, on affiche en deux colonnes côte à côte
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          flex: leftFlex.toInt(),
          child: leftColumn,
        ),
        SizedBox(width: spacing),
        Flexible(
          flex: rightFlex.toInt(),
          child: rightColumn,
        ),
      ],
    );
  }
} 