import '../models/project.dart';

abstract class ProjectRepository {
  Future<List<Project>> getActiveProjects();
  Future<List<Project>> getCompletedProjects();
  Future<List<Project>> getAllProjects();
  Future<Project?> getProjectById(String id);
  Future<void> insertProject(Project project);
  Future<void> updateProject(Project project);
  Future<void> deleteProject(String id);
  Future<void> setProjectCompleted(String id, bool isCompleted, {DateTime? completedAt});

  // Project items
  Future<void> insertProjectItem(ProjectItem item);
  Future<void> updateProjectItem(ProjectItem item);
  Future<void> deleteProjectItem(String itemId);
  Future<void> setProjectItemCompleted(String itemId, bool isCompleted, {DateTime? completedAt});
}
