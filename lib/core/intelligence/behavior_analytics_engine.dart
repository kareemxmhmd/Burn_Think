import '../../domain/models/task.dart';
import '../../domain/models/project.dart';
import '../../domain/models/workout.dart';
import '../../domain/models/content_item.dart';
import '../../domain/models/note.dart';
import '../../domain/models/shopping_item.dart';
import '../../domain/models/workspace_insights.dart';

class BehaviorAnalyticsEngine {
  WorkspaceInsights computeInsights({
    required List<Task> activeTasks,
    required List<Task> completedTasks,
    required List<Project> activeProjects,
    required List<Project> completedProjects,
    required List<Workout> workouts,
    required List<ContentItem> contentItems,
    required List<Note> notes,
    required List<ShoppingItem> toBuyShopping,
    required List<ShoppingItem> boughtShopping,
  }) {
    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 7));

    // 1. Average Task Completion Duration
    double avgCompletionDays = 0.0;
    if (completedTasks.isNotEmpty) {
      double totalDays = 0.0;
      int count = 0;
      for (final t in completedTasks) {
        if (t.completedAt != null) {
          final duration = t.completedAt!.difference(t.createdAt);
          totalDays += (duration.inMinutes / (60 * 24)).clamp(0.01, 365.0);
          count++;
        }
      }
      if (count > 0) {
        avgCompletionDays = double.parse((totalDays / count).toStringAsFixed(1));
      }
    }

    // 2. Tasks completed this week
    final completedThisWeek = completedTasks
        .where((t) => t.completedAt != null && t.completedAt!.isAfter(sevenDaysAgo))
        .length;

    // 3. Longest active task
    int longestActiveDays = 0;
    String? longestActiveTitle;
    for (final t in activeTasks) {
      final days = now.difference(t.createdAt).inDays;
      if (days > longestActiveDays) {
        longestActiveDays = days;
        longestActiveTitle = t.title;
      }
    }

    // 4. Total completed items across workspace
    final totalCompleted = completedTasks.length + completedProjects.length + boughtShopping.length;

    // 5. Category distribution
    final categoryDistribution = <String, int>{
      'Tasks': activeTasks.length + completedTasks.length,
      'Projects': activeProjects.length + completedProjects.length,
      'Workout': workouts.length,
      'Content': contentItems.length,
      'Notes': notes.length,
      'Shopping': toBuyShopping.length + boughtShopping.length,
    };

    // 6. Overall Completion Rate
    final totalItems = (activeTasks.length + completedTasks.length) +
        (activeProjects.length + completedProjects.length) +
        (toBuyShopping.length + boughtShopping.length);

    final completionRate = totalItems > 0
        ? double.parse(((totalCompleted / totalItems) * 100).toStringAsFixed(0))
        : 0.0;

    return WorkspaceInsights(
      averageTaskCompletionDays: avgCompletionDays,
      tasksCompletedThisWeek: completedThisWeek,
      totalCompletedItems: totalCompleted,
      activeProjectsCount: activeProjects.length,
      longestActiveTaskDays: longestActiveDays,
      longestActiveTaskTitle: longestActiveTitle,
      categoryDistribution: categoryDistribution,
      completionRate: completionRate,
    );
  }
}
