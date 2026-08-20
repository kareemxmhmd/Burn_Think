import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/radii.dart';
import '../../../core/constants/spacing.dart';
import '../../../core/constants/typography.dart';
import '../../state/search_controller.dart';
import '../../state/workspace_controller.dart';
import '../glass/glass_button.dart';
import '../glass/glass_surface.dart';

class SearchModal extends StatefulWidget {
  final WorkspaceController workspaceController;

  const SearchModal({super.key, required this.workspaceController});

  @override
  State<SearchModal> createState() => _SearchModalState();
}

class _SearchModalState extends State<SearchModal> {
  late final AppSearchController _searchController;
  final _inputController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController = AppSearchController(workspaceController: widget.workspaceController);
  }

  @override
  void dispose() {
    _inputController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): widget.workspaceController.closeSearch,
      },
      child: Focus(
        autofocus: true,
        child: Stack(
          children: [
            // Backdrop
            Positioned.fill(
              child: GestureDetector(
                onTap: widget.workspaceController.closeSearch,
                child: Container(
                  color: Colors.black.withValues(alpha: 0.65),
                ),
              ),
            ),

            // Search Dialog Box
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 580,
                  maxHeight: 520,
                ),
                child: GlassSurface(
                  level: GlassLevel.elevated,
                  borderRadius: AppRadii.radius20,
                  padding: AppSpacing.insets20,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Search Header Input
                      Row(
                        children: [
                          const Icon(Icons.search, size: 20, color: AppColors.textSecondary),
                          const SizedBox(width: AppSpacing.p12),
                          Expanded(
                            child: TextField(
                              controller: _inputController,
                              autofocus: true,
                              cursorColor: AppColors.metallicSilver,
                              style: AppTypography.cardTitle.copyWith(fontWeight: FontWeight.w500),
                              decoration: InputDecoration(
                                hintText: 'Search tasks, projects, notes, content...',
                                hintStyle: AppTypography.cardTitle.copyWith(
                                  color: AppColors.textTertiary,
                                  fontWeight: FontWeight.w400,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                              ),
                              onChanged: (val) {
                                _searchController.setQuery(val);
                                setState(() {});
                              },
                            ),
                          ),
                          if (_inputController.text.isNotEmpty)
                            GlassIconButton(
                              icon: const Icon(Icons.close, size: 14),
                              onPressed: () {
                                _inputController.clear();
                                _searchController.clear();
                                setState(() {});
                              },
                            )
                          else
                            GlassIconButton(
                              icon: const Icon(Icons.close, size: 14),
                              onPressed: widget.workspaceController.closeSearch,
                            ),
                        ],
                      ),

                      const SizedBox(height: AppSpacing.p12),
                      Container(height: 1, color: AppColors.glassBorderSubtle),
                      const SizedBox(height: AppSpacing.p12),

                      // Results List
                      Expanded(
                        child: ListenableBuilder(
                          listenable: _searchController,
                          builder: (context, _) {
                            if (_inputController.text.trim().isEmpty) {
                              return Center(
                                child: Text(
                                  'Type to search anything in your offline workspace.',
                                  style: AppTypography.body.copyWith(color: AppColors.textTertiary),
                                ),
                              );
                            }

                            if (_searchController.results.isEmpty) {
                              return Center(
                                child: Text(
                                  'No items found for "${_inputController.text.trim()}"',
                                  style: AppTypography.body.copyWith(color: AppColors.textTertiary),
                                ),
                              );
                            }

                            return ListView.builder(
                              itemCount: _searchController.results.length,
                              itemBuilder: (context, index) {
                                final result = _searchController.results[index];
                                return _SearchResultTile(
                                  result: result,
                                  onTap: () {
                                    widget.workspaceController.closeSearch();
                                    widget.workspaceController.openDetail(
                                      result.type,
                                      result.id,
                                      result.item,
                                    );
                                  },
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchResultTile extends StatefulWidget {
  final SearchResultItem result;
  final VoidCallback onTap;

  const _SearchResultTile({
    required this.result,
    required this.onTap,
  });

  @override
  State<_SearchResultTile> createState() => _SearchResultTileState();
}

class _SearchResultTileState extends State<_SearchResultTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    IconData getIcon() {
      switch (widget.result.type) {
        case DetailType.task:
          return Icons.check_box_outlined;
        case DetailType.project:
          return Icons.layers_outlined;
        case DetailType.workout:
          return Icons.fitness_center_outlined;
        case DetailType.content:
          return Icons.auto_awesome_outlined;
        case DetailType.note:
          return Icons.description_outlined;
        case DetailType.shopping:
          return Icons.shopping_bag_outlined;
      }
    }

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p12, vertical: AppSpacing.p8),
          decoration: BoxDecoration(
            color: _isHovered ? AppColors.glassHover : Colors.transparent,
            borderRadius: AppRadii.radius8,
            border: _isHovered ? Border.all(color: AppColors.glassBorderStandard, width: 1.0) : null,
          ),
          child: Row(
            children: [
              Icon(getIcon(), size: 16, color: AppColors.textSecondary),
              const SizedBox(width: AppSpacing.p12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.result.title,
                      style: AppTypography.itemTitle.copyWith(fontWeight: FontWeight.w500),
                    ),
                    if (widget.result.subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        widget.result.subtitle!,
                        style: AppTypography.caption.copyWith(color: AppColors.textTertiary),
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.glassSubtle,
                  borderRadius: AppRadii.radius8,
                ),
                child: Text(
                  widget.result.category,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textTertiary,
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
