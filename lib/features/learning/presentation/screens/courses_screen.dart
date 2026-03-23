import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/config/app_router.dart';
import '../../../../shared/widgets/ready_empty_state.dart';
import '../../../../shared/widgets/ready_error_state.dart';
import '../../../../shared/widgets/ready_offline_banner.dart';
import '../../../../shared/widgets/ready_skeleton.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../data/models/course_model.dart';
import '../../providers/courses_provider.dart';
import '../widgets/course_card.dart';
import '../widgets/course_filter_bar.dart';
import '../widgets/learn_banner.dart';

/// Displays the full course catalogue for the Learn tab.
class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

enum _CourseSortMode { difficulty, progress }

class _CoursesScreenState extends State<CoursesScreen> {
  _CourseSortMode _sortMode = _CourseSortMode.difficulty;
  bool _isDifficultyAscending = true;
  bool _isProgressDescending = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = context.read<AuthProvider>().currentUser?.id;
      if (userId != null) {
        context.read<CoursesProvider>().loadCourses(userId);
      }
    });
  }

  List<CourseModel> _sortedCourses(
    List<CourseModel> courses,
    CoursesProvider provider,
  ) {
    return [...courses]..sort((a, b) => _compareCourses(a, b, provider));
  }

  int _difficultyRank(String difficulty) {
    switch (difficulty) {
      case 'beginner':
        return 0;
      case 'intermediate':
        return 1;
      case 'advanced':
        return 2;
      default:
        return 99;
    }
  }

  void _handleSortTap(String mode) {
    setState(() {
      if (mode == 'difficulty') {
        if (_sortMode == _CourseSortMode.difficulty) {
          _isDifficultyAscending = !_isDifficultyAscending;
        } else {
          _sortMode = _CourseSortMode.difficulty;
          _isDifficultyAscending = true;
        }
      } else if (mode == 'progress') {
        if (_sortMode == _CourseSortMode.progress) {
          _isProgressDescending = !_isProgressDescending;
        } else {
          _sortMode = _CourseSortMode.progress;
          _isProgressDescending = true;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CoursesProvider>();

    Widget body;

    if (provider.isLoading && !provider.hasData) {
      body = const ReadySkeletonGrid(
        key: ValueKey('courses-skeleton'),
        count: 4,
        crossAxisCount: 2,
      );
    } else if (!provider.hasData && provider.error != null) {
      body = ReadyErrorState(
        key: const ValueKey('courses-error'),
        message: 'Failed to load courses. Check your connection.',
        onRetry: () {
          final userId = context.read<AuthProvider>().currentUser?.id;
          if (userId != null) {
            context.read<CoursesProvider>().loadCourses(userId);
          }
        },
      );
    } else if (provider.courses.isEmpty) {
      body = ReadyEmptyState(
        key: const ValueKey('courses-empty'),
        icon: Icons.school_outlined,
        title: 'No courses available',
        subtitle: 'Check your connection and try again.',
        onRetry: () {
          final userId = context.read<AuthProvider>().currentUser?.id;
          if (userId != null) {
            context.read<CoursesProvider>().loadCourses(userId);
          }
        },
      );
    } else {
      final visible = _sortedCourses(provider.courses, provider);
      final totalLessons = provider.courses.fold<int>(
        0,
        (sum, course) => sum + provider.lessonsForCourse(course.id).length,
      );
      final completedLessons = provider.totalCompletedLessons;

      body = RefreshIndicator(
        key: const ValueKey('courses-list'),
        onRefresh: () => context.read<CoursesProvider>().refresh(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 100),
          children: [
            LearnBanner(
              completedLessons: completedLessons,
              totalLessons: totalLessons,
            ),
            CourseFilterBar(
              sortMode: _sortMode == _CourseSortMode.difficulty
                  ? 'difficulty'
                  : 'progress',
              onSortChanged: _handleSortTap,
            ),
            ReadyOfflineBanner(
                visible: provider.syncFailed && provider.hasData),
            if (visible.isEmpty)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'No courses available.',
                  textAlign: TextAlign.center,
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Column(
                  children: visible.map((course) {
                    final lessons = provider.lessonsForCourse(course.id);
                    return CourseCard(
                      course: course,
                      completedCount:
                          provider.completedCountForCourse(course.id),
                      totalCount: lessons.length,
                      progressFraction:
                          provider.progressFractionForCourse(course.id),
                      onTap: () =>
                          context.push(AppRouter.coursePath(course.id)),
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      );
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: body,
    );
  }

  int _compareCourses(
    CourseModel a,
    CourseModel b,
    CoursesProvider provider,
  ) {
    final orderedComparisons = _sortMode == _CourseSortMode.progress
        ? <int>[
            _compareProgress(a, b, provider),
            _compareDifficulty(a, b),
          ]
        : <int>[
            _compareDifficulty(a, b),
            _compareProgress(a, b, provider),
          ];

    for (final comparison in orderedComparisons) {
      if (comparison != 0) return comparison;
    }

    return _compareTitle(a, b);
  }

  int _compareDifficulty(CourseModel a, CourseModel b) {
    final rawComparison = _difficultyRank(a.difficulty).compareTo(
      _difficultyRank(b.difficulty),
    );
    return _isDifficultyAscending ? rawComparison : -rawComparison;
  }

  int _compareProgress(
    CourseModel a,
    CourseModel b,
    CoursesProvider provider,
  ) {
    final rawComparison = provider
        .progressFractionForCourse(b.id)
        .compareTo(provider.progressFractionForCourse(a.id));
    return _isProgressDescending ? rawComparison : -rawComparison;
  }

  int _compareTitle(CourseModel a, CourseModel b) {
    return a.title.toLowerCase().compareTo(b.title.toLowerCase());
  }
}
