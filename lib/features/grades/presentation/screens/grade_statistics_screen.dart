import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GradeStatisticsScreen extends StatefulWidget {
  final String? subjectFilter; // Matière spécifique (optionnel)
  
  const GradeStatisticsScreen({super.key, this.subjectFilter});

  @override
  State<GradeStatisticsScreen> createState() => _GradeStatisticsScreenState();
}

class _GradeStatisticsScreenState extends State<GradeStatisticsScreen> {
  bool _isLoading = true;
  Map<String, dynamic> _statistics = {};
  String _selectedSubject = 'all';

  // Données simulées pour les statistiques - dans un vrai projet, viendraient de la base de données
  final Map<String, Map<String, dynamic>> _mockSubjectStats = {
    'all': {
      'totalStudents': 120,
      'classAverage': 13.8,
      'minGrade': 6.5,
      'maxGrade': 19.5,
      'passedStudents': 92,
      'failedStudents': 28,
      'passRate': 76.7,
      'gradeDistribution': {
        'excellent': 18, // >= 16
        'good': 28,      // 14-15.99
        'fair': 32,      // 12-13.99
        'pass': 14,      // 10-11.99
        'fail': 28,      // < 10
      },
    },
    'Mathématiques': {
      'totalStudents': 42,
      'classAverage': 12.4,
      'minGrade': 4.0,
      'maxGrade': 18.5,
      'passedStudents': 28,
      'failedStudents': 14,
      'passRate': 66.7,
      'gradeDistribution': {
        'excellent': 5,
        'good': 8,
        'fair': 12,
        'pass': 3,
        'fail': 14,
      },
    },
    'Informatique': {
      'totalStudents': 38,
      'classAverage': 15.2,
      'minGrade': 9.0,
      'maxGrade': 19.5,
      'passedStudents': 36,
      'failedStudents': 2,
      'passRate': 94.7,
      'gradeDistribution': {
        'excellent': 12,
        'good': 14,
        'fair': 8,
        'pass': 2,
        'fail': 2,
      },
    },
    'Physique': {
      'totalStudents': 40,
      'classAverage': 13.1,
      'minGrade': 6.5,
      'maxGrade': 17.0,
      'passedStudents': 28,
      'failedStudents': 12,
      'passRate': 70.0,
      'gradeDistribution': {
        'excellent': 1,
        'good': 6,
        'fair': 12,
        'pass': 9,
        'fail': 12,
      },
    },
  };

  final List<String> _subjects = ['all', 'Mathématiques', 'Informatique', 'Physique'];

  @override
  void initState() {
    super.initState();
    
    // Si une matière est pré-sélectionnée
    if (widget.subjectFilter != null) {
      _selectedSubject = widget.subjectFilter!;
    }
    
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(milliseconds: 800)); // Simulation délai réseau

