import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/radii.dart';
import '../../../core/constants/spacing.dart';
import '../../../core/constants/typography.dart';
import '../../../domain/models/content_item.dart';
import '../../state/workspace_controller.dart';
import '../../widgets/glass/glass_button.dart';
import '../../widgets/glass/glass_input.dart';
import '../../widgets/modals/confirm_dialog.dart';

class ContentDetailPanel extends StatefulWidget {
  final String? contentId;
  final ContentItem? initialContent;
  final WorkspaceController controller;

  const ContentDetailPanel({
    super.key,
    this.contentId,
    this.initialContent,
    required this.controller,
  });

  @override
  State<ContentDetailPanel> createState() => _ContentDetailPanelState();
}

class _ContentDetailPanelState extends State<ContentDetailPanel> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _durationController;
  late final TextEditingController _notesController;
  String _contentType = 'Idea';
  String _status = 'Idea';

  ContentItem? _currentItem;

  @override
  void initState() {
    super.initState();
    _currentItem = widget.initialContent ??
        widget.controller.contentItems.where((c) => c.id == widget.contentId).firstOrNull;

    _titleController = TextEditingController(text: _currentItem?.title ?? '');
    _descriptionController = TextEditingController(text: _currentItem?.description ?? '');
    _durationController = TextEditingController(text: _currentItem?.duration ?? '');
    _notesController = TextEditingController(text: _currentItem?.notes ?? '');
    _contentType = _currentItem?.contentType ?? 'Idea';
    _status = _currentItem?.status ?? 'Idea';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    if (_currentItem != null) {
      final updated = _currentItem!.copyWith(
        title: title,
        description: _descriptionController.text.trim(),
        contentType: _contentType,
        duration: _durationController.text.trim(),
        notes: _notesController.text.trim(),
        status: _status,
      );
      await widget.controller.updateContentItem(updated);
    } else {
      await widget.controller.createContentItem(
        title: title,
        description: _descriptionController.text.trim(),
        contentType: _contentType,
        duration: _durationController.text.trim(),
        notes: _notesController.text.trim(),
        status: _status,
      );
    }
    widget.controller.closeDetail();
  }

  Future<void> _handleDelete() async {
    if (_currentItem == null) return;
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Delete Content Idea',
      message: 'Are you sure you want to delete "${_currentItem!.title}"?',
    );
    if (confirmed == true && mounted) {
      await widget.controller.deleteContentItem(_currentItem!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.auto_awesome_outlined, size: 18, color: AppColors.textSecondary),
                const SizedBox(width: AppSpacing.p8),
                Text(
                  _currentItem == null ? 'New Content Idea' : 'Content Idea',
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
                  hintText: 'Content idea title...',
                ),

                const SizedBox(height: AppSpacing.p16),

                // Type & Duration
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('TYPE', style: AppTypography.sectionHeader),
                          const SizedBox(height: AppSpacing.p8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p12, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.glassSubtle,
                              borderRadius: AppRadii.radius10,
                              border: Border.all(color: AppColors.glassBorderSubtle, width: 1.0),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _contentType,
                                dropdownColor: AppColors.surfaceDark,
                                isExpanded: true,
                                style: AppTypography.itemTitle.copyWith(fontSize: 13),
                                icon: const Icon(Icons.arrow_drop_down, color: AppColors.textTertiary),
                                items: ['Idea', 'Video', 'Post', 'Article', 'Short'].map((t) {
                                  return DropdownMenuItem(value: t, child: Text(t));
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) setState(() => _contentType = val);
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.p12),
                    Expanded(
                      child: GlassTextField(
                        controller: _durationController,
                        labelText: 'DURATION (OPT)',
                        hintText: '45 mins',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.p16),

                GlassTextField(
                  controller: _descriptionController,
                  labelText: 'SYNOPSIS / CONCEPT',
                  hintText: 'Strategic overview or key thesis...',
                  maxLines: 4,
                ),

                const SizedBox(height: AppSpacing.p16),

                GlassTextField(
                  controller: _notesController,
                  labelText: 'REFERENCES & NOTES',
                  hintText: 'Links, key points, references...',
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.p16),

        // Footer
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (_currentItem != null)
              GlassIconButton(
                icon: const Icon(Icons.delete_outline, size: 16, color: AppColors.danger),
                tooltip: 'Delete Idea',
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
