import 'package:flutter_test/flutter_test.dart';
import 'package:ready_sg/core/utils/time_ago_formatter.dart';

void main() {
  group('TimeAgoFormatter.format', () {
    final now = DateTime(2026, 3, 21, 12, 0);

    test('returns just now for future timestamps', () {
      final result = TimeAgoFormatter.format(
        now.add(const Duration(minutes: 5)),
        now: now,
      );

      expect(result, 'just now');
    });

    test('formats minute differences', () {
      final result = TimeAgoFormatter.format(
        now.subtract(const Duration(minutes: 3)),
        now: now,
      );

      expect(result, '3 minutes ago');
    });

    test('formats hour differences', () {
      final result = TimeAgoFormatter.format(
        now.subtract(const Duration(hours: 1)),
        now: now,
      );

      expect(result, '1 hour ago');
    });

    test('formats day differences', () {
      final result = TimeAgoFormatter.format(
        now.subtract(const Duration(days: 2)),
        now: now,
      );

      expect(result, '2 days ago');
    });
  });

  group('TimeAgoFormatter.dateKey', () {
    test('formats date as YYYY-MM-DD with zero-padded month and day', () {
      expect(TimeAgoFormatter.dateKey(DateTime(2026, 3, 5)), '2026-03-05');
      expect(TimeAgoFormatter.dateKey(DateTime(2026, 12, 25)), '2026-12-25');
    });

    test('handles single-digit month and day', () {
      expect(TimeAgoFormatter.dateKey(DateTime(2026, 1, 1)), '2026-01-01');
    });
  });

  group('TimeAgoFormatter.startOfDay', () {
    test('truncates time to midnight', () {
      final result = TimeAgoFormatter.startOfDay(DateTime(2026, 3, 21, 14, 30, 45));
      expect(result, DateTime(2026, 3, 21));
      expect(result.hour, 0);
      expect(result.minute, 0);
      expect(result.second, 0);
    });
  });
}
