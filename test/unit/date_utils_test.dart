import 'package:flutter_test/flutter_test.dart';
import 'package:burn_think/core/utils/date_utils.dart';

void main() {
  group('DateUtils Tests', () {
    test('Dynamic greeting based on hour', () {
      final morning = DateTime(2026, 8, 20, 8, 30);
      final afternoon = DateTime(2026, 8, 20, 14, 0);
      final evening = DateTime(2026, 8, 20, 20, 0);

      expect(AppDateUtils.getGreeting(morning), 'Good morning');
      expect(AppDateUtils.getGreeting(afternoon), 'Good afternoon');
      expect(AppDateUtils.getGreeting(evening), 'Good evening');
    });

    test('Full date format', () {
      final date = DateTime(2026, 10, 25, 12, 0);
      expect(AppDateUtils.formatFullDate(date), 'Sunday, October 25');
    });

    test('Due date format', () {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day, 14, 0);
      final tomorrow = DateTime(now.year, now.month, now.day + 1, 10, 0);

      expect(AppDateUtils.formatDue(today), contains('Due Today'));
      expect(AppDateUtils.formatDue(tomorrow), 'Due Tomorrow');
    });
  });
}
