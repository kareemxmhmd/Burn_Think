import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/radii.dart';
import 'glass_surface.dart';

class GlassCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final GlassLevel level;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final bool enableHover;
  final Color? customBorderColor;

  const GlassCard({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.level = GlassLevel.standard,
    this.borderRadius,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.enableHover = true,
    this.customBorderColor,
  });

  @override
  State<GlassCard> createState() => _GlassCardState();
}

class _GlassCardState extends State<GlassCard> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = widget.borderRadius ?? AppRadii.radius16;

    Color? getInteractiveBg() {
      if (_isPressed) return AppColors.glassActive;
      if (_isHovered && widget.enableHover) return AppColors.glassHover;
      return null;
    }

    Color? getInteractiveBorder() {
      if (_isPressed || (_isHovered && widget.enableHover)) {
        return AppColors.glassBorderStrong;
      }
      return widget.customBorderColor;
    }

    Widget content = GlassSurface(
      level: widget.level,
      borderRadius: effectiveRadius,
      padding: widget.padding,
      margin: widget.margin,
      width: widget.width,
      height: widget.height,
      customBorderColor: getInteractiveBorder(),
      customBackgroundColor: getInteractiveBg(),
      child: widget.child,
    );

    if (widget.onTap != null || widget.enableHover) {
      content = MouseRegion(
        cursor: widget.onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          onTap: widget.onTap,
          onLongPress: widget.onLongPress,
          child: content,
        ),
      );
    }

    return content;
  }
}
