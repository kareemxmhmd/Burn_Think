import 'package:flutter_test/flutter_test.dart';
import 'package:burn_shut/core/database/app_database.dart';
import 'package:burn_shut/data/repositories/sqlite_task_repository.dart';
import 'package:burn_shut/data/repositories/sqlite_project_repository.dart';
import 'package:burn_shut/data/repositories/sqlite_workout_repository.dart';
import 'package:burn_shut/data/repositories/sqlite_note_repository.dart';
import 'package:burn_shut/data/repositories/sqlite_shopping_repository.dart';
import 'package:burn_shut/data/repositories/sqlite_content_repository.dart';
import 'package:burn_shut/domain/models/task.dart';
import 'package:burn_shut/domain/models/project.dart';
import 'package:burn_shut/domain/models/workout.dart';
import 'package:burn_shut/domain/models/note.dart';
import 'package:burn_shut/domain/models/shopping_item.dart';
import 'package:burn_shut/domain/models/content_item.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late SqliteTaskRepository taskRepo;
  late SqliteProjectRepository projectRepo;
  late SqliteWorkoutRepository workoutRepo;
  late SqliteNoteRepository noteRepo;
  late SqliteShoppingRepository shoppingRepo;
  late SqliteContentRepository contentRepo;

  setUp(() async {
    db = await AppDatabase.createInMemory();
    taskRepo = SqliteTaskRepository(appDatabase: db);
    projectRepo = SqliteProjectRepository(appDatabase: db);
    workoutRepo = SqliteWorkoutRepository(appDatabase: db);
    noteRepo = SqliteNoteRepository(appDatabase: db);
    shoppingRepo = SqliteShoppingRepository(appDatabase: db);
    contentRepo = SqliteContentRepository(appDatabase: db);
  });

  tearDown(() async {
    await db.close();
  });

  group('SQLite Repositories Persistence Tests', () {
    test('Task CRUD and completion flow', () async {
      final now = DateTime.now();
      final task = Task(
        id: 't-1',
        title: 'Initial Task',
        description: 'Description 1',
        priority: TaskPriority.high,
        createdAt: now,
        updatedAt: now,
      );

      // Create
      await taskRepo.insertTask(task);
      var activeTasks = await taskRepo.getActiveTasks();
      expect(activeTasks.length, 1);
      expect(activeTasks.first.title, 'Initial Task');

      // Update
      final updatedTask = task.copyWith(title: 'Updated Task');
      await taskRepo.updateTask(updatedTask);
      var fetched = await taskRepo.getTaskById('t-1');
      expect(fetched?.title, 'Updated Task');

      // Complete
      await taskRepo.setTaskCompleted('t-1', true);
      activeTasks = await taskRepo.getActiveTasks();
      expect(activeTasks.isEmpty, true);

      var completedTasks = await taskRepo.getCompletedTasks();
      expect(completedTasks.length, 1);
      expect(completedTasks.first.id, 't-1');

      // Uncomplete / Restore
      await taskRepo.setTaskCompleted('t-1', false);
      activeTasks = await taskRepo.getActiveTasks();
      expect(activeTasks.length, 1);

      // Delete
      await taskRepo.deleteTask('t-1');
      activeTasks = await taskRepo.getActiveTasks();
      expect(activeTasks.isEmpty, true);
    });

    test('Project and project items cascading delete', () async {
      final now = DateTime.now();
      final project = Project(
        id: 'p-1',
        title: 'Alpha Project',
        createdAt: now,
        updatedAt: now,
        items: [
          ProjectItem(
            id: 'pi-1',
            projectId: 'p-1',
            title: 'Item 1',
            createdAt: now,
            updatedAt: now,
          ),
          ProjectItem(
            id: 'pi-2',
            projectId: 'p-1',
            title: 'Item 2',
            createdAt: now,
            updatedAt: now,
          ),
        ],
      );

      await projectRepo.insertProject(project);
      var projects = await projectRepo.getActiveProjects();
      expect(projects.length, 1);
      expect(projects.first.items.length, 2);

      // Add task linked to project
      final task = Task(
        id: 't-proj',
        title: 'Task in project',
        projectId: 'p-1',
        createdAt: now,
        updatedAt: now,
      );
      await taskRepo.insertTask(task);

      // Delete Project
      await projectRepo.deleteProject('p-1');
      projects = await projectRepo.getActiveProjects();
      expect(projects.isEmpty, true);

      // Associated task should have detached projectId
      final fetchedTask = await taskRepo.getTaskById('t-proj');
      expect(fetchedTask?.projectId, isNull);
    });

    test('Workout exercises reordering and focus toggle', () async {
      final now = DateTime.now();
      final workout1 = Workout(
        id: 'w-1',
        name: 'Upper Body',
        isCurrentFocus: true,
        createdAt: now,
        updatedAt: now,
        exercises: [
          Exercise(
            id: 'e-1',
            workoutId: 'w-1',
            name: 'Bench Press',
            sortOrder: 0,
            createdAt: now,
            updatedAt: now,
          ),
          Exercise(
            id: 'e-2',
            workoutId: 'w-1',
            name: 'Incline Press',
            sortOrder: 1,
            createdAt: now,
            updatedAt: now,
          ),
        ],
      );

      final workout2 = Workout(
        id: 'w-2',
        name: 'Leg Day',
        isCurrentFocus: false,
        createdAt: now,
        updatedAt: now,
      );

      await workoutRepo.insertWorkout(workout1);
      await workoutRepo.insertWorkout(workout2);

      var focus = await workoutRepo.getCurrentFocusWorkout();
      expect(focus?.id, 'w-1');

      // Change focus to w-2
      await workoutRepo.setCurrentFocusWorkout('w-2');
      focus = await workoutRepo.getCurrentFocusWorkout();
      expect(focus?.id, 'w-2');

      // Reorder exercises in w-1
      await workoutRepo.reorderExercises('w-1', ['e-2', 'e-1']);
      final fetchedW1 = await workoutRepo.getWorkoutById('w-1');
      expect(fetchedW1?.exercises.first.id, 'e-2');
    });

    test('Notes pinning and quick note retrieval', () async {
      final now = DateTime.now();
      final note1 = Note(
        id: 'n-1',
        title: 'Unpinned Note',
        body: 'Body 1',
        isPinned: false,
        createdAt: now,
        updatedAt: now,
      );
      final note2 = Note(
        id: 'n-2',
        title: 'Pinned Note',
        body: 'Important body',
        isPinned: true,
        createdAt: now.add(const Duration(minutes: 5)),
        updatedAt: now.add(const Duration(minutes: 5)),
      );

      await noteRepo.insertNote(note1);
      await noteRepo.insertNote(note2);

      final quickNote = await noteRepo.getQuickNote();
      expect(quickNote?.id, 'n-2');
      expect(quickNote?.isPinned, true);
    });

    test('Shopping items To Buy and Bought queries', () async {
      final now = DateTime.now();
      final item1 = ShoppingItem(
        id: 's-1',
        title: 'Coffee',
        isBought: false,
        createdAt: now,
        updatedAt: now,
      );
      final item2 = ShoppingItem(
        id: 's-2',
        title: 'Milk',
        isBought: false,
        createdAt: now,
        updatedAt: now,
      );

      await shoppingRepo.insertShoppingItem(item1);
      await shoppingRepo.insertShoppingItem(item2);

      var toBuy = await shoppingRepo.getToBuyItems();
      expect(toBuy.length, 2);

      await shoppingRepo.setShoppingItemBought('s-1', true);
      toBuy = await shoppingRepo.getToBuyItems();
      expect(toBuy.length, 1);
      expect(toBuy.first.id, 's-2');

      final bought = await shoppingRepo.getBoughtItems();
      expect(bought.length, 1);
      expect(bought.first.id, 's-1');
    });

    test('Content items CRUD', () async {
      final now = DateTime.now();
      final item = ContentItem(
        id: 'c-1',
        title: 'Architecture Overview',
        description: 'Detailed video plan',
        contentType: 'Video',
        duration: '30 mins',
        createdAt: now,
        updatedAt: now,
      );

      await contentRepo.insertContentItem(item);
      var allContent = await contentRepo.getAllContentItems();
      expect(allContent.length, 1);
      expect(allContent.first.title, 'Architecture Overview');

      await contentRepo.deleteContentItem('c-1');
      allContent = await contentRepo.getAllContentItems();
      expect(allContent.isEmpty, true);
    });
  });
}
