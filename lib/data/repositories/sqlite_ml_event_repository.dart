import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../../core/database/app_database.dart';
import '../../domain/models/ml_event.dart';
import '../../domain/repositories/ml_event_repository.dart';

class SqliteMLEventRepository implements MLEventRepository {
  final AppDatabase appDatabase;

  SqliteMLEventRepository({AppDatabase? appDatabase})
      : appDatabase = appDatabase ?? AppDatabase.instance;

  @override
  Future<void> recordEvent(MLEvent event) async {
    try {
      final db = await appDatabase.database;
      await db.insert(
        'ml_events',
        event.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (_) {
      // Graceful ML failure handling (PRD §36)
    }
  }

  @override
  Future<List<MLEvent>> getRecentEvents({int limit = 100}) async {
    try {
      final db = await appDatabase.database;
      final maps = await db.query(
        'ml_events',
        orderBy: 'createdAt DESC',
        limit: limit,
      );
      return maps.map((m) => MLEvent.fromMap(m)).toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<List<MLEvent>> getEventsByType(MLEventType type, {int limit = 100}) async {
    try {
      final db = await appDatabase.database;
      final maps = await db.query(
        'ml_events',
        where: 'eventType = ?',
        whereArgs: [type.name],
        orderBy: 'createdAt DESC',
        limit: limit,
      );
      return maps.map((m) => MLEvent.fromMap(m)).toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<int> getEventCount() async {
    try {
      final db = await appDatabase.database;
      final result = await db.rawQuery('SELECT COUNT(*) as count FROM ml_events');
      return (result.firstOrNull?['count'] as int?) ?? 0;
    } catch (_) {
      return 0;
    }
  }

  @override
  Future<void> clearAllEvents() async {
    try {
      final db = await appDatabase.database;
      await db.delete('ml_events');
    } catch (_) {
      // Fallback
    }
  }

  @override
  Future<Map<String, String>> getCategoryOverrideFeedback() async {
    try {
      final events = await getEventsByType(
        MLEventType.categorySuggestionOverridden,
        limit: 200,
      );
      final map = <String, String>{};
      for (final ev in events) {
        if (ev.metadata != null &&
            ev.metadata!['inputText'] != null &&
            ev.metadata!['userChosenType'] != null) {
          final text = (ev.metadata!['inputText'] as String).trim().toLowerCase();
          final chosen = ev.metadata!['userChosenType'] as String;
          if (text.isNotEmpty) {
            map[text] = chosen;
          }
        }
      }
      return map;
    } catch (_) {
      return {};
    }
  }
}
