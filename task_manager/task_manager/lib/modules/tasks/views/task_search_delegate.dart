import 'package:flutter/material.dart';
import 'package:task_manager/modules/tasks/controllers/task_controller.dart';

class TaskSearchDelegate extends SearchDelegate {
  final TaskController controller;

  TaskSearchDelegate(this.controller);

  @override
  String get searchFieldLabel => 'Buscar tarefas...';

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
            controller.updateSearch('');
          },
        )
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        controller.updateSearch('');
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    controller.updateSearch(query);
    close(context, null);
    return const SizedBox(); // Nada visível, mas atualiza a busca no controller
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // Você pode adicionar sugestões baseadas em histórico ou palavras-chave aqui
    return const SizedBox();
  }
}
