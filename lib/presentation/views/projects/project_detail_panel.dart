import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/radii.dart';
import '../../../core/constants/spacing.dart';
import '../../../core/constants/typography.dart';
import '../../../domain/models/project.dart';
import '../../state/workspace_controller.dart';
import '../../widgets/feedback/progress_bar.dart';
import '../../widgets/glass/glass_button.dart';
import '../../widgets/glass/glass_input.dart';
import '../../widgets/modals/confirm_dialog.dart';

class ProjectDetailPanel extends StatefulWidget {
  final String? projectId;
  final Project? initialProject;
  final WorkspaceController controller;

  const ProjectDetailPanel({
    super.key,
    this.projectId,
    this.initialProject,
    required this.controller,
  });

  @override
  State<ProjectDetailPanel> createState() => _ProjectDetailPanelState();
}

class _ProjectDetailPanelState extends State<ProjectDetailPanel> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  final _newItemController = TextEditingController();

  Project? _currentProject;

  @override
  void initState() {
    super.initState();
    _currentProject = widget.initialProject ??
        widget.controller.activeProjects.where((p) => p.id == widget.projectId).firstOrNull ??
        widget.controller.completedProjects.where((p) => p.id == widget.projectId).firstOrNull;

    _titleController = TextEditingController(text: _currentProject?.title ?? '');
    _descriptionController = TextEditingController(text: _currentProject?.description ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _newItemController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    if (_currentProject != null) {
      final updated = _currentProject!.copyWith(
        title: title,
        description: _descriptionController.text.trim(),
      );
      await widget.controller.updateProject(updated);
    } else {
      await widget.controller.createProject(
        title: title,
        description: _descriptionController.text.trim(),
      );
    }
    widget.controller.closeDetail();
  }

  Future<void> _handleAddItem() async {
    final text = _newItemController.text.trim();
    if (text.isEmpty) return;

    if (_currentProject == null) {
      final title = _titleController.text.trim();
      final projectTitle = title.isNotEmpty ? title : 'New Project';
      final newProj = await widget.controller.createProject(
        title: projectTitle,
        description: _descriptionController.text.trim(),
      );
      _currentProject = newProj;
    }

    await widget.controller.addProjectItem(_currentProject!.id, text);
    _newItemController.clear();
    // Update local reference from controller
    setState(() {
      _currentProject = widget.controller.activeProjects
          .where((p) => p.id == _currentProject!.id)
          .firstOrNull;
    });
  }

  Future<void> _handleDelete() async {
    if (_currentProject == null) return;
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Delete Project',
      message:
          'Are you sure you want to delete "${_currentProject!.title}" and all its items? Associated tasks will be detached.',
    );
    if (confirmed == true && mounted) {
      await widget.controller.deleteProject(_currentProject!);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Keep project items refreshed
    final latestProject = _currentProject != null
        ? widget.controller.activeProjects
                .where((p) => p.id == _currentProject!.id)
                .firstOrNull ??
            widget.controller.completedProjects
                .where((p) => p.id == _currentProject!.id)
                .firstOrNull ??
            _currentProject
        : null;

    final progress = latestProject?.progress ?? 0.0;
    final progressPercent = latestProject?.progressPercent ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.layers_outlined, size: 18, color: AppColors.textSecondary),
                const SizedBox(width: AppSpacing.p8),
                Text(
                  _currentProject == null ? 'New Project' : 'Project Details',
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
                GlassTextField(
                  controller: _titleController,
                  labelText: 'TITLE',
                  hintText: 'Project name...',
                ),

                const SizedBox(height: AppSpacing.p16),

                GlassTextField(
                  controller: _descriptionController,
                  labelText: 'DESCRIPTION',
                  hintText: 'Project scope, goals, or summary...',
                  maxLines: 3,
                ),

                if (latestProject != null) ...[
                  const SizedBox(height: AppSpacing.p20),

                  // Progress Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('PROGRESS', style: AppTypography.sectionHeader),
                      Text(
                        '$progressPercent% (${latestProject.completedItemCount}/${latestProject.totalItemCount})',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.metallicWhite,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.p8),
                  MetallicProgressBar(value: progress, height: 6),

                  const SizedBox(height: AppSpacing.p24),

                  // Project Items Checklist
                  const Text('ITEMS', style: AppTypography.sectionHeader),
                  const SizedBox(height: AppSpacing.p8),

                  // New item input
                  Row(
                    children: [
                      Expanded(
                        child: GlassTextField(
                          controller: _newItemController,
                          hintText: 'Add an item (e.g. Train model)...',
                          onSubmitted: (_) => _handleAddItem(),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.p8),
                      GlassIconButton(
                        icon: const Icon(Icons.add, size: 16),
                        tooltip: 'Add Item',
                        onPressed: _handleAddItem,
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.p12),

                  if (latestProject.items.isEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.p12),
                      child: Text(
                        'No project items yet. Add pieces of work above.',
                        style: AppTypography.caption.copyWith(color: AppColors.textTertiary),
                      ),
                    ),
                  ] else ...[
                    ...latestProject.items.map((item) {
                      return _ProjectItemRow(
                        item: item,
                        onToggle: (val) async {
                          await widget.controller.toggleProjectItem(item, val);
                        },
                        onDelete: () async {
                          await widget.controller.deleteProjectItem(item);
                        },
                      );
                    }),
                  ],
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
            if (_currentProject != null)
              GlassIconButton(
                icon: const Icon(Icons.delete_outline, size: 16, color: AppColors.danger),
                tooltip: 'Delete Project',
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

class _ProjectItemRow extends StatefulWidget {
  final ProjectItem item;
  final ValueChanged<bool> onToggle;
  final VoidCallback onDelete;

  const _ProjectItemRow({
    required this.item,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  State<_ProjectItemRow> createState() => _ProjectItemRowState();
}

class _ProjectItemRowState extends State<_ProjectItemRow> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p8, vertical: 6),
        decoration: BoxDecoration(
          color: _isHovered ? AppColors.glassHover : AppColors.glassSubtle,
          borderRadius: AppRadii.radius8,
          border: Border.all(
            color: _isHovered ? AppColors.glassBorderStandard : AppColors.glassBorderSubtle,
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => widget.onToggle(!widget.item.isCompleted),
              child: Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: widget.item.isCompleted ? AppColors.metallicWhite : AppColors.glassSubtle,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: widget.item.isCompleted ? AppColors.metallicWhite : AppColors.glassBorderStrong,
                    width: 1.2,
                  ),
                ),
                child: widget.item.isCompleted
                    ? const Icon(Icons.check, size: 13, color: Color(0xFF08090A))
                    : null,
              ),
            ),
            const SizedBox(width: AppSpacing.p12),
            Expanded(
              child: Text(
                widget.item.title,
                style: AppTypography.itemTitle.copyWith(
                  fontSize: 13.5,
                  decoration: widget.item.isCompleted ? TextDecoration.lineThrough : null,
                  color: widget.item.isCompleted ? AppColors.textTertiary : AppColors.textPrimary,
                ),
              ),
            ),
            if (_isHovered)
              GestureDetector(
                onTap: widget.onDelete,
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(Icons.close, size: 14, color: AppColors.textTertiary),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
