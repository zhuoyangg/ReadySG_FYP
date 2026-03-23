import 'package:flutter/material.dart';

import '../../../../core/services/notification_service.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/utils/app_feedback.dart';

class NotificationDebugPanel extends StatelessWidget {
  final int dueCount;
  final Future<NotificationDebugSnapshot> snapshotFuture;
  final VoidCallback onRefresh;
  final void Function(
    BuildContext context,
    NotificationScheduleResult result, {
    required String successMessage,
    required String fallbackMessage,
  }) onShowResult;

  const NotificationDebugPanel({
    super.key,
    required this.dueCount,
    required this.snapshotFuture,
    required this.onRefresh,
    required this.onShowResult,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = AppSemanticColors.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'These tools are available for quick in-app checks of reminder delivery and scheduling behavior.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: tokens.subtleText,
              ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilledButton.tonalIcon(
              onPressed: () async {
                await NotificationService().showDebugNotificationNow();
                if (!context.mounted) return;
                AppFeedback.show(
                  context,
                  'Test notification sent immediately.',
                  type: AppFeedbackType.success,
                );
                onRefresh();
              },
              icon: const Icon(Icons.notifications_active_outlined),
              label: const Text('Send Test Now'),
            ),
            OutlinedButton.icon(
              onPressed: () async {
                final result =
                    await NotificationService().scheduleDebugReviewReminderIn(
                  const Duration(seconds: 5),
                );
                if (!context.mounted) return;
                onShowResult(
                  context,
                  result,
                  successMessage:
                      'Debug review reminder scheduled for 5 seconds from now.',
                  fallbackMessage:
                      'Debug review reminder could not be scheduled.',
                );
                onRefresh();
              },
              icon: const Icon(Icons.schedule_send_outlined),
              label: const Text('Review in 5s'),
            ),
            OutlinedButton.icon(
              onPressed: () async {
                final result =
                    await NotificationService().scheduleDebugStreakNudgeIn(
                  const Duration(seconds: 5),
                );
                if (!context.mounted) return;
                onShowResult(
                  context,
                  result,
                  successMessage:
                      'Debug streak nudge scheduled for 5 seconds from now.',
                  fallbackMessage:
                      'Debug streak nudge could not be scheduled.',
                );
                onRefresh();
              },
              icon: const Icon(Icons.alarm_rounded),
              label: const Text('Streak in 5s'),
            ),
            OutlinedButton.icon(
              onPressed: () async {
                final reviewResult =
                    await NotificationService().scheduleReviewReminder(
                  dueCount,
                  promptForExactPermission: true,
                );
                if (!context.mounted) return;
                onShowResult(
                  context,
                  reviewResult,
                  successMessage: 'Review reminder rescheduled.',
                  fallbackMessage:
                      'Review reminder could not be rescheduled.',
                );

                final streakResult =
                    await NotificationService().scheduleStreakNudge(
                  promptForExactPermission: true,
                );
                if (!context.mounted) return;
                onShowResult(
                  context,
                  streakResult,
                  successMessage: 'Streak nudge rescheduled.',
                  fallbackMessage: 'Streak nudge could not be rescheduled.',
                );
                onRefresh();
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reschedule Both'),
            ),
            TextButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.sync),
              label: const Text('Refresh Status'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        FutureBuilder<NotificationDebugSnapshot>(
          future: snapshotFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.hasError) {
              return Text(
                'Debug snapshot failed to load.',
                style: TextStyle(color: tokens.danger),
              );
            }

            final data = snapshot.data;
            if (data == null) {
              return Text(
                'No debug snapshot available.',
                style: TextStyle(color: tokens.subtleText),
              );
            }

            final hasReviewPending = data.pendingRequests.any(
              (request) => request.id == 100,
            );
            final hasStreakPending = data.pendingRequests.any(
              (request) => request.id == 101,
            );

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DebugRow(
                  label: 'Service initialized',
                  value: data.initialized ? 'yes' : 'no',
                ),
                _DebugRow(
                  label: 'Notifications enabled',
                  value: _yesNoUnknown(data.notificationsEnabled),
                ),
                _DebugRow(
                  label: 'Exact alarms allowed',
                  value: _yesNoUnknown(data.exactAlarmAllowed),
                ),
                _DebugRow(
                  label: 'Review reminder pending',
                  value: hasReviewPending ? 'yes' : 'no',
                ),
                _DebugRow(
                  label: 'Streak nudge pending',
                  value: hasStreakPending ? 'yes' : 'no',
                ),
                _DebugRow(
                  label: 'Next review target',
                  value: _formatDateTime(data.nextReviewAt),
                ),
                _DebugRow(
                  label: 'Next streak target',
                  value: _formatDateTime(data.nextStreakAt),
                  isLast: data.pendingRequests.isEmpty,
                ),
                if (data.pendingRequests.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Pending requests',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 8),
                  ...data.pendingRequests.map((request) {
                    final title = request.title ?? '(no title)';
                    final body = request.body ?? '(no body)';
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        '#${request.id}: $title\n$body',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: tokens.subtleText,
                              height: 1.35,
                            ),
                      ),
                    );
                  }),
                ],
              ],
            );
          },
        ),
      ],
    );
  }

  String _yesNoUnknown(bool? value) {
    if (value == null) return 'unknown';
    return value ? 'yes' : 'no';
  }

  String _formatDateTime(DateTime? value) {
    if (value == null) return 'n/a';
    String two(int n) => n.toString().padLeft(2, '0');
    return '${value.year}-${two(value.month)}-${two(value.day)} '
        '${two(value.hour)}:${two(value.minute)}';
  }
}

class _DebugRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isLast;

  const _DebugRow({
    required this.label,
    required this.value,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
