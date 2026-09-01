import 'package:flutter_test/flutter_test.dart';
import 'package:burn_think/core/intelligence/priority_predictor.dart';
import 'package:burn_think/domain/models/task.dart';

void main() {
  group('PriorityPredictor Tests', () {
    late PriorityPredictor predictor;

    setUp(() {
      predictor = PriorityPredictor();
    });

    test('Ranks urgent and overdue tasks at top of focus list', () {
      final now = DateTime.now();
      final t1 = Task(
        id: '1',
        title: 'Regular task',
        priority: TaskPriority.low,
        createdAt: now,
        updatedAt: now,
      );
      final t2 = Task(
        id: '2',
        title: 'Urgent task due today',
        priority: TaskPriority.high,
        dueDate: now.add(const Duration(hours: 2)),
        createdAt: now,
        updatedAt: now,
      );
      final t3 = Task(
        id: '3',
        title: 'Overdue task',
        priority: TaskPriority.medium,
        dueDate: now.subtract(const Duration(days: 1)),
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now,
      );

      final focus = predictor.computeTodaysFocus(
        activeTasks: [t1, t2, t3],
        activeProjects: const [],
      );

      expect(focus.isNotEmpty, isTrue);
      expect(focus.first.task.id, equals('2')); // urgent + due today gives highest score
      expect(focus.any((f) => f.task.id == '3'), isTrue);
    });

    test('Returns empty when no active tasks exist', () {
      expect(predictor.computeTodaysFocus(activeTasks: [], activeProjects: []), isEmpty);
    });
  });
}
