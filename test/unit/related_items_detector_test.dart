import 'package:flutter_test/flutter_test.dart';
import 'package:burn_think/core/intelligence/related_items_detector.dart';
import 'package:burn_think/domain/models/task.dart';
import 'package:burn_think/domain/models/project.dart';

void main() {
  group('RelatedItemsDetector Tests', () {
    late RelatedItemsDetector detector;
    late List<Task> tasks;
    late List<Project> projects;

    setUp(() {
      detector = RelatedItemsDetector();
      final now = DateTime.now();
      tasks = [
        Task(
          id: 't1',
          title: 'Train customer churn model',
          createdAt: now,
          updatedAt: now,
        ),
        Task(
          id: 't2',
          title: 'Buy groceries and milk',
          createdAt: now,
          updatedAt: now,
        ),
      ];
      projects = [
        Project(
          id: 'p1',
          title: 'Data Science ML Project',
          createdAt: now,
          updatedAt: now,
          items: const [],
        ),
      ];
    });

    test('Identifies related items with high similarity (PRD §26 example)', () {
      final related = detector.findRelated(
        candidateTitle: 'Build churn prediction model',
        tasks: tasks,
        projects: projects,
        otherItems: const [],
      );

      expect(related.isNotEmpty, isTrue);
      expect(related.first.id, equals('t1'));
    });

    test('Ignores candidate if too short or no significant similarity', () {
      final related = detector.findRelated(
        candidateTitle: 'xyz',
        tasks: tasks,
        projects: projects,
        otherItems: const [],
      );

      expect(related, isEmpty);
    });

    test('Ignores self when currentItemId matches', () {
      final related = detector.findRelated(
        candidateTitle: 'Train customer churn model',
        currentItemId: 't1',
        tasks: tasks,
        projects: projects,
        otherItems: const [],
      );

      expect(related.where((r) => r.id == 't1'), isEmpty);
    });
  });
}
