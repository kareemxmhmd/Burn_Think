import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/spacing.dart';
import '../../../core/constants/typography.dart';
import '../../../domain/models/note.dart';
import '../../state/workspace_controller.dart';
import '../../widgets/feedback/empty_state.dart';
import '../../widgets/glass/glass_button.dart';
import '../../widgets/glass/glass_card.dart';

class NotesView extends StatelessWidget {
  final WorkspaceController controller;

  const NotesView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final notes = controller.notes;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p32, vertical: AppSpacing.p8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${notes.length} Notes Saved',
                style: AppTypography.itemTitle.copyWith(color: AppColors.textSecondary),
              ),
              GlassButton.primary(
                icon: const Icon(Icons.add, size: 16, color: Color(0xFF08090A)),
                text: 'New Note',
                onPressed: () => controller.openDetail(DetailType.note),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.p20),

          // Notes Grid
          Expanded(
            child: notes.isEmpty
                ? EmptyState(
                    title: 'No notes yet.',
                    subtitle: 'Capture anything you want to remember or keep.',
                    actionLabel: 'Write Note',
                    icon: Icons.description_outlined,
                    onAction: () => controller.openDetail(DetailType.note),
                  )
                : LayoutBuilder(
                    builder: (context, constraints) {
                      final crossAxisCount = constraints.maxWidth > 800 ? 3 : (constraints.maxWidth > 500 ? 2 : 1);

                      return GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 1.3,
                        ),
                        itemCount: notes.length,
                        itemBuilder: (context, index) {
                          final note = notes[index];
                          return _NoteGridCard(
                            note: note,
                            onTap: () => controller.openDetail(DetailType.note, note.id, note),
                            onTogglePin: () => controller.togglePinNote(note),
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

class _NoteGridCard extends StatelessWidget {
  final Note note;
  final VoidCallback onTap;
  final VoidCallback onTogglePin;

  const _NoteGridCard({
    required this.note,
    required this.onTap,
    required this.onTogglePin,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: AppSpacing.insets16,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  note.title,
                  style: AppTypography.cardTitle.copyWith(fontSize: 15),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              GestureDetector(
                onTap: onTogglePin,
                child: Icon(
                  note.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                  size: 14,
                  color: note.isPinned ? AppColors.metallicWhite : AppColors.textTertiary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Expanded(
            child: Text(
              note.body,
              style: AppTypography.body.copyWith(
                color: AppColors.textSecondary,
                fontSize: 13,
                height: 1.35,
              ),
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
