import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class QrSharingService {
  /// Partage un QR code avec les informations de session
  static Future<void> shareQrCode({
    required GlobalKey qrKey,
    required String sessionId,
    required String courseId,
    required DateTime sessionDate,
    required String teacherName,
    String? customMessage,
  }) async {
    try {
      // Capture du widget QR code
      final qrImageData = await _captureQrWidget(qrKey);
      
      if (qrImageData == null) {
        throw Exception('Impossible de capturer le QR code');
      }

      // Sauvegarde temporaire
      final directory = await getTemporaryDirectory();
      final fileName = _generateQrFileName(sessionId, sessionDate);
      final filePath = path.join(directory.path, fileName);
      
      final file = File(filePath);
      await file.writeAsBytes(qrImageData);
      
      // Message de partage
      final shareText = customMessage ?? _generateShareMessage(
        sessionId, courseId, sessionDate, teacherName
      );
      
      final xFile = XFile(filePath);
      await Share.shareXFiles(
        [xFile],
        text: shareText,
        subject: 'QR Code de Présence - $sessionId',
      );
      
      // Nettoyage après délai
      Future.delayed(const Duration(minutes: 5), () {
        if (file.existsSync()) {
          file.deleteSync();
        }
      });
    } catch (e) {
      throw Exception('Erreur lors du partage: $e');
    }
  }

  /// Sauvegarde le QR code localement
  static Future<String> saveQrCodeLocally({
    required GlobalKey qrKey,
    required String sessionId,
    required DateTime sessionDate,
  }) async {
    try {
      final qrImageData = await _captureQrWidget(qrKey);
      
      if (qrImageData == null) {
        throw Exception('Impossible de capturer le QR code');
      }

      final directory = await getApplicationDocumentsDirectory();
      final qrCodesDir = Directory(path.join(directory.path, 'qr_codes'));
      
      if (!qrCodesDir.existsSync()) {
        qrCodesDir.createSync(recursive: true);
      }
      
      final fileName = _generateQrFileName(sessionId, sessionDate);
      final filePath = path.join(qrCodesDir.path, fileName);
      
      final file = File(filePath);
      await file.writeAsBytes(qrImageData);
      
      return filePath;
    } catch (e) {
      throw Exception('Erreur lors de la sauvegarde: $e');
    }
  }

  /// Options de partage avec BottomSheet
  static Future<void> showSharingOptions({
    required BuildContext context,
    required GlobalKey qrKey,
    required String sessionId,
    required String courseId,
    required DateTime sessionDate,
    required String teacherName,
  }) async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _QrSharingOptionsBottomSheet(
        qrKey: qrKey,
        sessionId: sessionId,
        courseId: courseId,
        sessionDate: sessionDate,
        teacherName: teacherName,
      ),
    );
  }

  /// Capture le widget QR code en image
  static Future<Uint8List?> _captureQrWidget(GlobalKey qrKey) async {
    try {
      final RenderRepaintBoundary boundary =
          qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      
      return byteData?.buffer.asUint8List();
    } catch (e) {
      print('Erreur capture QR: $e');
      return null;
    }
  }

  /// Génère le nom du fichier QR
  static String _generateQrFileName(String sessionId, DateTime sessionDate) {
    final dateStr = _formatDateForFileName(sessionDate);
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    
    return 'qr_code_${sessionId}_${dateStr}_$timestamp.png';
  }

  /// Génère le message de partage
  static String _generateShareMessage(
    String sessionId,
    String courseId,
    DateTime sessionDate,
    String teacherName,
  ) {
    final dateStr = _formatDateForDisplay(sessionDate);
    
    return '''📱 QR Code de Présence - ESTM Digital

Session: $sessionId
${courseId.isNotEmpty ? 'Cours: $courseId\n' : ''}Date: $dateStr
Enseignant: $teacherName

📋 Instructions:
1. Scannez ce QR code avec l'app ESTM Digital
2. Confirmez votre présence
3. La présence sera enregistrée automatiquement

⏰ Validité: 1 heure à partir de la génération

---
ESTM - École Supérieure de Technologie et Management''';
  }

  /// Formate la date pour nom de fichier
  static String _formatDateForFileName(DateTime date) {
    return '${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}';
  }

  /// Formate la date pour affichage
  static String _formatDateForDisplay(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

/// Widget pour les options de partage de QR code
class _QrSharingOptionsBottomSheet extends StatelessWidget {
  final GlobalKey qrKey;
  final String sessionId;
  final String courseId;
  final DateTime sessionDate;
  final String teacherName;

  const _QrSharingOptionsBottomSheet({
    required this.qrKey,
    required this.sessionId,
    required this.courseId,
    required this.sessionDate,
    required this.teacherName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.qr_code, color: colorScheme.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Partager le QR Code',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      'Session: $sessionId',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Options de partage
          _QrSharingOptionTile(
            icon: Icons.share,
            title: 'Partage général',
            subtitle: 'Partager via les applications installées',
            onTap: () async {
              Navigator.pop(context);
              await _shareGeneral(context);
            },
          ),
          const SizedBox(height: 12),
          _QrSharingOptionTile(
            icon: Icons.email,
            title: 'Envoyer par email',
            subtitle: 'Partager le QR code par email',
            onTap: () async {
              Navigator.pop(context);
              await _shareByEmail(context);
            },
          ),
          const SizedBox(height: 12),
          _QrSharingOptionTile(
            icon: Icons.save,
            title: 'Sauvegarder',
            subtitle: 'Enregistrer le QR code localement',
            onTap: () async {
              Navigator.pop(context);
              await _saveLocally(context);
            },
          ),
          const SizedBox(height: 16),

          // Bouton Annuler
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _shareGeneral(BuildContext context) async {
    try {
      await QrSharingService.shareQrCode(
        qrKey: qrKey,
        sessionId: sessionId,
        courseId: courseId,
        sessionDate: sessionDate,
        teacherName: teacherName,
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _shareByEmail(BuildContext context) async {
    try {
      await QrSharingService.shareQrCode(
        qrKey: qrKey,
        sessionId: sessionId,
        courseId: courseId,
        sessionDate: sessionDate,
        teacherName: teacherName,
        customMessage: '''Bonjour,

Veuillez trouver ci-joint le QR code de présence pour la session $sessionId.

${courseId.isNotEmpty ? 'Cours: $courseId\n' : ''}Date: ${QrSharingService._formatDateForDisplay(sessionDate)}
Enseignant: $teacherName

Les étudiants doivent scanner ce QR code pour confirmer leur présence.

Cordialement,
$teacherName

---
ESTM Digital - Système de Gestion de Présence''',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveLocally(BuildContext context) async {
    try {
      final savedPath = await QrSharingService.saveQrCodeLocally(
        qrKey: qrKey,
        sessionId: sessionId,
        sessionDate: sessionDate,
      );
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('QR code sauvegardé: $savedPath'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

/// Widget pour une option de partage de QR code
class _QrSharingOptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _QrSharingOptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: colorScheme.primary),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: colorScheme.onSurface.withValues(alpha: 0.5),
        ),
        onTap: onTap,
      ),
    );
  }
} 