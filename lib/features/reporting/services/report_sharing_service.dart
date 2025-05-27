import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class ReportSharingService {
  /// Partage un rapport PDF ou CSV
  static Future<void> shareReport({
    required String reportType,
    required String format,
    required DateTime startDate,
    required DateTime endDate,
    required Uint8List fileData,
    String? customMessage,
  }) async {
    try {
      final directory = await getTemporaryDirectory();
      final fileName = _generateFileName(reportType, format, startDate, endDate);
      final filePath = path.join(directory.path, fileName);
      
      final file = File(filePath);
      await file.writeAsBytes(fileData);
      
      final shareText = customMessage ?? _generateShareMessage(reportType, startDate, endDate);
      
      final xFile = XFile(filePath);
      await Share.shareXFiles(
        [xFile],
        text: shareText,
        subject: _generateEmailSubject(reportType, startDate, endDate),
      );
      
      // Nettoyer le fichier temporaire après un délai
      Future.delayed(const Duration(minutes: 5), () {
        if (file.existsSync()) {
          file.deleteSync();
        }
      });
    } catch (e) {
      throw Exception('Erreur lors du partage: $e');
    }
  }

  /// Partage par email spécifiquement
  static Future<void> shareByEmail({
    required String reportType,
    required String format,
    required DateTime startDate,
    required DateTime endDate,
    required Uint8List fileData,
    List<String>? emailRecipients,
    String? customMessage,
  }) async {
    try {
      final directory = await getTemporaryDirectory();
      final fileName = _generateFileName(reportType, format, startDate, endDate);
      final filePath = path.join(directory.path, fileName);
      
      final file = File(filePath);
      await file.writeAsBytes(fileData);
      
      final emailBody = customMessage ?? _generateEmailBody(reportType, startDate, endDate);
      final subject = _generateEmailSubject(reportType, startDate, endDate);
      
      final xFile = XFile(filePath);
      await Share.shareXFiles(
        [xFile],
        text: emailBody,
        subject: subject,
      );
      
      // Nettoyer le fichier temporaire
      Future.delayed(const Duration(minutes: 5), () {
        if (file.existsSync()) {
          file.deleteSync();
        }
      });
    } catch (e) {
      throw Exception('Erreur lors de l\'envoi par email: $e');
    }
  }

  /// Sauvegarde locale du rapport
  static Future<String> saveReportLocally({
    required String reportType,
    required String format,
    required DateTime startDate,
    required DateTime endDate,
    required Uint8List fileData,
  }) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final reportsDir = Directory(path.join(directory.path, 'reports'));
      
      if (!reportsDir.existsSync()) {
        reportsDir.createSync(recursive: true);
      }
      
      final fileName = _generateFileName(reportType, format, startDate, endDate);
      final filePath = path.join(reportsDir.path, fileName);
      
      final file = File(filePath);
      await file.writeAsBytes(fileData);
      
      return filePath;
    } catch (e) {
      throw Exception('Erreur lors de la sauvegarde: $e');
    }
  }

  /// Affiche les options de partage
  static Future<void> showSharingOptions({
    required BuildContext context,
    required String reportType,
    required String format,
    required DateTime startDate,
    required DateTime endDate,
    required Uint8List fileData,
  }) async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _SharingOptionsBottomSheet(
        reportType: reportType,
        format: format,
        startDate: startDate,
        endDate: endDate,
        fileData: fileData,
      ),
    );
  }

  /// Génère le nom du fichier
  static String _generateFileName(String reportType, String format, DateTime startDate, DateTime endDate) {
    final startStr = _formatDateForFileName(startDate);
    final endStr = _formatDateForFileName(endDate);
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    
    return 'rapport_${reportType}_${startStr}_${endStr}_$timestamp.$format';
  }

  /// Génère le message de partage
  static String _generateShareMessage(String reportType, DateTime startDate, DateTime endDate) {
    final startStr = _formatDateForDisplay(startDate);
    final endStr = _formatDateForDisplay(endDate);
    
    return '''📊 Rapport ESTM Digital

Type: ${getReportTypeLabel(reportType)}
Période: du $startStr au $endStr

Généré le ${_formatDateForDisplay(DateTime.now())} via l'application ESTM Digital.

---
ESTM - École Supérieure de Technologie et Management''';
  }

  /// Génère le sujet de l'email
  static String _generateEmailSubject(String reportType, DateTime startDate, DateTime endDate) {
    final startStr = _formatDateForDisplay(startDate);
    final endStr = _formatDateForDisplay(endDate);
    return 'Rapport ${getReportTypeLabel(reportType)} - $startStr au $endStr';
  }

  /// Génère le corps de l'email
  static String _generateEmailBody(String reportType, DateTime startDate, DateTime endDate) {
    final startStr = _formatDateForDisplay(startDate);
    final endStr = _formatDateForDisplay(endDate);
    
    return '''Bonjour,

Veuillez trouver ci-joint le rapport ${getReportTypeLabel(reportType)} pour la période du $startStr au $endStr.

Ce rapport a été généré automatiquement via l'application ESTM Digital le ${_formatDateForDisplay(DateTime.now())}.

Cordialement,
L'équipe ESTM Digital

---
ESTM - École Supérieure de Technologie et Management
Application de Gestion Académique''';
  }

  /// Formatage de date pour nom de fichier
  static String _formatDateForFileName(DateTime date) {
    return '${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}';
  }

  /// Formatage de date pour affichage
  static String _formatDateForDisplay(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  /// Obtient le label du type de rapport
  static String getReportTypeLabel(String reportType) {
    switch (reportType) {
      case 'absences':
        return 'Absences';
      case 'grades':
        return 'Notes';
      case 'attendance':
        return 'Présence';
      case 'students':
        return 'Étudiants';
      default:
        return 'Général';
    }
  }
}

