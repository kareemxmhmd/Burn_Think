import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/radii.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../core/constants/typography.dart';
import '../../../../domain/models/task.dart';
import '../../../state/workspace_controller.dart';
import '../../../widgets/glass/glass_card.dart';

class HomeFocusCard extends StatelessWidget {
  final WorkspaceController controller;

  const HomeFocusCard({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final focusItems = controller.todaysFocus;
    if (focusItems.isEmpty) return const SizedBox.shrink();

    return GlassCard(
      padding: AppSpacing.insets16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.auto_awesome, size: 14, color: AppColors.metallicWhite),
                  const SizedBox(width: 6),
                  Text(
                    "TODAY'S FOCUS",
                    style: AppTypography.sectionHeader.copyWith(color: AppColors.metallicWhite),
                  ),
                ],
              ),
              Text(
                '${focusItems.length} recommended',
                style: AppTypography.caption.copyWith(color: AppColors.textTertiary, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.p12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: focusItems.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final focus = focusItems[index];
              return _FocusTaskRow(
                focus: focus,
                onComplete: () => controller.completeTask(focus.task),
                onTap: () => controller.openDetail(DetailType.task, focus.task.id),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _FocusTaskRow extends StatefulWidget {
  final dynamic focus;
  final VoidCallback onComplete;
  final VoidCallback onTap;

  const _FocusTaskRow({
    required this.focus,
    required this.onComplete,
    required this.onTap,
  });

  @override
  State<_FocusTaskRow> createState() => _FocusTaskRowState();
}

class _FocusTaskRowState extends State<_FocusTaskRow> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final task = widget.focus.task as Task;
    final reason = widget.focus.focusReason as String;

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
          child: Row(
            children: [
              GestureDetector(
                onTap: widget.onComplete,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: AppColors.glassSubtle,
                    borderRadius: AppRadii.radius8,
                    border: Border.all(color: AppColors.glassBorderStrong, width: 1.0),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.p12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: AppTypography.itemTitle.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      reason,
                      style: AppTypography.caption.copyWith(
                        fontSize: 10.5,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              if (task.priority != TaskPriority.none)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.glassSubtle,
                    borderRadius: AppRadii.radius8,
                  ),
                  child: Text(
                    task.priority.label,
                    style: AppTypography.caption.copyWith(fontSize: 10, color: AppColors.textSecondary),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
