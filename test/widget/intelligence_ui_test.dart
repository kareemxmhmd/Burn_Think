import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:burn_think/app/app.dart';
import 'package:burn_think/core/database/app_database.dart';
import 'package:burn_think/data/repositories/sqlite_content_repository.dart';
import 'package:burn_think/data/repositories/sqlite_ml_event_repository.dart';
import 'package:burn_think/data/repositories/sqlite_note_repository.dart';
import 'package:burn_think/data/repositories/sqlite_project_repository.dart';
import 'package:burn_think/data/repositories/sqlite_shopping_repository.dart';
import 'package:burn_think/data/repositories/sqlite_task_repository.dart';
import 'package:burn_think/data/repositories/sqlite_workout_repository.dart';
import 'package:burn_think/domain/models/task.dart';
import 'package:burn_think/presentation/state/workspace_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Intelligence UI: Quick Add shows smart categorization pill', (tester) async {
    late AppDatabase appDatabase;
    late WorkspaceController controller;

    await tester.runAsync(() async {
      appDatabase = await AppDatabase.createInMemory();
      controller = WorkspaceController(
        taskRepository: SqliteTaskRepository(appDatabase: appDatabase),
        projectRepository: SqliteProjectRepository(appDatabase: appDatabase),
        workoutRepository: SqliteWorkoutRepository(appDatabase: appDatabase),
        contentRepository: SqliteContentRepository(appDatabase: appDatabase),
        noteRepository: SqliteNoteRepository(appDatabase: appDatabase),
        shoppingRepository: SqliteShoppingRepository(appDatabase: appDatabase),
        mlEventRepository: SqliteMLEventRepository(appDatabase: appDatabase),
      );
      await controller.loadWorkspace();
    });

    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(BurnThinkApp(controller: controller));
    await tester.pump();

    controller.openQuickAdd();
    await tester.pump();

    // Find title textfield
    final titleField = find.byType(TextField).first;
    await tester.enterText(titleField, 'Buy fresh coffee and milk');
    await tester.pump();

    expect(find.textContaining('Suggested: Shopping'), findsOneWidget);

    await tester.runAsync(() async => appDatabase.close());
  });

  testWidgets('Intelligence UI: Home view renders Today Focus card', (tester) async {
    late AppDatabase appDatabase;
    late WorkspaceController controller;

    await tester.runAsync(() async {
      appDatabase = await AppDatabase.createInMemory();
      controller = WorkspaceController(
        taskRepository: SqliteTaskRepository(appDatabase: appDatabase),
        projectRepository: SqliteProjectRepository(appDatabase: appDatabase),
        workoutRepository: SqliteWorkoutRepository(appDatabase: appDatabase),
        contentRepository: SqliteContentRepository(appDatabase: appDatabase),
        noteRepository: SqliteNoteRepository(appDatabase: appDatabase),
        shoppingRepository: SqliteShoppingRepository(appDatabase: appDatabase),
        mlEventRepository: SqliteMLEventRepository(appDatabase: appDatabase),
      );
      await controller.loadWorkspace();
      await controller.createTask(
        title: 'Urgent ML review task',
        priority: TaskPriority.high,
      );
    });

    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(BurnThinkApp(controller: controller));
    await tester.pump();

    expect(find.text("TODAY'S FOCUS"), findsOneWidget);
    expect(find.text('Urgent ML review task'), findsAtLeastNWidgets(1));

    await tester.runAsync(() async => appDatabase.close());
  });

  testWidgets('Intelligence UI: Settings view renders Personal Intelligence toggles', (tester) async {
    late AppDatabase appDatabase;
    late WorkspaceController controller;

    await tester.runAsync(() async {
      appDatabase = await AppDatabase.createInMemory();
      controller = WorkspaceController(
        taskRepository: SqliteTaskRepository(appDatabase: appDatabase),
        projectRepository: SqliteProjectRepository(appDatabase: appDatabase),
        workoutRepository: SqliteWorkoutRepository(appDatabase: appDatabase),
        contentRepository: SqliteContentRepository(appDatabase: appDatabase),
        noteRepository: SqliteNoteRepository(appDatabase: appDatabase),
        shoppingRepository: SqliteShoppingRepository(appDatabase: appDatabase),
        mlEventRepository: SqliteMLEventRepository(appDatabase: appDatabase),
      );
      await controller.loadWorkspace();
    });

    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(BurnThinkApp(controller: controller));
    await tester.pump();

    controller.navigateTo(AppSection.settings);
    await tester.pump();

    expect(find.text('PERSONAL INTELLIGENCE'), findsOneWidget);
    expect(find.text('100% Local & Private'), findsOneWidget);
    expect(find.text('Smart Categorization'), findsOneWidget);
    expect(find.text("Today's Focus Prediction"), findsOneWidget);

    await tester.runAsync(() async => appDatabase.close());
  });
}
