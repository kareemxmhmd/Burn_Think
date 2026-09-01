import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../../core/services/toast_service.dart';
import '../../domain/models/task.dart';
import '../../domain/models/project.dart';
import '../../domain/models/workout.dart';
import '../../domain/models/content_item.dart';
import '../../domain/models/note.dart';
import '../../domain/models/shopping_item.dart';
import '../../domain/models/workspace_stats.dart';
import '../../domain/repositories/task_repository.dart';
import '../../domain/repositories/project_repository.dart';
import '../../domain/repositories/workout_repository.dart';
import '../../domain/repositories/content_repository.dart';
import '../../domain/repositories/note_repository.dart';
import '../../domain/repositories/shopping_repository.dart';

import '../../core/intelligence/intelligence_service.dart';
import '../../core/intelligence/priority_predictor.dart';
import '../../data/repositories/sqlite_ml_event_repository.dart';
import '../../domain/models/ml_event.dart';
import '../../domain/models/workspace_insights.dart';
import '../../domain/repositories/ml_event_repository.dart';

enum AppSection {
  home('Home'),
  tasks('Tasks'),
  projects('Projects'),
  workout('Workout'),
  content('Content'),
  notes('Notes'),
  shopping('Shopping'),
  completed('Completed'),
  settings('Settings');

  final String title;
  const AppSection(this.title);
}

enum DetailType {
  task,
  project,
  workout,
  content,
  note,
  shopping,
}

class DetailPanelTarget {
  final DetailType type;
  final String? id; // null means create new within detail panel
  final Object? initialData;

  const DetailPanelTarget({
    required this.type,
    this.id,
    this.initialData,
  });
}

class WorkspaceController extends ChangeNotifier {
  final TaskRepository taskRepository;
  final ProjectRepository projectRepository;
  final WorkoutRepository workoutRepository;
  final ContentRepository contentRepository;
  final NoteRepository noteRepository;
  final ShoppingRepository shoppingRepository;
  final IntelligenceService intelligenceService;
  final ToastService _toastService;

  final _uuid = const Uuid();

  WorkspaceController({
    required this.taskRepository,
    required this.projectRepository,
    required this.workoutRepository,
    required this.contentRepository,
    required this.noteRepository,
    required this.shoppingRepository,
    MLEventRepository? mlEventRepository,
    IntelligenceService? intelligenceService,
    ToastService? toastService,
  })  : _toastService = toastService ?? ToastService.instance,
        intelligenceService = intelligenceService ??
            IntelligenceService(
              mlEventRepository: mlEventRepository ?? SqliteMLEventRepository(),
            );

  // UI State
  AppSection _currentSection = AppSection.home;
  AppSection get currentSection => _currentSection;

  DetailPanelTarget? _detailTarget;
  DetailPanelTarget? get detailTarget => _detailTarget;
  bool get isDetailOpen => _detailTarget != null;

  bool _isQuickAddOpen = false;
  bool get isQuickAddOpen => _isQuickAddOpen;

  bool _isSearchOpen = false;
  bool get isSearchOpen => _isSearchOpen;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Workspace Data Collections
  List<Task> _activeTasks = [];
  List<Task> get activeTasks => _activeTasks;

  List<Task> _completedTasks = [];
  List<Task> get completedTasks => _completedTasks;

  List<Project> _activeProjects = [];
  List<Project> get activeProjects => _activeProjects;

  List<Project> _completedProjects = [];
  List<Project> get completedProjects => _completedProjects;

  List<Workout> _allWorkouts = [];
  List<Workout> get allWorkouts => _allWorkouts;

  Workout? _currentFocusWorkout;
  Workout? get currentFocusWorkout => _currentFocusWorkout;

  List<ContentItem> _contentItems = [];
  List<ContentItem> get contentItems => _contentItems;

  List<Note> _notes = [];
  List<Note> get notes => _notes;

  Note? _quickNote;
  Note? get quickNote => _quickNote;

