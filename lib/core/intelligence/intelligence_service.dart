import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../../domain/models/intelligence_settings.dart';
import '../../domain/models/ml_event.dart';
import '../../domain/models/project.dart';
import '../../domain/models/task.dart';
import '../../domain/models/workspace_insights.dart';
import '../../domain/repositories/ml_event_repository.dart';
import '../../presentation/state/search_controller.dart';
import '../../presentation/state/workspace_controller.dart';
import 'behavior_analytics_engine.dart';
import 'priority_predictor.dart';
import 'related_items_detector.dart';
import 'semantic_search_engine.dart';
import 'smart_categorizer.dart';

class IntelligenceService extends ChangeNotifier {
  final MLEventRepository mlEventRepository;
  final _uuid = const Uuid();

  late final SmartCategorizer _categorizer;
  late final SemanticSearchEngine _searchEngine;
  late final RelatedItemsDetector _relatedDetector;
  late final PriorityPredictor _priorityPredictor;
  late final BehaviorAnalyticsEngine _analyticsEngine;

  IntelligenceSettings _settings = const IntelligenceSettings();
  IntelligenceSettings get settings => _settings;

  IntelligenceService({required this.mlEventRepository}) {
    _categorizer = SmartCategorizer();
    _searchEngine = SemanticSearchEngine();
    _relatedDetector = RelatedItemsDetector();
    _priorityPredictor = PriorityPredictor();
    _analyticsEngine = BehaviorAnalyticsEngine();
    _loadFeedbackAndSettings();
  }

  Future<void> _loadFeedbackAndSettings() async {
    try {
      final feedback = await mlEventRepository.getCategoryOverrideFeedback();
      _categorizer.updateFeedback(feedback);
    } catch (_) {
      // Graceful fallback
    }
  }

  void updateSettings(IntelligenceSettings newSettings) {
    _settings = newSettings;
    notifyListeners();
  }

  // --- 1. Event Tracking ---
  Future<void> recordEvent({
    required MLEventType eventType,
    String? itemType,
    String? itemId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final event = MLEvent(
        id: _uuid.v4(),
        eventType: eventType,
        itemType: itemType,
        itemId: itemId,
        metadata: metadata,
        createdAt: DateTime.now(),
      );
      await mlEventRepository.recordEvent(event);
    } catch (_) {
      // Fail safely without disrupting UI
    }
  }

  // --- 2. Smart Categorization ---
  CategorizationResult? categorize(String input) {
    if (!_settings.enableSmartCategorization) return null;
    try {
      return _categorizer.categorize(input);
    } catch (_) {
      return null;
    }
  }

  Future<void> recordCategoryOverride({
    required String inputText,
    required DetailType suggestedType,
    required DetailType userChosenType,
  }) async {
    if (suggestedType == userChosenType) return;
    _categorizer.addSingleFeedback(inputText, userChosenType);

    await recordEvent(
      eventType: MLEventType.categorySuggestionOverridden,
      itemType: userChosenType.name,
      metadata: {
        'inputText': inputText,
        'suggestedType': suggestedType.name,
        'userChosenType': userChosenType.name,
      },
    );
  }

  // --- 3. Semantic Search ---
  List<ScoredSearchResult> semanticSearch(String query, List<SearchResultItem> items) {
    if (!_settings.enableSemanticSearch) {
      return items.where((i) {
        final q = query.toLowerCase();
        return i.title.toLowerCase().contains(q) || (i.subtitle?.toLowerCase().contains(q) ?? false);
      }).map((i) => ScoredSearchResult(item: i, score: 1.0, isSemanticMatch: false)).toList();
    }

    try {
      return _searchEngine.search(query, items);
    } catch (_) {
      return [];
    }
  }

  // --- 4. Related Items Detection ---
  List<RelatedItemMatch> findRelated({
    required String candidateTitle,
    String? candidateProjectId,
    String? currentItemId,
    required List<Task> tasks,
    required List<Project> projects,
  }) {
    if (!_settings.enableRelatedItemDetection) return [];
    try {
      return _relatedDetector.findRelated(
        candidateTitle: candidateTitle,
        candidateProjectId: candidateProjectId,
        currentItemId: currentItemId,
        tasks: tasks,
        projects: projects,
        otherItems: const [],
      );
    } catch (_) {
      return [];
    }
  }

  // --- 5. Priority Prediction ---
  List<PrioritizedFocusItem> predictFocus({
    required List<Task> activeTasks,
    required List<Project> activeProjects,
  }) {
    if (!_settings.enablePriorityPrediction) return [];
    try {
      return _priorityPredictor.computeTodaysFocus(
        activeTasks: activeTasks,
        activeProjects: activeProjects,
      );
    } catch (_) {
      return [];
    }
  }

  // --- 6. Behavior Analytics ---
  WorkspaceInsights getInsights({
    required WorkspaceController controller,
  }) {
    try {
      return _analyticsEngine.computeInsights(
        activeTasks: controller.activeTasks,
        completedTasks: controller.completedTasks,
        activeProjects: controller.activeProjects,
        completedProjects: controller.completedProjects,
        workouts: controller.allWorkouts,
        contentItems: controller.contentItems,
        notes: controller.notes,
        toBuyShopping: controller.toBuyShoppingItems,
        boughtShopping: controller.boughtShoppingItems,
      );
    } catch (_) {
      return WorkspaceInsights.empty();
    }
  }

  Future<int> getEventCount() async {
    return await mlEventRepository.getEventCount();
  }

  Future<void> clearLearningData() async {
    await mlEventRepository.clearAllEvents();
    _categorizer.updateFeedback({});
    notifyListeners();
  }
}
