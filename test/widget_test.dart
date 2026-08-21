import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:burn_shut/core/database/app_database.dart';
import 'package:burn_shut/data/repositories/sqlite_content_repository.dart';
import 'package:burn_shut/data/repositories/sqlite_note_repository.dart';
import 'package:burn_shut/data/repositories/sqlite_project_repository.dart';
import 'package:burn_shut/data/repositories/sqlite_shopping_repository.dart';
import 'package:burn_shut/data/repositories/sqlite_task_repository.dart';
import 'package:burn_shut/data/repositories/sqlite_workout_repository.dart';
import 'package:burn_shut/presentation/state/workspace_controller.dart';
import 'package:burn_shut/presentation/widgets/navigation/sidebar.dart';
import 'package:burn_shut/presentation/widgets/navigation/app_header.dart';
import 'package:burn_shut/presentation/views/home/widgets/home_overview_panel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Sidebar and AppHeader component rendering test', (WidgetTester tester) async {
    late AppDatabase db;
    late WorkspaceController controller;

    await tester.runAsync(() async {
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

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Row(
            children: [
              Sidebar(
                currentSection: AppSection.home,
                onSectionSelected: (_) {},
                controller: controller,
              ),
              Expanded(
                child: Column(
                  children: [
                    AppHeader(
                      currentSection: AppSection.home,
                      onSearchTap: () {},
                      onAddTap: () {},
                    ),
                    Expanded(
                      child: HomeOverviewPanel(controller: controller),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    await tester.pump();

    // Verify Branding
    expect(find.text('Burn Shut'), findsOneWidget);
    expect(find.text('Deep Workspace'), findsOneWidget);

    // Verify Sidebar Items
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Tasks'), findsWidgets);
    expect(find.text('Projects'), findsWidgets);
    expect(find.text('Settings'), findsOneWidget);

    // Verify Header Actions
    expect(find.text('Search'), findsOneWidget);
    expect(find.text('Offline'), findsOneWidget);

    await tester.runAsync(() async {
      await db.close();
    });
  });
}
