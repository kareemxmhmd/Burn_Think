import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../core/constants/typography.dart';
import '../../../state/workspace_controller.dart';
import '../../../widgets/glass/glass_card.dart';

class HomeWorkoutCard extends StatelessWidget {
  final WorkspaceController controller;

  const HomeWorkoutCard({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final workout = controller.currentFocusWorkout;

    if (workout == null) {
      return GlassCard(
        padding: AppSpacing.insets20,
        onTap: () => controller.navigateTo(AppSection.workout),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('WORKOUT', style: AppTypography.sectionHeader),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.p16),
              child: Text(
                'No workout set for today.',
                style: AppTypography.caption.copyWith(color: AppColors.textTertiary),
              ),
            ),
            Text(
              'Create routine',
              style: AppTypography.caption.copyWith(color: AppColors.textDisabled),
            ),
          ],
        ),
      );
    }

    final timeStr = workout.targetTime ?? 'Today';
    final durStr = workout.estimatedDurationMinutes != null
        ? '${workout.estimatedDurationMinutes} mins'
        : '${workout.exercises.length} exercises';

    return GlassCard(
      padding: AppSpacing.insets20,
      onTap: () => controller.openDetail(DetailType.workout, workout.id, workout),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('WORKOUT', style: AppTypography.sectionHeader),
              const Icon(Icons.fitness_center_outlined, size: 14, color: AppColors.textTertiary),
            ],
          ),

          const SizedBox(height: AppSpacing.p12),

          Text(
            workout.name,
            style: AppTypography.cardTitle.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: AppSpacing.p16),

          Text(
            '$timeStr • $durStr',
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
