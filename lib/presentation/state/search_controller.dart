import 'package:flutter/foundation.dart';
import '../../domain/models/ml_event.dart';
import 'workspace_controller.dart';

class SearchResultItem {
  final String id;
  final DetailType type;
  final String title;
  final String? subtitle;
  final String category;
  final Object item;
  final bool isSemanticMatch;

  const SearchResultItem({
    required this.id,
    required this.type,
    required this.title,
    this.subtitle,
    required this.category,
    required this.item,
    this.isSemanticMatch = false,
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
    final q = _query.trim();
    if (q.isEmpty) {
      _results = [];
      return;
    }

    // Collect all workspace items across sections
    final allItems = _collectAllWorkspaceItems();

    // Perform intelligence semantic & fuzzy ranked search
    final scored = workspaceController.intelligenceService.semanticSearch(q, allItems);

    _results = scored.map((s) {
      return SearchResultItem(
        id: s.item.id,
        type: s.item.type,
        title: s.item.title,
        subtitle: s.item.subtitle,
        category: s.item.category,
        item: s.item.item,
        isSemanticMatch: s.isSemanticMatch,
      );
    }).toList();

    // Log search event
    workspaceController.intelligenceService.recordEvent(
      eventType: MLEventType.searchPerformed,
      metadata: {'query': q, 'resultCount': _results.length},
    );
  }

  List<SearchResultItem> _collectAllWorkspaceItems() {
    final list = <SearchResultItem>[];

    // 1. Active Tasks
    for (final t in workspaceController.activeTasks) {
      list.add(SearchResultItem(
        id: t.id,
        type: DetailType.task,
        title: t.title,
        subtitle: t.projectName != null ? 'Task • ${t.projectName}' : 'Task • Active',
        category: 'Tasks',
        item: t,
      ));
    }

    // 2. Active Projects
    for (final p in workspaceController.activeProjects) {
      final childTitles = p.items.map((i) => i.title).join(' ');
      list.add(SearchResultItem(
        id: p.id,
        type: DetailType.project,
        title: p.title,
        subtitle: 'Project • ${p.progressPercent}% complete${childTitles.isNotEmpty ? " • $childTitles" : ""}',
        category: 'Projects',
        item: p,
      ));
    }

    // 3. Workouts
    for (final w in workspaceController.allWorkouts) {
      final exNames = w.exercises.map((e) => e.name).join(', ');
      list.add(SearchResultItem(
        id: w.id,
        type: DetailType.workout,
        title: w.name,
        subtitle: 'Workout • ${w.exercises.length} exercises${exNames.isNotEmpty ? " • $exNames" : ""}',
        category: 'Workout',
        item: w,
      ));
    }

    // 4. Content Items
    for (final c in workspaceController.contentItems) {
      list.add(SearchResultItem(
        id: c.id,
        type: DetailType.content,
        title: c.title,
        subtitle: 'Content • ${c.contentType ?? "Idea"}${c.description != null ? " • ${c.description}" : ""}',
        category: 'Content',
        item: c,
      ));
    }

    // 5. Notes
    for (final n in workspaceController.notes) {
      list.add(SearchResultItem(
        id: n.id,
        type: DetailType.note,
        title: n.title,
        subtitle: n.isPinned ? 'Note • Pinned • ${n.body}' : 'Note • ${n.body}',
        category: 'Notes',
        item: n,
      ));
    }

    // 6. Shopping Items
    for (final s in workspaceController.toBuyShoppingItems) {
      list.add(SearchResultItem(
        id: s.id,
        type: DetailType.shopping,
        title: s.title,
        subtitle: 'Shopping • To Buy${s.notes != null ? " • ${s.notes}" : ""}',
        category: 'Shopping',
        item: s,
      ));
    }

    // 7. Completed Items
    for (final t in workspaceController.completedTasks) {
      list.add(SearchResultItem(
        id: t.id,
        type: DetailType.task,
        title: t.title,
        subtitle: 'Completed Task',
        category: 'Completed',
        item: t,
      ));
    }

    for (final p in workspaceController.completedProjects) {
      list.add(SearchResultItem(
        id: p.id,
        type: DetailType.project,
        title: p.title,
        subtitle: 'Completed Project',
        category: 'Completed',
        item: p,
      ));
    }

    for (final s in workspaceController.boughtShoppingItems) {
      list.add(SearchResultItem(
        id: s.id,
        type: DetailType.shopping,
        title: s.title,
        subtitle: 'Completed • Bought',
        category: 'Completed',
        item: s,
      ));
    }

    return list;
  }
}
