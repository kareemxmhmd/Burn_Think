import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/radii.dart';
import '../../../core/constants/spacing.dart';
import '../../../core/constants/typography.dart';

enum GlassButtonVariant {
  primary,
  secondary,
  destructive,
  ghost,
}

class GlassButton extends StatefulWidget {
  final String? text;
  final Widget? icon;
  final VoidCallback? onPressed;
  final GlassButtonVariant variant;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;
  final bool isLoading;

  const GlassButton({
    super.key,
    this.text,
    this.icon,
    required this.onPressed,
    this.variant = GlassButtonVariant.secondary,
    this.padding,
    this.width,
    this.height = 40.0,
    this.isLoading = false,
  });

  const GlassButton.primary({
    super.key,
    this.text,
    this.icon,
    required this.onPressed,
    this.padding,
    this.width,
    this.height = 40.0,
    this.isLoading = false,
  }) : variant = GlassButtonVariant.primary;

  const GlassButton.destructive({
    super.key,
    this.text,
    this.icon,
    required this.onPressed,
    this.padding,
    this.width,
    this.height = 40.0,
    this.isLoading = false,
  }) : variant = GlassButtonVariant.destructive;

  @override
  State<GlassButton> createState() => _GlassButtonState();
}

class _GlassButtonState extends State<GlassButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onPressed != null && !widget.isLoading;

    BoxDecoration getDecoration() {
      switch (widget.variant) {
        case GlassButtonVariant.primary:
          return BoxDecoration(
            gradient: isEnabled ? AppColors.metallicGradient : null,
            color: !isEnabled ? AppColors.metallicDark : null,
            borderRadius: AppRadii.radius10,
            boxShadow: _isHovered && isEnabled
                ? [
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          );

        case GlassButtonVariant.secondary:
          return BoxDecoration(
            color: _isPressed
                ? AppColors.glassActive
                : (_isHovered ? AppColors.glassHover : AppColors.glassSubtle),
            borderRadius: AppRadii.radius10,
            border: Border.all(
              color: _isHovered ? AppColors.glassBorderStrong : AppColors.glassBorderSubtle,
              width: 1.0,
            ),
          );

        case GlassButtonVariant.destructive:
          return BoxDecoration(
            color: _isHovered ? AppColors.dangerSurface : AppColors.glassSubtle,
            borderRadius: AppRadii.radius10,
            border: Border.all(
              color: _isHovered ? AppColors.danger : AppColors.dangerBorder,
              width: 1.0,
            ),
          );

        case GlassButtonVariant.ghost:
          return BoxDecoration(
            color: _isHovered ? AppColors.glassHover : Colors.transparent,
            borderRadius: AppRadii.radius10,
          );
      }
    }

    Color getTextColor() {
      if (!isEnabled) return AppColors.textDisabled;
      switch (widget.variant) {
        case GlassButtonVariant.primary:
          return const Color(0xFF08090A); // High contrast dark text on metallic gradient
        case GlassButtonVariant.secondary:
        case GlassButtonVariant.ghost:
          return AppColors.textPrimary;
        case GlassButtonVariant.destructive:
          return AppColors.danger;
      }
    }

    Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.isLoading) ...[
          SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(getTextColor()),
            ),
          ),
          if (widget.text != null) const SizedBox(width: AppSpacing.p8),
        ] else if (widget.icon != null) ...[
          IconTheme(
            data: IconThemeData(
              size: 16,
              color: getTextColor(),
            ),
            child: widget.icon!,
          ),
          if (widget.text != null) const SizedBox(width: AppSpacing.p8),
        ],
        if (widget.text != null)
          Text(
            widget.text!,
            style: AppTypography.button.copyWith(color: getTextColor()),
          ),
      ],
    );

    return MouseRegion(
      cursor: isEnabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: isEnabled ? (_) => setState(() => _isPressed = true) : null,
        onTapUp: isEnabled ? (_) => setState(() => _isPressed = false) : null,
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: isEnabled ? widget.onPressed : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: widget.width,
          height: widget.height,
          padding: widget.padding ?? AppSpacing.h16,
          decoration: getDecoration(),
          alignment: Alignment.center,
          child: content,
        ),
      ),
    );
  }
}

class GlassIconButton extends StatefulWidget {
  final Widget icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final double size;
  final Color? color;

  const GlassIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.size = 36.0,
    this.color,
  });

  @override
  State<GlassIconButton> createState() => _GlassIconButtonState();
}

class _GlassIconButtonState extends State<GlassIconButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    Widget btn = MouseRegion(
      cursor: widget.onPressed != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: _isHovered ? AppColors.glassHover : AppColors.glassSubtle,
            borderRadius: AppRadii.radius8,
            border: Border.all(
              color: _isHovered ? AppColors.glassBorderStrong : AppColors.glassBorderSubtle,
              width: 1.0,
            ),
          ),
          child: Center(
            child: IconTheme(
              data: IconThemeData(
                size: 17,
                color: widget.color ?? AppColors.textPrimary,
              ),
              child: widget.icon,
            ),
          ),
        ),
      ),
    );

    if (widget.tooltip != null) {
      return Tooltip(
        message: widget.tooltip!,
        child: btn,
      );
    }
    return btn;
  }
}
