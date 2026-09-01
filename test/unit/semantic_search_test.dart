import 'package:flutter_test/flutter_test.dart';
import 'package:burn_think/core/intelligence/semantic_search_engine.dart';
import 'package:burn_think/presentation/state/search_controller.dart';
import 'package:burn_think/presentation/state/workspace_controller.dart';

void main() {
  group('SemanticSearchEngine Tests', () {
    late SemanticSearchEngine engine;
    late List<SearchResultItem> sampleItems;

    setUp(() {
      engine = SemanticSearchEngine();
      sampleItems = [
        const SearchResultItem(
          id: '1',
          type: DetailType.task,
          title: 'ML deployment with Docker',
          subtitle: 'Task • Active',
          category: 'Tasks',
          item: 'ML deployment with Docker',
        ),
        const SearchResultItem(
          id: '2',
          type: DetailType.task,
          title: 'Deploy model API to production',
          subtitle: 'Task • Active',
          category: 'Tasks',
          item: 'Deploy model API to production',
        ),
        const SearchResultItem(
          id: '3',
          type: DetailType.project,
          title: 'Customer Churn Model',
          subtitle: 'Project • 50% complete',
          category: 'Projects',
          item: 'Customer Churn Model',
        ),
        const SearchResultItem(
          id: '4',
          type: DetailType.shopping,
          title: 'Buy fresh coffee beans',
          subtitle: 'Shopping • To Buy',
          category: 'Shopping',
          item: 'Buy fresh coffee beans',
        ),
      ];
    });

    test('Finds exact match and ranks it highest', () {
      final results = engine.search('coffee beans', sampleItems);
      expect(results.isNotEmpty, isTrue);
      expect(results.first.item.id, equals('4'));
      expect(results.first.score, equals(1.0));
    });

    test('Finds semantic matches using synonyms and cluster tokens (PRD §25 example)', () {
      final results = engine.search('the thing about deploying the model', sampleItems);
      expect(results.isNotEmpty, isTrue);
      final matchedIds = results.map((r) => r.item.id).toList();
      expect(matchedIds.contains('1') || matchedIds.contains('2'), isTrue);
    });

    test('Returns empty list for empty or space-only query', () {
      expect(engine.search('', sampleItems), isEmpty);
      expect(engine.search('   ', sampleItems), isEmpty);
    });
  });
}
