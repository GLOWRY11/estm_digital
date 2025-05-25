import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/services/user_service.dart';
import '../../../auth/domain/entities/user.dart';

class UserFormScreen extends ConsumerStatefulWidget {
  final String? userId;

  const UserFormScreen({Key? key, this.userId}) : super(key: key);

  @override
  ConsumerState<UserFormScreen> createState() => _UserFormScreenState();
}

class _UserFormScreenState extends ConsumerState<UserFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _classIdController = TextEditingController();
  final _studentIdController = TextEditingController();

  String _selectedRole = 'student';
  bool _isLoading = false;
  bool _isEditing = false;
  User? _existingUser;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.userId != null;
    if (_isEditing) {
      _loadUser();
    }
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

  Future<void> _loadUser() async {
    if (widget.userId == null) return;

    setState(() => _isLoading = true);

    try {
      final user = await UserService.getUserById(widget.userId!);
      if (user != null) {
        _existingUser = user;
        _emailController.text = user.email;
        _displayNameController.text = user.displayName ?? '';
        _phoneController.text = user.phoneNumber ?? '';
        _addressController.text = user.address ?? '';
        _classIdController.text = user.classId ?? '';
        _studentIdController.text = user.studentId?.toString() ?? '';
        _selectedRole = user.role;
      }
    } catch (e) {
      _showErrorDialog('Erreur lors du chargement: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      if (_isEditing && _existingUser != null) {
        // Mise à jour
        final updates = <String, dynamic>{};
        
        if (_emailController.text != _existingUser!.email) {
          updates['email'] = _emailController.text.trim();
        }
        
        if (_passwordController.text.isNotEmpty) {
          updates['password'] = _passwordController.text;
        }
        
        if (_displayNameController.text != (_existingUser!.displayName ?? '')) {
          updates['displayName'] = _displayNameController.text.trim().isNotEmpty 
              ? _displayNameController.text.trim() 
              : null;
        }
        
        if (_phoneController.text != (_existingUser!.phoneNumber ?? '')) {
          updates['phoneNumber'] = _phoneController.text.trim().isNotEmpty 
              ? _phoneController.text.trim() 
              : null;
        }
        
        if (_addressController.text != (_existingUser!.address ?? '')) {
          updates['address'] = _addressController.text.trim().isNotEmpty 
              ? _addressController.text.trim() 
              : null;
        }
        
        if (_classIdController.text != (_existingUser!.classId ?? '')) {
          updates['classId'] = _classIdController.text.trim().isNotEmpty 
              ? _classIdController.text.trim() 
              : null;
        }
        
        final studentIdText = _studentIdController.text.trim();
        final newStudentId = studentIdText.isNotEmpty ? int.tryParse(studentIdText) : null;
        if (newStudentId != _existingUser!.studentId) {
          updates['studentId'] = newStudentId;
        }

        if (updates.isNotEmpty) {
          final success = await UserService.updateUser(widget.userId!, updates);
          if (success) {
            _showSuccessMessage('Utilisateur mis à jour avec succès');
            Navigator.of(context).pop();
          } else {
            _showErrorDialog('Erreur lors de la mise à jour');
          }
        } else {
          Navigator.of(context).pop();
        }
      } else {
        // Création
        final success = await UserService.insertUser(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          role: _selectedRole,
          displayName: _displayNameController.text.trim().isNotEmpty 
              ? _displayNameController.text.trim() 
              : null,
          phoneNumber: _phoneController.text.trim().isNotEmpty 
              ? _phoneController.text.trim() 
              : null,
          address: _addressController.text.trim().isNotEmpty 
              ? _addressController.text.trim() 
              : null,
          classId: _selectedRole == 'student' && _classIdController.text.trim().isNotEmpty
              ? _classIdController.text.trim()
              : null,
          studentId: _selectedRole == 'student' && _studentIdController.text.trim().isNotEmpty
              ? int.tryParse(_studentIdController.text.trim())
              : null,
        );

        if (success) {
          _showSuccessMessage('Utilisateur créé avec succès');
          Navigator.of(context).pop();
        } else {
          _showErrorDialog('Erreur lors de la création');
        }
      }
    } catch (e) {
      _showErrorDialog('Erreur: $e');
    } finally {
      setState(() => _isLoading = false);
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

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (_isLoading && _isEditing) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chargement...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Modifier Utilisateur' : 'Nouveau Utilisateur',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Sélection du rôle (seulement pour la création)
              if (!_isEditing) ...[
                Text(
                  'Type de compte',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(
                      value: 'student',
                      label: Text('Étudiant'),
                      icon: Icon(Icons.school),
                    ),
                    ButtonSegment(
                      value: 'teacher',
                      label: Text('Enseignant'),
                      icon: Icon(Icons.person),
                    ),
                    ButtonSegment(
                      value: 'admin',
                      label: Text('Admin'),
                      icon: Icon(Icons.admin_panel_settings),
                    ),
                  ],
                  selected: {_selectedRole},
                  onSelectionChanged: (Set<String> newSelection) {
                    setState(() {
                      _selectedRole = newSelection.first;
                    });
                  },
                ),
                const SizedBox(height: 24),
              ],

              // Email
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email *',
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email requis';
                  }
                  if (!UserService.isValidEmail(value)) {
                    return 'Email invalide';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Mot de passe
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: _isEditing ? 'Nouveau mot de passe (optionnel)' : 'Mot de passe *',
                  prefixIcon: const Icon(Icons.lock),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (!_isEditing && (value == null || value.isEmpty)) {
                    return 'Mot de passe requis';
                  }
                  if (value != null && value.isNotEmpty && !UserService.isValidPassword(value)) {
                    return 'Le mot de passe doit contenir au moins 6 caractères';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Nom complet
              TextFormField(
                controller: _displayNameController,
                decoration: InputDecoration(
                  labelText: 'Nom complet',
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Téléphone
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Téléphone',
                  prefixIcon: const Icon(Icons.phone),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Adresse
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: 'Adresse',
                  prefixIcon: const Icon(Icons.location_on),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              // Champs spécifiques aux étudiants
              if (_selectedRole == 'student') ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _classIdController,
                  decoration: InputDecoration(
                    labelText: 'Classe',
                    hintText: 'Ex: L3-INFO',
                    prefixIcon: const Icon(Icons.class_),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _studentIdController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Numéro étudiant',
                    prefixIcon: const Icon(Icons.badge),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      if (int.tryParse(value) == null) {
                        return 'Numéro invalide';
                      }
                    }
                    return null;
                  },
                ),
              ],

              const SizedBox(height: 32),

              // Boutons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Annuler'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: FilledButton(
                      onPressed: _isLoading ? null : _saveUser,
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(_isEditing ? 'Modifier' : 'Créer'),
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