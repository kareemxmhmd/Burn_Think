import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/radii.dart';
import '../../../core/constants/spacing.dart';
import '../../../core/constants/typography.dart';
import '../../../core/utils/date_utils.dart';
import '../../../domain/models/shopping_item.dart';
import '../../state/workspace_controller.dart';
import '../../widgets/glass/glass_button.dart';
import '../../widgets/glass/glass_input.dart';
import '../../widgets/modals/confirm_dialog.dart';

class ShoppingDetailPanel extends StatefulWidget {
  final String? itemId;
  final ShoppingItem? initialItem;
  final WorkspaceController controller;

  const ShoppingDetailPanel({
    super.key,
    this.itemId,
    this.initialItem,
    required this.controller,
  });

  @override
  State<ShoppingDetailPanel> createState() => _ShoppingDetailPanelState();
}

class _ShoppingDetailPanelState extends State<ShoppingDetailPanel> {
  late final TextEditingController _titleController;
  late final TextEditingController _notesController;
  bool _isBought = false;

  ShoppingItem? _currentItem;

  @override
  void initState() {
    super.initState();
    _currentItem = widget.initialItem ??
        widget.controller.toBuyShoppingItems.where((s) => s.id == widget.itemId).firstOrNull ??
        widget.controller.boughtShoppingItems.where((s) => s.id == widget.itemId).firstOrNull;

    _titleController = TextEditingController(text: _currentItem?.title ?? '');
    _notesController = TextEditingController(text: _currentItem?.notes ?? '');
    _isBought = _currentItem?.isBought ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    if (_currentItem != null) {
      final updated = _currentItem!.copyWith(
        title: title,
        notes: _notesController.text.trim(),
      );
      await widget.controller.updateShoppingItem(updated);
    } else {
      await widget.controller.createShoppingItem(
        title: title,
        notes: _notesController.text.trim(),
      );
    }
    widget.controller.closeDetail();
  }

  Future<void> _handleDelete() async {
    if (_currentItem == null) return;
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Delete Shopping Item',
      message: 'Are you sure you want to delete "${_currentItem!.title}"?',
    );
    if (confirmed == true && mounted) {
      await widget.controller.deleteShoppingItem(_currentItem!);
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
                const Icon(Icons.shopping_bag_outlined, size: 18, color: AppColors.textSecondary),
                const SizedBox(width: AppSpacing.p8),
                Text(
                  _currentItem == null ? 'New Shopping Item' : 'Shopping Item',
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
                  labelText: 'ITEM NAME',
                  hintText: 'e.g. Coffee, Milk, New mouse...',
                ),

                const SizedBox(height: AppSpacing.p16),

                GlassTextField(
                  controller: _notesController,
                  labelText: 'NOTES (OPTIONAL)',
                  hintText: 'Quantity, brand, store, or specs...',
                  maxLines: 3,
                ),

                const SizedBox(height: AppSpacing.p16),

                if (_currentItem != null) ...[
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
                          'Status: ${_isBought ? "Bought" : "To Buy"}',
                          style: AppTypography.caption,
                        ),
                        if (_currentItem!.boughtAt != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Bought on: ${AppDateUtils.formatDateTime(_currentItem!.boughtAt!)}',
                            style: AppTypography.caption,
                          ),
                        ],
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
            if (_currentItem != null)
              GlassIconButton(
                icon: const Icon(Icons.delete_outline, size: 16, color: AppColors.danger),
                tooltip: 'Delete Item',
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
