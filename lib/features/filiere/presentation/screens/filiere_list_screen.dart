import 'package:flutter/material.dart';
import 'package:estm_digital/features/filiere/domain/filiere_model.dart';
import 'package:estm_digital/features/filiere/data/filiere_service.dart';
import 'package:estm_digital/features/filiere/presentation/screens/filiere_form_screen.dart';

class FiliereListScreen extends StatefulWidget {
  const FiliereListScreen({Key? key}) : super(key: key);

  @override
  _FiliereListScreenState createState() => _FiliereListScreenState();
}

class _FiliereListScreenState extends State<FiliereListScreen> {
  final FiliereService _filiereService = FiliereService();
  late Future<List<Filiere>> _filieresFuture;

  @override
  void initState() {
    super.initState();
    _refreshFilieres();
  }

  void _refreshFilieres() {
    setState(() {
      _filieresFuture = _filiereService.queryAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Liste des Filières'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshFilieres,
            tooltip: 'Actualiser',
          ),
        ],
      ),
      body: FutureBuilder<List<Filiere>>(
        future: _filieresFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Erreur: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _refreshFilieres,
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          final filieres = snapshot.data ?? [];

          if (filieres.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.school, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('Aucune filière enregistrée'),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _addNewFiliere,
                    icon: const Icon(Icons.add),
                    label: const Text('Ajouter une filière'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: filieres.length,
            itemBuilder: (context, index) {
              final filiere = filieres[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(
                    filiere.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('Année: ${filiere.annee ?? "Non spécifiée"}'),
                  leading: const CircleAvatar(
                    child: Icon(Icons.school),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          _editFiliere(filiere);
                        },
                        tooltip: 'Modifier',
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          _showDeleteConfirmation(filiere);
                        },
                        tooltip: 'Supprimer',
                      ),
                    ],
                  ),
                  onTap: () {
                    _showFiliereDetails(filiere);
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewFiliere,
        tooltip: 'Ajouter une filière',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showFiliereDetails(Filiere filiere) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(filiere.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nom: ${filiere.name}'),
            Text('Année: ${filiere.annee ?? "Non spécifiée"}'),
            Text('ID: ${filiere.id ?? "Non défini"}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              _editFiliere(filiere);
            },
            icon: const Icon(Icons.edit),
            label: const Text('Modifier'),
          ),
        ],
      ),
    );
  }

  void _addNewFiliere() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FiliereFormScreen(
          onSave: (filiere) async {
            await _filiereService.insert(filiere);
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Filière ajoutée avec succès')),
            );
            _refreshFilieres();
          },
        ),
      ),
    );
  }

  void _editFiliere(Filiere filiere) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FiliereFormScreen(
          filiere: filiere,
          onSave: (updatedFiliere) async {
            await _filiereService.update(updatedFiliere);
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Filière mise à jour avec succès')),
            );
            _refreshFilieres();
          },
        ),
      ),
    );
  }

  Future<void> _showDeleteConfirmation(Filiere filiere) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation'),
          content: Text('Voulez-vous vraiment supprimer la filière "${filiere.name}"?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _filiereService.delete(filiere.id!);
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Filière "${filiere.name}" supprimée')),
                );
                _refreshFilieres();
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );
  }
} 