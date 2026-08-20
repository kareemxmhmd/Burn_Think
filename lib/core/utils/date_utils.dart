import 'package:intl/intl.dart';

abstract final class AppDateUtils {
  static String getGreeting([DateTime? time]) {
    final hour = (time ?? DateTime.now()).hour;
    if (hour >= 5 && hour < 12) {
      return 'Good morning';
    } else if (hour >= 12 && hour < 17) {
      return 'Good afternoon';
    } else {
      return 'Good evening';
    }
  }

  static String formatFullDate([DateTime? date]) {
    final d = date ?? DateTime.now();
    return DateFormat('EEEE, MMMM d').format(d);
  }

  static String formatShortDate(DateTime date) {
    return DateFormat('MMM d').format(date);
  }

  static String formatTime(DateTime time) {
    return DateFormat('HH:mm').format(time);
  }

  static String formatDateTime(DateTime dateTime) {
    return DateFormat('MMM d, HH:mm').format(dateTime);
  }

  static String formatRelativeOrDate(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24 && now.day == dateTime.day) {
      return 'Today at ${DateFormat('HH:mm').format(dateTime)}';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d').format(dateTime);
    }
  }

  static String formatDue(DateTime due) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueDay = DateTime(due.year, due.month, due.day);

    final diffDays = dueDay.difference(today).inDays;
    if (diffDays == 0) {
      return 'Due Today ${DateFormat('HH:mm').format(due)}';
    } else if (diffDays == 1) {
      return 'Due Tomorrow';
    } else if (diffDays > 1 && diffDays <= 7) {
      return 'Due in $diffDays days';
    } else if (diffDays < 0) {
      return 'Overdue by ${-diffDays} days';
    } else {
      return 'Due ${DateFormat('MMM d').format(due)}';
    }
  }
}
