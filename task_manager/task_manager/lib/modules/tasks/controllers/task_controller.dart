import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TaskController extends GetxController {
  final RxBool showFavoritesOnly = false.obs;
  final RxString searchQuery = ''.obs;

  Stream<QuerySnapshot> get tasksStream {
    Query query = FirebaseFirestore.instance.collection('tasks');

    if (showFavoritesOnly.value) {
      query = query.where('favorite', isEqualTo: true);
    }

    query = query.orderBy('createdAt', descending: true);

    return query.snapshots();
  }

  void toggleFavoriteFilter() {
    showFavoritesOnly.value = !showFavoritesOnly.value;
  }

  void updateSearch(String value) {
    searchQuery.value = value;
  }

  Future<void> deleteTask(String taskId) async {
    await FirebaseFirestore.instance.collection('tasks').doc(taskId).delete();
  }
}
