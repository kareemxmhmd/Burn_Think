import 'package:flutter_test/flutter_test.dart';
import 'package:burn_shut/core/database/app_database.dart';
import 'package:burn_shut/core/services/toast_service.dart';
import 'package:burn_shut/data/repositories/sqlite_content_repository.dart';
import 'package:burn_shut/data/repositories/sqlite_note_repository.dart';
import 'package:burn_shut/data/repositories/sqlite_project_repository.dart';
import 'package:burn_shut/data/repositories/sqlite_shopping_repository.dart';
import 'package:burn_shut/data/repositories/sqlite_task_repository.dart';
import 'package:burn_shut/data/repositories/sqlite_workout_repository.dart';
import 'package:burn_shut/domain/models/task.dart';
import 'package:burn_shut/domain/models/workout.dart';
import 'package:burn_shut/presentation/state/search_controller.dart';
import 'package:burn_shut/presentation/state/workspace_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late WorkspaceController controller;

  setUp(() async {
    db = await AppDatabase.createInMemory();
    controller = WorkspaceController(
      taskRepository: SqliteTaskRepository(appDatabase: db),
      projectRepository: SqliteProjectRepository(appDatabase: db),
      workoutRepository: SqliteWorkoutRepository(appDatabase: db),
      contentRepository: SqliteContentRepository(appDatabase: db),
      noteRepository: SqliteNoteRepository(appDatabase: db),
      shoppingRepository: SqliteShoppingRepository(appDatabase: db),
    );
    await controller.loadWorkspace();
  });

  tearDown(() async {
    ToastService.instance.dismiss();
    await db.close();
  });

  group('WorkspaceController Refactoring & Undo Tests', () {
    test('Task completion and undo lifecycle', () async {
      await controller.createTask(title: 'Refactor Task', priority: TaskPriority.high);
      expect(controller.activeTasks.length, 1);
      expect(controller.completedTasks.isEmpty, true);

      final task = controller.activeTasks.first;
      await controller.completeTask(task);
      expect(controller.activeTasks.isEmpty, true);
      expect(controller.completedTasks.length, 1);

      // Verify undo toast
      expect(ToastService.instance.currentToast?.message, 'Task completed');
      expect(ToastService.instance.currentToast?.undoLabel, 'Undo');

      // Trigger undo
      ToastService.instance.triggerUndo();
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(controller.activeTasks.length, 1);
      expect(controller.completedTasks.isEmpty, true);
    });

    test('Note deletion and undo lifecycle', () async {
      await controller.createNote(title: 'Design Idea', body: 'Architecture notes');
      expect(controller.notes.length, 1);

      final note = controller.notes.first;
      await controller.deleteNote(note);
      expect(controller.notes.isEmpty, true);

      // Verify undo toast is present
      expect(ToastService.instance.currentToast?.message, 'Note deleted');
      expect(ToastService.instance.currentToast?.undoLabel, 'Undo');

      // Trigger undo
      ToastService.instance.triggerUndo();
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(controller.notes.length, 1);
      expect(controller.notes.first.title, 'Design Idea');
    });

    test('Content item deletion and undo lifecycle', () async {
      await controller.createContentItem(title: 'Flutter Desktop Video', contentType: 'Video');
      expect(controller.contentItems.length, 1);

      final item = controller.contentItems.first;
      await controller.deleteContentItem(item);
      expect(controller.contentItems.isEmpty, true);

      // Verify undo toast is present
      expect(ToastService.instance.currentToast?.message, 'Content idea deleted');
      expect(ToastService.instance.currentToast?.undoLabel, 'Undo');

      // Trigger undo
      ToastService.instance.triggerUndo();
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(controller.contentItems.length, 1);
      expect(controller.contentItems.first.title, 'Flutter Desktop Video');
    });

    test('Workout deletion and undo lifecycle', () async {
      final workout = await controller.createWorkout(
        name: 'Full Body Routine',
        initialExercises: [
          Exercise(
            id: 'ex-1',
            workoutId: '',
            name: 'Pullups',
            sets: 3,
            repetitions: 10,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ],
      );
      expect(controller.allWorkouts.length, 1);

      await controller.deleteWorkout(workout);
      expect(controller.allWorkouts.isEmpty, true);

      // Verify undo toast is present
      expect(ToastService.instance.currentToast?.message, 'Workout deleted');
      expect(ToastService.instance.currentToast?.undoLabel, 'Undo');

      // Trigger undo
      ToastService.instance.triggerUndo();
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(controller.allWorkouts.length, 1);
      expect(controller.allWorkouts.first.name, 'Full Body Routine');
      expect(controller.allWorkouts.first.exercises.length, 1);
    });

    test('Workout exercise reordering via controller', () async {
      final workout = await controller.createWorkout(
        name: 'Upper Body',
      );
      await controller.addExerciseToWorkout(
        workout.id,
        Exercise(
          id: 'ex-1',
          workoutId: workout.id,
          name: 'Bench Press',
          sortOrder: 0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
      await controller.addExerciseToWorkout(
        workout.id,
        Exercise(
          id: 'ex-2',
          workoutId: workout.id,
          name: 'Overhead Press',
          sortOrder: 1,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

      expect(controller.allWorkouts.first.exercises.first.name, 'Bench Press');

      // Reorder
      await controller.reorderExercises(workout.id, ['ex-2', 'ex-1']);
      expect(controller.allWorkouts.first.exercises.first.name, 'Overhead Press');
    });

    test('SearchController includes completed projects in search index', () async {
      final project = await controller.createProject(title: 'Completed Flutter Migration');
      await controller.setProjectCompleted(project, true);
      ToastService.instance.dismiss();

      expect(controller.activeProjects.isEmpty, true);
      expect(controller.completedProjects.length, 1);

      final searchCtrl = AppSearchController(workspaceController: controller);
      searchCtrl.setQuery('Migration');

      expect(searchCtrl.results.length, 1);
      expect(searchCtrl.results.first.title, 'Completed Flutter Migration');
      expect(searchCtrl.results.first.category, 'Completed');
      expect(searchCtrl.results.first.subtitle, 'Completed Project');
      searchCtrl.dispose();
    });
  });
}
