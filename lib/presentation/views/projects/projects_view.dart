import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/spacing.dart';
import '../../../core/constants/typography.dart';
import '../../../core/utils/date_utils.dart';
import '../../../domain/models/project.dart';
import '../../state/workspace_controller.dart';
import '../../widgets/feedback/empty_state.dart';
import '../../widgets/feedback/progress_bar.dart';
import '../../widgets/glass/glass_button.dart';
import '../../widgets/glass/glass_card.dart';

class ProjectsView extends StatelessWidget {
  final WorkspaceController controller;

  const ProjectsView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final projects = controller.activeProjects;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p32, vertical: AppSpacing.p8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header action bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${projects.length} Active Projects',
                style: AppTypography.itemTitle.copyWith(color: AppColors.textSecondary),
              ),
              GlassButton.primary(
                icon: const Icon(Icons.add, size: 16, color: Color(0xFF08090A)),
                text: 'New Project',
                onPressed: () => controller.openDetail(DetailType.project),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.p20),

          // Projects Grid
          Expanded(
            child: projects.isEmpty
                ? EmptyState(
                    title: 'No active projects.',
                    subtitle: 'Organize your larger goals and milestones into focused projects.',
                    actionLabel: 'Create Project',
                    icon: Icons.layers_outlined,
                    onAction: () => controller.openDetail(DetailType.project),
                  )
                : LayoutBuilder(
                    builder: (context, constraints) {
                      final crossAxisCount = constraints.maxWidth > 800 ? 2 : 1;

                      return GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: crossAxisCount == 2 ? 1.8 : 2.2,
                        ),
                        itemCount: projects.length,
                        itemBuilder: (context, index) {
                          final project = projects[index];
                          return _ProjectGridCard(
                            project: project,
                            onTap: () => controller.openDetail(DetailType.project, project.id, project),
                            onComplete: () => controller.setProjectCompleted(project, true),
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

class _ProjectGridCard extends StatelessWidget {
  final Project project;
  final VoidCallback onTap;
  final VoidCallback onComplete;

  const _ProjectGridCard({
    required this.project,
    required this.onTap,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final progress = project.progress;
    final percent = project.progressPercent;
    final dueStr = project.dueDate != null
        ? AppDateUtils.formatDue(project.dueDate!)
        : '${project.items.length} items';

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
                  project.title,
                  style: AppTypography.cardTitle.copyWith(fontSize: 17),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.textTertiary),
            ],
          ),

          if (project.description != null && project.description!.isNotEmpty) ...[
            Text(
              project.description!,
              style: AppTypography.body.copyWith(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MetallicProgressBar(value: progress, height: 4),
              const SizedBox(height: AppSpacing.p8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$percent% Complete (${project.completedItemCount}/${project.totalItemCount})',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.metallicWhite,
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
