import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/providers/app_clock_provider.dart';
import '../../../../core/providers/app_preferences_provider.dart';
import '../../../../core/theme/app_tokens.dart';

class ProfileSettingsScreen extends StatelessWidget {
  const ProfileSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final preferences = context.watch<AppPreferencesProvider>();
    final cacheInfo = preferences.cacheInfo;
    final tokens = AppSemanticColors.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionCard(
            title: 'Offline Sync Preferences',
            child: Column(
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: preferences.preferOfflineCache,
                  onChanged: (value) => context
                      .read<AppPreferencesProvider>()
                      .setPreferOfflineCache(value),
                  title: const Text('Prefer cached content'),
                  subtitle: const Text(
                    'Keep existing downloaded data on screen and skip automatic remote refresh when cache is available.',
                  ),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: preferences.autoSyncOnLaunch,
                  onChanged: (value) => context
                      .read<AppPreferencesProvider>()
                      .setAutoSyncOnLaunch(value),
                  title: const Text('Auto-sync on app open'),
                  subtitle: const Text(
                    'When off, cached content stays local until the user triggers a manual refresh.',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _SectionCard(
            title: 'Cache Info',
            child: Column(
              children: [
                _InfoRow(label: 'Courses', value: '${cacheInfo.courses}'),
                _InfoRow(label: 'Lessons', value: '${cacheInfo.lessons}'),
                _InfoRow(label: 'Quizzes', value: '${cacheInfo.quizzes}'),
                _InfoRow(label: 'Progress entries', value: '${cacheInfo.progressEntries}'),
                _InfoRow(label: 'Emergency guides', value: '${cacheInfo.guides}'),
                _InfoRow(label: 'AED locations', value: '${cacheInfo.aeds}'),
                _InfoRow(label: 'Badges', value: '${cacheInfo.badges}'),
                _InfoRow(
                  label: 'Review schedules',
                  value: '${cacheInfo.reviewSchedules}',
                ),
                _InfoRow(
                  label: 'App settings entries',
                  value: '${cacheInfo.settingsEntries}',
                  isLast: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          if (preferences.debugToolsAvailable) ...[
            _SectionCard(
              title: 'Testing Tools',
              child: Column(
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: preferences.showDebugTools,
                    onChanged: (value) => context
                        .read<AppPreferencesProvider>()
                        .setShowDebugTools(value),
                    title: const Text('Show advanced tools'),
                    subtitle: const Text(
                      'Enable in-app controls for time overrides and other QA checks.',
                    ),
                  ),
                  if (preferences.showDebugTools) ...[
                    const Divider(height: 1),
                    const SizedBox(height: 12),
                    const _DebugTimeControls(),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          Text(
            'Changing sync preferences affects the next provider load cycle. Pull-to-refresh still performs manual sync.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: tokens.subtleText,
                ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD8DDE8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isLast;

  const _InfoRow({
    required this.label,
    required this.value,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: Text(label)),
            Text(
              value,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),
        if (!isLast) const SizedBox(height: 12),
      ],
    );
  }
}

class _DebugTimeControls extends StatelessWidget {
  const _DebugTimeControls();

  @override
  Widget build(BuildContext context) {
    return Consumer<AppClockProvider>(
      builder: (context, clockProvider, _) {
        final systemNow = DateTime.now();
        final appNow = clockProvider.now;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'System: ${_formatDateTime(systemNow)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 4),
            Text(
              'App: ${_formatDateTime(appNow)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: clockProvider.hasOverride
                        ? AppSemanticColors.of(context).warning
                        : null,
                    fontWeight: clockProvider.hasOverride
                        ? FontWeight.w700
                        : FontWeight.w500,
                  ),
            ),
            const SizedBox(height: 14),
            Text(
              'These tools help validate reminder timing and other date-sensitive flows without changing device settings.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppSemanticColors.of(context).subtleText,
                  ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton(
                  onPressed: () => clockProvider.shiftBy(const Duration(days: -1)),
                  child: const Text('-1 day'),
                ),
                OutlinedButton(
                  onPressed: () => clockProvider.shiftBy(const Duration(days: 1)),
                  child: const Text('+1 day'),
                ),
                OutlinedButton(
                  onPressed: () => clockProvider.shiftBy(const Duration(days: 7)),
                  child: const Text('+7 days'),
                ),
                FilledButton.tonal(
                  onPressed: () => _pickCustomDateTime(context, clockProvider),
                  child: const Text('Set date/time'),
                ),
                TextButton(
                  onPressed:
                      clockProvider.hasOverride ? clockProvider.clearOverride : null,
                  child: const Text('Reset'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickCustomDateTime(
    BuildContext context,
    AppClockProvider clockProvider,
  ) async {
    final seed = clockProvider.overrideTime ?? DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: seed,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (pickedDate == null || !context.mounted) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(seed),
    );
    if (pickedTime == null) return;

    final custom = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );
    clockProvider.setOverride(custom);
  }

  static String _formatDateTime(DateTime value) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${value.year}-${two(value.month)}-${two(value.day)} '
        '${two(value.hour)}:${two(value.minute)}';
  }
}
