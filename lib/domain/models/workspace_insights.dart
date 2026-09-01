class WorkspaceInsights {
  final double averageTaskCompletionDays;
  final int tasksCompletedThisWeek;
  final int totalCompletedItems;
  final int activeProjectsCount;
  final int longestActiveTaskDays;
  final String? longestActiveTaskTitle;
  final Map<String, int> categoryDistribution;
  final double completionRate;

  const WorkspaceInsights({
    required this.averageTaskCompletionDays,
    required this.tasksCompletedThisWeek,
    required this.totalCompletedItems,
    required this.activeProjectsCount,
    required this.longestActiveTaskDays,
    this.longestActiveTaskTitle,
    required this.categoryDistribution,
    required this.completionRate,
  });

  factory WorkspaceInsights.empty() {
    return const WorkspaceInsights(
      averageTaskCompletionDays: 0.0,
      tasksCompletedThisWeek: 0,
      totalCompletedItems: 0,
      activeProjectsCount: 0,
      longestActiveTaskDays: 0,
      longestActiveTaskTitle: null,
      categoryDistribution: {},
      completionRate: 0.0,
    );
  }
}
