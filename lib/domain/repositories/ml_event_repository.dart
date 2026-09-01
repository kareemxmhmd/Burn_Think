import '../models/ml_event.dart';

abstract class MLEventRepository {
  Future<void> recordEvent(MLEvent event);
  Future<List<MLEvent>> getRecentEvents({int limit = 100});
  Future<List<MLEvent>> getEventsByType(MLEventType type, {int limit = 100});
  Future<int> getEventCount();
  Future<void> clearAllEvents();
  Future<Map<String, String>> getCategoryOverrideFeedback();
}
