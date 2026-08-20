import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/colors.dart';
import '../presentation/state/workspace_controller.dart';
import '../presentation/views/completed/completed_view.dart';
import '../presentation/views/content/content_view.dart';
import '../presentation/views/home/home_view.dart';
import '../presentation/views/notes/notes_view.dart';
import '../presentation/views/projects/projects_view.dart';
import '../presentation/views/settings/settings_view.dart';
import '../presentation/views/shopping/shopping_view.dart';
import '../presentation/views/tasks/tasks_view.dart';
import '../presentation/views/workout/workout_view.dart';
import '../presentation/widgets/feedback/glass_toast.dart';
import '../presentation/widgets/modals/detail_drawer.dart';
import '../presentation/widgets/modals/quick_add_modal.dart';
import '../presentation/widgets/modals/search_modal.dart';
import '../presentation/widgets/navigation/app_header.dart';
import '../presentation/widgets/navigation/sidebar.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<WorkspaceController>();

    if (controller.isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.metallicSilver),
          ),
        ),
      );
    }

    Widget buildCurrentView() {
      switch (controller.currentSection) {
        case AppSection.home:
          return HomeView(controller: controller);
        case AppSection.tasks:
          return TasksView(controller: controller);
        case AppSection.projects:
          return ProjectsView(controller: controller);
        case AppSection.workout:
          return WorkoutView(controller: controller);
        case AppSection.content:
          return ContentView(controller: controller);
        case AppSection.notes:
          return NotesView(controller: controller);
        case AppSection.shopping:
          return ShoppingView(controller: controller);
        case AppSection.completed:
          return CompletedView(controller: controller);
        case AppSection.settings:
          return SettingsView(controller: controller);
      }
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Base Desktop Shell (Sidebar + Main Workspace)
          Row(
            children: [
              // Sidebar
              Sidebar(
                currentSection: controller.currentSection,
                onSectionSelected: controller.navigateTo,
                controller: controller,
              ),

              // Divider
              Container(
                width: 1,
                color: AppColors.glassBorderSubtle,
              ),

              // Main Workspace
              Expanded(
                child: Container(
                  color: AppColors.backgroundSecondary,
                  child: Column(
                    children: [
                      // Header
                      AppHeader(
                        currentSection: controller.currentSection,
                        onSearchTap: controller.openSearch,
                        onAddTap: controller.openQuickAdd,
                      ),

                      // Active View
                      Expanded(
                        child: buildCurrentView(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Contextual Detail Drawer Overlay
          if (controller.isDetailOpen)
            DetailDrawer(controller: controller),

          // Quick Add Modal Overlay
          if (controller.isQuickAddOpen)
            QuickAddModal(controller: controller),

          // Search Modal Overlay
          if (controller.isSearchOpen)
            SearchModal(workspaceController: controller),

          // Non-blocking Toast Notification System
          const GlassToastOverlay(),
        ],
      ),
    );
  }
}
