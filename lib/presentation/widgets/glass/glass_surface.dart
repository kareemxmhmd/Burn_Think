import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/radii.dart';

enum GlassLevel {
  subtle,
  standard,
  elevated,
  dark,
}

class GlassSurface extends StatelessWidget {
  final Widget child;
  final GlassLevel level;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final Color? customBorderColor;
  final Color? customBackgroundColor;

  const GlassSurface({
    super.key,
    required this.child,
    this.level = GlassLevel.standard,
    this.borderRadius,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.customBorderColor,
    this.customBackgroundColor,
    // Kept for call-site compatibility; blur/reflection are no longer used.
    bool enableBlur = false,
    bool enableReflection = false,
  });

  Color _getBackgroundColor() {
    if (customBackgroundColor != null) return customBackgroundColor!;
    return switch (level) {
      GlassLevel.dark => AppColors.background,
      GlassLevel.subtle => AppColors.backgroundSecondary,
      GlassLevel.standard => AppColors.sidebar,
      GlassLevel.elevated => AppColors.surfaceDark,
    };
  }

  Color _getBorderColor() {
    if (customBorderColor != null) return customBorderColor!;
    return switch (level) {
      GlassLevel.subtle => AppColors.glassBorderSubtle,
      GlassLevel.standard => AppColors.glassBorderStandard,
      GlassLevel.elevated => AppColors.glassBorderStrong,
      GlassLevel.dark => AppColors.glassBorderSubtle,
    };
  }

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = borderRadius ?? AppRadii.radius16;

    Widget content = Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: effectiveRadius,
        border: Border.all(
          color: _getBorderColor(),
          width: 1.0,
        ),
      ),
      child: child,
    );

    if (margin != null) {
      content = Padding(padding: margin!, child: content);
    }

    return content;
  }
}