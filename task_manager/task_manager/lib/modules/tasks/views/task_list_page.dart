import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:task_manager/core/routes/routes.dart';
import 'package:task_manager/core/themes/app_theme.dart';
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
        title: const Text(
          'Minhas Tarefas',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue[800],
        elevation: 4,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Obx(() {
            final themeController = Get.find<ThemeController>();
            return IconButton(
              icon: Icon(
                themeController.isDarkMode.value
                    ? Icons.light_mode_rounded
                    : Icons.dark_mode_rounded,
                size: 26,
                color: Colors.white,
              ),
              onPressed: themeController.toggleTheme,
              tooltip:
                  themeController.isDarkMode.value
                      ? 'Modo Claro'
                      : 'Modo Escuro',
            );
          }),
          IconButton(
            icon: const Icon(Icons.search, size: 26),
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
                size: 26,
                color:
                    controller.showFavoritesOnly.value
                        ? Colors.amber
                        : Colors.white,
              ),
              onPressed: controller.toggleFavoriteFilter,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout, size: 26),
            onPressed: () => Get.offNamed(Routes.AUTH),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskDialog(context),
        backgroundColor: Colors.blue[800],
        elevation: 4,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      body: Obx(() {
        final isDarkMode = Get.find<ThemeController>().isDarkMode.value;

        return Container(
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.black87 : Colors.grey[50],
            gradient:
                !isDarkMode
                    ? LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.blue.shade50.withOpacity(0.1),
                        Colors.grey[50]!,
                      ],
                    )
                    : null,
          ),
          child: StreamBuilder<QuerySnapshot>(
            stream: controller.tasksStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(Colors.blue),
                  ),
                );
              }

              if (snapshot.hasError) {
                return _buildErrorState(snapshot.error.toString());
              }

              final tasks = snapshot.data?.docs ?? [];

              if (tasks.isEmpty) {
                return _buildEmptyState();
              }

              return _buildTaskList(tasks);
            },
          ),
        );
      }),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 50, color: Colors.red),
          const SizedBox(height: 16),
          Text('Erro: $error', style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              controller.showFavoritesOnly.value = false;
              controller.updateSearch('');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[800],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(
              'Recarregar',
              style: TextStyle(color: Colors.white),
            ),
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
          Icon(
            controller.showFavoritesOnly.value
                ? Icons.star_border_rounded
                : Icons.task_alt_rounded,
            size: 60,
            color: Colors.blue[800]?.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            controller.showFavoritesOnly.value
                ? 'Nenhuma tarefa favorita encontrada'
                : 'Nenhuma tarefa cadastrada',
            style: TextStyle(fontSize: 18, color: Colors.grey[700]),
          ),
          if (controller.showFavoritesOnly.value) ...[
            const SizedBox(height: 12),
            TextButton(
              onPressed: controller.toggleFavoriteFilter,
              child: Text(
                'Ver todas as tarefas',
                style: TextStyle(
                  color: Colors.blue[800],
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => _showAddTaskDialog(Get.context!),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[800],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(
              'Criar primeira tarefa',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskList(List<DocumentSnapshot> tasks) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: tasks.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => _showEditTaskDialog(context, task.id, data),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: _buildTaskTitle(data)),
                        _buildTaskTrailing(task, data),
                      ],
                    ),
                    if (data['description']?.isNotEmpty ?? false) ...[
                      const SizedBox(height: 8),
                      _buildTaskDescription(data),
                    ],
                    if (createdAt != null) ...[
                      const SizedBox(height: 8),
                      _buildTaskDate(createdAt),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDismissibleBackground() {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.red[400],
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      child: const Icon(Icons.delete_forever, color: Colors.white, size: 30),
    );
  }

  Widget _buildTaskTitle(Map<String, dynamic> data) {
    return Text(
      data['title'] ?? '',
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        decoration:
            data['completed'] == true ? TextDecoration.lineThrough : null,
        color: data['completed'] == true ? Colors.grey : Colors.black87,
      ),
    );
  }

  Widget _buildTaskDescription(Map<String, dynamic> data) {
    return Text(
      data['description'] ?? '',
      style: TextStyle(color: Colors.grey[700], fontSize: 14),
    );
  }

  Widget _buildTaskDate(DateTime createdAt) {
    return Row(
      children: [
        const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
        const SizedBox(width: 4),
        Text(
          DateFormat('dd/MM/yyyy HH:mm').format(createdAt),
          style: const TextStyle(fontSize: 12, color: Colors.grey),
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
            data['favorite'] == true
                ? Icons.star_rounded
                : Icons.star_border_rounded,
            color: data['favorite'] == true ? Colors.amber : Colors.grey,
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
                ? Icons.check_circle_rounded
                : Icons.radio_button_unchecked_rounded,
            color: data['completed'] == true ? Colors.green : Colors.grey,
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

  Future<bool> _confirmDelete(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Confirmar exclusão'),
                content: const Text(
                  'Tem certeza que deseja excluir esta tarefa?',
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancelar'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text(
                      'Excluir',
                      style: TextStyle(color: Colors.white),
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
      Get.snackbar(
        'Sucesso',
        'Tarefa excluída com sucesso',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        margin: const EdgeInsets.all(20),
        borderRadius: 12,
      );
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Falha ao excluir tarefa',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        margin: const EdgeInsets.all(20),
        borderRadius: 12,
      );
    }
  }

  void _showAddTaskDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: TaskDialog(
              title: 'Adicionar Tarefa',
              onSave: (title, description) {
                controller.addTask(title, description);
                Navigator.pop(context);
              },
            ),
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
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: TaskDialog(
              title: 'Editar Tarefa',
              initialTitle: data['title'] ?? '',
              initialDescription: data['description'] ?? '',
              onSave: (title, description) {
                controller.updateTask(taskId, title, description);
                Navigator.pop(context);
              },
            ),
          ),
    );
  }
}
