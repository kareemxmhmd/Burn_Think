import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/radii.dart';
import '../../../core/constants/spacing.dart';
import '../../../core/constants/typography.dart';
import '../../../core/utils/date_utils.dart';
import '../../../domain/models/task.dart';
import '../../state/workspace_controller.dart';
import '../../widgets/feedback/empty_state.dart';
import '../../widgets/glass/glass_button.dart';
import '../../widgets/glass/glass_card.dart';
import '../../widgets/glass/glass_input.dart';

class TasksView extends StatefulWidget {
  final WorkspaceController controller;

  const TasksView({super.key, required this.controller});

  @override
  State<TasksView> createState() => _TasksViewState();
}

class _TasksViewState extends State<TasksView> {
  final _quickInputController = TextEditingController();
  TaskPriority? _priorityFilter;
  String? _projectFilter;

  @override
  void dispose() {
    _quickInputController.dispose();
    super.dispose();
  }

  Future<void> _handleQuickAdd() async {
    final text = _quickInputController.text.trim();
    if (text.isEmpty) return;
    await widget.controller.createTask(
      title: text,
      priority: _priorityFilter ?? TaskPriority.none,
      projectId: _projectFilter,
    );
    _quickInputController.clear();
  }

  @override
  Widget build(BuildContext context) {
    var tasks = widget.controller.activeTasks;

    if (_priorityFilter != null) {
      tasks = tasks.where((t) => t.priority == _priorityFilter).toList();
    }
    if (_projectFilter != null) {
      tasks = tasks.where((t) => t.projectId == _projectFilter).toList();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p32, vertical: AppSpacing.p8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick inline creation bar
          Row(
            children: [
              Expanded(
                child: GlassTextField(
                  controller: _quickInputController,
                  hintText: 'Add a new task and press Enter...',
                  prefixIcon: const Icon(Icons.add, size: 16),
                  onSubmitted: (_) => _handleQuickAdd(),
                ),
              ),
              const SizedBox(width: AppSpacing.p12),
              GlassButton.primary(
                text: 'Add Task',
                onPressed: _handleQuickAdd,
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.p16),

          // Filters Bar
          Row(
            children: [
              _FilterPill(
                label: 'All Priorities',
                isSelected: _priorityFilter == null,
                onTap: () => setState(() => _priorityFilter = null),
              ),
              const SizedBox(width: AppSpacing.p8),
              _FilterPill(
                label: 'High',
                isSelected: _priorityFilter == TaskPriority.high,
                onTap: () => setState(() => _priorityFilter = TaskPriority.high),
              ),
              const SizedBox(width: AppSpacing.p8),
              _FilterPill(
                label: 'Medium',
                isSelected: _priorityFilter == TaskPriority.medium,
                onTap: () => setState(() => _priorityFilter = TaskPriority.medium),
              ),
              const SizedBox(width: AppSpacing.p8),
              _FilterPill(
                label: 'Low',
                isSelected: _priorityFilter == TaskPriority.low,
                onTap: () => setState(() => _priorityFilter = TaskPriority.low),
              ),
              const Spacer(),
              if (widget.controller.activeProjects.isNotEmpty)
                DropdownButtonHideUnderline(
                  child: DropdownButton<String?>(
                    value: _projectFilter,
                    dropdownColor: AppColors.surfaceDark,
                    style: AppTypography.caption.copyWith(color: AppColors.textPrimary),
                    icon: const Icon(Icons.arrow_drop_down, color: AppColors.textTertiary, size: 16),
                    hint: Text(
                      'Filter by Project',
                      style: AppTypography.caption.copyWith(color: AppColors.textTertiary),
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('All Projects'),
                      ),
                      ...widget.controller.activeProjects.map((p) {
                        return DropdownMenuItem(
                          value: p.id,
                          child: Text(p.title),
                        );
                      }),
                    ],
                    onChanged: (val) => setState(() => _projectFilter = val),
                  ),
                ),
            ],
          ),

          const SizedBox(height: AppSpacing.p20),

          // Task List
          Expanded(
            child: tasks.isEmpty
                ? EmptyState(
                    title: 'No tasks yet.',
                    subtitle: 'Add something you want to finish.',
                    actionLabel: 'Add Task',
                    icon: Icons.check_box_outlined,
                    onAction: () => widget.controller.openDetail(DetailType.task),
                  )
                : ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return _TaskRowCard(
                        task: task,
                        onComplete: () => widget.controller.completeTask(task),
                        onTap: () => widget.controller.openDetail(DetailType.task, task.id, task),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterPill({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.glassElevated : AppColors.glassSubtle,
          borderRadius: AppRadii.radius8,
          border: Border.all(
            color: isSelected ? AppColors.glassBorderStrong : AppColors.glassBorderSubtle,
            width: 1.0,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.caption.copyWith(
            color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

class _TaskRowCard extends StatelessWidget {
  final Task task;
  final VoidCallback onComplete;
  final VoidCallback onTap;

  const _TaskRowCard({
    required this.task,
    required this.onComplete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    String getMetadata() {
      final parts = <String>[];
      if (task.dueDate != null) {
        parts.add(AppDateUtils.formatDue(task.dueDate!));
      }
      if (task.projectName != null) {
        parts.add(task.projectName!);
      }
      if (task.priority != TaskPriority.none) {
        parts.add('${task.priority.label} Priority');
      }
      return parts.join(' • ');
    }

    final metadata = getMetadata();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p16, vertical: AppSpacing.p12),
        onTap: onTap,
        child: Row(
          children: [
            GestureDetector(
              onTap: onComplete,
              child: Container(
                width: 18,
                height: 18,
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
            const SizedBox(width: AppSpacing.p16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: AppTypography.itemTitle.copyWith(fontSize: 14.5),
                  ),
                  if (metadata.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      metadata,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textTertiary,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (task.priority == TaskPriority.high)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.glassSubtle,
                  borderRadius: AppRadii.radius8,
                  border: Border.all(color: AppColors.glassBorderSubtle, width: 0.5),
                ),
                child: Text(
                  'High',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.metallicWhite,
                    fontWeight: FontWeight.w600,
                    fontSize: 10.5,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
