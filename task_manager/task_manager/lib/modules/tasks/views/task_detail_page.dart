import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TaskDetailPage extends StatelessWidget {
  final String taskId = Get.parameters['taskId'] ?? '';

  TaskDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes da Tarefa'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Navegar para tela de edição
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              // Excluir tarefa
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Título da Tarefa',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            const Text(
              'Descrição detalhada da tarefa vai aqui...',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16),
                const SizedBox(width: 8),
                Text(
                  'Criada em: ${DateTime.now().toString()}',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.star, size: 16),
                const SizedBox(width: 8),
                const Text(
                  'Favorita: ',
                  style: TextStyle(fontSize: 14),
                ),
                Switch(
                  value: true,
                  onChanged: (value) {
                    // Alterar status de favorito
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.check_circle, size: 16),
                const SizedBox(width: 8),
                const Text(
                  'Concluída: ',
                  style: TextStyle(fontSize: 14),
                ),
                Switch(
                  value: false,
                  onChanged: (value) {
                    // Alterar status de concluída
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}