  List<ShoppingItem> _toBuyShoppingItems = [];
  List<ShoppingItem> get toBuyShoppingItems => _toBuyShoppingItems;

  List<ShoppingItem> _boughtShoppingItems = [];
  List<ShoppingItem> get boughtShoppingItems => _boughtShoppingItems;

  WorkspaceStats _stats = const WorkspaceStats();
  WorkspaceStats get stats => _stats;

  // Intelligence Getters
  List<PrioritizedFocusItem> get todaysFocus =>
      intelligenceService.predictFocus(
        activeTasks: _activeTasks,
        activeProjects: _activeProjects,
      );

  WorkspaceInsights get insights =>
      intelligenceService.getInsights(controller: this);

  // Navigation
  void navigateTo(AppSection section) {
    _currentSection = section;
    closeDetail();
    notifyListeners();

    switch (section) {
      case AppSection.projects:
        intelligenceService.recordEvent(eventType: MLEventType.projectOpened);
        break;
      case AppSection.workout:
        intelligenceService.recordEvent(eventType: MLEventType.workoutOpened);
        break;
      case AppSection.content:
        intelligenceService.recordEvent(eventType: MLEventType.contentOpened);
        break;
      case AppSection.notes:
        intelligenceService.recordEvent(eventType: MLEventType.noteOpened);
        break;
      default:
        break;
    }
  }

  // Detail Panel
  void openDetail(DetailType type, [String? id, Object? initialData]) {
    _detailTarget = DetailPanelTarget(type: type, id: id, initialData: initialData);
    notifyListeners();
  }

  void closeDetail() {
    if (_detailTarget != null) {
      _detailTarget = null;
      notifyListeners();
    }
  }

  // Quick Add
  void openQuickAdd() {
    _isQuickAddOpen = true;
    intelligenceService.recordEvent(eventType: MLEventType.quickAddUsed);
    notifyListeners();
  }

  void closeQuickAdd() {
    _isQuickAddOpen = false;
    notifyListeners();
  }

  // Search
  void openSearch() {
    _isSearchOpen = true;
    notifyListeners();
  }

  void closeSearch() {
    _isSearchOpen = false;
    notifyListeners();
  }

