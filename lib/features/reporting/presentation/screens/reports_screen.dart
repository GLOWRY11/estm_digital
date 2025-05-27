import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/report_sharing_service.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  String _selectedReportType = 'absences';
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  bool _isGenerating = false;

  final List<Map<String, dynamic>> _reportTypes = [
    {
      'value': 'absences',
      'label': 'Rapport d\'Absences',
      'icon': Icons.event_busy,
      'description': 'Statistiques des absences par étudiant et matière',
    },
    {
      'value': 'grades',
      'label': 'Rapport de Notes',
      'icon': Icons.grade,
      'description': 'Moyennes et statistiques des notes',
    },
    {
      'value': 'attendance',
      'label': 'Taux de Présence',
      'icon': Icons.people,
      'description': 'Analyse du taux de présence global',
    },
    {
      'value': 'students',
      'label': 'Liste des Étudiants',
      'icon': Icons.school,
      'description': 'Informations complètes des étudiants',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Rapports & Statistiques',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Type de rapport
            Text(
              'Type de rapport',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            
            ..._reportTypes.map((reportType) {
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: RadioListTile<String>(
                  value: reportType['value'],
                  groupValue: _selectedReportType,
                  onChanged: (value) {
                    setState(() {
                      _selectedReportType = value!;
                    });
                  },
                  title: Row(
                    children: [
                      Icon(reportType['icon'], size: 20),
                      const SizedBox(width: 8),
                      Text(
                        reportType['label'],
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  subtitle: Text(
                    reportType['description'],
                    style: GoogleFonts.roboto(fontSize: 12),
                  ),
                ),
              );
            }),

            const SizedBox(height: 24),

            // Période
            Text(
              'Période',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Date de début',
                                style: GoogleFonts.roboto(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              InkWell(
                                onTap: () async {
                                  final date = await showDatePicker(
                                    context: context,
                                    initialDate: _startDate,
                                    firstDate: DateTime.now().subtract(const Duration(days: 365)),
                                    lastDate: _endDate,
                                  );
                                  if (date != null) {
                                    setState(() {
                                      _startDate = date;
                                    });
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: colorScheme.outline),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.calendar_today, size: 16),
                                      const SizedBox(width: 8),
                                      Text(_formatDate(_startDate)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Date de fin',
                                style: GoogleFonts.roboto(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              InkWell(
                                onTap: () async {
                                  final date = await showDatePicker(
                                    context: context,
                                    initialDate: _endDate,
                                    firstDate: _startDate,
                                    lastDate: DateTime.now().add(const Duration(days: 30)),
                                  );
                                  if (date != null) {
                                    setState(() {
                                      _endDate = date;
                                    });
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: colorScheme.outline),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.calendar_today, size: 16),
                                      const SizedBox(width: 8),
                                      Text(_formatDate(_endDate)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Boutons de génération
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isGenerating ? null : () => _generateReport('pdf'),
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text('Générer PDF'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _isGenerating ? null : () => _generateReport('csv'),
                    icon: const Icon(Icons.table_chart),
                    label: const Text('Générer CSV'),
                  ),
                ),
              ],
            ),

            if (_isGenerating) ...[
              const SizedBox(height: 24),
              const Center(
                child: CircularProgressIndicator(),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'Génération du rapport en cours...',
                  style: GoogleFonts.roboto(
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _generateReport(String format) async {
    setState(() {
      _isGenerating = true;
    });

    try {
      // Simulation de génération
      await Future.delayed(const Duration(seconds: 2));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Rapport $format généré avec succès'),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'Partager',
              onPressed: () => _shareReport(format),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la génération: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
    }
  }

  /// Partage un rapport généré
  Future<void> _shareReport(String format) async {
    try {
      // Simulation de données de rapport pour la démonstration
      // En production, ces données viendraient de la génération du rapport
      final mockData = _generateMockReportData();
      
      await ReportSharingService.showSharingOptions(
        context: context,
        reportType: _selectedReportType,
        format: format,
        startDate: _startDate,
        endDate: _endDate,
        fileData: mockData,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du partage: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Génère des données simulées pour le rapport
  Uint8List _generateMockReportData() {
    // Simulation d'un fichier rapport simple
    final reportContent = '''
RAPPORT ESTM DIGITAL - ${ReportSharingService.getReportTypeLabel(_selectedReportType).toUpperCase()}

Période: ${_formatDate(_startDate)} au ${_formatDate(_endDate)}
Type: $_selectedReportType

--- DONNÉES SIMULÉES ---
Nombre d'étudiants: 45
Nombre de cours: 12
Taux de présence moyen: 87%
Nombre d'absences: 23

--- DÉTAILS ---
${List.generate(10, (index) => 'Ligne de données $index').join('\n')}

--- GÉNÉRÉ LE ---
${DateTime.now().toString()}

ESTM - École Supérieure de Technologie et Management
Application de Gestion Académique
    ''';
    
    return Uint8List.fromList(reportContent.codeUnits);
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
} 