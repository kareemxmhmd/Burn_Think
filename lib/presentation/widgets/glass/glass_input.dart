import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/radii.dart';
import '../../../core/constants/spacing.dart';
import '../../../core/constants/typography.dart';

class GlassTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? initialValue;
  final String? hintText;
  final String? labelText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool autofocus;
  final int maxLines;
  final int minLines;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final bool readOnly;
  final String? errorText;

  const GlassTextField({
    super.key,
    this.controller,
    this.initialValue,
    this.hintText,
    this.labelText,
    this.prefixIcon,
    this.suffixIcon,
    this.autofocus = false,
    this.maxLines = 1,
    this.minLines = 1,
    this.onChanged,
    this.onSubmitted,
    this.textInputAction,
    this.focusNode,
    this.readOnly = false,
    this.errorText,
  });

  @override
  State<GlassTextField> createState() => _GlassTextFieldState();
}

class _GlassTextFieldState extends State<GlassTextField> {
  late FocusNode _focusNode;
  bool _isFocused = false;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    if (mounted) {
      setState(() => _isFocused = _focusNode.hasFocus);
    }
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    } else {
      _focusNode.removeListener(_handleFocusChange);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color getBorderColor() {
      if (widget.errorText != null) return AppColors.danger;
      if (_isFocused) return AppColors.glassBorderStrong;
      if (_isHovered) return AppColors.glassBorderStandard;
      return AppColors.glassBorderSubtle;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.labelText != null) ...[
          Text(
            widget.labelText!,
            style: AppTypography.sectionHeader,
          ),
          const SizedBox(height: AppSpacing.p8),
        ],
        MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              color: _isFocused
                  ? AppColors.glassStandard
                  : (_isHovered ? AppColors.glassHover : AppColors.glassSubtle),
              borderRadius: AppRadii.radius10,
              border: Border.all(
                color: getBorderColor(),
                width: 1.0,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p12, vertical: AppSpacing.p4),
            child: Row(
              crossAxisAlignment: widget.maxLines > 1 ? CrossAxisAlignment.start : CrossAxisAlignment.center,
              children: [
                if (widget.prefixIcon != null) ...[
                  Padding(
                    padding: EdgeInsets.only(top: widget.maxLines > 1 ? 6.0 : 0.0, right: AppSpacing.p8),
                    child: IconTheme(
                      data: const IconThemeData(size: 16, color: AppColors.textTertiary),
                      child: widget.prefixIcon!,
                    ),
                  ),
                ],
                Expanded(
                  child: TextField(
                    controller: widget.controller,
                    focusNode: _focusNode,
                    autofocus: widget.autofocus,
                    maxLines: widget.maxLines,
                    minLines: widget.minLines,
                    readOnly: widget.readOnly,
                    onChanged: widget.onChanged,
                    onSubmitted: widget.onSubmitted,
                    textInputAction: widget.textInputAction,
                    cursorColor: AppColors.metallicSilver,
                    style: AppTypography.itemTitle,
                    decoration: InputDecoration(
                      hintText: widget.hintText,
                      hintStyle: AppTypography.body.copyWith(color: AppColors.textTertiary),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: AppSpacing.p8),
                    ),
                  ),
                ),
                if (widget.suffixIcon != null) ...[
                  Padding(
                    padding: EdgeInsets.only(top: widget.maxLines > 1 ? 6.0 : 0.0, left: AppSpacing.p8),
                    child: IconTheme(
                      data: const IconThemeData(size: 16, color: AppColors.textTertiary),
                      child: widget.suffixIcon!,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        if (widget.errorText != null) ...[
          const SizedBox(height: AppSpacing.p4),
          Text(
            widget.errorText!,
            style: AppTypography.caption.copyWith(color: AppColors.danger),
          ),
        ],
      ],
    );
  }
}
