import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/radii.dart';
import '../../../core/constants/spacing.dart';
import '../../../core/constants/typography.dart';
import '../../../core/intelligence/related_items_detector.dart';
import '../../../core/intelligence/smart_categorizer.dart';
import '../../../domain/models/task.dart';
import '../../../domain/models/workout.dart';
import '../../state/workspace_controller.dart';
import '../glass/glass_button.dart';
import '../glass/glass_input.dart';
import '../glass/glass_surface.dart';

class QuickAddModal extends StatefulWidget {
  final WorkspaceController controller;

  const QuickAddModal({super.key, required this.controller});

  @override
  State<QuickAddModal> createState() => _QuickAddModalState();
}

class _QuickAddModalState extends State<QuickAddModal> {
  DetailType _selectedType = DetailType.task;
  bool _userManuallySelectedType = false;

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _notesController = TextEditingController();

  // Task specific
  TaskPriority _taskPriority = TaskPriority.none;
  DateTime? _taskDueDate;
  String? _taskProjectId;

  // Workout specific
  final _workoutTargetTimeController = TextEditingController(text: '18:00');
  final _workoutDurationController = TextEditingController(text: '45');
  final _workoutFirstExerciseController = TextEditingController();

  // Content specific
  String _contentType = 'Idea';

  bool _isSubmitting = false;

  // Intelligence State
  CategorizationResult? _currentSuggestion;
  List<RelatedItemMatch> _relatedItems = [];

  @override
  void initState() {
    super.initState();
    _titleController.addListener(_onTitleChanged);
  }

  @override
  void dispose() {
    _titleController.removeListener(_onTitleChanged);
    _titleController.dispose();
    _descriptionController.dispose();
    _notesController.dispose();
    _workoutTargetTimeController.dispose();
    _workoutDurationController.dispose();
    _workoutFirstExerciseController.dispose();
    super.dispose();
  }

