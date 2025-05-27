import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/services/absence_service.dart';
import '../auth/providers/auth_provider.dart';
import 'services/qr_sharing_service.dart';

class QRGeneratorScreen extends ConsumerStatefulWidget {
  const QRGeneratorScreen({super.key});

  @override
  ConsumerState<QRGeneratorScreen> createState() => _QRGeneratorScreenState();
}

class _QRGeneratorScreenState extends ConsumerState<QRGeneratorScreen> {
  final _sessionIdController = TextEditingController();
  final _courseIdController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String? _qrCodeData;
  bool _isGenerating = false;
  final GlobalKey _qrKey = GlobalKey();

  @override
  void dispose() {
    _sessionIdController.dispose();
    _courseIdController.dispose();
    super.dispose();
  }

  Future<void> _generateQRCode() async {
    final user = ref.read(authStateProvider).user;
    if (user == null || user.role != 'teacher') {
      _showErrorDialog('Seuls les enseignants peuvent générer des QR codes');
      return;
    }

    if (_sessionIdController.text.trim().isEmpty) {
      _showErrorDialog('Veuillez saisir un ID de session');
      return;
    }

    setState(() => _isGenerating = true);

    try {
      final qrData = AbsenceService.generateQRCodeData(
        sessionId: _sessionIdController.text.trim(),
        date: _selectedDate,
        teacherId: user.id,
        courseId: _courseIdController.text.trim().isNotEmpty 
            ? _courseIdController.text.trim() 
            : null,
      );

      setState(() {
        _qrCodeData = qrData;
        _isGenerating = false;
      });

      _showSuccessSnackBar('QR Code généré avec succès !');
    } catch (e) {
      setState(() => _isGenerating = false);
      _showErrorDialog('Erreur lors de la génération: $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Erreur'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _selectDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (pickedDate != null) {
      setState(() => _selectedDate = pickedDate);
    }
  }

  void _resetForm() {
    setState(() {
      _qrCodeData = null;
      _sessionIdController.clear();
      _courseIdController.clear();
      _selectedDate = DateTime.now();
    });
  }

  /// Partage le QR code généré
  Future<void> _shareQrCode() async {
    final user = ref.read(authStateProvider).user;
    
    if (user == null || _qrCodeData == null) {
      _showErrorDialog('Aucun QR code à partager');
      return;
    }

    try {
      await QrSharingService.showSharingOptions(
        context: context,
        qrKey: _qrKey,
        sessionId: _sessionIdController.text.trim(),
        courseId: _courseIdController.text.trim(),
        sessionDate: _selectedDate,
        teacherName: user.displayName ?? user.email ?? 'Enseignant',
      );
    } catch (e) {
      _showErrorDialog('Erreur lors du partage: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final user = ref.watch(authStateProvider).user;

    // Vérification des permissions
    if (user?.role != 'teacher' && user?.role != 'admin') {
      return Scaffold(
        appBar: AppBar(title: const Text('Génération QR Code')),
        body: const Center(
          child: Text(
            'Accès non autorisé\nSeuls les enseignants peuvent générer des QR codes',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Générer QR Code',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          if (_qrCodeData != null)
            IconButton(
              onPressed: _resetForm,
              icon: const Icon(Icons.refresh),
              tooltip: 'Nouveau QR Code',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // En-tête informatif
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.qr_code,
                      size: 48,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Générateur QR Code de Présence',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Créez un QR code que vos étudiants pourront scanner pour marquer leur présence',
                      style: TextStyle(
                        color: colorScheme.onSurface.withValues(alpha: 0.7),
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Formulaire de configuration
            if (_qrCodeData == null) ...[
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Configuration de la session',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ID de session
                      TextFormField(
                        controller: _sessionIdController,
                        decoration: InputDecoration(
                          labelText: 'ID de Session *',
                          hintText: 'Ex: MATH-L3-001',
                          prefixIcon: const Icon(Icons.fingerprint),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'L\'ID de session est requis';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Cours (optionnel)
                      TextFormField(
                        controller: _courseIdController,
                        decoration: InputDecoration(
                          labelText: 'Code du cours',
                          hintText: 'Ex: MATH101',
                          prefixIcon: const Icon(Icons.book),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Sélection de date
                      InkWell(
                        onTap: _selectDate,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: theme.dividerColor,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                color: colorScheme.primary,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Date de la session',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: colorScheme.onSurface.withValues(alpha: 0.7),
                                      ),
                                    ),
                                    Text(
                                      '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: colorScheme.onSurface.withValues(alpha: 0.5),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Bouton de génération
                      FilledButton(
                        onPressed: _isGenerating ? null : _generateQRCode,
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isGenerating
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.qr_code),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Générer QR Code',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            // QR Code généré
            if (_qrCodeData != null) ...[
              Card(
                elevation: 8,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Text(
                        'QR Code de Présence',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // QR Code
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: RepaintBoundary(
                          key: _qrKey,
                          child: QrImageView(
                            data: _qrCodeData!,
                            version: QrVersions.auto,
                            size: 250.0,
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Informations de session
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            _buildInfoRow(
                              'Session:',
                              _sessionIdController.text,
                              Icons.fingerprint,
                            ),
                            if (_courseIdController.text.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              _buildInfoRow(
                                'Cours:',
                                _courseIdController.text,
                                Icons.book,
                              ),
                            ],
                            const SizedBox(height: 8),
                            _buildInfoRow(
                              'Date:',
                              '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                              Icons.calendar_today,
                            ),
                            const SizedBox(height: 8),
                            _buildInfoRow(
                              'Enseignant:',
                              user?.displayName ?? user?.email ?? 'Inconnu',
                              Icons.person,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Boutons d'action
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _resetForm,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Nouveau'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: _shareQrCode,
                              icon: const Icon(Icons.share),
                              label: const Text('Partager'),
                              style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Avertissement de validité
              Card(
                color: Colors.orange.withValues(alpha: 0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        color: Colors.orange[700],
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Validité du QR Code',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                color: Colors.orange[700],
                              ),
                            ),
                            Text(
                              'Ce QR code est valide pendant 1 heure à partir de sa génération.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.orange[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 12),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
} 