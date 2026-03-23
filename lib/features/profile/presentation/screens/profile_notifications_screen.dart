import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/providers/app_preferences_provider.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/utils/app_feedback.dart';
import '../../../gamification/providers/spaced_practice_provider.dart';
import '../widgets/notification_debug_panel.dart';
import '../widgets/notification_section_card.dart';

class ProfileNotificationsScreen extends StatefulWidget {
  const ProfileNotificationsScreen({super.key});

  @override
  State<ProfileNotificationsScreen> createState() =>
      _ProfileNotificationsScreenState();
}

class _ProfileNotificationsScreenState extends State<ProfileNotificationsScreen> {
  late Future<NotificationDebugSnapshot> _debugSnapshotFuture;

  @override
  void initState() {
    super.initState();
    _debugSnapshotFuture = NotificationService().getDebugSnapshot();
  }

  void _refreshDebugSnapshot() {
    setState(() {
      _debugSnapshotFuture = NotificationService().getDebugSnapshot();
    });
  }

  @override
  Widget build(BuildContext context) {
    final preferences = context.watch<AppPreferencesProvider>();
    final spaced = context.watch<SpacedPracticeProvider>();
    final tokens = AppSemanticColors.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          NotificationSectionCard(
            title: 'Practice Reminders',
            child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: preferences.reviewRemindersEnabled,
              onChanged: (value) async {
                final preferencesProvider = context.read<AppPreferencesProvider>();
                await preferencesProvider.setReviewRemindersEnabled(value);
                if (!mounted) return;
                if (value) {
                  final result = await NotificationService().scheduleReviewReminder(
                    spaced.dueCount,
                    promptForExactPermission: true,
                  );
                  if (!mounted) return;
                  if (!result.isScheduled) {
                    await preferencesProvider.setReviewRemindersEnabled(false);
                    if (!mounted) return;
                  }
                  _refreshDebugSnapshot();
                  if (!context.mounted) return;
                  _showResultMessage(
                    context,
                    result,
                    successMessage: 'Review reminders enabled for 8:00 PM.',
                    fallbackMessage:
                        'Review reminders need exact alarm permission to be enabled.',
                  );
                } else {
                  await NotificationService().cancelReviewReminder();
                  if (!mounted) return;
                  _refreshDebugSnapshot();
                  if (!context.mounted) return;
                  AppFeedback.show(
                    context,
                    'Review reminders turned off.',
                    type: AppFeedbackType.info,
                  );
                }
              },
              title: const Text('Review reminders'),
              subtitle: const Text(
                'Daily reminder at 8:00 PM for lessons due for review.',
              ),
            ),
          ),
          const SizedBox(height: 14),
          NotificationSectionCard(
            title: 'Streak Protection',
            child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: preferences.streakNudgesEnabled,
              onChanged: (value) async {
                final preferencesProvider = context.read<AppPreferencesProvider>();
                await preferencesProvider.setStreakNudgesEnabled(value);
                if (!mounted) return;
                if (value) {
                  final result = await NotificationService().scheduleStreakNudge(
                    promptForExactPermission: true,
                  );
                  if (!mounted) return;
                  if (!result.isScheduled) {
                    await preferencesProvider.setStreakNudgesEnabled(false);
                    if (!mounted) return;
                  }
                  _refreshDebugSnapshot();
                  if (!context.mounted) return;
                  _showResultMessage(
                    context,
                    result,
                    successMessage: 'Streak nudges enabled for 11:00 PM.',
                    fallbackMessage:
                        'Streak nudges need exact alarm permission to be enabled.',
                  );
                } else {
                  await NotificationService().cancelStreakNudge();
                  if (!mounted) return;
                  _refreshDebugSnapshot();
                  if (!context.mounted) return;
                  AppFeedback.show(
                    context,
                    'Streak nudges turned off.',
                    type: AppFeedbackType.info,
                  );
                }
              },
              title: const Text('Streak nudges'),
              subtitle: const Text(
                'Reminder at 11:00 PM when you still need activity to keep the streak alive.',
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Notification schedules use your local device time in Singapore.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: tokens.subtleText,
                ),
          ),
          if (preferences.debugToolsAvailable && preferences.showDebugTools) ...[
            const SizedBox(height: 18),
            NotificationSectionCard(
              title: 'Testing Tools',
              child: NotificationDebugPanel(
                dueCount: spaced.dueCount,
                snapshotFuture: _debugSnapshotFuture,
                onRefresh: _refreshDebugSnapshot,
                onShowResult: _showResultMessage,
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showResultMessage(
    BuildContext context,
    NotificationScheduleResult result, {
    required String successMessage,
    required String fallbackMessage,
  }) {
    switch (result.status) {
      case NotificationScheduleStatus.scheduledExact:
        AppFeedback.show(
          context,
          successMessage,
          type: AppFeedbackType.success,
        );
        return;
      case NotificationScheduleStatus.scheduledInexact:
        AppFeedback.show(
          context,
          'Reminder scheduled, but Android may deliver it a little later than requested.',
          type: AppFeedbackType.warning,
          duration: const Duration(seconds: 5),
        );
        return;
      case NotificationScheduleStatus.permissionDenied:
        AppFeedback.show(
          context,
          fallbackMessage,
          type: AppFeedbackType.error,
          duration: const Duration(seconds: 5),
        );
        return;
      case NotificationScheduleStatus.notInitialized:
      case NotificationScheduleStatus.failed:
        AppFeedback.show(
          context,
          'Reminder could not be scheduled right now. Try again after restarting the app.',
          type: AppFeedbackType.error,
          duration: const Duration(seconds: 5),
        );
        return;
      case NotificationScheduleStatus.disabled:
        AppFeedback.show(
          context,
          'Reminder is disabled in preferences.',
          type: AppFeedbackType.info,
        );
        return;
      case NotificationScheduleStatus.unsupported:
        AppFeedback.show(
          context,
          'Local reminders are only available on Android and iOS devices.',
          type: AppFeedbackType.warning,
        );
        return;
    }
  }
}
