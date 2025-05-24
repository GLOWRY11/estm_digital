import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import '../../../../core/local_database.dart';
import '../../../auth/domain/entities/user.dart';
import 'user_form_screen.dart';

class UsersListScreen extends ConsumerStatefulWidget {
  const UsersListScreen({super.key});

  @override
  ConsumerState<UsersListScreen> createState() => _UsersListScreenState();
}

class _UsersListScreenState extends ConsumerState<UsersListScreen> {
  List<User> _users = [];
  bool _isLoading = true;
  String _selectedRole = 'all';

  final List<Map<String, dynamic>> _roleFilters = [
    {'value': 'all', 'label': 'Tous les utilisateurs', 'icon': Icons.people},
    {'value': 'student', 'label': 'Étudiants', 'icon': Icons.school},
    {'value': 'teacher', 'label': 'Enseignants', 'icon': Icons.person},
    {'value': 'admin', 'label': 'Administrateurs', 'icon': Icons.admin_panel_settings},
  ];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    try {
      final db = await LocalDatabase.open();
      String query = 'SELECT * FROM users WHERE 1=1';
      List<dynamic> whereArgs = [];

      if (_selectedRole != 'all') {
        query += ' AND role = ?';
        whereArgs.add(_selectedRole);
      }

      query += ' ORDER BY createdAt DESC';

      final result = await db.rawQuery(query, whereArgs);
      final users = result.map((userData) {
        final now = DateTime.now();
        return User(
          id: userData['id'] as String,
          email: userData['email'] as String,
          displayName: userData['displayName'] as String?,
          role: userData['role'] as String,
          phoneNumber: userData['phoneNumber'] as String?,
          address: userData['address'] as String?,
          profileImageUrl: userData['profileImageUrl'] as String?,
          classId: userData['classId'] as String?,
          studentId: userData['studentId'] as int?,
          isActive: userData['isActive'] == 1,
          createdAt: userData['createdAt'] != null
              ? DateTime.parse(userData['createdAt'] as String)
              : now,
          lastModifiedAt: userData['lastModifiedAt'] != null
              ? DateTime.parse(userData['lastModifiedAt'] as String)
              : null,
        );
      }).toList();

      setState(() {
        _users = users;
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

  Future<void> _deleteUser(User user) async {
    try {
      final db = await LocalDatabase.open();
      await db.delete('users', where: 'id = ?', whereArgs: [user.id]);
      
      setState(() {
        _users.removeWhere((u) => u.id == user.id);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Utilisateur "${user.email}" supprimé')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la suppression: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Utilisateurs'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filtrer par rôle',
            onSelected: (value) {
              setState(() => _selectedRole = value);
              _loadUsers();
            },
            itemBuilder: (context) => _roleFilters.map((filter) {
              return PopupMenuItem<String>(
                value: filter['value'],
                child: Row(
                  children: [
                    Icon(filter['icon'], size: 20),
                    const SizedBox(width: 8),
                    Text(filter['label']),
                    if (_selectedRole == filter['value'])
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
            onPressed: _loadUsers,
            tooltip: 'Actualiser',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _users.isEmpty
              ? _buildEmptyState()
              : _buildUsersList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToUserForm(),
        tooltip: 'Ajouter un utilisateur',
        child: const Icon(Icons.person_add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _selectedRole == 'all' ? Icons.people : _roleFilters
                .firstWhere((f) => f['value'] == _selectedRole)['icon'],
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _selectedRole == 'all' 
                ? 'Aucun utilisateur enregistré'
                : 'Aucun ${_roleFilters.firstWhere((f) => f['value'] == _selectedRole)['label'].toLowerCase()}',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _navigateToUserForm(),
            icon: const Icon(Icons.person_add),
            label: const Text('Ajouter un utilisateur'),
          ),
        ],
      ),
    );
  }

  Widget _buildUsersList() {
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
              _buildStatChip('Total', _users.length, Icons.people),
              _buildStatChip('Actifs', _users.where((u) => u.isActive).length, Icons.check_circle),
              _buildStatChip('Inactifs', _users.where((u) => !u.isActive).length, Icons.cancel),
            ],
          ),
        ),
        
        // Liste des utilisateurs
        Expanded(
          child: ListView.builder(
            itemCount: _users.length,
            itemBuilder: (context, index) {
              final user = _users[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getRoleColor(user.role),
                    child: Icon(
                      _getRoleIcon(user.role),
                      color: Colors.white,
                    ),
                  ),
                  title: Text(
                    user.displayName ?? user.email,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      decoration: user.isActive ? null : TextDecoration.lineThrough,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.email),
                      Text(
                        _getRoleLabel(user.role),
                        style: TextStyle(
                          color: _getRoleColor(user.role),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!user.isActive)
                        Icon(Icons.pause_circle, color: Colors.orange[600]),
                      PopupMenuButton<String>(
                        onSelected: (action) => _handleUserAction(action, user),
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
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit),
                                SizedBox(width: 8),
                                Text('Modifier'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: user.isActive ? 'deactivate' : 'activate',
                            child: Row(
                              children: [
                                Icon(user.isActive ? Icons.pause : Icons.play_arrow),
                                const SizedBox(width: 8),
                                Text(user.isActive ? 'Désactiver' : 'Activer'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, color: Colors.red),
                                SizedBox(width: 8),
                                Text('Supprimer', style: TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  onTap: () => _showUserDetails(user),
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

  Color _getRoleColor(String role) {
    switch (role) {
      case 'admin': return Colors.red;
      case 'teacher': return Colors.blue;
      case 'student': return Colors.green;
      default: return Colors.grey;
    }
  }

  IconData _getRoleIcon(String role) {
    switch (role) {
      case 'admin': return Icons.admin_panel_settings;
      case 'teacher': return Icons.person;
      case 'student': return Icons.school;
      default: return Icons.person;
    }
  }

  String _getRoleLabel(String role) {
    switch (role) {
      case 'admin': return 'Administrateur';
      case 'teacher': return 'Enseignant';
      case 'student': return 'Étudiant';
      default: return role;
    }
  }

  void _handleUserAction(String action, User user) {
    switch (action) {
      case 'view':
        _showUserDetails(user);
        break;
      case 'edit':
        _navigateToUserForm(user: user);
        break;
      case 'activate':
      case 'deactivate':
        _toggleUserStatus(user);
        break;
      case 'delete':
        _confirmDeleteUser(user);
        break;
    }
  }

  void _showUserDetails(User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Détails - ${user.displayName ?? user.email}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Email', user.email),
              _buildDetailRow('Rôle', _getRoleLabel(user.role)),
              _buildDetailRow('Statut', user.isActive ? 'Actif' : 'Inactif'),
              if (user.phoneNumber != null)
                _buildDetailRow('Téléphone', user.phoneNumber!),
              if (user.address != null)
                _buildDetailRow('Adresse', user.address!),
              if (user.classId != null)
                _buildDetailRow('Classe', user.classId!),
              if (user.studentId != null)
                _buildDetailRow('ID Étudiant', user.studentId.toString()),
              _buildDetailRow('Créé le', user.createdAt.toString().split(' ')[0]),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              _navigateToUserForm(user: user);
            },
            icon: const Icon(Icons.edit),
            label: const Text('Modifier'),
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

  Future<void> _toggleUserStatus(User user) async {
    try {
      final db = await LocalDatabase.open();
      await db.update(
        'users',
        {'isActive': user.isActive ? 0 : 1},
        where: 'id = ?',
        whereArgs: [user.id],
      );
      
      _loadUsers();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Utilisateur ${user.isActive ? 'désactivé' : 'activé'}',
            ),
          ),
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

  void _confirmDeleteUser(User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmation'),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer l\'utilisateur "${user.displayName ?? user.email}" ?\n\nCette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteUser(user);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Supprimer', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _navigateToUserForm({User? user}) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => UserFormScreen(user: user),
      ),
    );
    
    if (result == true) {
      _loadUsers();
    }
  }
} 