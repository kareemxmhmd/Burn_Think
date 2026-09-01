import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/radii.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../core/constants/typography.dart';
import '../../../state/workspace_controller.dart';
import '../../../widgets/glass/glass_surface.dart';

class HomeOverviewPanel extends StatelessWidget {
  final WorkspaceController controller;

  const HomeOverviewPanel({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final stats = controller.stats;
    final insights = controller.insights;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GlassSurface(
            level: GlassLevel.subtle,
            borderRadius: AppRadii.radius16,
            padding: AppSpacing.insets20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("TODAY'S OVERVIEW", style: AppTypography.sectionHeader),
                const SizedBox(height: AppSpacing.p16),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth > 600;
                    final crossAxisCount = isWide ? 6 : 3;

                    return GridView.count(
                      crossAxisCount: crossAxisCount,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: isWide ? 1.6 : 1.3,
                      children: [
                        _MetricTile(
                          count: '${stats.activeTasksCount}',
                          label: 'Tasks',
                          sublabel: '${stats.activeTasksCount} remaining',
                          onTap: () => controller.navigateTo(AppSection.tasks),
                        ),
                        _MetricTile(
                          count: '${stats.activeProjectsCount}',
                          label: 'Projects',
                          sublabel: '${stats.activeProjectsCount} active',
                          onTap: () => controller.navigateTo(AppSection.projects),
                        ),
                        _MetricTile(
                          count: '${stats.workoutsCount}',
                          label: 'Workout',
                          sublabel: controller.currentFocusWorkout != null ? 'Today' : 'None',
                          onTap: () => controller.navigateTo(AppSection.workout),
                        ),
                        _MetricTile(
                          count: '${stats.contentItemsCount}',
                          label: 'Content',
                          sublabel: 'In queue',
                          onTap: () => controller.navigateTo(AppSection.content),
                        ),
                        _MetricTile(
                          count: '${stats.notesCount}',
                          label: 'Notes',
                          sublabel: 'Saved',
                          onTap: () => controller.navigateTo(AppSection.notes),
                        ),
                        _MetricTile(
                          count: '${stats.shoppingItemsToBuyCount}',
                          label: 'Shopping',
                          sublabel: 'To buy',
                          onTap: () => controller.navigateTo(AppSection.shopping),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.p20),

          // Workspace Descriptive Insights (PRD §28)
          GlassSurface(
            level: GlassLevel.subtle,
            borderRadius: AppRadii.radius16,
            padding: AppSpacing.insets20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.analytics_outlined, size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 6),
                        Text('WORKSPACE INSIGHTS', style: AppTypography.sectionHeader.copyWith(fontSize: 11)),
                      ],
                    ),
                    Text(
                      'Offline Analytics',
                      style: AppTypography.caption.copyWith(color: AppColors.textTertiary, fontSize: 10.5),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.p16),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth > 550;
                    return isWide
                        ? Row(
                            children: [
                              Expanded(
                                child: _InsightStatItem(
                                  value: insights.averageTaskCompletionDays > 0
                                      ? '${insights.averageTaskCompletionDays}d'
                                      : '< 1d',
                                  label: 'Avg Task Completion',
                                  hint: 'Based on finished tasks',
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _InsightStatItem(
                                  value: '${insights.tasksCompletedThisWeek}',
                                  label: 'Completed This Week',
                                  hint: 'Past 7 days velocity',
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _InsightStatItem(
                                  value: '${insights.completionRate.toInt()}%',
                                  label: 'Completion Rate',
                                  hint: '${insights.totalCompletedItems} total finished',
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _InsightStatItem(
                                  value: insights.longestActiveTaskDays > 0
                                      ? '${insights.longestActiveTaskDays}d'
                                      : '0d',
                                  label: 'Longest Active Task',
                                  hint: insights.longestActiveTaskTitle ?? 'None',
                                ),
                              ),
                            ],
                          )
                        : Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              _InsightStatItem(
                                value: insights.averageTaskCompletionDays > 0
                                    ? '${insights.averageTaskCompletionDays}d'
                                    : '< 1d',
                                label: 'Avg Completion',
                                hint: 'Based on finished tasks',
                              ),
                              _InsightStatItem(
                                value: '${insights.tasksCompletedThisWeek}',
                                label: 'This Week',
                                hint: 'Past 7 days',
                              ),
                              _InsightStatItem(
                                value: '${insights.completionRate.toInt()}%',
                                label: 'Completion Rate',
                                hint: '${insights.totalCompletedItems} finished',
                              ),
                            ],
                          );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightStatItem extends StatelessWidget {
  final String value;
  final String label;
  final String hint;

  const _InsightStatItem({
    required this.value,
    required this.label,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.glassSubtle,
        borderRadius: AppRadii.radius10,
        border: Border.all(color: AppColors.glassBorderSubtle, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: AppTypography.cardTitle.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTypography.caption.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            hint,
            style: AppTypography.caption.copyWith(
              fontSize: 9.5,
              color: AppColors.textTertiary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatefulWidget {
  final String count;
  final String label;
  final String sublabel;
  final VoidCallback onTap;

  const _MetricTile({
    required this.count,
    required this.label,
    required this.sublabel,
    required this.onTap,
  });

  @override
  State<_MetricTile> createState() => _MetricTileState();
}

class _MetricTileState extends State<_MetricTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: _isHovered ? AppColors.glassHover : AppColors.glassSubtle,
            borderRadius: AppRadii.radius10,
            border: Border.all(
              color: _isHovered ? AppColors.glassBorderStrong : AppColors.glassBorderSubtle,
              width: 0.5,
            ),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.count,
                  style: AppTypography.cardTitle.copyWith(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  widget.label,
                  style: AppTypography.itemTitle.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  widget.sublabel,
                  style: AppTypography.caption.copyWith(
                    fontSize: 10,
                    color: AppColors.textTertiary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
