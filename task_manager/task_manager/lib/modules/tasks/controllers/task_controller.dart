import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TaskController extends GetxController {
  final RxBool showFavoritesOnly = false.obs;
  final RxString searchQuery = ''.obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  String get currentUserId => FirebaseAuth.instance.currentUser?.uid ?? '';

  Stream<QuerySnapshot> get tasksStream {
    try {
      Query query = FirebaseFirestore.instance
          .collection('tasks')
          .where('userId', isEqualTo: currentUserId);

      if (showFavoritesOnly.value) {
        query = query.where('favorite', isEqualTo: true);
      }

      if (searchQuery.value.isNotEmpty) {
        query = query
            .orderBy('title')
            .where('title', isGreaterThanOrEqualTo: searchQuery.value)
            .where('title', isLessThan: searchQuery.value + 'z');
      } else {
        query = query.orderBy('createdAt', descending: true);
      }

      return query.snapshots();
    } catch (e) {
      errorMessage.value = 'Erro ao carregar tarefas: $e';
      return const Stream.empty();
    }
  }

  void toggleFavoriteFilter() {
    showFavoritesOnly.value = !showFavoritesOnly.value;
  }

  void updateSearch(String value) {
    searchQuery.value = value;
  }

  Future<void> addTask(String title, String description) async {
    try {
      isLoading.value = true;
      await FirebaseFirestore.instance.collection('tasks').add({
        'title': title,
        'description': description,
        'userId': currentUserId,
        'createdAt': Timestamp.now(),
        'completed': false,
        'favorite': false,
      });
    } catch (e) {
      errorMessage.value = 'Erro ao adicionar tarefa: ${e.toString()}';
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateTask(
    String taskId,
    String title,
    String description,
  ) async {
    try {
      isLoading.value = true;
      await FirebaseFirestore.instance.collection('tasks').doc(taskId).update({
        'title': title,
        'description': description,
      });
    } catch (e) {
      errorMessage.value = 'Erro ao atualizar tarefa: ${e.toString()}';
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> clearTasks() async {
    try {
      isLoading.value = true;

      final querySnapshot =
          await FirebaseFirestore.instance
              .collection('tasks')
              .where('userId', isEqualTo: currentUserId)
              .get();

      for (var doc in querySnapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      errorMessage.value = 'Erro ao limpar tarefas: ${e.toString()}';
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteTask(String taskId) async {
    try {
      isLoading.value = true;
      await FirebaseFirestore.instance.collection('tasks').doc(taskId).delete();
    } catch (e) {
      errorMessage.value = 'Erro ao deletar tarefa: ${e.toString()}';
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleTaskStatus(String taskId, bool currentStatus) async {
    try {
      await FirebaseFirestore.instance.collection('tasks').doc(taskId).update({
        'completed': !currentStatus,
      });
    } catch (e) {
      errorMessage.value = 'Erro ao alterar status: ${e.toString()}';
      rethrow;
    }
  }

  Future<void> toggleFavoriteStatus(String taskId, bool currentStatus) async {
    try {
      await FirebaseFirestore.instance.collection('tasks').doc(taskId).update({
        'favorite': !currentStatus,
      });
    } catch (e) {
      errorMessage.value = 'Erro ao favoritar: ${e.toString()}';
      rethrow;
    }
  }
}