  void _onTitleChanged() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      if (mounted) {
        setState(() {
          _currentSuggestion = null;
          _relatedItems = [];
        });
      }
      return;
    }

    // 1. Smart Categorization
    final suggestion = widget.controller.intelligenceService.categorize(title);

    // 2. Related items detection
    final related = widget.controller.intelligenceService.findRelated(
      candidateTitle: title,
      tasks: widget.controller.activeTasks,
      projects: widget.controller.activeProjects,
    );

    if (mounted) {
      setState(() {
        _currentSuggestion = suggestion;
        _relatedItems = related;
        if (!_userManuallySelectedType && suggestion != null && suggestion.confidence >= 0.7) {
          _selectedType = suggestion.type;
        }
      });
    }
  }

  void _selectType(DetailType type, {bool manual = true}) {
    setState(() {
      _selectedType = type;
      if (manual) _userManuallySelectedType = true;
    });
  }

  Future<void> _handleSave() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    setState(() => _isSubmitting = true);

    try {
      // Record category feedback if user overridden ML suggestion
      if (_currentSuggestion != null && _currentSuggestion!.type != _selectedType) {
        await widget.controller.intelligenceService.recordCategoryOverride(
          inputText: title,
          suggestedType: _currentSuggestion!.type,
          userChosenType: _selectedType,
        );
      }

      switch (_selectedType) {
        case DetailType.task:
          await widget.controller.createTask(
            title: title,
            description: _descriptionController.text.trim(),
            priority: _taskPriority,
            dueDate: _taskDueDate,
            projectId: _taskProjectId,
          );
          break;

        case DetailType.project:
          await widget.controller.createProject(
            title: title,
            description: _descriptionController.text.trim(),
          );
          break;

        case DetailType.workout:
          final duration = int.tryParse(_workoutDurationController.text.trim());
          final exName = _workoutFirstExerciseController.text.trim();
          final exercises = exName.isNotEmpty
              ? [
                  Exercise(
                    id: '',
                    workoutId: '',
                    name: exName,
                    sets: 3,
                    repetitions: 10,
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  )
                ]
              : <Exercise>[];

          await widget.controller.createWorkout(
            name: title,
            targetTime: _workoutTargetTimeController.text.trim(),
            estimatedDurationMinutes: duration,
            notes: _notesController.text.trim(),
            initialExercises: exercises,
          );
          break;

        case DetailType.content:
          await widget.controller.createContentItem(
            title: title,
            description: _descriptionController.text.trim(),
            contentType: _contentType,
            notes: _notesController.text.trim(),
          );
          break;

        case DetailType.note:
          await widget.controller.createNote(
            title: title,
            body: _descriptionController.text.trim(),
          );
          break;

        case DetailType.shopping:
          await widget.controller.createShoppingItem(
            title: title,
            notes: _notesController.text.trim(),
          );
          break;
      }

      widget.controller.closeQuickAdd();
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): widget.controller.closeQuickAdd,
      },
      child: Focus(
        autofocus: true,
        child: Stack(
          children: [
            // Backdrop dismissal
            Positioned.fill(
              child: GestureDetector(
                onTap: widget.controller.closeQuickAdd,
                child: Container(
                  color: Colors.black.withValues(alpha: 0.65),
                ),
              ),
            ),

            // Modal dialog
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 540,
                  maxHeight: 640,
                ),
                child: GlassSurface(
                  level: GlassLevel.elevated,
                  borderRadius: AppRadii.radius20,
                  padding: AppSpacing.insets24,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Add something',
                                style: AppTypography.cardTitle.copyWith(fontSize: 18),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'What is on your mind?',
                                style: AppTypography.caption.copyWith(color: AppColors.textTertiary),
                              ),
                            ],
                          ),
                          GlassIconButton(
                            icon: const Icon(Icons.close, size: 16),
                            onPressed: widget.controller.closeQuickAdd,
                          ),
                        ],
                      ),

                      const SizedBox(height: AppSpacing.p16),

                      // Type Selector Pills
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _TypePill(
                              label: 'Task',
                              icon: Icons.check_box_outlined,
                              isSelected: _selectedType == DetailType.task,
                              onTap: () => _selectType(DetailType.task),
                            ),
                            _TypePill(
                              label: 'Project',
                              icon: Icons.layers_outlined,
                              isSelected: _selectedType == DetailType.project,
                              onTap: () => _selectType(DetailType.project),
                            ),
                            _TypePill(
                              label: 'Workout',
                              icon: Icons.fitness_center_outlined,
                              isSelected: _selectedType == DetailType.workout,
                              onTap: () => _selectType(DetailType.workout),
                            ),
                            _TypePill(
                              label: 'Content',
                              icon: Icons.auto_awesome_outlined,
                              isSelected: _selectedType == DetailType.content,
                              onTap: () => _selectType(DetailType.content),
                            ),
                            _TypePill(
                              label: 'Note',
                              icon: Icons.description_outlined,
                              isSelected: _selectedType == DetailType.note,
                              onTap: () => _selectType(DetailType.note),
                            ),
                            _TypePill(
                              label: 'Shopping',
                              icon: Icons.shopping_bag_outlined,
                              isSelected: _selectedType == DetailType.shopping,
                              onTap: () => _selectType(DetailType.shopping),
                            ),
                          ],
                        ),
                      ),

                      // Smart Intelligence Suggestion & Related Items Banner
                      if (_currentSuggestion != null && _currentSuggestion!.confidence >= 0.6) ...[
                        const SizedBox(height: AppSpacing.p8),
                        GestureDetector(
                          onTap: () => _selectType(_currentSuggestion!.type, manual: false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppColors.glassSubtle,
                              borderRadius: AppRadii.radius8,
                              border: Border.all(color: AppColors.glassBorderSubtle, width: 0.5),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.auto_awesome, size: 12, color: AppColors.metallicWhite),
                                const SizedBox(width: 6),
                                Text(
                                  'Suggested: ${_capitalize(_currentSuggestion!.type.name)} (${(_currentSuggestion!.confidence * 100).toInt()}%)',
                                  style: AppTypography.caption.copyWith(
                                    color: AppColors.metallicWhite,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                if (_selectedType != _currentSuggestion!.type) ...[
                                  const SizedBox(width: 6),
                                  Text(
                                    '• Switch',
                                    style: AppTypography.caption.copyWith(
                                      color: AppColors.textSecondary,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ],

                      if (_relatedItems.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.p8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.glassSubtle,
                            borderRadius: AppRadii.radius8,
                            border: Border.all(color: AppColors.glassBorderSubtle, width: 0.5),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.info_outline, size: 13, color: AppColors.textSecondary),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Related item found: "${_relatedItems.first.title}"',
                                  style: AppTypography.caption.copyWith(
                                    color: AppColors.textSecondary,
                                    fontSize: 11,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: AppSpacing.p16),

                      // Title input
                      GlassTextField(
                        controller: _titleController,
                        autofocus: true,
                        hintText: _getTitleHint(),
                        labelText: _selectedType == DetailType.shopping ? 'ITEM NAME' : 'TITLE',
                        onSubmitted: (_) => _handleSave(),
                      ),

                      const SizedBox(height: AppSpacing.p12),

                      // Dynamic Fields based on Type
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (_selectedType == DetailType.task) ...[
                                GlassTextField(
                                  controller: _descriptionController,
                                  hintText: 'Optional description or notes',
                                  labelText: 'DESCRIPTION',
                                  maxLines: 3,
                                ),
                                const SizedBox(height: AppSpacing.p12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _PrioritySelector(
                                        selectedPriority: _taskPriority,
                                        onChanged: (p) => setState(() => _taskPriority = p),
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.p12),
                                    Expanded(
                                      child: _ProjectSelector(
                                        projects: widget.controller.activeProjects,
                                        selectedProjectId: _taskProjectId,
                                        onChanged: (id) => setState(() => _taskProjectId = id),
                                      ),
                                    ),
                                  ],
                                ),
                              ] else if (_selectedType == DetailType.project) ...[
                                GlassTextField(
                                  controller: _descriptionController,
                                  hintText: 'Project scope, goals, or summary',
                                  labelText: 'DESCRIPTION',
                                  maxLines: 3,
                                ),
                              ] else if (_selectedType == DetailType.workout) ...[
                                Row(
                                  children: [
                                    Expanded(
                                      child: GlassTextField(
                                        controller: _workoutTargetTimeController,
                                        hintText: '18:00',
                                        labelText: 'TIME',
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.p12),
                                    Expanded(
                                      child: GlassTextField(
                                        controller: _workoutDurationController,
                                        hintText: '45 mins',
                                        labelText: 'DURATION (MINS)',
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppSpacing.p12),
                                GlassTextField(
                                  controller: _workoutFirstExerciseController,
                                  hintText: 'e.g. Bench Press (3x10)',
                                  labelText: 'FIRST EXERCISE (OPTIONAL)',
                                ),
                              ] else if (_selectedType == DetailType.content) ...[
                                GlassTextField(
                                  controller: _descriptionController,
                                  hintText: 'Concept, outline, or key points',
                                  labelText: 'DESCRIPTION',
                                  maxLines: 3,
                                ),
                                const SizedBox(height: AppSpacing.p12),
                                Row(
                                  children: [
                                    _ContentTypePill(
                                      label: 'Idea',
                                      isSelected: _contentType == 'Idea',
                                      onTap: () => setState(() => _contentType = 'Idea'),
                                    ),
                                    const SizedBox(width: AppSpacing.p8),
                                    _ContentTypePill(
                                      label: 'Video',
                                      isSelected: _contentType == 'Video',
                                      onTap: () => setState(() => _contentType = 'Video'),
                                    ),
                                    const SizedBox(width: AppSpacing.p8),
                                    _ContentTypePill(
                                      label: 'Post',
                                      isSelected: _contentType == 'Post',
                                      onTap: () => setState(() => _contentType = 'Post'),
                                    ),
                                    const SizedBox(width: AppSpacing.p8),
                                    _ContentTypePill(
                                      label: 'Article',
                                      isSelected: _contentType == 'Article',
                                      onTap: () => setState(() => _contentType = 'Article'),
                                    ),
                                  ],
                                ),
                              ] else if (_selectedType == DetailType.note) ...[
                                GlassTextField(
                                  controller: _descriptionController,
                                  hintText: 'Write your thoughts, references, or notes...',
                                  labelText: 'CONTENT',
                                  maxLines: 5,
                                ),
                              ] else if (_selectedType == DetailType.shopping) ...[
                                GlassTextField(
                                  controller: _notesController,
                                  hintText: 'Optional notes (e.g. brand, quantity)',
                                  labelText: 'NOTES',
                                  maxLines: 2,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: AppSpacing.p16),

                      // Footer Actions
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          GlassButton(
                            text: 'Cancel',
                            onPressed: widget.controller.closeQuickAdd,
                          ),
                          const SizedBox(width: AppSpacing.p12),
                          GlassButton.primary(
                            text: 'Save',
                            isLoading: _isSubmitting,
                            onPressed: _handleSave,
                          ),
                        ],
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

  String _capitalize(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  String _getTitleHint() {
    switch (_selectedType) {
      case DetailType.task:
        return 'What do you need to finish?';
      case DetailType.project:
        return 'Project title (e.g. Data Science Project)';
      case DetailType.workout:
        return 'Workout routine name (e.g. Upper Body)';
      case DetailType.content:
        return 'Content title or topic';
      case DetailType.note:
        return 'Note title or topic';
      case DetailType.shopping:
        return 'Item to buy (e.g. Coffee, New mouse)';
    }
  }
}

class _TypePill extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypePill({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: AppSpacing.p8),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p12, vertical: AppSpacing.p8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.glassElevated : AppColors.glassSubtle,
          borderRadius: AppRadii.radius10,
          border: Border.all(
            color: isSelected ? AppColors.glassBorderStrong : AppColors.glassBorderSubtle,
            width: 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
            ),
            const SizedBox(width: AppSpacing.p8),
            Text(
              label,
              style: AppTypography.itemTitle.copyWith(
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContentTypePill extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ContentTypePill({
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

class _PrioritySelector extends StatelessWidget {
  final TaskPriority selectedPriority;
  final ValueChanged<TaskPriority> onChanged;

  const _PrioritySelector({
    required this.selectedPriority,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('PRIORITY', style: AppTypography.sectionHeader),
        const SizedBox(height: AppSpacing.p8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p12, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.glassSubtle,
            borderRadius: AppRadii.radius10,
            border: Border.all(color: AppColors.glassBorderSubtle, width: 1.0),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<TaskPriority>(
              value: selectedPriority,
              dropdownColor: AppColors.surfaceDark,
              isExpanded: true,
              style: AppTypography.itemTitle.copyWith(fontSize: 13),
              icon: const Icon(Icons.arrow_drop_down, color: AppColors.textTertiary),
              items: TaskPriority.values.map((p) {
                return DropdownMenuItem(
                  value: p,
                  child: Text(p.label),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) onChanged(val);
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _ProjectSelector extends StatelessWidget {
  final List<dynamic> projects;
  final String? selectedProjectId;
  final ValueChanged<String?> onChanged;

  const _ProjectSelector({
    required this.projects,
    required this.selectedProjectId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('PROJECT', style: AppTypography.sectionHeader),
        const SizedBox(height: AppSpacing.p8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p12, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.glassSubtle,
            borderRadius: AppRadii.radius10,
            border: Border.all(color: AppColors.glassBorderSubtle, width: 1.0),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String?>(
              value: selectedProjectId,
              dropdownColor: AppColors.surfaceDark,
              isExpanded: true,
              style: AppTypography.itemTitle.copyWith(fontSize: 13),
              icon: const Icon(Icons.arrow_drop_down, color: AppColors.textTertiary),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('None', style: TextStyle(color: AppColors.textTertiary)),
                ),
                ...projects.map((p) {
                  return DropdownMenuItem<String?>(
                    value: p.id as String,
                    child: Text(
                      p.title as String,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }),
              ],
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
