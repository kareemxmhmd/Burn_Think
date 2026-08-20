import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/colors.dart';
import '../data/repositories/sqlite_content_repository.dart';
import '../data/repositories/sqlite_note_repository.dart';
import '../data/repositories/sqlite_project_repository.dart';
import '../data/repositories/sqlite_shopping_repository.dart';
import '../data/repositories/sqlite_task_repository.dart';
import '../data/repositories/sqlite_workout_repository.dart';
import '../presentation/state/workspace_controller.dart';
import 'app_shell.dart';

class BurnShutApp extends StatelessWidget {
  final WorkspaceController? controller;

  const BurnShutApp({super.key, this.controller});

  Widget _buildMaterialApp() {
    return MaterialApp(
      title: 'Burn Shut',
      debugShowCheckedModeBanner: false,
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.mouse,
          PointerDeviceKind.touch,
          PointerDeviceKind.trackpad,
        },
      ),
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.dark(
          surface: AppColors.surfaceDark,
          primary: AppColors.metallicSilver,
          onPrimary: AppColors.background,
          secondary: AppColors.metallicSilver,
        ),
        fontFamily: 'Segoe UI',
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
      ),
      home: const AppShell(),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (controller != null) {
      return ChangeNotifierProvider<WorkspaceController>.value(
        value: controller!,
        child: _buildMaterialApp(),
      );
    }

    return ChangeNotifierProvider<WorkspaceController>(
      create: (_) {
        final ctrl = WorkspaceController(
          taskRepository: SqliteTaskRepository(),
          projectRepository: SqliteProjectRepository(),
          workoutRepository: SqliteWorkoutRepository(),
          contentRepository: SqliteContentRepository(),
          noteRepository: SqliteNoteRepository(),
          shoppingRepository: SqliteShoppingRepository(),
        );
        ctrl.loadWorkspace();
        return ctrl;
      },
      child: _buildMaterialApp(),
    );
  }
}
