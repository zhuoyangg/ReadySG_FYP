import 'dart:async';
import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../providers/app_preferences_provider.dart';
import '../utils/app_logger.dart';

enum NotificationScheduleStatus {
  scheduledExact,
  scheduledInexact,
  disabled,
  permissionDenied,
  notInitialized,
  unsupported,
  failed,
}

class PendingNotificationSummary {
  final int id;
  final String? title;
  final String? body;

  const PendingNotificationSummary({
    required this.id,
    required this.title,
    required this.body,
  });
}

class NotificationDebugSnapshot {
  final bool initialized;
  final bool isMobile;
  final bool? notificationsEnabled;
  final bool? exactAlarmAllowed;
  final DateTime? nextReviewAt;
  final DateTime? nextStreakAt;
  final List<PendingNotificationSummary> pendingRequests;

  const NotificationDebugSnapshot({
    required this.initialized,
    required this.isMobile,
    required this.notificationsEnabled,
    required this.exactAlarmAllowed,
    required this.nextReviewAt,
    required this.nextStreakAt,
    required this.pendingRequests,
  });
}

class NotificationScheduleResult {
  final NotificationScheduleStatus status;
  final Object? error;

  const NotificationScheduleResult(this.status, {this.error});

  bool get isScheduled =>
      status == NotificationScheduleStatus.scheduledExact ||
      status == NotificationScheduleStatus.scheduledInexact;
}

