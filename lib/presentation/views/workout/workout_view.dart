import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/radii.dart';
import '../../../core/constants/spacing.dart';
import '../../../core/constants/typography.dart';
import '../../../domain/models/workout.dart';
import '../../state/workspace_controller.dart';
import '../../widgets/feedback/empty_state.dart';
import '../../widgets/glass/glass_button.dart';
import '../../widgets/glass/glass_card.dart';

class WorkoutView extends StatelessWidget {
  final WorkspaceController controller;

  const WorkoutView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final workouts = controller.allWorkouts;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p32, vertical: AppSpacing.p8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${workouts.length} Workout Routines',
                style: AppTypography.itemTitle.copyWith(color: AppColors.textSecondary),
              ),
              GlassButton.primary(
                icon: const Icon(Icons.add, size: 16, color: Color(0xFF08090A)),
                text: 'New Routine',
                onPressed: () => controller.openDetail(DetailType.workout),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.p20),

          // Workout Grid
          Expanded(
            child: workouts.isEmpty
                ? EmptyState(
                    title: 'No workouts yet.',
                    subtitle: 'Create a routine (e.g. Upper Body, 3x10 Bench Press).',
                    actionLabel: 'Create Routine',
                    icon: Icons.fitness_center_outlined,
                    onAction: () => controller.openDetail(DetailType.workout),
                  )
                : LayoutBuilder(
                    builder: (context, constraints) {
                      final crossAxisCount = constraints.maxWidth > 800 ? 2 : 1;

                      return GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: crossAxisCount == 2 ? 1.7 : 2.0,
                        ),
                        itemCount: workouts.length,
                        itemBuilder: (context, index) {
                          final workout = workouts[index];
                          return _WorkoutGridCard(
                            workout: workout,
                            onTap: () => controller.openDetail(DetailType.workout, workout.id, workout),
                            onSetFocus: () => controller.setFocusWorkout(workout.id),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _WorkoutGridCard extends StatelessWidget {
  final Workout workout;
  final VoidCallback onTap;
  final VoidCallback onSetFocus;

  const _WorkoutGridCard({
    required this.workout,
    required this.onTap,
    required this.onSetFocus,
  });

  @override
  Widget build(BuildContext context) {
    final exercisesPreview = workout.exercises.take(3).map((e) => e.name).join(', ');

    return GlassCard(
      padding: AppSpacing.insets20,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  workout.name,
                  style: AppTypography.cardTitle.copyWith(fontSize: 17),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (workout.isCurrentFocus)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.glassElevated,
                    borderRadius: AppRadii.radius8,
                    border: Border.all(color: AppColors.glassBorderStrong, width: 1.0),
                  ),
                  child: Text(
                    '● Focus',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.metallicWhite,
                      fontWeight: FontWeight.w600,
                      fontSize: 10.5,
                    ),
                  ),
                ),
            ],
          ),

          if (workout.exercises.isNotEmpty) ...[
            Text(
              exercisesPreview + (workout.exercises.length > 3 ? '...' : ''),
              style: AppTypography.body.copyWith(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ] else ...[
            Text(
              'No exercises added yet.',
              style: AppTypography.caption.copyWith(color: AppColors.textTertiary),
            ),
          ],

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${workout.targetTime ?? "Flexible"} • ${workout.estimatedDurationMinutes ?? 45} mins',
                style: AppTypography.caption.copyWith(color: AppColors.textTertiary),
              ),
              Text(
                '${workout.exercises.length} exercises',
                style: AppTypography.caption.copyWith(
                  color: AppColors.metallicWhite,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
