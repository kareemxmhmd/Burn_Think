import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:burn_shut/app/app.dart';
import 'package:burn_shut/core/database/app_database.dart';
import 'package:burn_shut/core/services/toast_service.dart';
import 'package:burn_shut/data/repositories/sqlite_content_repository.dart';
import 'package:burn_shut/data/repositories/sqlite_note_repository.dart';
import 'package:burn_shut/data/repositories/sqlite_project_repository.dart';
import 'package:burn_shut/data/repositories/sqlite_shopping_repository.dart';
import 'package:burn_shut/data/repositories/sqlite_task_repository.dart';
import 'package:burn_shut/data/repositories/sqlite_workout_repository.dart';
import 'package:burn_shut/presentation/state/workspace_controller.dart';
import 'package:burn_shut/presentation/widgets/navigation/sidebar.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Finder sidebarItem(String label) {
    return find.descendant(
      of: find.byType(Sidebar),
      matching: find.text(label),
    );
  }

  Future<WorkspaceController> createTestController(AppDatabase inMemoryDb) async {
    final controller = WorkspaceController(
      taskRepository: SqliteTaskRepository(appDatabase: inMemoryDb),
      projectRepository: SqliteProjectRepository(appDatabase: inMemoryDb),
      workoutRepository: SqliteWorkoutRepository(appDatabase: inMemoryDb),
      contentRepository: SqliteContentRepository(appDatabase: inMemoryDb),
      noteRepository: SqliteNoteRepository(appDatabase: inMemoryDb),
      shoppingRepository: SqliteShoppingRepository(appDatabase: inMemoryDb),
    );
    await controller.loadWorkspace();
    return controller;
  }

  testWidgets('Burn Shut App Shell renders sidebar and empty workspace on first launch', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    late AppDatabase inMemoryDb;
    late WorkspaceController controller;

    await tester.runAsync(() async {
      inMemoryDb = await AppDatabase.createInMemory();
      controller = await createTestController(inMemoryDb);
    });

    await tester.pumpWidget(BurnShutApp(controller: controller));
    await tester.pump();

    // Verify Branding
    expect(find.text('Burn Shut'), findsWidgets);
    expect(find.text('Deep Work Workspace'), findsOneWidget);

    // Verify Sidebar navigation items
    expect(sidebarItem('Home'), findsOneWidget);
    expect(sidebarItem('Tasks'), findsOneWidget);
    expect(sidebarItem('Projects'), findsOneWidget);
    expect(sidebarItem('Workout'), findsOneWidget);
    expect(sidebarItem('Content'), findsOneWidget);
    expect(sidebarItem('Notes'), findsOneWidget);
    expect(sidebarItem('Shopping'), findsOneWidget);
    expect(sidebarItem('Completed'), findsOneWidget);
    expect(sidebarItem('Settings'), findsOneWidget);

    // Verify Empty Home State
    expect(find.text('Your workspace is empty.'), findsOneWidget);

    await tester.runAsync(() async {
      await inMemoryDb.close();
    });
  });

  testWidgets('Tasks navigation, creation, and completion workflow', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    late AppDatabase inMemoryDb;
    late WorkspaceController controller;

    await tester.runAsync(() async {
      inMemoryDb = await AppDatabase.createInMemory();
      controller = await createTestController(inMemoryDb);
    });

    await tester.pumpWidget(BurnShutApp(controller: controller));
    await tester.pump();

    // Tap Tasks in sidebar
    await tester.tap(sidebarItem('Tasks'));
    await tester.pump();

    // Verify Tasks view empty state
    expect(find.text('No tasks yet.'), findsOneWidget);

    // Create a task via controller
    await tester.runAsync(() async {
      await controller.createTask(title: 'Design architecture review');
    });
    await tester.pump();

    // Verify task is added to list
    expect(find.text('Design architecture review'), findsOneWidget);

    // Navigate to Home -> Tasks card should now display the task
    await tester.tap(sidebarItem('Home'));
    await tester.pump();
    expect(find.text('Design architecture review'), findsOneWidget);

    // Complete the task from Home
    await tester.runAsync(() async {
      await controller.completeTask(controller.activeTasks.first);
      ToastService.instance.dismiss();
    });
    await tester.pump();

    // Verify task is moved to Completed
    await tester.tap(sidebarItem('Completed'));
    await tester.pump();
    expect(find.text('Design architecture review'), findsOneWidget);
    expect(find.text('Task'), findsOneWidget);

    await tester.runAsync(() async {
      await inMemoryDb.close();
    });
  });

  testWidgets('Quick Add modal opens and dismisses cleanly', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    late AppDatabase inMemoryDb;
    late WorkspaceController controller;

    await tester.runAsync(() async {
      inMemoryDb = await AppDatabase.createInMemory();
      controller = await createTestController(inMemoryDb);
    });

    await tester.pumpWidget(BurnShutApp(controller: controller));
    await tester.pump();

    // Trigger Quick Add via controller
    controller.openQuickAdd();
    await tester.pump();

    expect(find.text('What is on your mind?'), findsOneWidget);

    // Close Quick Add
    await tester.tap(find.text('Cancel'));
    await tester.pump();

    expect(find.text('What is on your mind?'), findsNothing);

    await tester.runAsync(() async {
      await inMemoryDb.close();
    });
  });
}
