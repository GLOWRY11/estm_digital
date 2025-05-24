import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../utils/accessibility_helper.dart';

/// Widget qui crée un overlay pour afficher un rapport d'accessibilité
/// sur le contraste des couleurs et autres problèmes d'accessibilité
class AccessibilityReportOverlay extends StatefulWidget {
  final Widget child;
  final bool enabled;

  const AccessibilityReportOverlay({
    super.key,
    required this.child,
    this.enabled = false,
  });

  @override
  State<AccessibilityReportOverlay> createState() => _AccessibilityReportOverlayState();
}

class _AccessibilityReportOverlayState extends State<AccessibilityReportOverlay> with WidgetsBindingObserver {
  final GlobalKey _childKey = GlobalKey();
  List<_AccessibilityIssue> _issues = [];
  bool _isScanning = false;
  
  // Limites pour éviter les surcharges
  static const int _maxIssues = 50;  // Nombre maximal de problèmes à afficher
  static const int _maxDepth = 15;   // Profondeur maximale de l'arbre des widgets à analyser
  static const int _analysisTimeoutMs = 5000;  // Timeout en millisecondes

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    if (widget.enabled) {
      // Exécuter l'analyse après le premier rendu
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scanForAccessibilityIssues();
      });
    }
  }

  @override
  void didUpdateWidget(AccessibilityReportOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enabled && !oldWidget.enabled) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scanForAccessibilityIssues();
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    if (widget.enabled) {
      _scanForAccessibilityIssues();
    }
  }

  // Analyse l'interface pour détecter des problèmes d'accessibilité
  Future<void> _scanForAccessibilityIssues() async {
    if (_isScanning || !widget.enabled) return;
    
    setState(() {
      _isScanning = true;
      _issues = [];
    });
    
    // Ajouter un timeout pour éviter les scans trop longs
    bool hasTimedOut = false;
    Future.delayed(Duration(milliseconds: _analysisTimeoutMs), () {
      if (_isScanning && mounted) {
        hasTimedOut = true;
        setState(() {
          _isScanning = false;
          _issues.add(_AccessibilityIssue(
            rect: const Rect.fromLTWH(10, 10, 100, 30),
            message: 'Analyse interrompue (timeout)',
            severity: _IssueSeverity.info,
            suggestion: 'L\'analyse a été arrêtée pour éviter de ralentir l\'application',
          ));
        });
      }
    });
    
    try {
      final RenderObject? renderObject = _childKey.currentContext?.findRenderObject();
      if (renderObject is RenderBox && !hasTimedOut) {
        try {
          await _findTextContrastIssues(renderObject);
        } catch (e) {
          debugPrint('Erreur lors de l\'analyse du contraste: $e');
        }
        
        if (!hasTimedOut) {
          try {
            await _findAccessibleSizeIssues();
          } catch (e) {
            debugPrint('Erreur lors de l\'analyse des tailles: $e');
          }
        }
      }
    } catch (e) {
      debugPrint('Erreur lors de l\'analyse d\'accessibilité: $e');
    } finally {
      if (mounted && !hasTimedOut) {
        setState(() {
          _isScanning = false;
        });
      }
    }
  }

  // Trouve les problèmes de contraste du texte
  Future<void> _findTextContrastIssues(RenderObject renderObject) async {
    if (renderObject is RenderParagraph) {
      final TextSpan? textSpan = renderObject.text as TextSpan?;
      if (textSpan != null && textSpan.style != null) {
        final TextStyle style = textSpan.style!;
        
        // Remonter l'arbre pour trouver la couleur de fond
        Color? backgroundColor = _findBackgroundColor(renderObject);
        if (backgroundColor != null && style.color != null) {
          final contrastRatio = AccessibilityHelper.calculateContrastRatio(
            style.color!,
            backgroundColor,
          );
          
          final hasGoodContrast = contrastRatio >= 4.5;
          if (!hasGoodContrast) {
            final Offset position = renderObject.localToGlobal(Offset.zero);
            final Size size = renderObject.semanticBounds.size;
            
            setState(() {
              _issues.add(_AccessibilityIssue(
                rect: Rect.fromLTWH(position.dx, position.dy, size.width, size.height),
                message: 'Contraste insuffisant (${contrastRatio.toStringAsFixed(2)}:1)',
                severity: contrastRatio >= 3.0 ? _IssueSeverity.warning : _IssueSeverity.error,
                suggestion: 'Utiliser un contraste d\'au moins 4.5:1',
              ));
            });
          }
        }
      }
    }
    
    // Parcourir les enfants
    renderObject.visitChildren((child) {
      _findTextContrastIssues(child);
    });
  }
  
  // Analyse les widgets de l'application pour trouver des problèmes de taille d'accessibilité
  Future<void> _findAccessibleSizeIssues() async {
    // Collecter les widgets visibles avec des interactions tactiles
    final context = _childKey.currentContext;
    if (context == null || !mounted) return;
    
    // Parcourir l'arbre des widgets
    void inspectWidget(BuildContext context, [int depth = 0]) {
      // Limiter la profondeur de l'analyse pour éviter une récursion trop profonde
      if (depth >= _maxDepth || _issues.length >= _maxIssues) {
        return;
      }
      
      try {
        context.visitChildElements((element) {
          if (_issues.length >= _maxIssues) {
            return;
          }
          
          try {
            final widget = element.widget;
            
            // Vérifier les boutons et éléments tactiles
            if (widget is IconButton || 
                widget is FloatingActionButton ||
                widget is ElevatedButton ||
                widget is TextButton ||
                widget is OutlinedButton ||
                widget is InkWell) {
              
              try {
                final RenderBox? box = element.renderObject as RenderBox?;
                if (box != null && mounted) {
                  final size = box.size;
                  // Vérifier la taille minimale pour l'accessibilité (48x48 dp)
                  if (size.width < 48 || size.height < 48) {
                    final position = box.localToGlobal(Offset.zero);
                    setState(() {
                      _issues.add(_AccessibilityIssue(
                        rect: Rect.fromLTWH(position.dx, position.dy, size.width, size.height),
                        message: 'Cible tactile trop petite (${size.width.toInt()}x${size.height.toInt()})',
                        severity: _IssueSeverity.warning,
                        suggestion: 'Augmenter à au moins 48x48dp',
                      ));
                    });
                  }
                  
                  // Vérifier si le bouton a un tooltip
                  final bool hasTooltip = widget is IconButton && widget.tooltip != null ||
                                        widget is FloatingActionButton && widget.tooltip != null;
                  
                  if (!hasTooltip) {
                    final position = box.localToGlobal(Offset.zero);
                    if (mounted) {
                      setState(() {
                        _issues.add(_AccessibilityIssue(
                          rect: Rect.fromLTWH(position.dx, position.dy, size.width, size.height),
                          message: 'Bouton sans tooltip',
                          severity: _IssueSeverity.error,
                          suggestion: 'Ajouter un tooltip pour l\'accessibilité',
                        ));
                      });
                    }
                  }
                }
              } catch (e) {
                debugPrint('Erreur lors de l\'analyse d\'un bouton: $e');
              }
            }
            
            // Vérifier les images pour semantic labels
            if (widget is Image) {
              try {
                final bool hasSemanticLabel = widget.semanticLabel != null;
                
                if (!hasSemanticLabel) {
                  final RenderBox? box = element.renderObject as RenderBox?;
                  if (box != null && mounted) {
                    final position = box.localToGlobal(Offset.zero);
                    final size = box.size;
                    setState(() {
                      _issues.add(_AccessibilityIssue(
                        rect: Rect.fromLTWH(position.dx, position.dy, size.width, size.height),
                        message: 'Image sans semanticLabel',
                        severity: _IssueSeverity.error,
                        suggestion: 'Ajouter un semanticLabel pour l\'accessibilité',
                      ));
                    });
                  }
                }
              } catch (e) {
                debugPrint('Erreur lors de l\'analyse d\'une image: $e');
              }
            }
            
            // Continuer à parcourir l'arbre avec une profondeur augmentée
            try {
              inspectWidget(element, depth + 1);
            } catch (e) {
              debugPrint('Erreur lors de la traversée de l\'arbre: $e');
            }
          } catch (e) {
            debugPrint('Erreur lors de l\'analyse d\'un élément: $e');
          }
        });
      } catch (e) {
        debugPrint('Erreur lors de la visite des enfants: $e');
      }
    }
    
    try {
      inspectWidget(context);
      
      // Si nous avons limité le nombre de problèmes, ajouter une note
      if (_issues.length >= _maxIssues) {
        _issues.add(_AccessibilityIssue(
          rect: const Rect.fromLTWH(10, 10, 100, 30),
          message: 'Analyse limitée',
          severity: _IssueSeverity.info,
          suggestion: 'Seuls les $_maxIssues premiers problèmes sont affichés',
        ));
      }
    } catch (e) {
      debugPrint('Erreur globale dans l\'analyse des tailles: $e');
    }
  }

  // Trouve la couleur de fond d'un objet de rendu
  Color? _findBackgroundColor(RenderObject renderObject) {
    RenderObject? current = renderObject.parent;
    while (current != null) {
      if (current is RenderDecoratedBox) {
        final decoration = current.decoration;
        if (decoration is BoxDecoration && decoration.color != null) {
          return decoration.color;
        }
      }
      current = current.parent;
    }
    
    // Fallback: utiliser la couleur de fond du scaffold
    return Theme.of(context).scaffoldBackgroundColor;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Contenu principal
        KeyedSubtree(
          key: _childKey,
          child: widget.child,
        ),
        
        // Overlay des problèmes d'accessibilité
        if (widget.enabled)
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _AccessibilityOverlayPainter(issues: _issues),
              ),
            ),
          ),
        
        // Bouton de scan 
        if (widget.enabled)
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              mini: true,
              onPressed: _scanForAccessibilityIssues,
              tooltip: 'Scanner les problèmes d\'accessibilité',
              child: _isScanning
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Icon(Icons.accessibility),
            ),
          ),
          
        // Info sur les problèmes détectés
        if (widget.enabled && _issues.isNotEmpty)
          Positioned(
            top: 100,
            left: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(8),
              child: Text(
                'Problèmes: ${_issues.length}\n'
                '- Erreurs: ${_issues.where((i) => i.severity == _IssueSeverity.error).length}\n'
                '- Warnings: ${_issues.where((i) => i.severity == _IssueSeverity.warning).length}',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
      ],
    );
  }
}

