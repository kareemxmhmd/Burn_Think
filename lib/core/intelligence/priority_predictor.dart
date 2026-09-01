import '../../domain/models/task.dart';
import '../../domain/models/project.dart';

class PrioritizedFocusItem {
  final Task task;
  final double score;
  final String focusReason;

  const PrioritizedFocusItem({
    required this.task,
    required this.score,
    required this.focusReason,
  });
}

class PriorityPredictor {
  List<PrioritizedFocusItem> computeTodaysFocus({
    required List<Task> activeTasks,
    required List<Project> activeProjects,
    int maxItems = 4,
  }) {
    if (activeTasks.isEmpty) return [];

    final now = DateTime.now();
    final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);

    final scored = <PrioritizedFocusItem>[];

    for (final task in activeTasks) {
      double score = 0.0;
      final reasons = <String>[];

      // 1. Explicit user priority weight
      switch (task.priority) {
        case TaskPriority.high:
          score += 40.0;
          reasons.add('High priority');
          break;
        case TaskPriority.medium:
          score += 20.0;
          break;
        case TaskPriority.low:
          score += 10.0;
          break;
        case TaskPriority.none:
          score += 5.0;
          break;
      }

      // 2. Due Date Urgency
      if (task.dueDate != null) {
        final diffDays = task.dueDate!.difference(now).inDays;
        final diffHours = task.dueDate!.difference(now).inHours;

        if (task.dueDate!.isBefore(now)) {
          score += 45.0;
          reasons.add('Overdue');
        } else if (task.dueDate!.isBefore(todayEnd) || diffHours <= 24) {
          score += 35.0;
          reasons.add('Due today');
        } else if (diffDays <= 2) {
          score += 20.0;
          reasons.add('Due in $diffDays days');
        } else if (diffDays <= 7) {
          score += 10.0;
        }
      }

      // 3. Project momentum
      if (task.projectId != null) {
        final project = activeProjects.where((p) => p.id == task.projectId).firstOrNull;
        if (project != null && project.progressPercent > 50) {
          score += 10.0;
          reasons.add('Active project (${project.progressPercent}% done)');
        }
      }

      // 4. Age / Staleness boost (prevent tasks from being ignored indefinitely)
      final ageDays = now.difference(task.createdAt).inDays;
      if (ageDays >= 7) {
        score += 8.0;
        if (reasons.isEmpty) reasons.add('Created $ageDays days ago');
      }

      final reason = reasons.isNotEmpty ? reasons.join(' • ') : 'Recommended for today';

      scored.add(PrioritizedFocusItem(
        task: task,
        score: score,
        focusReason: reason,
      ));
    }

    scored.sort((a, b) => b.score.compareTo(a.score));
    return scored.take(maxItems).toList();
  }
}
