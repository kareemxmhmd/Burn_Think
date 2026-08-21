import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/radii.dart';
import '../../../core/constants/spacing.dart';
import '../../../core/constants/typography.dart';
import '../../state/workspace_controller.dart';

class Sidebar extends StatelessWidget {
  final AppSection currentSection;
  final ValueChanged<AppSection> onSectionSelected;
  final WorkspaceController controller;

  const Sidebar({
    super.key,
    required this.currentSection,
    required this.onSectionSelected,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      color: AppColors.sidebar,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Branding
          Padding(
            padding: const EdgeInsets.only(left: AppSpacing.p16, right: AppSpacing.p16, top: AppSpacing.p20, bottom: AppSpacing.p16),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: AppRadii.radius8,
                  child: Image.asset(
                    'assets/icon/app_icon.png',
                    width: 36,
                    height: 36,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: AppSpacing.p12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Burn Shut',
                        style: AppTypography.pageTitle.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Deep Workspace',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textTertiary,
                          letterSpacing: 0.3,
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.p8),

          // Primary Navigation Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p12),
              children: [
                _NavItem(
                  section: AppSection.home,
                  icon: Icons.dashboard_outlined,
                  isSelected: currentSection == AppSection.home,
                  onTap: () => onSectionSelected(AppSection.home),
                ),
                _NavItem(
                  section: AppSection.tasks,
                  icon: Icons.check_box_outlined,
                  isSelected: currentSection == AppSection.tasks,
                  badgeCount: controller.stats.activeTasksCount > 0 ? controller.stats.activeTasksCount : null,
                  onTap: () => onSectionSelected(AppSection.tasks),
                ),
                _NavItem(
                  section: AppSection.projects,
                  icon: Icons.layers_outlined,
                  isSelected: currentSection == AppSection.projects,
                  badgeCount: controller.stats.activeProjectsCount > 0 ? controller.stats.activeProjectsCount : null,
                  onTap: () => onSectionSelected(AppSection.projects),
                ),
                _NavItem(
                  section: AppSection.workout,
                  icon: Icons.fitness_center_outlined,
                  isSelected: currentSection == AppSection.workout,
                  onTap: () => onSectionSelected(AppSection.workout),
                ),
                _NavItem(
                  section: AppSection.content,
                  icon: Icons.auto_awesome_outlined,
                  isSelected: currentSection == AppSection.content,
                  badgeCount: controller.stats.contentItemsCount > 0 ? controller.stats.contentItemsCount : null,
                  onTap: () => onSectionSelected(AppSection.content),
                ),
                _NavItem(
                  section: AppSection.notes,
                  icon: Icons.description_outlined,
                  isSelected: currentSection == AppSection.notes,
                  badgeCount: controller.stats.notesCount > 0 ? controller.stats.notesCount : null,
                  onTap: () => onSectionSelected(AppSection.notes),
                ),
                _NavItem(
                  section: AppSection.shopping,
                  icon: Icons.shopping_bag_outlined,
                  isSelected: currentSection == AppSection.shopping,
                  badgeCount: controller.stats.shoppingItemsToBuyCount > 0 ? controller.stats.shoppingItemsToBuyCount : null,
                  onTap: () => onSectionSelected(AppSection.shopping),
                ),
                _NavItem(
                  section: AppSection.completed,
                  icon: Icons.done_all_outlined,
                  isSelected: currentSection == AppSection.completed,
                  onTap: () => onSectionSelected(AppSection.completed),
                ),
              ],
            ),
          ),

          // Divider
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p16),
            child: Container(
              height: 1,
              color: AppColors.glassBorderSubtle,
            ),
          ),

          // Bottom Navigation - Settings
          Padding(
            padding: const EdgeInsets.all(AppSpacing.p12),
            child: _NavItem(
              section: AppSection.settings,
              icon: Icons.settings_outlined,
              isSelected: currentSection == AppSection.settings,
              onTap: () => onSectionSelected(AppSection.settings),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatefulWidget {
  final AppSection section;
  final IconData icon;
  final bool isSelected;
  final int? badgeCount;
  final VoidCallback onTap;

  const _NavItem({
    required this.section,
    required this.icon,
    required this.isSelected,
    this.badgeCount,
    required this.onTap,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    Color getTextColor() {
      if (widget.isSelected) return AppColors.textPrimary;
      if (_isHovered) return AppColors.textPrimary;
      return AppColors.textSecondary;
    }

    BoxDecoration getDecoration() {
      if (widget.isSelected) {
        return BoxDecoration(
          color: AppColors.glassStandard,
          borderRadius: AppRadii.radius10,
          border: Border.all(
            color: AppColors.glassBorderStrong,
            width: 1.0,
          ),
        );
      }
      if (_isHovered) {
        return BoxDecoration(
          color: AppColors.glassHover,
          borderRadius: AppRadii.radius10,
        );
      }
      return const BoxDecoration(color: Colors.transparent);
    }

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 2.0),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p12, vertical: AppSpacing.p8),
          decoration: getDecoration(),
          child: Row(
            children: [
              Icon(
                widget.icon,
                size: 17,
                color: getTextColor(),
              ),
              const SizedBox(width: AppSpacing.p12),
              Expanded(
                child: Text(
                  widget.section.title,
                  style: AppTypography.itemTitle.copyWith(
                    color: getTextColor(),
                    fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
              if (widget.badgeCount != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: widget.isSelected ? AppColors.glassHover : AppColors.glassSubtle,
                    borderRadius: AppRadii.radius8,
                  ),
                  child: Text(
                    '${widget.badgeCount}',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textTertiary,
                      fontWeight: FontWeight.w600,
                      fontSize: 10.5,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
