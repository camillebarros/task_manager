import 'package:flutter/material.dart';
import 'package:task_manager/modules/tasks/controllers/task_controller.dart';

class TaskSearchDelegate extends SearchDelegate {
  final TaskController controller;
  final List<String> searchHistory = [];

  TaskSearchDelegate(this.controller);

  @override
  String get searchFieldLabel => 'Buscar tarefas...';

  @override
  ThemeData appBarTheme(BuildContext context) {
    final theme = Theme.of(context);
    return theme.copyWith(
      appBarTheme: theme.appBarTheme.copyWith(
        backgroundColor: theme.scaffoldBackgroundColor,
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: theme.textTheme.titleMedium?.copyWith(
          color: theme.hintColor,
        ),
        border: InputBorder.none,
      ),
    );
  }

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
        ),
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
    if (query.isNotEmpty && !searchHistory.contains(query)) {
      searchHistory.add(query);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.updateSearch(query);
    });

    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions =
        searchHistory.where((item) {
          return item.toLowerCase().contains(query.toLowerCase());
        }).toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: const Icon(Icons.history),
          title: Text(suggestions[index]),
          onTap: () {
            query = suggestions[index];
            showResults(context);
          },
        );
      },
    );
  }

  Widget _buildSearchResults() {
    return const SizedBox();
  }
}
