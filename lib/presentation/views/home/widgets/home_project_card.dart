import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../core/constants/typography.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../state/workspace_controller.dart';
import '../../../widgets/feedback/progress_bar.dart';
import '../../../widgets/glass/glass_card.dart';

class HomeProjectCard extends StatelessWidget {
  final WorkspaceController controller;

  const HomeProjectCard({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    // Current focus project or first active project
    final currentProject = controller.activeProjects.firstOrNull;

    if (currentProject == null) {
      return GlassCard(
        padding: AppSpacing.insets20,
        onTap: () => controller.navigateTo(AppSection.projects),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('CURRENT FOCUS', style: AppTypography.sectionHeader),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.p20),
              child: Text(
                'No active projects.\nCreate a project to track your focus.',
                style: AppTypography.caption.copyWith(color: AppColors.textTertiary),
              ),
            ),
            Text(
              '0 Projects',
              style: AppTypography.caption.copyWith(color: AppColors.textDisabled),
            ),
          ],
        ),
      );
    }

    final progress = currentProject.progress;
    final percent = currentProject.progressPercent;
    final dueStr = currentProject.dueDate != null
        ? AppDateUtils.formatDue(currentProject.dueDate!)
        : '${currentProject.items.length} items';

    return GlassCard(
      padding: AppSpacing.insets20,
      onTap: () => controller.openDetail(DetailType.project, currentProject.id, currentProject),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('CURRENT FOCUS', style: AppTypography.sectionHeader),
              const Icon(Icons.layers_outlined, size: 14, color: AppColors.textTertiary),
            ],
          ),

          const SizedBox(height: AppSpacing.p16),

          Text(
            currentProject.title,
            style: AppTypography.cardTitle.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: AppSpacing.p20),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MetallicProgressBar(value: progress, height: 4),
              const SizedBox(height: AppSpacing.p8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$percent% Complete',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    dueStr,
                    style: AppTypography.caption.copyWith(color: AppColors.textTertiary),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
