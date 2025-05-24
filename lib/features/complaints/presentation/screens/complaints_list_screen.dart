import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/local_database.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

class ComplaintsListScreen extends ConsumerStatefulWidget {
  const ComplaintsListScreen({super.key});

  @override
  ConsumerState<ComplaintsListScreen> createState() => _ComplaintsListScreenState();
}

class _ComplaintsListScreenState extends ConsumerState<ComplaintsListScreen> {
  List<Map<String, dynamic>> _complaints = [];
  bool _isLoading = true;
  String _selectedFilter = 'all';
  final _uuid = const Uuid();

  final List<Map<String, dynamic>> _statusFilters = [
    {'value': 'all', 'label': 'Toutes', 'icon': Icons.list, 'color': Colors.grey},
    {'value': 'pending', 'label': 'En attente', 'icon': Icons.schedule, 'color': Colors.orange},
    {'value': 'in_progress', 'label': 'En cours', 'icon': Icons.hourglass_empty, 'color': Colors.blue},
    {'value': 'resolved', 'label': 'Résolues', 'icon': Icons.check_circle, 'color': Colors.green},
    {'value': 'rejected', 'label': 'Rejetées', 'icon': Icons.cancel, 'color': Colors.red},
  ];

  @override
  void initState() {
    super.initState();
    _loadComplaints();
  }

  Future<void> _loadComplaints() async {
    setState(() => _isLoading = true);
    try {
      final db = await LocalDatabase.open();
      String query = '''
        SELECT c.*, u.displayName, u.email 
        FROM complaints c 
        LEFT JOIN users u ON c.userId = u.id 
        WHERE 1=1
      ''';
      List<dynamic> whereArgs = [];

      if (_selectedFilter != 'all') {
        query += ' AND c.status = ?';
        whereArgs.add(_selectedFilter);
      }

      query += ' ORDER BY c.createdAt DESC';

      final result = await db.rawQuery(query, whereArgs);
      
      setState(() {
        _complaints = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors du chargement: $e')),
        );
      }
    }
  }

