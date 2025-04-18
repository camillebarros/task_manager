import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:task_manager/data/models/task_model.dart';

class TaskRepository {
  final CollectionReference _tasks = FirebaseFirestore.instance.collection('tasks');

  Stream<List<Task>> getUserTasks(String userId) {
    return _tasks
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => Task.fromFirestore(doc)).toList();
        });
  }

  Future<void> addTask(Task task, String userId) async {
    await _tasks.add({
      'title': task.title,
      'description': task.description,
      'isCompleted': task.isCompleted,
      'userId': userId,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateTaskCompletion(String taskId, bool isCompleted) async {
    await _tasks.doc(taskId).update({'isCompleted': isCompleted});
  }

  Future<void> deleteTask(String taskId) async {
    await _tasks.doc(taskId).delete();
  }
}
