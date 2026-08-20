import '../models/task.dart';

abstract class TaskRepository {
  Future<List<Task>> getActiveTasks();
  Future<List<Task>> getCompletedTasks();
  Future<Task?> getTaskById(String id);
  Future<void> insertTask(Task task);
  Future<void> updateTask(Task task);
  Future<void> deleteTask(String id);
  Future<void> setTaskCompleted(String id, bool isCompleted, {DateTime? completedAt});
}
