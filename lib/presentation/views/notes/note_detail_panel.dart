import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/spacing.dart';
import '../../../core/constants/typography.dart';
import '../../../core/utils/date_utils.dart';
import '../../../domain/models/note.dart';
import '../../state/workspace_controller.dart';
import '../../widgets/glass/glass_button.dart';
import '../../widgets/glass/glass_input.dart';
import '../../widgets/modals/confirm_dialog.dart';

class NoteDetailPanel extends StatefulWidget {
  final String? noteId;
  final Note? initialNote;
  final WorkspaceController controller;

  const NoteDetailPanel({
    super.key,
    this.noteId,
    this.initialNote,
    required this.controller,
  });

  @override
  State<NoteDetailPanel> createState() => _NoteDetailPanelState();
}

class _NoteDetailPanelState extends State<NoteDetailPanel> {
  late final TextEditingController _titleController;
  late final TextEditingController _bodyController;
  bool _isPinned = false;

  Note? _currentNote;

  @override
  void initState() {
    super.initState();
    _currentNote = widget.initialNote ??
        widget.controller.notes.where((n) => n.id == widget.noteId).firstOrNull;

    _titleController = TextEditingController(text: _currentNote?.title ?? '');
    _bodyController = TextEditingController(text: _currentNote?.body ?? '');
    _isPinned = _currentNote?.isPinned ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final title = _titleController.text.trim();
    final body = _bodyController.text.trim();
    if (title.isEmpty && body.isEmpty) return;

    if (_currentNote != null) {
      final updated = _currentNote!.copyWith(
        title: title.isNotEmpty ? title : 'Untitled Note',
        body: body,
        isPinned: _isPinned,
      );
      await widget.controller.updateNote(updated);
    } else {
      await widget.controller.createNote(
        title: title.isNotEmpty ? title : 'Untitled Note',
        body: body,
        isPinned: _isPinned,
      );
    }
    widget.controller.closeDetail();
  }

  Future<void> _handleDelete() async {
    if (_currentNote == null) return;
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Delete Note',
      message: 'Are you sure you want to delete "${_currentNote!.title}"?',
    );
    if (confirmed == true && mounted) {
      await widget.controller.deleteNote(_currentNote!);
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
                const Icon(Icons.description_outlined, size: 18, color: AppColors.textSecondary),
                const SizedBox(width: AppSpacing.p8),
                Text(
                  _currentNote == null ? 'New Note' : 'Note Details',
                  style: AppTypography.cardTitle,
                ),
              ],
            ),
            Row(
              children: [
                GlassIconButton(
                  icon: Icon(
                    _isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                    size: 16,
                    color: _isPinned ? AppColors.metallicWhite : AppColors.textTertiary,
                  ),
                  tooltip: _isPinned ? 'Unpin Note' : 'Pin Note',
                  onPressed: () => setState(() => _isPinned = !_isPinned),
                ),
                const SizedBox(width: AppSpacing.p8),
                GlassIconButton(
                  icon: const Icon(Icons.close, size: 16),
                  onPressed: widget.controller.closeDetail,
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.p20),

        // Body
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GlassTextField(
                controller: _titleController,
                labelText: 'TITLE',
                hintText: 'Note title...',
              ),

              const SizedBox(height: AppSpacing.p16),

              Expanded(
                child: GlassTextField(
                  controller: _bodyController,
                  labelText: 'NOTE CONTENT',
                  hintText: 'Write down anything you want to remember or keep...',
                  maxLines: 20,
                  minLines: 8,
                ),
              ),

              if (_currentNote != null) ...[
                const SizedBox(height: AppSpacing.p8),
                Text(
                  'Last updated: ${AppDateUtils.formatDateTime(_currentNote!.updatedAt)}',
                  style: AppTypography.caption,
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.p16),

        // Footer
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (_currentNote != null)
              GlassIconButton(
                icon: const Icon(Icons.delete_outline, size: 16, color: AppColors.danger),
                tooltip: 'Delete Note',
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
