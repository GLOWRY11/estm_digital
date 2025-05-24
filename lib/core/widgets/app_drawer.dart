import 'package:flutter/material.dart';
import 'package:estm_digital/core/routes/app_routes.dart';

class AppDrawer extends StatelessWidget {
  final String currentUserRole;
  
  const AppDrawer({
    Key? key,
    required this.currentUserRole,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // En-tête du drawer
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: Text(
                    'ESTM Digital',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Rôle: ${_formatRole(currentUserRole)}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          
          // Options du menu
          _buildMenuOption(
            context: context,
            title: 'Tableau de bord',
            icon: Icons.dashboard,
            onTap: () => _navigateTo(context, AppRoutes.home),
            showDivider: true,
          ),
          
          // Section des fonctionnalités principales
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'GESTION ACADÉMIQUE',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          _buildMenuOption(
            context: context,
            title: 'Cours',
            icon: Icons.school,
            onTap: () => _navigateTo(context, AppRoutes.coursesList),
          ),
          
          _buildMenuOption(
            context: context,
            title: 'Notes',
            icon: Icons.grade,
            onTap: () => _navigateTo(context, AppRoutes.gradesList),
          ),
          
          _buildMenuOption(
            context: context,
            title: 'Planning',
            icon: Icons.calendar_today,
            onTap: () => _navigateTo(context, AppRoutes.calendar),
          ),
          
          _buildMenuOption(
            context: context,
            title: 'Réclamations',
            icon: Icons.feedback,
            onTap: () => _navigateTo(context, AppRoutes.complaints),
            showDivider: true,
          ),
          
          // Section des entités SQLite
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'BASE DE DONNÉES',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          _buildMenuOption(
            context: context,
            title: 'Absences',
            icon: Icons.event_busy,
            onTap: () => _navigateTo(context, AppRoutes.absenceList),
          ),
          
          _buildMenuOption(
            context: context,
            title: 'Filières',
            icon: Icons.category,
            onTap: () => _navigateTo(context, AppRoutes.filiereList),
          ),
          
          // Admin only options
          if (currentUserRole == 'admin')
            _buildMenuOption(
              context: context,
              title: 'Rapports',
              icon: Icons.bar_chart,
              onTap: () => _navigateTo(context, AppRoutes.reports),
              showDivider: true,
            ),
          
          const Spacer(),
          
          // Déconnexion
          _buildMenuOption(
            context: context,
            title: 'Déconnexion',
            icon: Icons.logout,
            onTap: () {
              Navigator.pop(context);
              // Ajouter ici la logique de déconnexion
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Déconnexion...')),
              );
            },
            showDivider: false,
            useAccentColor: true,
          ),
          
          // Espace en bas pour éviter les problèmes de navigation
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // Helper pour formater le rôle en français
  String _formatRole(String role) {
    switch (role) {
      case 'admin':
        return 'Administrateur';
      case 'teacher':
        return 'Enseignant';
      case 'student':
        return 'Étudiant';
      default:
        return role;
    }
  }

  // Helper pour la navigation
  void _navigateTo(BuildContext context, String route) {
    Navigator.pop(context);
    
    // Ne pas naviguer si on est déjà sur cette page
    if (ModalRoute.of(context)?.settings.name != route) {
      Navigator.pushNamed(context, route);
    }
  }

  // Widget pour une option de menu
  Widget _buildMenuOption({
    required BuildContext context,
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    bool showDivider = false,
    bool useAccentColor = false,
  }) {
    final color = useAccentColor 
        ? Theme.of(context).colorScheme.error
        : null;
    
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: color),
          title: Text(title, style: TextStyle(color: color)),
          onTap: onTap,
        ),
        if (showDivider)
          const Divider(),
      ],
    );
  }
} 