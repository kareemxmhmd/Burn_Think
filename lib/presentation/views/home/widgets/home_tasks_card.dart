import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/radii.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../core/constants/typography.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../domain/models/task.dart';
import '../../../state/workspace_controller.dart';
import '../../../widgets/glass/glass_card.dart';

class HomeTasksCard extends StatelessWidget {
  final WorkspaceController controller;

  const HomeTasksCard({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final activeTasks = controller.activeTasks.take(4).toList();
    final count = controller.activeTasks.length;

    return GlassCard(
      padding: AppSpacing.insets20,
      onTap: () => controller.navigateTo(AppSection.tasks),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.check_box_outlined, size: 16, color: AppColors.textTertiary),
                  const SizedBox(width: AppSpacing.p8),
                  Text(
                    'TASKS',
                    style: AppTypography.sectionHeader,
                  ),
                ],
              ),
              Text(
                '$count Active',
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.p16),

          if (activeTasks.isEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.p16),
              child: Text(
                'No active tasks. Tap + to add something.',
                style: AppTypography.caption.copyWith(color: AppColors.textTertiary),
              ),
            ),
          ] else ...[
            ...activeTasks.map((task) {
              return _HomeTaskRow(
                task: task,
                onComplete: () => controller.completeTask(task),
                onTap: () => controller.openDetail(DetailType.task, task.id, task),
              );
            }),
          ],
        ],
      ),
    );
  }
}

class _HomeTaskRow extends StatefulWidget {
  final Task task;
  final VoidCallback onComplete;
  final VoidCallback onTap;

  const _HomeTaskRow({
    required this.task,
    required this.onComplete,
    required this.onTap,
  });

  @override
  State<_HomeTaskRow> createState() => _HomeTaskRowState();
}

class _HomeTaskRowState extends State<_HomeTaskRow> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    String getMetadata() {
      final parts = <String>[];
      if (widget.task.dueDate != null) {
        parts.add(AppDateUtils.formatDue(widget.task.dueDate!));
      }
      if (widget.task.projectName != null) {
        parts.add(widget.task.projectName!);
      }
      if (widget.task.priority != TaskPriority.none) {
        parts.add('${widget.task.priority.label} Priority');
      }
      return parts.join(' • ');
    }

    final metadata = getMetadata();

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: _isHovered ? AppColors.glassHover : Colors.transparent,
            borderRadius: AppRadii.radius8,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: widget.onComplete,
                child: Container(
                  width: 17,
                  height: 17,
                  margin: const EdgeInsets.only(top: 2),
                  decoration: BoxDecoration(
                    color: AppColors.glassSubtle,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: AppColors.glassBorderStrong,
                      width: 1.2,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.p12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.task.title,
                      style: AppTypography.itemTitle.copyWith(fontSize: 13.5),
                    ),
                    if (metadata.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        metadata,
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textTertiary,
                          fontSize: 11.0,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
