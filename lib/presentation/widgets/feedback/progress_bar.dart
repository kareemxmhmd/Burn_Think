import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/radii.dart';

class MetallicProgressBar extends StatelessWidget {
  final double value; // 0.0 to 1.0
  final double height;
  final BorderRadius? borderRadius;

  const MetallicProgressBar({
    super.key,
    required this.value,
    this.height = 4.0,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final clampedValue = value.clamp(0.0, 1.0);
    final effectiveRadius = borderRadius ?? AppRadii.radius8;

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.glassSubtle,
        borderRadius: effectiveRadius,
        border: Border.all(
          color: AppColors.glassBorderSubtle,
          width: 0.5,
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final progressWidth = constraints.maxWidth * clampedValue;
          return Align(
            alignment: Alignment.centerLeft,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              width: progressWidth,
              height: height,
              decoration: BoxDecoration(
                gradient: AppColors.metallicGradient,
                borderRadius: effectiveRadius,
                boxShadow: clampedValue > 0
                    ? [
                        BoxShadow(
                          color: Colors.white.withValues(alpha: 0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 0),
                        ),
                      ]
                    : null,
              ),
            ),
          );
        },
      ),
    );
  }
}
