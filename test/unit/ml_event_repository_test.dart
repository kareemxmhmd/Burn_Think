import 'package:flutter_test/flutter_test.dart';
import 'package:burn_think/core/database/app_database.dart';
import 'package:burn_think/data/repositories/sqlite_ml_event_repository.dart';
import 'package:burn_think/domain/models/ml_event.dart';

void main() {
  group('SqliteMLEventRepository Persistence Tests', () {
    late AppDatabase appDatabase;
    late SqliteMLEventRepository repository;

    setUp(() async {
      appDatabase = await AppDatabase.createInMemory();
      repository = SqliteMLEventRepository(appDatabase: appDatabase);
    });

    tearDown(() async {
      await appDatabase.close();
    });

    test('Records events and counts correctly', () async {
      final now = DateTime.now();
      await repository.recordEvent(MLEvent(
        id: 'ev-1',
        eventType: MLEventType.itemCreated,
        itemType: 'task',
        itemId: 't-1',
        metadata: {'title': 'My task'},
        createdAt: now,
      ));

      await repository.recordEvent(MLEvent(
        id: 'ev-2',
        eventType: MLEventType.searchPerformed,
        metadata: {'query': 'test query'},
        createdAt: now,
      ));

      final count = await repository.getEventCount();
      expect(count, equals(2));

      final recent = await repository.getRecentEvents();
      expect(recent.length, equals(2));

      final createdEvents = await repository.getEventsByType(MLEventType.itemCreated);
      expect(createdEvents.length, equals(1));
      expect(createdEvents.first.id, equals('ev-1'));
    });

    test('Retrieves category override feedback correctly', () async {
      await repository.recordEvent(MLEvent(
        id: 'ev-override',
        eventType: MLEventType.categorySuggestionOverridden,
        itemType: 'shopping',
        metadata: {
          'inputText': 'Buy specialized tool',
          'suggestedType': 'task',
          'userChosenType': 'shopping',
        },
        createdAt: DateTime.now(),
      ));

      final feedback = await repository.getCategoryOverrideFeedback();
      expect(feedback['buy specialized tool'], equals('shopping'));
    });

    test('Clears all recorded events', () async {
      await repository.recordEvent(MLEvent(
        id: 'ev-1',
        eventType: MLEventType.itemCreated,
        createdAt: DateTime.now(),
      ));

      expect(await repository.getEventCount(), equals(1));
      await repository.clearAllEvents();
      expect(await repository.getEventCount(), equals(0));
    });
  });
}
