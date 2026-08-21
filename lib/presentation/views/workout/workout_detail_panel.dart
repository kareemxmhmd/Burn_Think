import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/radii.dart';
import '../../../core/constants/spacing.dart';
import '../../../core/constants/typography.dart';
import '../../../domain/models/workout.dart';
import '../../state/workspace_controller.dart';
import '../../widgets/glass/glass_button.dart';
import '../../widgets/glass/glass_input.dart';
import '../../widgets/modals/confirm_dialog.dart';

class WorkoutDetailPanel extends StatefulWidget {
  final String? workoutId;
  final Workout? initialWorkout;
  final WorkspaceController controller;

  const WorkoutDetailPanel({
    super.key,
    this.workoutId,
    this.initialWorkout,
    required this.controller,
  });

  @override
  State<WorkoutDetailPanel> createState() => _WorkoutDetailPanelState();
}

class _WorkoutDetailPanelState extends State<WorkoutDetailPanel> {
  late final TextEditingController _nameController;
  late final TextEditingController _targetTimeController;
  late final TextEditingController _durationController;
  late final TextEditingController _notesController;

  // New exercise inputs
  final _newCategoryController = TextEditingController();
  final _newNameController = TextEditingController();
  final _newSetsController = TextEditingController(text: '3');
  final _newRepsController = TextEditingController(text: '10');
  final _newWeightController = TextEditingController();

  Workout? _currentWorkout;

