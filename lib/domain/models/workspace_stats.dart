class WorkspaceStats {
  final int activeTasksCount;
  final int totalTasksCount;
  final int activeProjectsCount;
  final int completedProjectsCount;
  final int workoutsCount;
  final int contentItemsCount;
  final int notesCount;
  final int shoppingItemsToBuyCount;
  final int completedItemsTotalCount;

  const WorkspaceStats({
    this.activeTasksCount = 0,
    this.totalTasksCount = 0,
    this.activeProjectsCount = 0,
    this.completedProjectsCount = 0,
    this.workoutsCount = 0,
    this.contentItemsCount = 0,
    this.notesCount = 0,
    this.shoppingItemsToBuyCount = 0,
    this.completedItemsTotalCount = 0,
  });
}
