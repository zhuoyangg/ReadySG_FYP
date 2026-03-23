import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/config/app_router.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../shared/widgets/ready_empty_state.dart';
import '../../../../shared/widgets/ready_score_badge.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../gamification/providers/spaced_practice_provider.dart';
import '../../providers/courses_provider.dart';

/// Displays all lessons the user has completed, grouped by course.
class CompletedLessonsScreen extends StatelessWidget {
  const CompletedLessonsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = context.read<AuthProvider>().currentUser?.id;
    final courses = context.watch<CoursesProvider>();
    final spaced = context.watch<SpacedPracticeProvider>();

    if (userId == null) {
      return const Scaffold(body: Center(child: Text('Not signed in.')));
    }

    // Build ordered list: course → completed lessons
    final sections = <_CourseSection>[];
    for (final course in courses.courses) {
      final lessons = courses.lessonsForCourse(course.id);
      final completed = lessons.where((l) => courses.isLessonCompleted(l.id)).toList();
      if (completed.isEmpty) continue;
      sections.add(_CourseSection(
        courseTitle: course.title,
        courseEmoji: course.categoryEmoji,
        lessons: completed
            .map((l) {
              final progress = courses.progressFor(l.id);
              return _LessonEntry(
                lessonId: l.id,
                title: l.title,
                score: progress?.bestScore ?? 0,
                completedAt: progress?.completedAt,
              );
            })
            .toList(),
      ));
    }

    // Also include any completed lessons not yet in CoursesProvider cache
    // (edge case: lesson exists in progress but course not loaded)
    final allActivity = spaced.getRecentActivity(userId, limit: 100);
    final shownIds = sections.expand((s) => s.lessons.map((l) => l.lessonId)).toSet();
    final extra = allActivity
        .where((p) => !shownIds.contains(p.lessonId))
        .map((p) {
          final lesson = spaced.findLesson(p.lessonId);
          return lesson == null
              ? null
              : _LessonEntry(
                  lessonId: p.lessonId,
                  title: lesson.title,
                  score: p.bestScore,
                  completedAt: p.completedAt,
                );
        })
        .whereType<_LessonEntry>()
        .toList();
    if (extra.isNotEmpty) {
      sections.add(_CourseSection(
        courseTitle: 'Other',
        courseEmoji: '📚',
        lessons: extra,
      ));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Completed Lessons'),
        centerTitle: true,
      ),
      body: sections.isEmpty
          ? const ReadyEmptyState(
              icon: Icons.school_outlined,
              title: 'No completed lessons yet.',
              subtitle: 'Complete a lesson and come back here!',
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              itemCount: sections.length,
              itemBuilder: (context, i) => _CourseSectionWidget(section: sections[i]),
            ),
    );
  }
}

// ─── Data classes ─────────────────────────────────────────────────────────────

class _LessonEntry {
  final String lessonId;
  final String title;
  final int score;
  final DateTime? completedAt;
  const _LessonEntry({
    required this.lessonId,
    required this.title,
    required this.score,
    this.completedAt,
  });
}

class _CourseSection {
  final String courseTitle;
  final String courseEmoji;
  final List<_LessonEntry> lessons;
  const _CourseSection({
    required this.courseTitle,
    required this.courseEmoji,
    required this.lessons,
  });
}

// ─── Widgets ─────────────────────────────────────────────────────────────────

class _CourseSectionWidget extends StatelessWidget {
  final _CourseSection section;
  const _CourseSectionWidget({required this.section});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8, top: 4),
          child: Row(
            children: [
              Text(section.courseEmoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                section.courseTitle,
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        ...section.lessons.map((entry) => _LessonTile(entry: entry)),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _LessonTile extends StatelessWidget {
  final _LessonEntry entry;
  const _LessonTile({required this.entry});

  String _formatDate(DateTime? dt) {
    if (dt == null) return '';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AppSemanticColors.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          radius: 20,
          backgroundColor: tokens.success.withValues(alpha: 0.1),
          child: Icon(Icons.check, color: tokens.success, size: 18),
        ),
        title: Text(entry.title, maxLines: 2, overflow: TextOverflow.ellipsis),
        subtitle: entry.completedAt != null
            ? Text(_formatDate(entry.completedAt))
            : null,
        trailing: ReadyScoreBadge(score: entry.score),
        onTap: () => context.push(AppRouter.lessonPath(entry.lessonId)),
      ),
    );
  }
}
