import 'package:cloud_firestore/cloud_firestore.dart';
// Tarefas
class Task {
  final String? id;
  final String title;
  final String description; 
  bool isCompleted; 

  Task({
    this.id,
    required this.title,
    this.description = '', 
    this.isCompleted = false,
  });

  factory Task.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Task(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '', 
      isCompleted: data['isCompleted'] ?? false,
    );
  }

  void toggleCompletion() {
    isCompleted = !isCompleted;
  }
}
