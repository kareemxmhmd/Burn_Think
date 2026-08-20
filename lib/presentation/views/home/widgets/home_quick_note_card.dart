import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../core/constants/typography.dart';
import '../../../state/workspace_controller.dart';
import '../../../widgets/glass/glass_card.dart';

class HomeQuickNoteCard extends StatelessWidget {
  final WorkspaceController controller;

  const HomeQuickNoteCard({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final note = controller.quickNote;

    if (note == null) {
      return GlassCard(
        padding: AppSpacing.insets16,
        onTap: () => controller.openDetail(DetailType.note),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('QUICK NOTE', style: AppTypography.sectionHeader),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'No notes saved.',
                style: AppTypography.caption.copyWith(color: AppColors.textTertiary),
              ),
            ),
            Text(
              '+ Capture thought',
              style: AppTypography.caption.copyWith(color: AppColors.textDisabled),
            ),
          ],
        ),
      );
    }

    return GlassCard(
      padding: AppSpacing.insets16,
      onTap: () => controller.openDetail(DetailType.note, note.id, note),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('QUICK NOTE', style: AppTypography.sectionHeader),
              if (note.isPinned)
                const Icon(Icons.push_pin, size: 12, color: AppColors.metallicWhite)
              else
                const Icon(Icons.description_outlined, size: 12, color: AppColors.textTertiary),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            note.title,
            style: AppTypography.itemTitle.copyWith(fontWeight: FontWeight.w600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (note.body.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              note.body,
              style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}
