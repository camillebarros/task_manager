import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:task_manager/core/routes/routes.dart';
import 'package:task_manager/modules/tasks/controllers/task_controller.dart';
import 'package:task_manager/modules/tasks/views/task_dialog.dart';
import 'package:task_manager/modules/tasks/views/task_search_delegate.dart';

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
            onPressed:
                () => showSearch(
                  context: context,
                  delegate: TaskSearchDelegate(controller),
                ),
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
        // Tratamento de erros
        if (controller.errorMessage.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(controller.errorMessage.value)),
            );
            controller.errorMessage.value = '';
          });
        }

        return StreamBuilder<QuerySnapshot>(
          stream: controller.tasksStream,
          builder: (context, snapshot) {
            // Estados de carregamento
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            // Tratamento de erros
            if (snapshot.hasError) {
              return _buildErrorState(snapshot.error.toString());
            }

            final tasks = snapshot.data?.docs ?? [];

            // Estado vazio
            if (tasks.isEmpty) {
              return _buildEmptyState();
            }

            // Lista de tarefas
            return _buildTaskList(tasks);
          },
        );
      }),
    );
  }

  // Widgets auxiliares
  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Erro: $error'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              controller.showFavoritesOnly.value = false;
              controller.updateSearch('');
            },
            child: const Text('Recarregar'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            controller.showFavoritesOnly.value
                ? 'Nenhuma tarefa favorita encontrada'
                : 'Nenhuma tarefa cadastrada',
          ),
          if (controller.showFavoritesOnly.value) ...[
            const SizedBox(height: 8),
            TextButton(
              onPressed: controller.toggleFavoriteFilter,
              child: const Text('Ver todas as tarefas'),
            ),
          ],
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _showAddTaskDialog(Get.context!),
            child: const Text('Criar primeira tarefa'),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskList(List<DocumentSnapshot> tasks) {
    return ListView.separated(
      padding: const EdgeInsets.all(8),
      itemCount: tasks.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final task = tasks[index];
        final data = task.data() as Map<String, dynamic>;
        final createdAt = (data['createdAt'] as Timestamp?)?.toDate();

        return Dismissible(
          key: Key(task.id),
          direction: DismissDirection.endToStart,
          background: _buildDismissibleBackground(),
          confirmDismiss: (_) => _confirmDelete(context),
          onDismissed: (_) => _handleTaskDeletion(task.id),
          child: Card(
            elevation: 2,
            child: ListTile(
              title: _buildTaskTitle(data),
              subtitle: _buildTaskSubtitle(data, createdAt),
              trailing: _buildTaskTrailing(task, data),
              onTap: () => _showEditTaskDialog(context, task.id, data),
            ),
          ),
        );
      },
    );
  }

  // Componentes da lista
  Widget _buildDismissibleBackground() {
    return Container(
      color: Colors.red,
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      child: const Icon(Icons.delete, color: Colors.white),
    );
  }

  Widget _buildTaskTitle(Map<String, dynamic> data) {
    return Text(
      data['title'] ?? '',
      style: TextStyle(
        decoration:
            data['completed'] == true ? TextDecoration.lineThrough : null,
      ),
    );
  }

  Widget _buildTaskSubtitle(Map<String, dynamic> data, DateTime? createdAt) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (data['description']?.isNotEmpty ?? false)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(data['description'] ?? ''),
          ),
        if (createdAt != null)
          Text(
            'Criada em: ${DateFormat('dd/MM/yyyy HH:mm').format(createdAt)}',
            style: Get.textTheme.bodySmall,
          ),
      ],
    );
  }

  Widget _buildTaskTrailing(DocumentSnapshot task, Map<String, dynamic> data) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(
            data['favorite'] == true ? Icons.star : Icons.star_border,
            color: data['favorite'] == true ? Colors.amber : null,
          ),
          onPressed:
              () => controller.toggleFavoriteStatus(
                task.id,
                data['favorite'] == true,
              ),
        ),
        IconButton(
          icon: Icon(
            data['completed'] == true
                ? Icons.check_box
                : Icons.check_box_outline_blank,
            color: data['completed'] == true ? Colors.green : null,
          ),
          onPressed:
              () => controller.toggleTaskStatus(
                task.id,
                data['completed'] == true,
              ),
        ),
      ],
    );
  }

  // Diálogos e ações
  Future<bool> _confirmDelete(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Confirmar exclusão'),
                content: const Text(
                  'Tem certeza que deseja excluir esta tarefa?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancelar'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text(
                      'Excluir',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
        ) ??
        false;
  }

  Future<void> _handleTaskDeletion(String taskId) async {
    try {
      await controller.deleteTask(taskId);
      Get.snackbar('Sucesso', 'Tarefa excluída com sucesso');
    } catch (e) {
      Get.snackbar('Erro', 'Falha ao excluir tarefa');
    }
  }

  void _showAddTaskDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => TaskDialog(
            title: 'Adicionar Tarefa',
            onSave: (title, description) {
              controller.addTask(title, description);
              Navigator.pop(context);
            },
          ),
    );
  }

  void _showEditTaskDialog(
    BuildContext context,
    String taskId,
    Map<String, dynamic> data,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => TaskDialog(
            title: 'Editar Tarefa',
            initialTitle: data['title'] ?? '',
            initialDescription: data['description'] ?? '',
            onSave: (title, description) {
              controller.updateTask(taskId, title, description);
              Navigator.pop(context);
            },
          ),
    );
  }
}
