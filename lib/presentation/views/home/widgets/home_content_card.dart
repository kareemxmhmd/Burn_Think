import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../core/constants/typography.dart';
import '../../../state/workspace_controller.dart';
import '../../../widgets/glass/glass_card.dart';

class HomeContentCard extends StatelessWidget {
  final WorkspaceController controller;

  const HomeContentCard({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final item = controller.contentItems.firstOrNull;

    if (item == null) {
      return GlassCard(
        padding: AppSpacing.insets20,
        onTap: () => controller.navigateTo(AppSection.content),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('CONTENT QUEUE', style: AppTypography.sectionHeader),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.p16),
              child: Text(
                'No content ideas in queue.',
                style: AppTypography.caption.copyWith(color: AppColors.textTertiary),
              ),
            ),
            Text(
              'Add idea',
              style: AppTypography.caption.copyWith(color: AppColors.textDisabled),
            ),
          ],
        ),
      );
    }

    final metaParts = <String>[];
    if (item.duration != null && item.duration!.isNotEmpty) {
      metaParts.add(item.duration!);
    }
    if (item.contentType != null && item.contentType!.isNotEmpty) {
      metaParts.add(item.contentType!);
    }
    final metaStr = metaParts.isNotEmpty ? metaParts.join(' • ') : 'Idea';

    return GlassCard(
      padding: AppSpacing.insets20,
      onTap: () => controller.openDetail(DetailType.content, item.id, item),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('CONTENT QUEUE', style: AppTypography.sectionHeader),
              const Icon(Icons.auto_awesome_outlined, size: 14, color: AppColors.textTertiary),
            ],
          ),

          const SizedBox(height: AppSpacing.p12),

          Text(
            item.title,
            style: AppTypography.cardTitle.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          if (item.description != null && item.description!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              item.description!,
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],

          const SizedBox(height: AppSpacing.p16),

          Text(
            metaStr,
            style: AppTypography.caption.copyWith(
              color: AppColors.textTertiary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
