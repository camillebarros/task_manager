import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:task_manager/core/routes/routes.dart';
import 'package:task_manager/modules/tasks/controllers/task_controller.dart';
import 'package:task_manager/modules/tasks/controllers/task_search_delegate.dart';

class TaskListPage extends StatelessWidget {
  TaskListPage({super.key});

  final TaskController controller = Get.put(TaskController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Tarefas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: TaskSearchDelegate(controller),
              );
            },
          ),
          Obx(
            () => IconButton(
              icon: Icon(
                controller.showFavoritesOnly.value
                    ? Icons.filter_alt
                    : Icons.filter_alt_outlined,
                color: controller.showFavoritesOnly.value ? Colors.amber : null,
              ),
              onPressed: controller.toggleFavoriteFilter,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Get.offNamed(Routes.AUTH),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskDialog(context),
        child: const Icon(Icons.add),
      ),
      body: Obx(() {
        return StreamBuilder<QuerySnapshot>(
          stream: controller.tasksStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final tasks = snapshot.data?.docs ?? [];

            // Aplica busca manual, já que Firestore não tem contains
            final filteredTasks = tasks.where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final title = (data['title'] ?? '').toString().toLowerCase();
              return title.contains(controller.searchQuery.value.toLowerCase());
            }).toList();

            if (filteredTasks.isEmpty) {
              return Center(
                child: Text(
                  controller.showFavoritesOnly.value
                      ? 'Nenhuma tarefa favorita encontrada.'
                      : 'Nenhuma tarefa encontrada.',
                ),
              );
            }

            return ListView.builder(
              itemCount: filteredTasks.length,
              itemBuilder: (context, index) {
                final task = filteredTasks[index];
                final data = task.data() as Map<String, dynamic>;

                return Card(
                  child: ListTile(
                    title: Text(data['title'] ?? ''),
                    subtitle: Text(data['description'] ?? ''),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            data['favorite'] == true
                                ? Icons.star
                                : Icons.star_border,
                            color:
                                data['favorite'] == true ? Colors.amber : null,
                          ),
                          onPressed: () {
                            task.reference.update({
                              'favorite': !(data['favorite'] ?? false),
                            });
                          },
                        ),
                        IconButton(
                          icon: Icon(
                            data['completed'] == true
                                ? Icons.check_box
                                : Icons.check_box_outline_blank,
                          ),
                          onPressed: () {
                            task.reference.update({
                              'completed': !(data['completed'] ?? false),
                            });
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            controller.deleteTask(task.id);
                          },
                        ),
                      ],
                    ),
                    onTap: () =>
                        _showEditTaskDialog(context, task.id, data),
                  ),
                );
              },
            );
          },
        );
      }),
    );
  }

  void _addTask(String title, String description) {
    FirebaseFirestore.instance.collection('tasks').add({
      'title': title,
      'description': description,
      'createdAt': Timestamp.now(),
      'completed': false,
      'favorite': false,
    });
  }

  void _showAddTaskDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Adicionar Tarefa'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Título'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Descrição'),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                _addTask(titleController.text, descriptionController.text);
                Navigator.pop(context);
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  void _showEditTaskDialog(
    BuildContext context,
    String taskId,
    Map<String, dynamic> data,
  ) {
    final titleController = TextEditingController(text: data['title']);
    final descriptionController = TextEditingController(
      text: data['description'],
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Editar Tarefa'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Título'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Descrição'),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                FirebaseFirestore.instance
                    .collection('tasks')
                    .doc(taskId)
                    .update({
                  'title': titleController.text,
                  'description': descriptionController.text,
                });
                Navigator.pop(context);
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );
  }
}
