import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/spacing.dart';
import '../../../core/constants/typography.dart';
import '../../../domain/models/shopping_item.dart';
import '../../state/workspace_controller.dart';
import '../../widgets/feedback/empty_state.dart';
import '../../widgets/glass/glass_button.dart';
import '../../widgets/glass/glass_card.dart';
import '../../widgets/glass/glass_input.dart';

class ShoppingView extends StatefulWidget {
  final WorkspaceController controller;

  const ShoppingView({super.key, required this.controller});

  @override
  State<ShoppingView> createState() => _ShoppingViewState();
}

class _ShoppingViewState extends State<ShoppingView> {
  final _quickInputController = TextEditingController();

  @override
  void dispose() {
    _quickInputController.dispose();
    super.dispose();
  }

  Future<void> _handleQuickAdd() async {
    final text = _quickInputController.text.trim();
    if (text.isEmpty) {
      widget.controller.openDetail(DetailType.shopping);
      return;
    }
    await widget.controller.createShoppingItem(title: text);
    _quickInputController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.controller.toBuyShoppingItems;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p32, vertical: AppSpacing.p8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick add bar
          Row(
            children: [
              Expanded(
                child: GlassTextField(
                  controller: _quickInputController,
                  hintText: 'Add an item to buy (e.g. Coffee, USB-C Cable)...',
                  prefixIcon: const Icon(Icons.shopping_bag_outlined, size: 16),
                  onSubmitted: (_) => _handleQuickAdd(),
                ),
              ),
              const SizedBox(width: AppSpacing.p12),
              GlassButton.primary(
                text: 'Add Item',
                onPressed: _handleQuickAdd,
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.p20),

          // Items List
          Expanded(
            child: items.isEmpty
                ? EmptyState(
                    title: 'Shopping list is empty.',
                    subtitle: 'Add items you want to buy.',
                    actionLabel: 'Add Item',
                    icon: Icons.shopping_bag_outlined,
                    onAction: () => widget.controller.openDetail(DetailType.shopping),
                  )
                : ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return _ShoppingItemRow(
                        item: item,
                        onMarkBought: () => widget.controller.markShoppingItemBought(item),
                        onTap: () => widget.controller.openDetail(DetailType.shopping, item.id, item),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _ShoppingItemRow extends StatelessWidget {
  final ShoppingItem item;
  final VoidCallback onMarkBought;
  final VoidCallback onTap;

  const _ShoppingItemRow({
    required this.item,
    required this.onMarkBought,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p16, vertical: AppSpacing.p12),
        onTap: onTap,
        child: Row(
          children: [
            GestureDetector(
              onTap: onMarkBought,
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
                    item.title,
                    style: AppTypography.itemTitle.copyWith(fontSize: 14.5),
                  ),
                  if (item.notes != null && item.notes!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      item.notes!,
                      style: AppTypography.caption.copyWith(color: AppColors.textTertiary),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
