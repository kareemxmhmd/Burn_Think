import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/spacing.dart';
import '../../../core/constants/typography.dart';
import '../../../core/utils/date_utils.dart';
import '../../state/workspace_controller.dart';
import '../glass/glass_button.dart';

class AppHeader extends StatelessWidget {
  final AppSection currentSection;
  final VoidCallback onSearchTap;
  final VoidCallback onAddTap;

  const AppHeader({
    super.key,
    required this.currentSection,
    required this.onSearchTap,
    required this.onAddTap,
  });

  @override
  Widget build(BuildContext context) {
    final isHome = currentSection == AppSection.home;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.p32,
        vertical: AppSpacing.p24,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left: Greeting or Section Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isHome) ...[
                  Text(
                    AppDateUtils.getGreeting(),
                    style: AppTypography.display,
                  ),
                  const SizedBox(height: AppSpacing.p4),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: AppSpacing.p12,
                    runSpacing: AppSpacing.p4,
                    children: [
                      Text(
                        AppDateUtils.formatFullDate(),
                        style: AppTypography.body.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.glassSubtle,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: AppColors.glassBorderSubtle,
                            width: 0.5,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 5,
                              height: 5,
                              decoration: const BoxDecoration(
                                color: AppColors.textTertiary,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Offline',
                              style: AppTypography.caption.copyWith(
                                fontSize: 10.5,
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  Text(
                    currentSection.title,
                    style: AppTypography.display,
                  ),
                ],
              ],
            ),
          ),

          // Right: Action buttons (Search & Add)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GlassButton(
                icon: const Icon(Icons.search, size: 16),
                text: 'Search',
                onPressed: onSearchTap,
                height: 36,
              ),
              const SizedBox(width: AppSpacing.p12),
              GlassButton.primary(
                icon: const Icon(Icons.add, size: 16, color: Color(0xFF08090A)),
                onPressed: onAddTap,
                height: 36,
                padding: const EdgeInsets.symmetric(horizontal: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
