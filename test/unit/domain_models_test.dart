import 'package:flutter_test/flutter_test.dart';
import 'package:burn_shut/domain/models/task.dart';
import 'package:burn_shut/domain/models/project.dart';
import 'package:burn_shut/domain/models/workout.dart';
import 'package:burn_shut/domain/models/content_item.dart';
import 'package:burn_shut/domain/models/note.dart';
import 'package:burn_shut/domain/models/shopping_item.dart';

void main() {
  group('Domain Models Unit Tests', () {
    test('Task priority parsing and serialization', () {
      expect(TaskPriority.fromString('High'), TaskPriority.high);
      expect(TaskPriority.fromString('medium'), TaskPriority.medium);
      expect(TaskPriority.fromString('invalid'), TaskPriority.none);
      expect(TaskPriority.fromInt(3), TaskPriority.high);
      expect(TaskPriority.fromInt(null), TaskPriority.none);

      final now = DateTime(2026, 8, 20, 10, 0);
      final task = Task(
        id: 't-1',
        title: 'Review PR',
        description: 'Review architecture',
        priority: TaskPriority.high,
        dueDate: now,
        isCompleted: false,
        createdAt: now,
        updatedAt: now,
      );

      final map = task.toMap();
      expect(map['id'], 't-1');
      expect(map['priority'], 3);
      expect(map['isCompleted'], 0);

      final fromMap = Task.fromMap(map);
      expect(fromMap.id, task.id);
      expect(fromMap.priority, TaskPriority.high);
      expect(fromMap.isCompleted, false);
    });

    test('Project progress calculation', () {
      final now = DateTime.now();

      // Empty project
      final emptyProject = Project(
        id: 'p-1',
        title: 'Empty',
        createdAt: now,
        updatedAt: now,
      );
      expect(emptyProject.progress, 0.0);
      expect(emptyProject.progressPercent, 0);

      // Project with 4 items: 3 completed
      final project = Project(
        id: 'p-2',
        title: 'Data Science',
        createdAt: now,
        updatedAt: now,
        items: [
          ProjectItem(
            id: 'pi-1',
            projectId: 'p-2',
            title: 'EDA',
            isCompleted: true,
            createdAt: now,
            updatedAt: now,
          ),
          ProjectItem(
            id: 'pi-2',
            projectId: 'p-2',
            title: 'Feature Eng',
            isCompleted: true,
            createdAt: now,
            updatedAt: now,
          ),
          ProjectItem(
            id: 'pi-3',
            projectId: 'p-2',
            title: 'Model Training',
            isCompleted: true,
            createdAt: now,
            updatedAt: now,
          ),
          ProjectItem(
            id: 'pi-4',
            projectId: 'p-2',
            title: 'Deployment',
            isCompleted: false,
            createdAt: now,
            updatedAt: now,
          ),
        ],
      );

      expect(project.completedItemCount, 3);
      expect(project.totalItemCount, 4);
      expect(project.progress, 0.75);
      expect(project.progressPercent, 75);
    });

    test('Workout and Exercise serialization', () {
      final now = DateTime.now();
      final workout = Workout(
        id: 'w-1',
        name: 'Upper Body',
        targetTime: '18:00',
        estimatedDurationMinutes: 45,
        isCurrentFocus: true,
        createdAt: now,
        updatedAt: now,
        exercises: [
          Exercise(
            id: 'e-1',
            workoutId: 'w-1',
            category: 'Chest',
            name: 'Bench Press',
            sets: 3,
            repetitions: 10,
            weight: 80.0,
            createdAt: now,
            updatedAt: now,
          ),
        ],
      );

      final json = workout.toJson();
      final fromJson = Workout.fromJson(json);

      expect(fromJson.name, 'Upper Body');
      expect(fromJson.isCurrentFocus, true);
      expect(fromJson.exercises.length, 1);
      expect(fromJson.exercises.first.name, 'Bench Press');
      expect(fromJson.exercises.first.weight, 80.0);
    });

    test('ContentItem serialization', () {
      final now = DateTime.now();
      final item = ContentItem(
        id: 'c-1',
        title: 'Roadmap 2026',
        description: 'Strategic overview',
        contentType: 'Video',
        duration: '45 mins',
        createdAt: now,
        updatedAt: now,
      );

      final json = item.toJson();
      final restored = ContentItem.fromJson(json);

      expect(restored.title, 'Roadmap 2026');
      expect(restored.contentType, 'Video');
      expect(restored.duration, '45 mins');
    });

    test('Note pin and body serialization', () {
      final now = DateTime.now();
      final note = Note(
        id: 'n-1',
        title: 'Learn Docker',
        body: 'Read containers deep dive',
        isPinned: true,
        createdAt: now,
        updatedAt: now,
      );

      final json = note.toJson();
      final restored = Note.fromJson(json);

      expect(restored.title, 'Learn Docker');
      expect(restored.isPinned, true);
    });

    test('ShoppingItem bought lifecycle', () {
      final now = DateTime.now();
      final item = ShoppingItem(
        id: 's-1',
        title: 'Coffee Beans',
        notes: 'Ethiopian roast',
        isBought: false,
        createdAt: now,
        updatedAt: now,
      );

      final boughtItem = item.copyWith(
        isBought: true,
        boughtAt: now,
      );

      expect(boughtItem.isBought, true);
      expect(boughtItem.boughtAt, now);
      expect(boughtItem.title, 'Coffee Beans');
    });
  });
}
