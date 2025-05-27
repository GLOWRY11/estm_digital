import 'package:flutter/material.dart';
import 'package:estm_digital/features/filiere/domain/filiere_model.dart';

class FiliereFormScreen extends StatefulWidget {
  final Filiere? filiere;
  final Function(Filiere) onSave;

  const FiliereFormScreen({
    super.key,
    this.filiere,
    required this.onSave,
  });

  @override
  State<FiliereFormScreen> createState() => _FiliereFormScreenState();
}

class _FiliereFormScreenState extends State<FiliereFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _anneeController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Remplir le formulaire si on est en mode édition
    if (widget.filiere != null) {
      _nameController.text = widget.filiere!.name;
      if (widget.filiere!.annee != null) {
        _anneeController.text = widget.filiere!.annee!;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.filiere == null ? 'Nouvelle Filière' : 'Modifier Filière'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Nom de la filière
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom de la filière',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un nom de filière';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Année
              TextFormField(
                controller: _anneeController,
                decoration: const InputDecoration(
                  labelText: 'Année académique (optionnel)',
                  border: OutlineInputBorder(),
                  hintText: 'Ex: 2023-2024',
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Bouton de sauvegarde
              ElevatedButton(
                onPressed: _saveFiliere,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  widget.filiere == null ? 'Ajouter' : 'Mettre à jour',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveFiliere() {
    if (_formKey.currentState!.validate()) {
      // Créer ou mettre à jour la filière
      final filiere = Filiere(
        id: widget.filiere?.id,
        name: _nameController.text,
        annee: _anneeController.text.isEmpty ? null : _anneeController.text,
      );
      
      // Appeler la fonction de sauvegarde
      widget.onSave(filiere);
      
      // Retourner à l'écran précédent
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _anneeController.dispose();
    super.dispose();
  }
} 