import 'package:flutter/foundation.dart';
import 'workspace_controller.dart';

class SearchResultItem {
  final String id;
  final DetailType type;
  final String title;
  final String? subtitle;
  final String category;
  final Object item;

  const SearchResultItem({
    required this.id,
    required this.type,
    required this.title,
    this.subtitle,
    required this.category,
    required this.item,
  });
}

class AppSearchController extends ChangeNotifier {
  final WorkspaceController workspaceController;

  AppSearchController({required this.workspaceController});

  String _query = '';
  String get query => _query;

  List<SearchResultItem> _results = [];
  List<SearchResultItem> get results => _results;

  void setQuery(String q) {
    _query = q;
    _performSearch();
    notifyListeners();
  }

  void clear() {
    _query = '';
    _results = [];
    notifyListeners();
  }

  void _performSearch() {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) {
      _results = [];
      return;
    }

    final list = <SearchResultItem>[];

    // 1. Active Tasks
    for (final t in workspaceController.activeTasks) {
      if (t.title.toLowerCase().contains(q) ||
          (t.description?.toLowerCase().contains(q) ?? false)) {
        list.add(SearchResultItem(
          id: t.id,
          type: DetailType.task,
          title: t.title,
          subtitle: t.projectName != null ? 'Task • ${t.projectName}' : 'Task • Active',
          category: 'Tasks',
          item: t,
        ));
      }
    }

    // 2. Active Projects
    for (final p in workspaceController.activeProjects) {
      if (p.title.toLowerCase().contains(q) ||
          (p.description?.toLowerCase().contains(q) ?? false) ||
          p.items.any((i) => i.title.toLowerCase().contains(q))) {
        list.add(SearchResultItem(
          id: p.id,
          type: DetailType.project,
          title: p.title,
          subtitle: 'Project • ${p.progressPercent}% complete',
          category: 'Projects',
          item: p,
        ));
      }
    }

    // 3. Workouts
    for (final w in workspaceController.allWorkouts) {
      if (w.name.toLowerCase().contains(q) ||
          w.exercises.any((e) => e.name.toLowerCase().contains(q) || (e.category?.toLowerCase().contains(q) ?? false))) {
        list.add(SearchResultItem(
          id: w.id,
          type: DetailType.workout,
          title: w.name,
          subtitle: 'Workout • ${w.exercises.length} exercises',
          category: 'Workout',
          item: w,
        ));
      }
    }

    // 4. Content Items
    for (final c in workspaceController.contentItems) {
      if (c.title.toLowerCase().contains(q) ||
          (c.description?.toLowerCase().contains(q) ?? false) ||
          (c.contentType?.toLowerCase().contains(q) ?? false)) {
        list.add(SearchResultItem(
          id: c.id,
          type: DetailType.content,
          title: c.title,
          subtitle: 'Content • ${c.contentType ?? "Idea"}',
          category: 'Content',
          item: c,
        ));
      }
    }

    // 5. Notes
    for (final n in workspaceController.notes) {
      if (n.title.toLowerCase().contains(q) || n.body.toLowerCase().contains(q)) {
        list.add(SearchResultItem(
          id: n.id,
          type: DetailType.note,
          title: n.title,
          subtitle: n.isPinned ? 'Note • Pinned' : 'Note',
          category: 'Notes',
          item: n,
        ));
      }
    }

    // 6. Shopping Items
    for (final s in workspaceController.toBuyShoppingItems) {
      if (s.title.toLowerCase().contains(q) || (s.notes?.toLowerCase().contains(q) ?? false)) {
        list.add(SearchResultItem(
          id: s.id,
          type: DetailType.shopping,
          title: s.title,
          subtitle: 'Shopping • To Buy',
          category: 'Shopping',
          item: s,
        ));
      }
    }

    // 7. Completed Items
    for (final t in workspaceController.completedTasks) {
      if (t.title.toLowerCase().contains(q) ||
          (t.description?.toLowerCase().contains(q) ?? false)) {
        list.add(SearchResultItem(
          id: t.id,
          type: DetailType.task,
          title: t.title,
          subtitle: 'Completed Task',
          category: 'Completed',
          item: t,
        ));
      }
    }

    for (final p in workspaceController.completedProjects) {
      if (p.title.toLowerCase().contains(q) ||
          (p.description?.toLowerCase().contains(q) ?? false) ||
          p.items.any((i) => i.title.toLowerCase().contains(q))) {
        list.add(SearchResultItem(
          id: p.id,
          type: DetailType.project,
          title: p.title,
          subtitle: 'Completed Project',
          category: 'Completed',
          item: p,
        ));
      }
    }

    for (final s in workspaceController.boughtShoppingItems) {
      if (s.title.toLowerCase().contains(q) || (s.notes?.toLowerCase().contains(q) ?? false)) {
        list.add(SearchResultItem(
          id: s.id,
          type: DetailType.shopping,
          title: s.title,
          subtitle: 'Completed • Bought',
          category: 'Completed',
          item: s,
        ));
      }
    }

    _results = list;
  }
}

