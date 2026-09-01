import 'package:flutter_test/flutter_test.dart';
import 'package:burn_think/core/intelligence/behavior_analytics_engine.dart';
import 'package:burn_think/domain/models/task.dart';

void main() {
  group('BehaviorAnalyticsEngine Tests', () {
    late BehaviorAnalyticsEngine engine;

    setUp(() {
      engine = BehaviorAnalyticsEngine();
    });

    test('Computes descriptive insights correctly from completed tasks and active items', () {
      final now = DateTime.now();
      final activeTasks = [
        Task(
          id: '1',
          title: 'Old task',
          createdAt: now.subtract(const Duration(days: 9)),
          updatedAt: now,
        ),
      ];

      final completedTasks = [
        Task(
          id: '2',
          title: 'Completed task 1',
          isCompleted: true,
          createdAt: now.subtract(const Duration(days: 3)),
          completedAt: now.subtract(const Duration(days: 1)),
          updatedAt: now,
        ),
        Task(
          id: '3',
          title: 'Completed task 2',
          isCompleted: true,
          createdAt: now.subtract(const Duration(days: 2)),
          completedAt: now.subtract(const Duration(hours: 4)),
          updatedAt: now,
        ),
      ];

      final insights = engine.computeInsights(
        activeTasks: activeTasks,
        completedTasks: completedTasks,
        activeProjects: const [],
        completedProjects: const [],
        workouts: const [],
        contentItems: const [],
        notes: const [],
        toBuyShopping: const [],
        boughtShopping: const [],
      );

      expect(insights.longestActiveTaskDays, equals(9));
      expect(insights.longestActiveTaskTitle, equals('Old task'));
      expect(insights.tasksCompletedThisWeek, equals(2));
      expect(insights.totalCompletedItems, equals(2));
      expect(insights.averageTaskCompletionDays, greaterThan(0));
    });
  });
}
