import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/local_database.dart';
import '../../../auth/domain/entities/user.dart';

class UserFormScreen extends StatefulWidget {
  final User? user;

  const UserFormScreen({super.key, this.user});

  @override
  State<UserFormScreen> createState() => _UserFormScreenState();
}

class _UserFormScreenState extends State<UserFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _classIdController = TextEditingController();
  final _studentIdController = TextEditingController();

  String _selectedRole = 'student';
  bool _isActive = true;
  bool _isLoading = false;
  final _uuid = const Uuid();

  final List<Map<String, dynamic>> _roles = [
    {'value': 'student', 'label': 'Étudiant', 'icon': Icons.school},
    {'value': 'teacher', 'label': 'Enseignant', 'icon': Icons.person},
    {'value': 'admin', 'label': 'Administrateur', 'icon': Icons.admin_panel_settings},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.user != null) {
      _loadUserData();
    }
  }

  void _loadUserData() {
    final user = widget.user!;
    _emailController.text = user.email;
    _displayNameController.text = user.displayName ?? '';
    _phoneController.text = user.phoneNumber ?? '';
    _addressController.text = user.address ?? '';
    _classIdController.text = user.classId ?? '';
    _studentIdController.text = user.studentId?.toString() ?? '';
    _selectedRole = user.role;
    _isActive = user.isActive;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _displayNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _classIdController.dispose();
    _studentIdController.dispose();
    super.dispose();
  }

  Future<void> _saveUser() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final db = await LocalDatabase.open();
      final now = DateTime.now().toIso8601String();
      
      final userData = {
        'email': _emailController.text.trim(),
        'displayName': _displayNameController.text.trim().isEmpty 
            ? null : _displayNameController.text.trim(),
        'role': _selectedRole,
        'phoneNumber': _phoneController.text.trim().isEmpty 
            ? null : _phoneController.text.trim(),
        'address': _addressController.text.trim().isEmpty 
            ? null : _addressController.text.trim(),
        'classId': _classIdController.text.trim().isEmpty 
            ? null : _classIdController.text.trim(),
        'studentId': _studentIdController.text.trim().isEmpty 
            ? null : int.tryParse(_studentIdController.text.trim()),
        'isActive': _isActive ? 1 : 0,
        'lastModifiedAt': now,
      };

      if (widget.user == null) {
        // Création d'un nouvel utilisateur
        if (_passwordController.text.isEmpty) {
          throw Exception('Le mot de passe est requis pour un nouvel utilisateur');
        }
        
        // Vérifier que l'email n'existe pas déjà
        final existing = await db.query(
          'users',
          where: 'email = ?',
          whereArgs: [_emailController.text.trim()],
        );
        
        if (existing.isNotEmpty) {
          throw Exception('Un utilisateur avec cet email existe déjà');
        }

        userData['id'] = _uuid.v4();
        userData['password'] = _passwordController.text;
        userData['createdAt'] = now;

        await db.insert('users', userData);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Utilisateur créé avec succès')),
          );
        }
      } else {
        // Modification d'un utilisateur existant
        if (_passwordController.text.isNotEmpty) {
          userData['password'] = _passwordController.text;
        }

        await db.update(
          'users',
          userData,
          where: 'id = ?',
          whereArgs: [widget.user!.id],
        );
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Utilisateur modifié avec succès')),
          );
        }
      }

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.user != null;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Modifier Utilisateur' : 'Nouvel Utilisateur'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveUser,
            child: Text(
              isEditing ? 'MODIFIER' : 'CRÉER',
              style: TextStyle(
                color: _isLoading ? Colors.grey : Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Informations de base
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Informations de base',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),
                      
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.email),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'L\'email est requis';
                          }
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                            return 'Format d\'email invalide';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: isEditing ? 'Nouveau mot de passe (optionnel)' : 'Mot de passe *',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.lock),
                          helperText: isEditing ? 'Laissez vide pour garder l\'actuel' : null,
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (!isEditing && (value == null || value.isEmpty)) {
                            return 'Le mot de passe est requis';
                          }
                          if (value != null && value.isNotEmpty && value.length < 6) {
                            return 'Le mot de passe doit contenir au moins 6 caractères';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      TextFormField(
                        controller: _displayNameController,
                        decoration: const InputDecoration(
                          labelText: 'Nom d\'affichage',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Rôle et statut
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Rôle et statut',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),
                      
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Rôle *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.badge),
                        ),
                        value: _selectedRole,
                        items: _roles.map((role) {
                          return DropdownMenuItem<String>(
                            value: role['value'],
                            child: Row(
                              children: [
                                Icon(role['icon'], size: 20),
                                const SizedBox(width: 8),
                                Text(role['label']),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedRole = value!;
                          });
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      SwitchListTile(
                        title: const Text('Compte actif'),
                        subtitle: Text(_isActive ? 'L\'utilisateur peut se connecter' : 'L\'utilisateur ne peut pas se connecter'),
                        value: _isActive,
                        onChanged: (value) {
                          setState(() {
                            _isActive = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Informations complémentaires
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Informations complémentaires',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),
                      
                      TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(
                          labelText: 'Téléphone',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.phone),
                        ),
                        keyboardType: TextInputType.phone,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      TextFormField(
                        controller: _addressController,
                        decoration: const InputDecoration(
                          labelText: 'Adresse',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.location_on),
                        ),
                        maxLines: 2,
                      ),
                      
                      if (_selectedRole == 'student') ...[
                        const SizedBox(height: 16),
                        
                        TextFormField(
                          controller: _classIdController,
                          decoration: const InputDecoration(
                            labelText: 'ID de classe',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.class_),
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        TextFormField(
                          controller: _studentIdController,
                          decoration: const InputDecoration(
                            labelText: 'Numéro d\'étudiant',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.numbers),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Boutons d'action
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                      child: const Text('ANNULER'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveUser,
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(isEditing ? 'MODIFIER' : 'CRÉER'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
} 