/// Manages local notifications for review reminders and streak nudges.
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  final StreamController<String> _notificationTapController =
      StreamController<String>.broadcast();

  bool _initialized = false;

  static const int _reviewId = 100;
  static const int _streakId = 101;
  static const int _debugTestId = 999;
  static const int _debugScheduledReviewId = 1000;
  static const int _debugScheduledStreakId = 1001;
  static const String _homePayload = 'open_home';

  Stream<String> get notificationTapStream => _notificationTapController.stream;

  Future<void> initialize() async {
    if (!_isMobile || _initialized) return;

    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Singapore'));

    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        ),
      ),
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload != null && payload.isNotEmpty) {
          _notificationTapController.add(payload);
        }
      },
    );

    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        'review_reminders',
        'Review Reminders',
        description: 'Daily reminder to review due lessons at 8 PM',
        importance: Importance.high,
      ),
    );
    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        'streak_nudge',
        'Streak Nudge',
        description: 'Reminder to keep your streak alive at 11 PM',
        importance: Importance.defaultImportance,
      ),
    );

    await _requestPermissions();
    final launchDetails = await _plugin.getNotificationAppLaunchDetails();
    final launchPayload = launchDetails?.notificationResponse?.payload;
    if (launchPayload != null && launchPayload.isNotEmpty) {
      Future.microtask(() => _notificationTapController.add(launchPayload));
    }
    _initialized = true;
  }

  /// Schedules or replaces the 8 PM daily review reminder.
  Future<NotificationScheduleResult> scheduleReviewReminder(
    int dueCount, {
    bool promptForExactPermission = false,
  }) async {
    if (!_isMobile) {
      return const NotificationScheduleResult(
        NotificationScheduleStatus.unsupported,
      );
    }
    if (!_initialized) {
      return const NotificationScheduleResult(
        NotificationScheduleStatus.notInitialized,
      );
    }
    if (!AppPreferencesProvider.readReviewRemindersEnabled()) {
      await cancelReviewReminder();
      return const NotificationScheduleResult(NotificationScheduleStatus.disabled);
    }

    final body = dueCount > 0
        ? 'You have $dueCount lesson${dueCount == 1 ? '' : 's'} due for review'
        : 'Keep your skills sharp - review your lessons today';

    return _scheduleDailyAt(
      id: _reviewId,
      title: 'ReadySG - Time to Review',
      body: body,
      hour: 20,
      minute: 0,
      channelId: 'review_reminders',
      channelName: 'Review Reminders',
      promptForExactPermission: promptForExactPermission,
    );
  }

  /// Schedules the 11 PM streak reminder.
  Future<NotificationScheduleResult> scheduleStreakNudge({
    bool promptForExactPermission = false,
  }) async {
    if (!_isMobile) {
      return const NotificationScheduleResult(
        NotificationScheduleStatus.unsupported,
      );
    }
    if (!_initialized) {
      return const NotificationScheduleResult(
        NotificationScheduleStatus.notInitialized,
      );
    }
    if (!AppPreferencesProvider.readStreakNudgesEnabled()) {
      await cancelStreakNudge();
      return const NotificationScheduleResult(NotificationScheduleStatus.disabled);
    }

    return _scheduleDailyAt(
      id: _streakId,
      title: 'ReadySG - Keep Your Streak!',
      body: "Don't break your streak - complete today's challenge before midnight",
      hour: 23,
      minute: 0,
      channelId: 'streak_nudge',
      channelName: 'Streak Nudge',
      promptForExactPermission: promptForExactPermission,
    );
  }

  Future<void> cancelReviewReminder() async {
    if (!_isMobile) return;
    await _plugin.cancel(id: _reviewId);
  }

  Future<void> cancelStreakNudge() async {
    if (!_isMobile) return;
    await _plugin.cancel(id: _streakId);
  }

  Future<void> showDebugNotificationNow() async {
    if (!_isMobile || !_initialized) return;

    await _plugin.show(
      id: _debugTestId,
      title: 'ReadySG test notification',
      body:
          'If you can see this, local notifications are working on this device.',
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'review_reminders',
          'Review Reminders',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: _homePayload,
    );
  }

  Future<NotificationScheduleResult> scheduleDebugReviewReminderIn(
    Duration delay,
  ) async {
    return _scheduleAt(
      id: _debugScheduledReviewId,
      title: 'ReadySG debug review reminder',
      body: 'This is a short-delay test for review reminder delivery.',
      scheduledDate: _nextInstanceAfterDelay(delay),
      channelId: 'review_reminders',
      channelName: 'Review Reminders',
      promptForExactPermission: true,
      matchDateTimeComponents: null,
    );
  }

  Future<NotificationScheduleResult> scheduleDebugStreakNudgeIn(
    Duration delay,
  ) async {
    return _scheduleAt(
      id: _debugScheduledStreakId,
      title: 'ReadySG debug streak nudge',
      body: 'This is a short-delay test for streak nudge delivery.',
      scheduledDate: _nextInstanceAfterDelay(delay),
      channelId: 'streak_nudge',
      channelName: 'Streak Nudge',
      promptForExactPermission: true,
      matchDateTimeComponents: null,
    );
  }

  Future<NotificationDebugSnapshot> getDebugSnapshot() async {
    if (!_isMobile) {
      return const NotificationDebugSnapshot(
        initialized: false,
        isMobile: false,
        notificationsEnabled: null,
        exactAlarmAllowed: null,
        nextReviewAt: null,
        nextStreakAt: null,
        pendingRequests: [],
      );
    }

    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final notificationsEnabled = Platform.isAndroid
        ? await androidPlugin?.areNotificationsEnabled()
        : true;
    final exactAlarmAllowed = Platform.isAndroid
        ? await androidPlugin?.canScheduleExactNotifications()
        : true;
    final pending =
        await _plugin.pendingNotificationRequests();

    return NotificationDebugSnapshot(
      initialized: _initialized,
      isMobile: true,
      notificationsEnabled: notificationsEnabled,
      exactAlarmAllowed: exactAlarmAllowed,
      nextReviewAt: _initialized ? _nextInstanceOfTime(20, 0).toLocal() : null,
      nextStreakAt: _initialized ? _nextInstanceOfTime(23, 0).toLocal() : null,
      pendingRequests: pending
          .map(
            (request) => PendingNotificationSummary(
              id: request.id,
              title: request.title,
              body: request.body,
            ),
          )
          .toList(),
    );
  }

  Future<NotificationScheduleResult> _scheduleDailyAt({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    required String channelId,
    required String channelName,
    required bool promptForExactPermission,
  }) async {
    return _scheduleAt(
      id: id,
      title: title,
      body: body,
      scheduledDate: _nextInstanceOfTime(hour, minute),
      channelId: channelId,
      channelName: channelName,
      promptForExactPermission: promptForExactPermission,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<NotificationScheduleResult> _scheduleAt({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledDate,
    required String channelId,
    required String channelName,
    required bool promptForExactPermission,
    required DateTimeComponents? matchDateTimeComponents,
  }) async {
    try {
      final scheduleMode = await _resolveAndroidScheduleMode(
        promptForExactPermission: promptForExactPermission,
      );
      if (scheduleMode == null) {
        return const NotificationScheduleResult(
          NotificationScheduleStatus.permissionDenied,
        );
      }

      await _plugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: scheduledDate,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            channelId,
            channelName,
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        androidScheduleMode: scheduleMode,
        matchDateTimeComponents: matchDateTimeComponents,
        payload: _homePayload,
      );
      return NotificationScheduleResult(
        scheduleMode == AndroidScheduleMode.exactAllowWhileIdle
            ? NotificationScheduleStatus.scheduledExact
            : NotificationScheduleStatus.scheduledInexact,
      );
    } catch (e) {
      AppLogger.warning(
        'Notification scheduling failed',
        scope: 'notifications',
        error: e,
      );
      return NotificationScheduleResult(
        NotificationScheduleStatus.failed,
        error: e,
      );
    }
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  tz.TZDateTime _nextInstanceAfterDelay(Duration delay) {
    final now = tz.TZDateTime.now(tz.local);
    return now.add(delay);
  }

  Future<void> _requestPermissions() async {
    if (Platform.isIOS) {
      await _plugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    } else if (Platform.isAndroid) {
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }
  }

  Future<AndroidScheduleMode?> _resolveAndroidScheduleMode({
    required bool promptForExactPermission,
  }) async {
    if (!Platform.isAndroid) return AndroidScheduleMode.exactAllowWhileIdle;

    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin == null) {
      return AndroidScheduleMode.inexactAllowWhileIdle;
    }

    final canScheduleExact =
        await androidPlugin.canScheduleExactNotifications() ?? true;
    if (canScheduleExact) {
      return AndroidScheduleMode.exactAllowWhileIdle;
    }

    if (promptForExactPermission) {
      final granted = await androidPlugin.requestExactAlarmsPermission();
      if (granted ?? false) {
        return AndroidScheduleMode.exactAllowWhileIdle;
      }
      return null;
    }

    return AndroidScheduleMode.inexactAllowWhileIdle;
  }

  bool get _isMobile => Platform.isAndroid || Platform.isIOS;
}
