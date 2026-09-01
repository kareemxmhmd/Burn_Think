import 'package:flutter_test/flutter_test.dart';
import 'package:burn_think/core/intelligence/smart_categorizer.dart';
import 'package:burn_think/presentation/state/workspace_controller.dart';

void main() {
  group('SmartCategorizer Tests', () {
    late SmartCategorizer categorizer;

    setUp(() {
      categorizer = SmartCategorizer();
    });

    test('Categorizes shopping items correctly from keywords and action verbs', () {
      final res1 = categorizer.categorize('Buy organic coffee and milk');
      expect(res1.type, equals(DetailType.shopping));
      expect(res1.confidence, greaterThanOrEqualTo(0.6));

      final res2 = categorizer.categorize('Pick up new wireless mouse and keyboard');
      expect(res2.type, equals(DetailType.shopping));
    });

    test('Categorizes workouts correctly from exercises and gym terms', () {
      final res1 = categorizer.categorize('Upper body bench press and incline dumbbell press');
      expect(res1.type, equals(DetailType.workout));

      final res2 = categorizer.categorize('Legs and abs workout with 3 sets 10 reps');
      expect(res2.type, equals(DetailType.workout));
    });

    test('Categorizes content ideas from YouTube, post, video phrasing', () {
      final res1 = categorizer.categorize('YouTube video about machine learning roadmap');
      expect(res1.type, equals(DetailType.content));

      final res2 = categorizer.categorize('Draft linkedin post regarding software design');
      expect(res2.type, equals(DetailType.content));
    });

    test('Categorizes projects from architecture and overhaul keywords', () {
      final res1 = categorizer.categorize('Data Science Project roadmap and pipeline');
      expect(res1.type, equals(DetailType.project));
    });

    test('Categorizes notes from remember/concept phrases', () {
      final res1 = categorizer.categorize('Remember the definition of gradient descent');
      expect(res1.type, equals(DetailType.note));
    });

    test('Categorizes tasks by default or from action verbs', () {
      final res1 = categorizer.categorize('Finish database review and send email');
      expect(res1.type, equals(DetailType.task));

      final res2 = categorizer.categorize('Submit taxes for this quarter');
      expect(res2.type, equals(DetailType.task));
    });

    test('Adapts and learns from user feedback overrides', () {
      categorizer.addSingleFeedback('my special item', DetailType.note);
      final res = categorizer.categorize('my special item');
      expect(res.type, equals(DetailType.note));
      expect(res.confidence, greaterThanOrEqualTo(0.9));
    });
  });
}
