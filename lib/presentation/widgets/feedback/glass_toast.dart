import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/radii.dart';
import '../../../core/constants/spacing.dart';
import '../../../core/constants/typography.dart';
import '../../../core/services/toast_service.dart';
import '../glass/glass_surface.dart';

class GlassToastOverlay extends StatelessWidget {
  const GlassToastOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ToastService.instance,
      builder: (context, _) {
        final toast = ToastService.instance.currentToast;
        if (toast == null) return const SizedBox.shrink();

        return Positioned(
          bottom: 24,
          right: 24,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            builder: (context, val, child) {
              return Transform.translate(
                offset: Offset(0, (1 - val) * 10),
                child: Opacity(
                  opacity: val,
                  child: child,
                ),
              );
            },
            child: GlassSurface(
              level: GlassLevel.elevated,
              borderRadius: AppRadii.radius12,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.p16,
                vertical: AppSpacing.p12,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    size: 16,
                    color: AppColors.textPrimary,
                  ),
                  const SizedBox(width: AppSpacing.p8),
                  Text(
                    toast.message,
                    style: AppTypography.itemTitle.copyWith(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (toast.onUndo != null) ...[
                    const SizedBox(width: AppSpacing.p16),
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () => ToastService.instance.triggerUndo(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.p8,
                            vertical: AppSpacing.p4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.glassHover,
                            borderRadius: AppRadii.radius8,
                            border: Border.all(
                              color: AppColors.glassBorderStandard,
                              width: 1.0,
                            ),
                          ),
                          child: Text(
                            toast.undoLabel ?? 'Undo',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.metallicWhite,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(width: AppSpacing.p8),
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () => ToastService.instance.dismiss(),
                      child: const Icon(
                        Icons.close,
                        size: 14,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
