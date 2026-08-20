import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/radii.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../core/constants/typography.dart';
import '../../../state/workspace_controller.dart';
import '../../../widgets/glass/glass_card.dart';

class HomeShoppingCard extends StatelessWidget {
  final WorkspaceController controller;

  const HomeShoppingCard({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final count = controller.toBuyShoppingItems.length;

    return GlassCard(
      padding: AppSpacing.insets16,
      onTap: () => controller.navigateTo(AppSection.shopping),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.shopping_bag_outlined, size: 16, color: AppColors.textTertiary),
              const SizedBox(width: AppSpacing.p8),
              Text(
                'Shopping',
                style: AppTypography.itemTitle.copyWith(fontWeight: FontWeight.w500),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.glassSubtle,
              borderRadius: AppRadii.radius8,
              border: Border.all(color: AppColors.glassBorderSubtle, width: 0.5),
            ),
            child: Text(
              '$count',
              style: AppTypography.caption.copyWith(
                color: AppColors.metallicWhite,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