    try {
      // Charger les statistiques simulées
      _statistics = _mockSubjectStats[_selectedSubject] ?? _mockSubjectStats['all']!;
    } catch (e) {
      // Gestion d'erreur
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur de chargement: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Color _getGradeColor(double grade) {
    if (grade >= 16) return Colors.green;
    if (grade >= 14) return Colors.lightGreen;
    if (grade >= 12) return Colors.orange;
    if (grade >= 10) return Colors.deepOrange;
    return Colors.red;
  }

  Color _getDistributionColor(String level) {
    switch (level) {
      case 'excellent': return Colors.green;
      case 'good': return Colors.lightGreen;
      case 'fair': return Colors.orange;
      case 'pass': return Colors.deepOrange;
      case 'fail': return Colors.red;
      default: return Colors.grey;
    }
  }

  String _getDistributionLabel(String level) {
    switch (level) {
      case 'excellent': return 'Excellent (≥16)';
      case 'good': return 'Bien (14-15.99)';
      case 'fair': return 'Assez Bien (12-13.99)';
      case 'pass': return 'Passable (10-11.99)';
      case 'fail': return 'Échec (<10)';
      default: return level;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          widget.subjectFilter != null 
              ? 'Statistiques - ${widget.subjectFilter}'
              : 'Statistiques des Notes',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: colorScheme.primary,
        actions: [
          IconButton(
            onPressed: _loadStatistics,
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualiser',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Chargement des statistiques...'),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Sélecteur de matière
                  if (widget.subjectFilter == null) ...[
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Matière',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<String>(
                              value: _selectedSubject,
                              decoration: InputDecoration(
                                labelText: 'Sélectionner une matière',
                                prefixIcon: const Icon(Icons.school),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              items: _subjects.map((subject) {
                                return DropdownMenuItem<String>(
                                  value: subject,
                                  child: Text(subject == 'all' ? 'Toutes les matières' : subject),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedSubject = value!;
                                });
                                _loadStatistics();
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Aperçu général
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.analytics,
                                color: colorScheme.primary,
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Aperçu général',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  'Étudiants',
                                  _statistics['totalStudents'].toString(),
                                  Icons.people,
                                  Colors.blue,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildStatCard(
                                  'Moyenne',
                                  '${(_statistics['classAverage'] as double).toStringAsFixed(1)}/20',
                                  Icons.grade,
                                  _getGradeColor(_statistics['classAverage'] as double),
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 12),
                          
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  'Taux de réussite',
                                  '${(_statistics['passRate'] as double).toStringAsFixed(1)}%',
                                  Icons.check_circle,
                                  _statistics['passRate'] > 75 ? Colors.green : 
                                  _statistics['passRate'] > 50 ? Colors.orange : Colors.red,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildStatCard(
                                  'Échecs',
                                  _statistics['failedStudents'].toString(),
                                  Icons.warning,
                                  Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Notes min/max
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.trending_up,
                                color: colorScheme.primary,
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Étendue des notes',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(16.0),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.red, width: 1),
                                  ),
                                  child: Column(
                                    children: [
                                      Icon(Icons.trending_down, color: Colors.red),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Note minimale',
                                        style: GoogleFonts.roboto(fontSize: 12),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${(_statistics['minGrade'] as double).toStringAsFixed(1)}/20',
                                        style: GoogleFonts.poppins(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(16.0),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.green, width: 1),
                                  ),
                                  child: Column(
                                    children: [
                                      Icon(Icons.trending_up, color: Colors.green),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Note maximale',
                                        style: GoogleFonts.roboto(fontSize: 12),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${(_statistics['maxGrade'] as double).toStringAsFixed(1)}/20',
                                        style: GoogleFonts.poppins(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.green,
                                        ),
                                      ),
                                    ],
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

                  // Distribution des notes
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.bar_chart,
                                color: colorScheme.primary,
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Distribution des notes',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          
                          ..._buildDistributionBars(),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Actions rapides
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.quick_contacts_dialer,
                                color: colorScheme.primary,
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Actions rapides',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Export en développement'),
                                        backgroundColor: Colors.blue,
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.download),
                                  label: const Text('Exporter'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: FilledButton.icon(
                                  onPressed: () {
                                    Navigator.of(context).pushNamed('/grades');
                                  },
                                  icon: const Icon(Icons.list),
                                  label: const Text('Voir détails'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            style: GoogleFonts.roboto(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  List<Widget> _buildDistributionBars() {
    final distribution = _statistics['gradeDistribution'] as Map<String, dynamic>;
    final total = _statistics['totalStudents'] as int;
    
    return distribution.entries.map((entry) {
      final count = entry.value as int;
      final percentage = total > 0 ? (count / total * 100) : 0.0;
      final color = _getDistributionColor(entry.key);
      
      return Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _getDistributionLabel(entry.key),
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '$count étudiants (${percentage.toStringAsFixed(1)}%)',
                  style: GoogleFonts.roboto(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Container(
              height: 8,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(4),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: percentage / 100,
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
} 