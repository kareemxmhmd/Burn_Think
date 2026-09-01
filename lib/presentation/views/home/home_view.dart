import 'package:flutter/material.dart';
import '../../../core/constants/spacing.dart';
import '../../state/workspace_controller.dart';
import '../../widgets/feedback/empty_state.dart';
import 'widgets/home_content_card.dart';
import 'widgets/home_focus_card.dart';
import 'widgets/home_overview_panel.dart';
import 'widgets/home_project_card.dart';
import 'widgets/home_quick_note_card.dart';
import 'widgets/home_shopping_card.dart';
import 'widgets/home_tasks_card.dart';
import 'widgets/home_workout_card.dart';

class HomeView extends StatelessWidget {
  final WorkspaceController controller;

  const HomeView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    // Check if entire workspace is completely empty for clean first launch state
    final isCompletelyEmpty = controller.activeTasks.isEmpty &&
        controller.completedTasks.isEmpty &&
        controller.activeProjects.isEmpty &&
        controller.allWorkouts.isEmpty &&
        controller.contentItems.isEmpty &&
        controller.notes.isEmpty &&
        controller.toBuyShoppingItems.isEmpty;

    if (isCompletelyEmpty) {
      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: EmptyState(
            title: 'Your workspace is empty.',
            subtitle: 'Add something you want to do, remember, create, or keep.',
            actionLabel: 'Add something',
            icon: Icons.dashboard_outlined,
            onAction: controller.openQuickAdd,
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 860;
        final hasFocusItems = controller.todaysFocus.isNotEmpty;

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p32, vertical: AppSpacing.p8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row 0: Today's Focus Card (if recommended items exist)
              if (hasFocusItems) ...[
                HomeFocusCard(controller: controller),
                const SizedBox(height: AppSpacing.p20),
              ],

              // Row 1: Tasks & Current Focus Project
              if (isWide) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: HomeTasksCard(controller: controller),
                    ),
                    const SizedBox(width: AppSpacing.p20),
                    Expanded(
                      flex: 2,
                      child: HomeProjectCard(controller: controller),
                    ),
                  ],
                ),
              ] else ...[
                HomeTasksCard(controller: controller),
                const SizedBox(height: AppSpacing.p16),
                HomeProjectCard(controller: controller),
              ],

              const SizedBox(height: AppSpacing.p20),

              // Row 2: Content Queue, Workout, and Quick Note / Shopping
              if (isWide) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: HomeContentCard(controller: controller),
                    ),
                    const SizedBox(width: AppSpacing.p20),
                    Expanded(
                      flex: 2,
                      child: HomeWorkoutCard(controller: controller),
                    ),
                    const SizedBox(width: AppSpacing.p20),
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          HomeQuickNoteCard(controller: controller),
                          const SizedBox(height: AppSpacing.p12),
                          HomeShoppingCard(controller: controller),
                        ],
                      ),
                    ),
                  ],
                ),
              ] else ...[
                HomeContentCard(controller: controller),
                const SizedBox(height: AppSpacing.p16),
                HomeWorkoutCard(controller: controller),
                const SizedBox(height: AppSpacing.p16),
                HomeQuickNoteCard(controller: controller),
                const SizedBox(height: AppSpacing.p16),
                HomeShoppingCard(controller: controller),
              ],

              const SizedBox(height: AppSpacing.p24),

              // Row 3: Today's Overview Panel & Insights
              HomeOverviewPanel(controller: controller),

              const SizedBox(height: AppSpacing.p32),
            ],
          ),
        );
      },
    );
  }
}