/// Widget pour les options de partage
class _SharingOptionsBottomSheet extends StatelessWidget {
  final String reportType;
  final String format;
  final DateTime startDate;
  final DateTime endDate;
  final Uint8List fileData;

  const _SharingOptionsBottomSheet({
    required this.reportType,
    required this.format,
    required this.startDate,
    required this.endDate,
    required this.fileData,
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
              Icon(Icons.share, color: colorScheme.primary),
              const SizedBox(width: 12),
              Text(
                'Partager le rapport',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
                     Text(
             'Rapport ${ReportSharingService.getReportTypeLabel(reportType)} ($format)',
             style: TextStyle(
               fontSize: 14,
               color: colorScheme.onSurface.withValues(alpha: 0.7),
             ),
           ),
          const SizedBox(height: 24),

          // Options de partage
          _SharingOptionTile(
            icon: Icons.share,
            title: 'Partage général',
            subtitle: 'Partager via les applications installées',
            onTap: () async {
              Navigator.pop(context);
              await _shareGeneral(context);
            },
          ),
          const SizedBox(height: 12),
          _SharingOptionTile(
            icon: Icons.email,
            title: 'Envoyer par email',
            subtitle: 'Partager via application email',
            onTap: () async {
              Navigator.pop(context);
              await _shareByEmail(context);
            },
          ),
          const SizedBox(height: 12),
          _SharingOptionTile(
            icon: Icons.save,
            title: 'Sauvegarder localement',
            subtitle: 'Enregistrer dans les documents',
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
      await ReportSharingService.shareReport(
        reportType: reportType,
        format: format,
        startDate: startDate,
        endDate: endDate,
        fileData: fileData,
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
      await ReportSharingService.shareByEmail(
        reportType: reportType,
        format: format,
        startDate: startDate,
        endDate: endDate,
        fileData: fileData,
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
      final savedPath = await ReportSharingService.saveReportLocally(
        reportType: reportType,
        format: format,
        startDate: startDate,
        endDate: endDate,
        fileData: fileData,
      );
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Rapport sauvegardé: $savedPath'),
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

/// Widget pour une option de partage
class _SharingOptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SharingOptionTile({
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