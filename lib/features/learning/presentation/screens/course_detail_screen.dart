import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/config/app_router.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../data/models/course_model.dart';
import '../../providers/courses_provider.dart';
import '../widgets/course_header.dart';
import '../widgets/lesson_tile.dart';
import '../widgets/what_youll_learn.dart';

/// Shows the module list for a single course, with overall progress.
class CourseDetailScreen extends StatelessWidget {
  final String courseId;
  const CourseDetailScreen({super.key, required this.courseId});

  Color _accentColor(BuildContext context, String category) {
    switch (category) {
      case 'cpr':
        return const Color(0xFF1565C0);
      case 'first_aid':
        return const Color(0xFFFF9800);
      case 'fire_safety':
        return const Color(0xFFFF5722);
      case 'aed':
        return const Color(0xFF4CAF50);
      case 'emergency_prep':
        return Theme.of(context).colorScheme.primary;
      default:
        return const Color(0xFF607D8B);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CoursesProvider>();
    final course = provider.courses.cast<CourseModel?>().firstWhere(
          (c) => c?.id == courseId,
          orElse: () => null,
        );
    final lessons = provider.lessonsForCourse(courseId);
    final completed = provider.completedCountForCourse(courseId);
    final fraction = provider.progressFractionForCourse(courseId);

    if (course == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final accent = _accentColor(context, course.category);

    // Find next lesson to continue with (first incomplete)
    final nextIndex = lessons.indexWhere((l) => !provider.isLessonCompleted(l.id));
    final nextLesson = nextIndex >= 0 ? lessons[nextIndex] : null;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── Gradient header ─────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 360,
            pinned: true,
            backgroundColor: accent,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => context.pop(),
            ),
            title: const Text(
              'Back to Courses',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            centerTitle: false,
            titleSpacing: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: CourseHeader(
                course: course,
                completed: completed,
                total: lessons.length,
                fraction: fraction,
                accent: accent,
              ),
            ),
          ),

          // ── What You'll Learn ────────────────────────────────────────────
          SliverToBoxAdapter(
            child: WhatYoullLearn(lessons: lessons),
          ),

          // ── Course content label ─────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
              child: Text(
                'Course Content',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ),

          // ── Lesson tiles ─────────────────────────────────────────────────
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final lesson = lessons[index];
                final isCompleted = provider.isLessonCompleted(lesson.id);
                // Sequential unlock: a lesson is available if it's the first,
                // the previous lesson has been completed, or this lesson is
                // already completed (so completed lessons stay accessible).
                final isUnlocked = index == 0 ||
                    isCompleted ||
                    provider.isLessonCompleted(lessons[index - 1].id);
                return LessonTile(
                  number: index + 1,
                  lesson: lesson,
                  isCompleted: isCompleted,
                  isUnlocked: isUnlocked,
                  onTap: isUnlocked
                      ? () => context.push(AppRouter.lessonPath(lesson.id))
                      : null,
                );
              },
              childCount: lessons.length,
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),

      // ── Sticky bottom action ──────────────────────────────────────────────
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: nextLesson != null
              ? FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: accent,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () =>
                      context.push(AppRouter.lessonPath(nextLesson.id)),
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text(
                    'Continue Learning',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                )
              : FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppSemanticColors.of(context).success,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.school_outlined),
                  label: const Text(
                    'Back to Courses',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
        ),
      ),
    );
  }
}