/// Classe représentant un problème d'accessibilité
class _AccessibilityIssue {
  final Rect rect;
  final String message;
  final _IssueSeverity severity;
  final String? suggestion;

  _AccessibilityIssue({
    required this.rect,
    required this.message,
    required this.severity,
    this.suggestion,
  });
}

/// Niveaux de sévérité des problèmes d'accessibilité
enum _IssueSeverity {
  info,
  warning,
  error,
}

/// Peintre pour dessiner les problèmes d'accessibilité
class _AccessibilityOverlayPainter extends CustomPainter {
  final List<_AccessibilityIssue> issues;

  _AccessibilityOverlayPainter({required this.issues});

  @override
  void paint(Canvas canvas, Size size) {
    for (final issue in issues) {
      // Couleur selon la sévérité
      Color color;
      switch (issue.severity) {
        case _IssueSeverity.info:
          color = Colors.blue.withOpacity(0.7);
          break;
        case _IssueSeverity.warning:
          color = Colors.orange.withOpacity(0.7);
          break;
        case _IssueSeverity.error:
          color = Colors.red.withOpacity(0.7);
          break;
      }
      
      // Dessiner un rectangle autour du problème
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      
      canvas.drawRect(issue.rect, paint);
      
      // Dessiner un fond semi-transparent pour le texte
      final backgroundPaint = Paint()
        ..color = Colors.black.withOpacity(0.8)
        ..style = PaintingStyle.fill;
      
      final messageText = issue.message;
      final suggestionText = issue.suggestion != null ? '\n→ ${issue.suggestion}' : '';
      final displayText = '$messageText$suggestionText';
      
      // Calculer la hauteur du texte (approximation)
      final lines = displayText.split('\n').length;
      final textHeight = 20.0 * lines;
      
      final textRect = Rect.fromLTWH(
        issue.rect.left,
        issue.rect.bottom + 2,
        displayText.length * 7.0, // Estimation de la largeur du texte
        textHeight,
      );
      
      // Rectangle avec coin arrondi pour le texte
      final rrect = RRect.fromRectAndRadius(
        textRect, 
        const Radius.circular(4),
      );
      canvas.drawRRect(rrect, backgroundPaint);
      
      // Dessiner le texte explicatif
      final textPainter = TextPainter(
        text: TextSpan(
          text: displayText,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
        textDirection: TextDirection.ltr,
        maxLines: 2,
      );
      
      textPainter.layout(maxWidth: 300);
      textPainter.paint(canvas, Offset(issue.rect.left + 4, issue.rect.bottom + 4));
    }
  }

  @override
  bool shouldRepaint(_AccessibilityOverlayPainter oldDelegate) {
    return issues != oldDelegate.issues;
  }
} 