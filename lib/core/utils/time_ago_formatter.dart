import '../services/app_clock.dart';

/// Date and time formatting utilities used across the app.
class TimeAgoFormatter {
  const TimeAgoFormatter._();

  /// Returns a human-readable relative time string (e.g. "3 days ago").
  static String format(DateTime timestamp, {DateTime? now}) {
    final referenceTime = now ?? AppClock.now();
    if (timestamp.isAfter(referenceTime)) return 'just now';

    final difference = referenceTime.difference(timestamp);
    if (difference.inDays >= 1) {
      final days = difference.inDays;
      return '$days ${days == 1 ? 'day' : 'days'} ago';
    }
    if (difference.inHours >= 1) {
      final hours = difference.inHours;
      return '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
    }
    if (difference.inMinutes >= 1) {
      final minutes = difference.inMinutes;
      return '$minutes ${minutes == 1 ? 'minute' : 'minutes'} ago';
    }
    return 'just now';
  }

  /// Formats [dt] as 'YYYY-MM-DD' for use in Hive daily-counter keys.
  static String dateKey(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

  /// Returns [dt] truncated to midnight (start of day).
  static DateTime startOfDay(DateTime dt) => DateTime(dt.year, dt.month, dt.day);
}
