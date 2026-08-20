import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/radii.dart';
import '../../../core/constants/spacing.dart';
import '../../../core/constants/typography.dart';
import '../../../domain/models/content_item.dart';
import '../../state/workspace_controller.dart';
import '../../widgets/feedback/empty_state.dart';
import '../../widgets/glass/glass_button.dart';
import '../../widgets/glass/glass_card.dart';

class ContentView extends StatefulWidget {
  final WorkspaceController controller;

  const ContentView({super.key, required this.controller});

  @override
  State<ContentView> createState() => _ContentViewState();
}

class _ContentViewState extends State<ContentView> {
  String? _typeFilter;

  @override
  Widget build(BuildContext context) {
    var items = widget.controller.contentItems;

    if (_typeFilter != null) {
      items = items.where((i) => i.contentType?.toLowerCase() == _typeFilter!.toLowerCase()).toList();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p32, vertical: AppSpacing.p8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _FilterPill(
                    label: 'All Ideas',
                    isSelected: _typeFilter == null,
                    onTap: () => setState(() => _typeFilter = null),
                  ),
                  const SizedBox(width: AppSpacing.p8),
                  _FilterPill(
                    label: 'Video',
                    isSelected: _typeFilter == 'Video',
                    onTap: () => setState(() => _typeFilter = 'Video'),
                  ),
                  const SizedBox(width: AppSpacing.p8),
                  _FilterPill(
                    label: 'Post',
                    isSelected: _typeFilter == 'Post',
                    onTap: () => setState(() => _typeFilter = 'Post'),
                  ),
                  const SizedBox(width: AppSpacing.p8),
                  _FilterPill(
                    label: 'Article',
                    isSelected: _typeFilter == 'Article',
                    onTap: () => setState(() => _typeFilter = 'Article'),
                  ),
                ],
              ),
              GlassButton.primary(
                icon: const Icon(Icons.add, size: 16, color: Color(0xFF08090A)),
                text: 'New Idea',
                onPressed: () => widget.controller.openDetail(DetailType.content),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.p20),

          // Content Grid
          Expanded(
            child: items.isEmpty
                ? EmptyState(
                    title: 'No ideas yet.',
                    subtitle: 'Capture your next video, post, or article concept.',
                    actionLabel: 'Add Idea',
                    icon: Icons.auto_awesome_outlined,
                    onAction: () => widget.controller.openDetail(DetailType.content),
                  )
                : LayoutBuilder(
                    builder: (context, constraints) {
                      final crossAxisCount = constraints.maxWidth > 800 ? 3 : (constraints.maxWidth > 500 ? 2 : 1);

                      return GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 1.4,
                        ),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return _ContentGridCard(
                            item: item,
                            onTap: () => widget.controller.openDetail(DetailType.content, item.id, item),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterPill({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.glassElevated : AppColors.glassSubtle,
          borderRadius: AppRadii.radius8,
          border: Border.all(
            color: isSelected ? AppColors.glassBorderStrong : AppColors.glassBorderSubtle,
            width: 1.0,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.caption.copyWith(
            color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

class _ContentGridCard extends StatelessWidget {
  final ContentItem item;
  final VoidCallback onTap;

  const _ContentGridCard({
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final typeStr = item.contentType ?? 'Idea';
    final durStr = item.duration?.isNotEmpty == true ? ' • ${item.duration}' : '';

    return GlassCard(
      padding: AppSpacing.insets16,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.glassSubtle,
                  borderRadius: AppRadii.radius8,
                  border: Border.all(color: AppColors.glassBorderSubtle, width: 0.5),
                ),
                child: Text(
                  '$typeStr$durStr',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textTertiary,
                    fontSize: 10.5,
                  ),
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 10, color: AppColors.textTertiary),
            ],
          ),

          const SizedBox(height: 8),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: AppTypography.cardTitle.copyWith(fontSize: 15),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (item.description != null && item.description!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    item.description!,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
