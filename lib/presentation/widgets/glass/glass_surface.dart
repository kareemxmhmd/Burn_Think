import 'dart:ui';
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
  final bool enableBlur;
  final bool enableReflection;
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
    this.enableBlur = true,
    this.enableReflection = true,
    this.customBorderColor,
    this.customBackgroundColor,
  });

  Color _getBackgroundColor() {
    if (customBackgroundColor != null) return customBackgroundColor!;
    return switch (level) {
      GlassLevel.subtle => AppColors.glassSubtle,
      GlassLevel.standard => AppColors.glassStandard,
      GlassLevel.elevated => AppColors.glassElevated,
      GlassLevel.dark => AppColors.glassDark,
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

  double _getBlurSigma() {
    return switch (level) {
      GlassLevel.subtle => 8.0,
      GlassLevel.standard => 16.0,
      GlassLevel.elevated => 24.0,
      GlassLevel.dark => 8.0,
    };
  }

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = borderRadius ?? AppRadii.radius16;
    final blurSigma = _getBlurSigma();

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
      child: enableReflection
          ? Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: effectiveRadius,
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: AppColors.glassReflectionGradient,
                      ),
                    ),
                  ),
                ),
                child,
              ],
            )
          : child,
    );

    if (enableBlur) {
      content = ClipRRect(
        borderRadius: effectiveRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: content,
        ),
      );
    }

    if (margin != null) {
      content = Padding(padding: margin!, child: content);
    }

    return content;
  }
}