  Future<void> _updateComplaintStatus(String complaintId, String newStatus) async {
    try {
      final db = await LocalDatabase.open();
      await db.update(
        'complaints',
        {'status': newStatus},
        where: 'id = ?',
        whereArgs: [complaintId],
      );
      
      _loadComplaints();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Statut mis à jour: ${_getStatusLabel(newStatus)}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final isAdmin = currentUser?.role == 'admin';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Réclamations'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filtrer par statut',
            onSelected: (value) {
              setState(() => _selectedFilter = value);
              _loadComplaints();
            },
            itemBuilder: (context) => _statusFilters.map((filter) {
              return PopupMenuItem<String>(
                value: filter['value'],
                child: Row(
                  children: [
                    Icon(filter['icon'], size: 20, color: filter['color']),
                    const SizedBox(width: 8),
                    Text(filter['label']),
                    if (_selectedFilter == filter['value'])
                      const Padding(
                        padding: EdgeInsets.only(left: 8),
                        child: Icon(Icons.check, size: 16),
                      ),
                  ],
                ),
              );
            }).toList(),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadComplaints,
            tooltip: 'Actualiser',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _complaints.isEmpty
              ? _buildEmptyState()
              : _buildComplaintsList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddComplaintDialog(),
        tooltip: 'Nouvelle réclamation',
        child: const Icon(Icons.add_comment),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _selectedFilter == 'all' ? Icons.inbox : _statusFilters
                .firstWhere((f) => f['value'] == _selectedFilter)['icon'],
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _selectedFilter == 'all' 
                ? 'Aucune réclamation enregistrée'
                : 'Aucune réclamation ${_statusFilters.firstWhere((f) => f['value'] == _selectedFilter)['label'].toLowerCase()}',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _showAddComplaintDialog(),
            icon: const Icon(Icons.add_comment),
            label: const Text('Ajouter une réclamation'),
          ),
        ],
      ),
    );
  }

  Widget _buildComplaintsList() {
    final currentUser = ref.watch(currentUserProvider);
    final isAdmin = currentUser?.role == 'admin';

    return Column(
      children: [
        // Statistiques
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatChip('Total', _complaints.length, Icons.list),
              _buildStatChip(
                'En attente', 
                _complaints.where((c) => c['status'] == 'pending').length, 
                Icons.schedule,
              ),
              _buildStatChip(
                'Résolues', 
                _complaints.where((c) => c['status'] == 'resolved').length, 
                Icons.check_circle,
              ),
            ],
          ),
        ),
        
        // Liste des réclamations
        Expanded(
          child: ListView.builder(
            itemCount: _complaints.length,
            itemBuilder: (context, index) {
              final complaint = _complaints[index];
              final statusInfo = _statusFilters.firstWhere(
                (s) => s['value'] == complaint['status'],
                orElse: () => _statusFilters.first,
              );
              
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: statusInfo['color'],
                    child: Icon(
                      statusInfo['icon'],
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    complaint['text'],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Par: ${complaint['displayName'] ?? complaint['email'] ?? 'Utilisateur inconnu'}'),
                      Text(
                        'Créée: ${_formatDate(complaint['createdAt'])}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  trailing: isAdmin ? PopupMenuButton<String>(
                    onSelected: (action) => _handleComplaintAction(action, complaint),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'view',
                        child: Row(
                          children: [
                            Icon(Icons.visibility),
                            SizedBox(width: 8),
                            Text('Voir détails'),
                          ],
                        ),
                      ),
                      if (complaint['status'] != 'resolved') ...[
                        const PopupMenuItem(
                          value: 'in_progress',
                          child: Row(
                            children: [
                              Icon(Icons.hourglass_empty, color: Colors.blue),
                              SizedBox(width: 8),
                              Text('Marquer en cours'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'resolved',
                          child: Row(
                            children: [
                              Icon(Icons.check_circle, color: Colors.green),
                              SizedBox(width: 8),
                              Text('Marquer résolue'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'rejected',
                          child: Row(
                            children: [
                              Icon(Icons.cancel, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Rejeter'),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ) : null,
                  onTap: () => _showComplaintDetails(complaint),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatChip(String label, int count, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 24),
        const SizedBox(height: 4),
        Text(
          count.toString(),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  void _handleComplaintAction(String action, Map<String, dynamic> complaint) {
    switch (action) {
      case 'view':
        _showComplaintDetails(complaint);
        break;
      case 'in_progress':
      case 'resolved':
      case 'rejected':
        _updateComplaintStatus(complaint['id'], action);
        break;
    }
  }

  void _showComplaintDetails(Map<String, dynamic> complaint) {
    final statusInfo = _statusFilters.firstWhere(
      (s) => s['value'] == complaint['status'],
      orElse: () => _statusFilters.first,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(statusInfo['icon'], color: statusInfo['color']),
            const SizedBox(width: 8),
            Expanded(child: Text('Détails de la réclamation')),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Statut', _getStatusLabel(complaint['status'])),
              _buildDetailRow('Utilisateur', complaint['displayName'] ?? complaint['email'] ?? 'Inconnu'),
              _buildDetailRow('Date', _formatDate(complaint['createdAt'])),
              const SizedBox(height: 16),
              const Text(
                'Réclamation:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(complaint['text']),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _showAddComplaintDialog() {
    final textController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nouvelle réclamation'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Décrivez votre réclamation:'),
            const SizedBox(height: 16),
            TextField(
              controller: textController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Tapez votre réclamation ici...',
              ),
              maxLines: 4,
              maxLength: 500,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              if (textController.text.trim().isNotEmpty) {
                Navigator.of(context).pop();
                _submitComplaint(textController.text.trim());
              }
            },
            child: const Text('Soumettre'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitComplaint(String text) async {
    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vous devez être connecté pour soumettre une réclamation')),
      );
      return;
    }

    try {
      final db = await LocalDatabase.open();
      await db.insert('complaints', {
        'id': _uuid.v4(),
        'userId': currentUser.id,
        'text': text,
        'status': 'pending',
        'createdAt': DateTime.now().toIso8601String(),
      });
      
      _loadComplaints();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Réclamation soumise avec succès')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la soumission: $e')),
        );
      }
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'pending': return 'En attente';
      case 'in_progress': return 'En cours';
      case 'resolved': return 'Résolue';
      case 'rejected': return 'Rejetée';
      default: return status;
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Date inconnue';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year} à ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Date invalide';
    }
  }
} 