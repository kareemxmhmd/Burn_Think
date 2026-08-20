import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/radii.dart';
import '../../../core/constants/spacing.dart';
import '../../../domain/models/task.dart';
import '../../../domain/models/project.dart';
import '../../../domain/models/workout.dart';
import '../../../domain/models/content_item.dart';
import '../../../domain/models/note.dart';
import '../../../domain/models/shopping_item.dart';
import '../../state/workspace_controller.dart';
import '../../views/tasks/task_detail_panel.dart';
import '../../views/projects/project_detail_panel.dart';
import '../../views/workout/workout_detail_panel.dart';
import '../../views/content/content_detail_panel.dart';
import '../../views/notes/note_detail_panel.dart';
import '../../views/shopping/shopping_detail_panel.dart';
import '../glass/glass_surface.dart';

class DetailDrawer extends StatelessWidget {
  final WorkspaceController controller;

  const DetailDrawer({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final target = controller.detailTarget;
    if (target == null) return const SizedBox.shrink();

    Widget buildPanel() {
      switch (target.type) {
        case DetailType.task:
          return TaskDetailPanel(
            taskId: target.id,
            initialTask: target.initialData is Task ? target.initialData as Task : null,
            controller: controller,
          );
        case DetailType.project:
          return ProjectDetailPanel(
            projectId: target.id,
            initialProject: target.initialData is Project ? target.initialData as Project : null,
            controller: controller,
          );
        case DetailType.workout:
          return WorkoutDetailPanel(
            workoutId: target.id,
            initialWorkout: target.initialData is Workout ? target.initialData as Workout : null,
            controller: controller,
          );
        case DetailType.content:
          return ContentDetailPanel(
            contentId: target.id,
            initialContent: target.initialData is ContentItem ? target.initialData as ContentItem : null,
            controller: controller,
          );
        case DetailType.note:
          return NoteDetailPanel(
            noteId: target.id,
            initialNote: target.initialData is Note ? target.initialData as Note : null,
            controller: controller,
          );
        case DetailType.shopping:
          return ShoppingDetailPanel(
            itemId: target.id,
            initialItem: target.initialData is ShoppingItem ? target.initialData as ShoppingItem : null,
            controller: controller,
          );
      }
    }

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): controller.closeDetail,
      },
      child: Focus(
        autofocus: true,
        child: Stack(
          children: [
            // Scrim
            Positioned.fill(
              child: GestureDetector(
                onTap: controller.closeDetail,
                child: Container(
                  color: Colors.black.withValues(alpha: 0.45),
                ),
              ),
            ),

            // Slide-over drawer on right side
            Align(
              alignment: Alignment.centerRight,
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minWidth: 420,
                  maxWidth: 480,
                ),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutCubic,
                  builder: (context, val, child) {
                    return Transform.translate(
                      offset: Offset((1 - val) * 60, 0),
                      child: Opacity(opacity: val, child: child),
                    );
                  },
                  child: Container(
                    height: double.infinity,
                    margin: const EdgeInsets.only(top: 12, bottom: 12, right: 12),
                    child: GlassSurface(
                      level: GlassLevel.elevated,
                      borderRadius: AppRadii.radius20,
                      padding: AppSpacing.insets24,
                      child: buildPanel(),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
