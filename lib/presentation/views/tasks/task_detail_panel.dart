import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/radii.dart';
import '../../../core/constants/spacing.dart';
import '../../../core/constants/typography.dart';
import '../../../core/utils/date_utils.dart';
import '../../../domain/models/task.dart';
import '../../state/workspace_controller.dart';
import '../../widgets/glass/glass_button.dart';
import '../../widgets/glass/glass_input.dart';
import '../../widgets/modals/confirm_dialog.dart';

class TaskDetailPanel extends StatefulWidget {
  final String? taskId;
  final Task? initialTask;
  final WorkspaceController controller;

  const TaskDetailPanel({
    super.key,
    this.taskId,
    this.initialTask,
    required this.controller,
  });

  @override
  State<TaskDetailPanel> createState() => _TaskDetailPanelState();
}

class _TaskDetailPanelState extends State<TaskDetailPanel> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late TaskPriority _priority;
  DateTime? _dueDate;
  String? _projectId;
  bool _isCompleted = false;

  Task? _currentTask;

  @override
  void initState() {
    super.initState();
    _currentTask = widget.initialTask ??
        widget.controller.activeTasks.where((t) => t.id == widget.taskId).firstOrNull ??
        widget.controller.completedTasks.where((t) => t.id == widget.taskId).firstOrNull;

    _titleController = TextEditingController(text: _currentTask?.title ?? '');
    _descriptionController = TextEditingController(text: _currentTask?.description ?? '');
    _priority = _currentTask?.priority ?? TaskPriority.none;
    _dueDate = _currentTask?.dueDate;
    _projectId = _currentTask?.projectId;
    _isCompleted = _currentTask?.isCompleted ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    if (_currentTask != null) {
      final updated = _currentTask!.copyWith(
        title: title,
        description: _descriptionController.text.trim(),
        priority: _priority,
        dueDate: _dueDate,
        projectId: _projectId,
      );
      await widget.controller.updateTask(updated);
    } else {
      await widget.controller.createTask(
        title: title,
        description: _descriptionController.text.trim(),
        priority: _priority,
        dueDate: _dueDate,
        projectId: _projectId,
      );
    }
    widget.controller.closeDetail();
  }

  Future<void> _handleDelete() async {
    if (_currentTask == null) return;
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Delete Task',
      message: 'Are you sure you want to delete "${_currentTask!.title}"? This cannot be undone.',
    );
    if (confirmed == true && mounted) {
      await widget.controller.deleteTask(_currentTask!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Panel Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.check_box_outlined, size: 18, color: AppColors.textSecondary),
                const SizedBox(width: AppSpacing.p8),
                Text(
                  _currentTask == null ? 'New Task' : 'Task Details',
                  style: AppTypography.cardTitle,
                ),
              ],
            ),
            GlassIconButton(
              icon: const Icon(Icons.close, size: 16),
              onPressed: widget.controller.closeDetail,
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.p20),

        // Body
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                GlassTextField(
                  controller: _titleController,
                  labelText: 'TITLE',
                  hintText: 'Task title...',
                ),

                const SizedBox(height: AppSpacing.p16),

                // Description
                GlassTextField(
                  controller: _descriptionController,
                  labelText: 'DESCRIPTION',
                  hintText: 'Notes, context, or links...',
                  maxLines: 4,
                ),

                const SizedBox(height: AppSpacing.p16),

                // Priority
                const Text('PRIORITY', style: AppTypography.sectionHeader),
                const SizedBox(height: AppSpacing.p8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.glassSubtle,
                    borderRadius: AppRadii.radius10,
                    border: Border.all(color: AppColors.glassBorderSubtle, width: 1.0),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<TaskPriority>(
                      value: _priority,
                      dropdownColor: AppColors.surfaceDark,
                      isExpanded: true,
                      style: AppTypography.itemTitle.copyWith(fontSize: 13),
                      icon: const Icon(Icons.arrow_drop_down, color: AppColors.textTertiary),
                      items: TaskPriority.values.map((p) {
                        return DropdownMenuItem(
                          value: p,
                          child: Text(p.label),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _priority = val);
                      },
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.p16),

                // Project association
                const Text('PROJECT', style: AppTypography.sectionHeader),
                const SizedBox(height: AppSpacing.p8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.glassSubtle,
                    borderRadius: AppRadii.radius10,
                    border: Border.all(color: AppColors.glassBorderSubtle, width: 1.0),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String?>(
                      value: _projectId,
                      dropdownColor: AppColors.surfaceDark,
                      isExpanded: true,
                      style: AppTypography.itemTitle.copyWith(fontSize: 13),
                      icon: const Icon(Icons.arrow_drop_down, color: AppColors.textTertiary),
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('None', style: TextStyle(color: AppColors.textTertiary)),
                        ),
                        ...widget.controller.activeProjects.map((p) {
                          return DropdownMenuItem<String?>(
                            value: p.id,
                            child: Text(p.title, overflow: TextOverflow.ellipsis),
                          );
                        }),
                      ],
                      onChanged: (val) => setState(() => _projectId = val),
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.p16),

                // Metadata
                if (_currentTask != null) ...[
                  Container(
                    padding: AppSpacing.insets12,
                    decoration: BoxDecoration(
                      color: AppColors.glassSubtle,
                      borderRadius: AppRadii.radius10,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Created: ${AppDateUtils.formatDateTime(_currentTask!.createdAt)}',
                          style: AppTypography.caption,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Status: ${_isCompleted ? "Completed" : "Active"}',
                          style: AppTypography.caption,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.p16),

        // Footer
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (_currentTask != null)
              GlassIconButton(
                icon: const Icon(Icons.delete_outline, size: 16, color: AppColors.danger),
                tooltip: 'Delete Task',
                onPressed: _handleDelete,
              )
            else
              const SizedBox.shrink(),
            Row(
              children: [
                GlassButton(
                  text: 'Cancel',
                  onPressed: widget.controller.closeDetail,
                ),
                const SizedBox(width: AppSpacing.p12),
                GlassButton.primary(
                  text: 'Save',
                  onPressed: _handleSave,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
