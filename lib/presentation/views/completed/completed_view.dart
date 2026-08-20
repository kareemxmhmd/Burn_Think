import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/radii.dart';
import '../../../core/constants/spacing.dart';
import '../../../core/constants/typography.dart';
import '../../../core/utils/date_utils.dart';
import '../../../domain/models/project.dart';
import '../../../domain/models/shopping_item.dart';
import '../../../domain/models/task.dart';
import '../../state/workspace_controller.dart';
import '../../widgets/feedback/empty_state.dart';
import '../../widgets/glass/glass_card.dart';
import '../../widgets/modals/confirm_dialog.dart';

enum CompletedCategoryFilter {
  all('All'),
  tasks('Tasks'),
  shopping('Shopping'),
  projects('Projects');

  final String label;
  const CompletedCategoryFilter(this.label);
}

class CompletedView extends StatefulWidget {
  final WorkspaceController controller;

  const CompletedView({super.key, required this.controller});

  @override
  State<CompletedView> createState() => _CompletedViewState();
}

class _CompletedViewState extends State<CompletedView> {
  CompletedCategoryFilter _filter = CompletedCategoryFilter.all;

  @override
  Widget build(BuildContext context) {
    final completedTasks = widget.controller.completedTasks;
    final boughtShopping = widget.controller.boughtShoppingItems;
    final completedProjects = widget.controller.completedProjects;

    final totalCount = completedTasks.length + boughtShopping.length + completedProjects.length;

    // Assemble combined list of completed entries
    final entries = <_CompletedEntry>[];

    if (_filter == CompletedCategoryFilter.all || _filter == CompletedCategoryFilter.tasks) {
      for (final t in completedTasks) {
        entries.add(_CompletedEntry(
          id: t.id,
          title: t.title,
          category: 'Task',
          completedAt: t.completedAt ?? t.updatedAt,
          type: DetailType.task,
          rawItem: t,
          onRestore: () => widget.controller.uncompleteTask(t),
          onDelete: () => _confirmDeleteTask(t),
        ));
      }
    }

    if (_filter == CompletedCategoryFilter.all || _filter == CompletedCategoryFilter.shopping) {
      for (final s in boughtShopping) {
        entries.add(_CompletedEntry(
          id: s.id,
          title: s.title,
          category: 'Shopping',
          completedAt: s.boughtAt ?? s.updatedAt,
          type: DetailType.shopping,
          rawItem: s,
          onRestore: () => widget.controller.markShoppingItemUnbought(s),
          onDelete: () => _confirmDeleteShopping(s),
        ));
      }
    }

    if (_filter == CompletedCategoryFilter.all || _filter == CompletedCategoryFilter.projects) {
      for (final p in completedProjects) {
        entries.add(_CompletedEntry(
          id: p.id,
          title: p.title,
          category: 'Project',
          completedAt: p.completedAt ?? p.updatedAt,
          type: DetailType.project,
          rawItem: p,
          onRestore: () => widget.controller.setProjectCompleted(p, false),
          onDelete: () => _confirmDeleteProject(p),
        ));
      }
    }

    // Sort entries by completedAt descending
    entries.sort((a, b) => b.completedAt.compareTo(a.completedAt));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p32, vertical: AppSpacing.p8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter pills & Count
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: CompletedCategoryFilter.values.map((f) {
                  return Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.p8),
                    child: _FilterPill(
                      label: f.label,
                      isSelected: _filter == f,
                      onTap: () => setState(() => _filter = f),
                    ),
                  );
                }).toList(),
              ),
              Text(
                '$totalCount Completed Items',
                style: AppTypography.caption.copyWith(color: AppColors.textTertiary),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.p20),

          // Items list
          Expanded(
            child: entries.isEmpty
                ? const EmptyState(
                    title: 'Nothing completed yet.',
                    subtitle: 'Completed tasks, bought items, and finished projects will be stored here.',
                    icon: Icons.done_all_outlined,
                  )
                : ListView.builder(
                    itemCount: entries.length,
                    itemBuilder: (context, index) {
                      final entry = entries[index];
                      return _CompletedRowCard(
                        entry: entry,
                        onTap: () => widget.controller.openDetail(
                          entry.type,
                          entry.id,
                          entry.rawItem,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteTask(Task task) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Delete Completed Task',
      message: 'Permanently remove "${task.title}" from history?',
    );
    if (confirmed == true && mounted) {
      await widget.controller.deleteTask(task);
    }
  }

  Future<void> _confirmDeleteShopping(ShoppingItem item) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Delete Shopping Item',
      message: 'Permanently remove "${item.title}" from history?',
    );
    if (confirmed == true && mounted) {
      await widget.controller.deleteShoppingItem(item);
    }
  }

  Future<void> _confirmDeleteProject(Project project) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Delete Project',
      message: 'Permanently remove "${project.title}" from history?',
    );
    if (confirmed == true && mounted) {
      await widget.controller.deleteProject(project);
    }
  }
}

class _CompletedEntry {
  final String id;
  final String title;
  final String category;
  final DateTime completedAt;
  final DetailType type;
  final Object rawItem;
  final VoidCallback onRestore;
  final VoidCallback onDelete;

  const _CompletedEntry({
    required this.id,
    required this.title,
    required this.category,
    required this.completedAt,
    required this.type,
    required this.rawItem,
    required this.onRestore,
    required this.onDelete,
  });
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

class _CompletedRowCard extends StatefulWidget {
  final _CompletedEntry entry;
  final VoidCallback onTap;

  const _CompletedRowCard({
    required this.entry,
    required this.onTap,
  });

  @override
  State<_CompletedRowCard> createState() => _CompletedRowCardState();
}

class _CompletedRowCardState extends State<_CompletedRowCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: GlassCard(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p16, vertical: AppSpacing.p12),
          onTap: widget.onTap,
          child: Row(
            children: [
              // Checkbox indicating completed / restore on tap
              Tooltip(
                message: 'Restore to active',
                child: GestureDetector(
                  onTap: widget.entry.onRestore,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: AppColors.metallicWhite,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: AppColors.metallicWhite,
                        width: 1.2,
                      ),
                    ),
                    child: const Icon(
                      Icons.check,
                      size: 13,
                      color: Color(0xFF08090A),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.p16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.entry.title,
                      style: AppTypography.itemTitle.copyWith(
                        fontSize: 14.5,
                        decoration: TextDecoration.lineThrough,
                        color: AppColors.textTertiary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Completed ${AppDateUtils.formatRelativeOrDate(widget.entry.completedAt)}',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textDisabled,
                        fontSize: 11.0,
                      ),
                    ),
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
                  widget.entry.category,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textDisabled,
                    fontSize: 10.5,
                  ),
                ),
              ),
              if (_isHovered) ...[
                const SizedBox(width: AppSpacing.p8),
                GestureDetector(
                  onTap: widget.entry.onDelete,
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(Icons.delete_outline, size: 15, color: AppColors.danger),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