  @override
  void initState() {
    super.initState();
    _currentWorkout = widget.initialWorkout ??
        widget.controller.allWorkouts.where((w) => w.id == widget.workoutId).firstOrNull;

    _nameController = TextEditingController(text: _currentWorkout?.name ?? '');
    _targetTimeController = TextEditingController(text: _currentWorkout?.targetTime ?? '18:00');
    _durationController = TextEditingController(
      text: _currentWorkout?.estimatedDurationMinutes != null
          ? '${_currentWorkout!.estimatedDurationMinutes}'
          : '45',
    );
    _notesController = TextEditingController(text: _currentWorkout?.notes ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _targetTimeController.dispose();
    _durationController.dispose();
    _notesController.dispose();
    _newCategoryController.dispose();
    _newNameController.dispose();
    _newSetsController.dispose();
    _newRepsController.dispose();
    _newWeightController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final duration = int.tryParse(_durationController.text.trim());

    if (_currentWorkout != null) {
      final updated = _currentWorkout!.copyWith(
        name: name,
        targetTime: _targetTimeController.text.trim(),
        estimatedDurationMinutes: duration,
        notes: _notesController.text.trim(),
      );
      await widget.controller.updateWorkout(updated);
    } else {
      await widget.controller.createWorkout(
        name: name,
        targetTime: _targetTimeController.text.trim(),
        estimatedDurationMinutes: duration,
        notes: _notesController.text.trim(),
      );
    }
    widget.controller.closeDetail();
  }

  Future<void> _handleAddExercise() async {
    final name = _newNameController.text.trim();
    if (name.isEmpty) return;

    if (_currentWorkout == null) {
      final wName = _nameController.text.trim();
      final workoutName = wName.isNotEmpty ? wName : 'New Workout';
      final duration = int.tryParse(_durationController.text.trim());
      final newW = await widget.controller.createWorkout(
        name: workoutName,
        targetTime: _targetTimeController.text.trim(),
        estimatedDurationMinutes: duration,
        notes: _notesController.text.trim(),
      );
      _currentWorkout = newW;
    }

    final sets = int.tryParse(_newSetsController.text.trim()) ?? 3;
    final reps = int.tryParse(_newRepsController.text.trim()) ?? 10;
    final weight = double.tryParse(_newWeightController.text.trim());
    final category = _newCategoryController.text.trim();

    final exercise = Exercise(
      id: '',
      workoutId: _currentWorkout!.id,
      category: category.isNotEmpty ? category : null,
      name: name,
      sets: sets,
      repetitions: reps,
      weight: weight,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await widget.controller.addExerciseToWorkout(_currentWorkout!.id, exercise);
    _newNameController.clear();
    _newWeightController.clear();

    setState(() {
      _currentWorkout = widget.controller.allWorkouts
          .where((w) => w.id == _currentWorkout!.id)
          .firstOrNull;
    });
  }

  Future<void> _handleDelete() async {
    if (_currentWorkout == null) return;
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Delete Workout',
      message: 'Are you sure you want to delete "${_currentWorkout!.name}" routine?',
    );
    if (confirmed == true && mounted) {
      await widget.controller.deleteWorkout(_currentWorkout!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final latestWorkout = _currentWorkout != null
        ? widget.controller.allWorkouts
                .where((w) => w.id == _currentWorkout!.id)
                .firstOrNull ??
            _currentWorkout
        : null;

    // Group exercises by category
    final groupedExercises = <String, List<Exercise>>{};
    if (latestWorkout != null) {
      for (final ex in latestWorkout.exercises) {
        final cat = ex.category?.trim().isNotEmpty == true ? ex.category! : 'General';
        groupedExercises.putIfAbsent(cat, () => []).add(ex);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.fitness_center_outlined, size: 18, color: AppColors.textSecondary),
                const SizedBox(width: AppSpacing.p8),
                Text(
                  _currentWorkout == null ? 'New Workout' : 'Workout Routine',
                  style: AppTypography.cardTitle,
                ),
              ],
            ),
            GlassIconButton(
              icon: const Icon(Icons.close, size: 16),
              onPressed: widget.controller.closeDetail,
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.p20),

        // Body
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GlassTextField(
                  controller: _nameController,
                  labelText: 'ROUTINE NAME',
                  hintText: 'e.g. Upper Body, Leg Day...',
                ),

                const SizedBox(height: AppSpacing.p16),

                Row(
                  children: [
                    Expanded(
                      child: GlassTextField(
                        controller: _targetTimeController,
                        labelText: 'TARGET TIME',
                        hintText: '18:00',
                      ),
                    ),
                    const SizedBox(width: AppSpacing.p12),
                    Expanded(
                      child: GlassTextField(
                        controller: _durationController,
                        labelText: 'EST. DURATION (MINS)',
                        hintText: '45',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.p16),

                if (latestWorkout != null) ...[
                  // Focus indicator toggle
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('CURRENT FOCUS', style: AppTypography.sectionHeader),
                      GlassButton(
                        text: latestWorkout.isCurrentFocus ? '● Focused' : 'Set as Focus',
                        variant: latestWorkout.isCurrentFocus
                            ? GlassButtonVariant.primary
                            : GlassButtonVariant.secondary,
                        height: 28,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        onPressed: () => widget.controller.setFocusWorkout(latestWorkout.id),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.p20),

                  // Exercises section
                  const Text('EXERCISES', style: AppTypography.sectionHeader),
                  const SizedBox(height: AppSpacing.p8),

                  // Add exercise box
                  Container(
                    padding: AppSpacing.insets12,
                    decoration: BoxDecoration(
                      color: AppColors.glassSubtle,
                      borderRadius: AppRadii.radius12,
                      border: Border.all(color: AppColors.glassBorderSubtle, width: 0.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: GlassTextField(
                                controller: _newCategoryController,
                                hintText: 'Category (e.g. Chest)',
                              ),
                            ),
                            const SizedBox(width: AppSpacing.p8),
                            Expanded(
                              flex: 3,
                              child: GlassTextField(
                                controller: _newNameController,
                                hintText: 'Exercise name',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.p8),
                        Row(
                          children: [
                            Expanded(
                              child: GlassTextField(
                                controller: _newSetsController,
                                hintText: 'Sets (3)',
                              ),
                            ),
                            const SizedBox(width: AppSpacing.p8),
                            Expanded(
                              child: GlassTextField(
                                controller: _newRepsController,
                                hintText: 'Reps (10)',
                              ),
                            ),
                            const SizedBox(width: AppSpacing.p8),
                            Expanded(
                              child: GlassTextField(
                                controller: _newWeightController,
                                hintText: 'kg (opt)',
                              ),
                            ),
                            const SizedBox(width: AppSpacing.p8),
                            GlassIconButton(
                              icon: const Icon(Icons.add, size: 16),
                              tooltip: 'Add Exercise',
                              onPressed: _handleAddExercise,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.p16),

                  if (latestWorkout.exercises.isEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.p12),
                      child: Text(
                        'No exercises in this routine yet.',
                        style: AppTypography.caption.copyWith(color: AppColors.textTertiary),
                      ),
                    ),
                  ] else ...[
                    ...groupedExercises.entries.map((entry) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 8, bottom: 4),
                            child: Text(
                              entry.key.toUpperCase(),
                              style: AppTypography.sectionHeader.copyWith(
                                color: AppColors.textTertiary,
                                fontSize: 10.5,
                              ),
                            ),
                          ),
                          ...entry.value.map((ex) {
                            return _ExerciseItemRow(
                              exercise: ex,
                              onDelete: () => widget.controller.deleteExercise(ex),
                            );
                          }),
                        ],
                      );
                    }),
                  ],
                ],
              ],
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.p16),

        // Footer
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (_currentWorkout != null)
              GlassIconButton(
                icon: const Icon(Icons.delete_outline, size: 16, color: AppColors.danger),
                tooltip: 'Delete Workout',
                onPressed: _handleDelete,
              )
            else
              const SizedBox.shrink(),
            Row(
              children: [
                GlassButton(
                  text: 'Cancel',
                  onPressed: widget.controller.closeDetail,
                ),
                const SizedBox(width: AppSpacing.p12),
                GlassButton.primary(
                  text: 'Save',
                  onPressed: _handleSave,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class _ExerciseItemRow extends StatefulWidget {
  final Exercise exercise;
  final VoidCallback onDelete;

  const _ExerciseItemRow({
    required this.exercise,
    required this.onDelete,
  });

  @override
  State<_ExerciseItemRow> createState() => _ExerciseItemRowState();
}

class _ExerciseItemRowState extends State<_ExerciseItemRow> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final weightStr = widget.exercise.weight != null ? ' • ${widget.exercise.weight} kg' : '';

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p12, vertical: AppSpacing.p8),
        decoration: BoxDecoration(
          color: _isHovered ? AppColors.glassHover : AppColors.glassSubtle,
          borderRadius: AppRadii.radius8,
          border: Border.all(
            color: _isHovered ? AppColors.glassBorderStandard : AppColors.glassBorderSubtle,
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.exercise.name,
                    style: AppTypography.itemTitle.copyWith(fontSize: 13.5),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${widget.exercise.sets} × ${widget.exercise.repetitions}$weightStr',
                    style: AppTypography.caption.copyWith(color: AppColors.textTertiary),
                  ),
                ],
              ),
            ),
            if (_isHovered)
              GestureDetector(
                onTap: widget.onDelete,
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(Icons.close, size: 14, color: AppColors.textTertiary),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
