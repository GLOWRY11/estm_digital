import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'responsive_layout.dart';

/// Widget qui enveloppe une page avec un layout responsive
class PageWrapper extends ConsumerWidget {
  final String title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final Widget? drawer;
  final Widget? bottomNavigationBar;
  final bool hasScrollingBody;
  final EdgeInsetsGeometry? padding;

  const PageWrapper({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.floatingActionButton,
    this.drawer,
    this.bottomNavigationBar,
    this.hasScrollingBody = true,
    this.padding,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          semanticsLabel: title,
        ),
        actions: actions,
      ),
      drawer: drawer,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      body: ResponsiveLayout(
        mobileLayout: _buildMobileLayout(context),
        tabletLayout: _buildTabletLayout(context),
      ),
    );
  }

  /// Layout pour les écrans mobiles (< 600dp)
  Widget _buildMobileLayout(BuildContext context) {
    final finalPadding = padding ?? const EdgeInsets.all(16.0);
    
    if (hasScrollingBody) {
      return SingleChildScrollView(
        padding: finalPadding,
        child: body,
      );
    }
    
    return Padding(
      padding: finalPadding,
      child: body,
    );
  }

  /// Layout pour les tablettes et desktop (≥ 600dp)
  Widget _buildTabletLayout(BuildContext context) {
    final finalPadding = padding ?? const EdgeInsets.all(24.0);
    
    Widget contentWidget = body;
    
    // Sur tablette/desktop, on centre le contenu avec une largeur maximale
    contentWidget = Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: contentWidget,
      ),
    );
    
    if (hasScrollingBody) {
      return SingleChildScrollView(
        padding: finalPadding,
        child: contentWidget,
      );
    }
    
    return Padding(
      padding: finalPadding,
      child: contentWidget,
    );
  }
} 