import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'grade_edit_screen.dart';

class TeacherGradesScreen extends ConsumerStatefulWidget {
  static const routeName = '/teacher-grades';

  const TeacherGradesScreen({super.key});

  @override
  _TeacherGradesScreenState createState() => _TeacherGradesScreenState();
}

class _TeacherGradesScreenState extends ConsumerState<TeacherGradesScreen> {
  // Liste des étudiants avec leurs notes (données simulées)
  final List<Map<String, dynamic>> _students = [
    {
      'id': 'student1',
      'name': 'Fatou Diop',
      'email': 'fatou.diop@estm.sn',
      'class': 'Licence 1 Informatique',
      'grades': [
        {
          'courseTitle': 'Introduction à la programmation',
          'semester': 'Semestre 1',
          'midterm': 16.5,
          'final': 18.0,
          'average': 17.25,
          'comment': 'Excellent travail',
        },
        {
          'courseTitle': 'Algorithmes et structures de données',
          'semester': 'Semestre 1',
          'midterm': 14.0,
          'final': 15.5,
          'average': 14.75,
          'comment': 'Bon travail',
        },
      ],
    },
    {
      'id': 'student2',
      'name': 'Amadou Sow',
      'email': 'amadou.sow@estm.sn',
      'class': 'Licence 1 Informatique',
      'grades': [
        {
          'courseTitle': 'Introduction à la programmation',
          'semester': 'Semestre 1',
          'midterm': 12.5,
          'final': 14.0,
          'average': 13.25,
          'comment': 'Des progrès notables',
        },
        {
          'courseTitle': 'Algorithmes et structures de données',
          'semester': 'Semestre 1',
          'midterm': 10.0,
          'final': 11.5,
          'average': 10.75,
          'comment': 'Efforts à poursuivre',
        },
      ],
    },
    {
      'id': 'student3',
      'name': 'Mariama Ndiaye',
      'email': 'mariama.ndiaye@estm.sn',
      'class': 'Master 1 Réseaux',
      'grades': [
        {
          'courseTitle': 'Réseaux informatiques',
          'semester': 'Semestre 2',
          'midterm': 17.0,
          'final': 16.5,
          'average': 16.75,
          'comment': 'Très bon niveau',
        },
      ],
    },
  ];

  String _selectedClass = 'Tous';
  final List<String> _classes = ['Tous', 'Licence 1 Informatique', 'Master 1 Réseaux'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Filtrer les étudiants par classe si nécessaire
    final filteredStudents = _selectedClass == 'Tous'
        ? _students
        : _students.where((s) => s['class'] == _selectedClass).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des notes'),
        backgroundColor: theme.colorScheme.primary,
      ),
      body: Column(
        children: [
          // Filtre par classe
          Container(
            padding: const EdgeInsets.all(16),
            color: theme.colorScheme.primary.withOpacity(0.1),
            child: Row(
              children: [
                const Text('Filtrer par classe:'),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButton<String>(
                    value: _selectedClass,
                    isExpanded: true,
                    items: _classes.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _selectedClass = newValue!;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          // Liste des étudiants
          Expanded(
            child: filteredStudents.isEmpty
                ? const Center(
                    child: Text('Aucun étudiant trouvé pour cette classe'),
                  )
                : ListView.builder(
                    itemCount: filteredStudents.length,
                    padding: const EdgeInsets.all(16),
                    itemBuilder: (context, index) {
                      final student = filteredStudents[index];
                      return _buildStudentCard(student);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentCard(Map<String, dynamic> student) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        title: Text(
          student['name'],
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(student['email']),
            Text('Classe: ${student['class']}'),
          ],
        ),
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        childrenPadding: const EdgeInsets.all(16),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Notes et évaluations',
            style: theme.textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          ..._buildGradesList(student),
        ],
      ),
    );
  }

  List<Widget> _buildGradesList(Map<String, dynamic> student) {
    final List<Map<String, dynamic>> grades = List<Map<String, dynamic>>.from(student['grades']);
    
    if (grades.isEmpty) {
      return [const Text('Aucune note enregistrée pour cet étudiant')];
    }
    
    return grades.map((grade) {
      return InkWell(
        onTap: () => _editGrade(student, grade),
        child: Card(
          margin: const EdgeInsets.only(bottom: 8),
          color: Colors.grey[100],
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        grade['courseTitle'],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Text(
                      grade['semester'],
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Partiel: ${grade['midterm']}'),
                    Text('Final: ${grade['final']}'),
                    Text(
                      'Moyenne: ${grade['average']}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _getGradeColor(grade['average']),
                      ),
                    ),
                  ],
                ),
                if (grade['comment'] != null && grade['comment'].toString().isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Commentaire: ${grade['comment']}',
                      style: const TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ),
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: const Icon(Icons.edit, size: 16),
                    onPressed: () => _editGrade(student, grade),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }

  Future<void> _editGrade(Map<String, dynamic> student, Map<String, dynamic> grade) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GradeEditScreen(
          initialGrade: Map<String, dynamic>.from(grade),
          studentName: student['name'],
        ),
      ),
    );
    
    if (result != null) {
      // Mettre à jour la note dans la liste
      setState(() {
        final grades = student['grades'] as List;
        final index = grades.indexWhere((g) => 
          g['courseTitle'] == grade['courseTitle'] && 
          g['semester'] == grade['semester']
        );
        
        if (index >= 0) {
          grades[index] = result;
        }
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Note mise à jour avec succès')),
      );
    }
  }
  
  Color _getGradeColor(double grade) {
    if (grade >= 16) {
      return Colors.green;
    } else if (grade >= 14) {
      return Colors.lightGreen;
    } else if (grade >= 12) {
      return Colors.orange;
    } else if (grade >= 10) {
      return Colors.amber;
    } else {
      return Colors.red;
    }
  }
} 