  // Data Loading
  Future<void> loadWorkspace() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await refreshAllData();
    } catch (e) {
      _errorMessage = 'Failed to load workspace data: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshAllData() async {
    final activeTasks = await taskRepository.getActiveTasks();
    final completedTasks = await taskRepository.getCompletedTasks();
    final activeProjects = await projectRepository.getActiveProjects();
    final completedProjects = await projectRepository.getCompletedProjects();
    final workouts = await workoutRepository.getAllWorkouts();
    final focusWorkout = await workoutRepository.getCurrentFocusWorkout();
    final content = await contentRepository.getAllContentItems();
    final notesList = await noteRepository.getAllNotes();
    final quickNote = await noteRepository.getQuickNote();
    final toBuy = await shoppingRepository.getToBuyItems();
    final bought = await shoppingRepository.getBoughtItems();

    _activeTasks = activeTasks;
    _completedTasks = completedTasks;
    _activeProjects = activeProjects;
    _completedProjects = completedProjects;
    _allWorkouts = workouts;
    _currentFocusWorkout = focusWorkout;
    _contentItems = content;
    _notes = notesList;
    _quickNote = quickNote;
    _toBuyShoppingItems = toBuy;
    _boughtShoppingItems = bought;

    _stats = WorkspaceStats(
      activeTasksCount: activeTasks.length,
      totalTasksCount: activeTasks.length + completedTasks.length,
      activeProjectsCount: activeProjects.length,
      completedProjectsCount: completedProjects.length,
      workoutsCount: workouts.length,
      contentItemsCount: content.length,
      notesCount: notesList.length,
      shoppingItemsToBuyCount: toBuy.length,
      completedItemsTotalCount: completedTasks.length + bought.length + completedProjects.length,
    );

    notifyListeners();
  }

  // ==========================================
  // TASK OPERATIONS
  // ==========================================
  Future<void> createTask({
    required String title,
    String? description,
    TaskPriority priority = TaskPriority.none,
    DateTime? dueDate,
    String? projectId,
  }) async {
    try {
      final now = DateTime.now();
      final task = Task(
        id: _uuid.v4(),
        title: title.trim(),
        description: description?.trim().isEmpty == true ? null : description?.trim(),
        priority: priority,
        dueDate: dueDate,
        projectId: projectId,
        createdAt: now,
        updatedAt: now,
      );
      await taskRepository.insertTask(task);
      intelligenceService.recordEvent(
        eventType: MLEventType.itemCreated,
        itemType: 'task',
        itemId: task.id,
        metadata: {'title': task.title, 'priority': task.priority.name},
      );
      await refreshAllData();
    } catch (e) {
      _toastService.show('Failed to create task: $e');
    }
  }

  Future<void> updateTask(Task task) async {
    try {
      final updated = task.copyWith(updatedAt: DateTime.now());
      await taskRepository.updateTask(updated);
      intelligenceService.recordEvent(
        eventType: MLEventType.itemEdited,
        itemType: 'task',
        itemId: updated.id,
      );
      await refreshAllData();
    } catch (e) {
      _toastService.show('Failed to update task: $e');
    }
  }

  Future<void> completeTask(Task task) async {
    try {
      await taskRepository.setTaskCompleted(task.id, true);
      intelligenceService.recordEvent(
        eventType: MLEventType.itemCompleted,
        itemType: 'task',
        itemId: task.id,
      );
      await refreshAllData();

      _toastService.show(
        'Task completed',
        undoLabel: 'Undo',
        onUndo: () async {
          await taskRepository.setTaskCompleted(task.id, false);
          intelligenceService.recordEvent(
            eventType: MLEventType.itemReopened,
            itemType: 'task',
            itemId: task.id,
          );
          await refreshAllData();
        },
      );
    } catch (e) {
      _toastService.show('Failed to complete task: $e');
    }
  }

  Future<void> uncompleteTask(Task task) async {
    try {
      await taskRepository.setTaskCompleted(task.id, false);
      intelligenceService.recordEvent(
        eventType: MLEventType.itemReopened,
        itemType: 'task',
        itemId: task.id,
      );
      await refreshAllData();
      _toastService.show(
        'Task restored to active',
        undoLabel: 'Undo',
        onUndo: () async {
          await taskRepository.setTaskCompleted(task.id, true);
          await refreshAllData();
        },
      );
    } catch (e) {
      _toastService.show('Failed to restore task: $e');
    }
  }

  Future<void> deleteTask(Task task) async {
    try {
      await taskRepository.deleteTask(task.id);
      intelligenceService.recordEvent(
        eventType: MLEventType.itemDeleted,
        itemType: 'task',
        itemId: task.id,
      );
      await refreshAllData();
      if (_detailTarget?.id == task.id) closeDetail();

      _toastService.show(
        'Task deleted',
        undoLabel: 'Undo',
        onUndo: () async {
          await taskRepository.insertTask(task);
          intelligenceService.recordEvent(
            eventType: MLEventType.itemRestored,
            itemType: 'task',
            itemId: task.id,
          );
          await refreshAllData();
        },
      );
    } catch (e) {
      _toastService.show('Failed to delete task: $e');
    }
  }
  // ==========================================
  // PROJECT OPERATIONS
  // ==========================================
  Future<Project> createProject({
    required String title,
    String? description,
    DateTime? dueDate,
    List<String> initialItemTitles = const [],
  }) async {
    final now = DateTime.now();
    final pId = _uuid.v4();
    final items = <ProjectItem>[];
    for (var i = 0; i < initialItemTitles.length; i++) {
      items.add(ProjectItem(
        id: _uuid.v4(),
        projectId: pId,
        title: initialItemTitles[i].trim(),
        sortOrder: i,
        createdAt: now,
        updatedAt: now,
      ));
    }

    final project = Project(
      id: pId,
      title: title.trim(),
      description: description?.trim().isEmpty == true ? null : description?.trim(),
      dueDate: dueDate,
      createdAt: now,
      updatedAt: now,
      items: items,
    );

    try {
      await projectRepository.insertProject(project);
      intelligenceService.recordEvent(
        eventType: MLEventType.itemCreated,
        itemType: 'project',
        itemId: project.id,
        metadata: {'title': project.title},
      );
      await refreshAllData();
    } catch (e) {
      _toastService.show('Failed to create project: $e');
    }
    return project;
  }

  Future<void> updateProject(Project project) async {
    try {
      final updated = project.copyWith(updatedAt: DateTime.now());
      await projectRepository.updateProject(updated);
      intelligenceService.recordEvent(
        eventType: MLEventType.itemEdited,
        itemType: 'project',
        itemId: updated.id,
      );
      await refreshAllData();
    } catch (e) {
      _toastService.show('Failed to update project: $e');
    }
  }

  Future<void> deleteProject(Project project) async {
    try {
      await projectRepository.deleteProject(project.id);
      intelligenceService.recordEvent(
        eventType: MLEventType.itemDeleted,
        itemType: 'project',
        itemId: project.id,
      );
      await refreshAllData();
      if (_detailTarget?.id == project.id) closeDetail();

      _toastService.show(
        'Project deleted',
        undoLabel: 'Undo',
        onUndo: () async {
          await projectRepository.insertProject(project);
          intelligenceService.recordEvent(
            eventType: MLEventType.itemRestored,
            itemType: 'project',
            itemId: project.id,
          );
          await refreshAllData();
        },
      );
    } catch (e) {
      _toastService.show('Failed to delete project: $e');
    }
  }

  Future<void> setProjectCompleted(Project project, bool isCompleted) async {
    try {
      await projectRepository.setProjectCompleted(project.id, isCompleted);
      intelligenceService.recordEvent(
        eventType: isCompleted ? MLEventType.itemCompleted : MLEventType.itemReopened,
        itemType: 'project',
        itemId: project.id,
      );
      await refreshAllData();
      _toastService.show(
        isCompleted ? 'Project marked completed' : 'Project restored to active',
        undoLabel: 'Undo',
        onUndo: () async {
          await projectRepository.setProjectCompleted(project.id, !isCompleted);
          intelligenceService.recordEvent(
            eventType: !isCompleted ? MLEventType.itemCompleted : MLEventType.itemReopened,
            itemType: 'project',
            itemId: project.id,
          );
          await refreshAllData();
        },
      );
    } catch (e) {
      _toastService.show('Failed to update project status: $e');
    }
  }

  Future<void> addProjectItem(String projectId, String title) async {
    try {
      final now = DateTime.now();
      final item = ProjectItem(
        id: _uuid.v4(),
        projectId: projectId,
        title: title.trim(),
        createdAt: now,
        updatedAt: now,
      );
      await projectRepository.insertProjectItem(item);
      await refreshAllData();
    } catch (e) {
      _toastService.show('Failed to add project item: $e');
    }
  }

  Future<void> updateProjectItemTitle(ProjectItem item, String newTitle) async {
    try {
      final updated = item.copyWith(
        title: newTitle.trim(),
        updatedAt: DateTime.now(),
      );
      await projectRepository.updateProjectItem(updated);
      await refreshAllData();
    } catch (e) {
      _toastService.show('Failed to update project item: $e');
    }
  }

  Future<void> toggleProjectItem(ProjectItem item, bool isCompleted) async {
    try {
      await projectRepository.setProjectItemCompleted(item.id, isCompleted);
      await refreshAllData();
    } catch (e) {
      _toastService.show('Failed to toggle project item: $e');
    }
  }

  Future<void> deleteProjectItem(ProjectItem item) async {
    try {
      await projectRepository.deleteProjectItem(item.id);
      await refreshAllData();
    } catch (e) {
      _toastService.show('Failed to delete project item: $e');
    }
  }

  // ==========================================
  // WORKOUT OPERATIONS
  // ==========================================
  Future<Workout> createWorkout({
    required String name,
    String? targetTime,
    int? estimatedDurationMinutes,
    String? notes,
    bool isCurrentFocus = true,
    List<Exercise> initialExercises = const [],
  }) async {
    final now = DateTime.now();
    final wId = _uuid.v4();

    final exercises = initialExercises.map((e) {
      return e.copyWith(workoutId: wId);
    }).toList();

    final workout = Workout(
      id: wId,
      name: name.trim(),
      targetTime: targetTime,
      estimatedDurationMinutes: estimatedDurationMinutes,
      notes: notes,
      isCurrentFocus: isCurrentFocus,
      createdAt: now,
      updatedAt: now,
      exercises: exercises,
    );

    try {
      await workoutRepository.insertWorkout(workout);
      intelligenceService.recordEvent(
        eventType: MLEventType.itemCreated,
        itemType: 'workout',
        itemId: workout.id,
        metadata: {'name': workout.name},
      );
      await refreshAllData();
    } catch (e) {
      _toastService.show('Failed to create workout: $e');
    }
    return workout;
  }

  Future<void> updateWorkout(Workout workout) async {
    try {
      final updated = workout.copyWith(updatedAt: DateTime.now());
      await workoutRepository.updateWorkout(updated);
      intelligenceService.recordEvent(
        eventType: MLEventType.itemEdited,
        itemType: 'workout',
        itemId: updated.id,
      );
      await refreshAllData();
    } catch (e) {
      _toastService.show('Failed to update workout: $e');
    }
  }

  Future<void> deleteWorkout(Workout workout) async {
    try {
      await workoutRepository.deleteWorkout(workout.id);
      intelligenceService.recordEvent(
        eventType: MLEventType.itemDeleted,
        itemType: 'workout',
        itemId: workout.id,
      );
      await refreshAllData();
      if (_detailTarget?.id == workout.id) closeDetail();

      _toastService.show(
        'Workout deleted',
        undoLabel: 'Undo',
        onUndo: () async {
          await workoutRepository.insertWorkout(workout);
          intelligenceService.recordEvent(
            eventType: MLEventType.itemRestored,
            itemType: 'workout',
            itemId: workout.id,
          );
          await refreshAllData();
        },
      );
    } catch (e) {
      _toastService.show('Failed to delete workout: $e');
    }
  }

  Future<void> setFocusWorkout(String workoutId) async {
    try {
      await workoutRepository.setCurrentFocusWorkout(workoutId);
      await refreshAllData();
    } catch (e) {
      _toastService.show('Failed to set focus workout: $e');
    }
  }

  Future<void> addExerciseToWorkout(String workoutId, Exercise exercise) async {
    try {
      final now = DateTime.now();
      final newEx = exercise.copyWith(
        id: exercise.id.isNotEmpty ? exercise.id : _uuid.v4(),
        workoutId: workoutId,
        createdAt: now,
        updatedAt: now,
      );
      await workoutRepository.insertExercise(newEx);
      await refreshAllData();
    } catch (e) {
      _toastService.show('Failed to add exercise: $e');
    }
  }

  Future<void> updateExercise(Exercise exercise) async {
    try {
      final updated = exercise.copyWith(updatedAt: DateTime.now());
      await workoutRepository.updateExercise(updated);
      await refreshAllData();
    } catch (e) {
      _toastService.show('Failed to update exercise: $e');
    }
  }

  Future<void> deleteExercise(Exercise exercise) async {
    try {
      await workoutRepository.deleteExercise(exercise.id);
      await refreshAllData();
    } catch (e) {
      _toastService.show('Failed to delete exercise: $e');
    }
  }

  Future<void> reorderExercises(String workoutId, List<String> exerciseIdsInOrder) async {
    try {
      await workoutRepository.reorderExercises(workoutId, exerciseIdsInOrder);
      await refreshAllData();
    } catch (e) {
      _toastService.show('Failed to reorder exercises: $e');
    }
  }

  // ==========================================
  // CONTENT OPERATIONS
  // ==========================================
  Future<void> createContentItem({
    required String title,
    String? description,
    String? contentType,
    String? duration,
    String? notes,
    String status = 'Idea',
  }) async {
    try {
      final now = DateTime.now();
      final item = ContentItem(
        id: _uuid.v4(),
        title: title.trim(),
        description: description?.trim().isEmpty == true ? null : description?.trim(),
        contentType: contentType,
        duration: duration,
        notes: notes,
        status: status,
        createdAt: now,
        updatedAt: now,
      );
      await contentRepository.insertContentItem(item);
      intelligenceService.recordEvent(
        eventType: MLEventType.itemCreated,
        itemType: 'content',
        itemId: item.id,
        metadata: {'title': item.title, 'contentType': item.contentType},
      );
      await refreshAllData();
    } catch (e) {
      _toastService.show('Failed to create content idea: $e');
    }
  }

  Future<void> updateContentItem(ContentItem item) async {
    try {
      final updated = item.copyWith(updatedAt: DateTime.now());
      await contentRepository.updateContentItem(updated);
      intelligenceService.recordEvent(
        eventType: MLEventType.itemEdited,
        itemType: 'content',
        itemId: updated.id,
      );
      await refreshAllData();
    } catch (e) {
      _toastService.show('Failed to update content idea: $e');
    }
  }

  Future<void> deleteContentItem(ContentItem item) async {
    try {
      await contentRepository.deleteContentItem(item.id);
      intelligenceService.recordEvent(
        eventType: MLEventType.itemDeleted,
        itemType: 'content',
        itemId: item.id,
      );
      await refreshAllData();
      if (_detailTarget?.id == item.id) closeDetail();

      _toastService.show(
        'Content idea deleted',
        undoLabel: 'Undo',
        onUndo: () async {
          await contentRepository.insertContentItem(item);
          intelligenceService.recordEvent(
            eventType: MLEventType.itemRestored,
            itemType: 'content',
            itemId: item.id,
          );
          await refreshAllData();
        },
      );
    } catch (e) {
      _toastService.show('Failed to delete content idea: $e');
    }
  }

  // ==========================================
  // NOTE OPERATIONS
  // ==========================================
  Future<void> createNote({
    required String title,
    required String body,
    bool isPinned = false,
  }) async {
    try {
      final now = DateTime.now();
      final note = Note(
        id: _uuid.v4(),
        title: title.trim(),
        body: body.trim(),
        isPinned: isPinned,
        createdAt: now,
        updatedAt: now,
      );
      await noteRepository.insertNote(note);
      intelligenceService.recordEvent(
        eventType: MLEventType.itemCreated,
        itemType: 'note',
        itemId: note.id,
        metadata: {'title': note.title},
      );
      await refreshAllData();
    } catch (e) {
      _toastService.show('Failed to create note: $e');
    }
  }

  Future<void> updateNote(Note note) async {
    try {
      final updated = note.copyWith(updatedAt: DateTime.now());
      await noteRepository.updateNote(updated);
      intelligenceService.recordEvent(
        eventType: MLEventType.itemEdited,
        itemType: 'note',
        itemId: updated.id,
      );
      await refreshAllData();
    } catch (e) {
      _toastService.show('Failed to update note: $e');
    }
  }

  Future<void> togglePinNote(Note note) async {
    try {
      await noteRepository.togglePinNote(note.id, !note.isPinned);
      await refreshAllData();
    } catch (e) {
      _toastService.show('Failed to toggle pin: $e');
    }
  }

  Future<void> deleteNote(Note note) async {
    try {
      await noteRepository.deleteNote(note.id);
      intelligenceService.recordEvent(
        eventType: MLEventType.itemDeleted,
        itemType: 'note',
        itemId: note.id,
      );
      await refreshAllData();
      if (_detailTarget?.id == note.id) closeDetail();

      _toastService.show(
        'Note deleted',
        undoLabel: 'Undo',
        onUndo: () async {
          await noteRepository.insertNote(note);
          intelligenceService.recordEvent(
            eventType: MLEventType.itemRestored,
            itemType: 'note',
            itemId: note.id,
          );
          await refreshAllData();
        },
      );
    } catch (e) {
      _toastService.show('Failed to delete note: $e');
    }
  }

  // ==========================================
  // SHOPPING OPERATIONS
  // ==========================================
  Future<void> createShoppingItem({
    required String title,
    String? notes,
  }) async {
    try {
      final now = DateTime.now();
      final item = ShoppingItem(
        id: _uuid.v4(),
        title: title.trim(),
        notes: notes?.trim().isEmpty == true ? null : notes?.trim(),
        createdAt: now,
        updatedAt: now,
      );
      await shoppingRepository.insertShoppingItem(item);
      intelligenceService.recordEvent(
        eventType: MLEventType.itemCreated,
        itemType: 'shopping',
        itemId: item.id,
        metadata: {'title': item.title},
      );
      await refreshAllData();
    } catch (e) {
      _toastService.show('Failed to create shopping item: $e');
    }
  }

  Future<void> updateShoppingItem(ShoppingItem item) async {
    try {
      final updated = item.copyWith(updatedAt: DateTime.now());
      await shoppingRepository.updateShoppingItem(updated);
      intelligenceService.recordEvent(
        eventType: MLEventType.itemEdited,
        itemType: 'shopping',
        itemId: updated.id,
      );
      await refreshAllData();
    } catch (e) {
      _toastService.show('Failed to update shopping item: $e');
    }
  }

  Future<void> markShoppingItemBought(ShoppingItem item) async {
    try {
      await shoppingRepository.setShoppingItemBought(item.id, true);
      intelligenceService.recordEvent(
        eventType: MLEventType.itemCompleted,
        itemType: 'shopping',
        itemId: item.id,
      );
      await refreshAllData();

      _toastService.show(
        'Item marked as bought',
        undoLabel: 'Undo',
        onUndo: () async {
          await shoppingRepository.setShoppingItemBought(item.id, false);
          intelligenceService.recordEvent(
            eventType: MLEventType.itemReopened,
            itemType: 'shopping',
            itemId: item.id,
          );
          await refreshAllData();
        },
      );
    } catch (e) {
      _toastService.show('Failed to mark item bought: $e');
    }
  }

  Future<void> markShoppingItemUnbought(ShoppingItem item) async {
    try {
      await shoppingRepository.setShoppingItemBought(item.id, false);
      intelligenceService.recordEvent(
        eventType: MLEventType.itemReopened,
        itemType: 'shopping',
        itemId: item.id,
      );
      await refreshAllData();
      _toastService.show(
        'Item moved back to To Buy',
        undoLabel: 'Undo',
        onUndo: () async {
          await shoppingRepository.setShoppingItemBought(item.id, true);
          intelligenceService.recordEvent(
            eventType: MLEventType.itemCompleted,
            itemType: 'shopping',
            itemId: item.id,
          );
          await refreshAllData();
        },
      );
    } catch (e) {
      _toastService.show('Failed to restore shopping item: $e');
    }
  }

  Future<void> deleteShoppingItem(ShoppingItem item) async {
    try {
      await shoppingRepository.deleteShoppingItem(item.id);
      intelligenceService.recordEvent(
        eventType: MLEventType.itemDeleted,
        itemType: 'shopping',
        itemId: item.id,
      );
      await refreshAllData();
      if (_detailTarget?.id == item.id) closeDetail();

      _toastService.show(
        'Shopping item deleted',
        undoLabel: 'Undo',
        onUndo: () async {
          await shoppingRepository.insertShoppingItem(item);
          intelligenceService.recordEvent(
            eventType: MLEventType.itemRestored,
            itemType: 'shopping',
            itemId: item.id,
          );
          await refreshAllData();
        },
      );
    } catch (e) {
      _toastService.show('Failed to delete shopping item: $e');
    }
  }
}
