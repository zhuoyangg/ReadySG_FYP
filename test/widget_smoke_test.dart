// Characterization widget tests for M15 extracted widgets.
//
// Each test pumps a single widget in isolation inside a MaterialApp with
// ThemeData.light() and asserts that key UI elements are visible.  No
// network, Supabase, or Hive calls are made.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ready_sg/features/emergency/presentation/widgets/emergency_guides_hero.dart';
import 'package:ready_sg/features/emergency/presentation/widgets/emergency_situation_card.dart';
import 'package:ready_sg/features/emergency/presentation/widgets/important_reminder_card.dart';
import 'package:ready_sg/features/learning/data/models/course_model.dart';
import 'package:ready_sg/features/learning/presentation/widgets/course_card.dart';
import 'package:ready_sg/features/learning/presentation/widgets/learn_banner.dart';
import 'package:ready_sg/features/learning/presentation/widgets/quiz_header.dart';
import 'package:ready_sg/features/practice/presentation/widgets/trial_stat_chip.dart';
import 'package:ready_sg/features/profile/presentation/widgets/notification_section_card.dart';

/// Minimal helper: wraps [child] in a MaterialApp with a light theme so all
/// Theme.of(context) calls resolve. The app does NOT include GoRouter or any
/// Provider, because every widget under test is purely presentational.
Widget _wrap(Widget child) {
  return MaterialApp(
    theme: ThemeData.light(),
    home: Scaffold(body: child),
  );
}

// ---------------------------------------------------------------------------
// Dummy CourseModel used across learning widget tests.
// ---------------------------------------------------------------------------
CourseModel _dummyCourse() => CourseModel(
      id: 'test-course-1',
      title: 'CPR Basics',
      description: 'Learn how to perform CPR correctly.',
      thumbnailUrl: null,
      category: 'cpr',
      difficulty: 'beginner',
      sortOrder: 1,
      isPublished: true,
      createdAt: DateTime(2024, 1, 1),
    );

void main() {
  // -------------------------------------------------------------------------
  // Emergency feature widgets
  // -------------------------------------------------------------------------

  group('EmergencyGuidesHero', () {
    testWidgets('renders "Emergency Guides" heading', (tester) async {
      await tester.pumpWidget(_wrap(const EmergencyGuidesHero()));

      expect(find.text('Emergency Guides'), findsOneWidget);
    });

    testWidgets('renders subtitle text', (tester) async {
      await tester
          .pumpWidget(_wrap(const EmergencyGuidesHero()));

      expect(
        find.text('Quick access to life-saving procedures'),
        findsOneWidget,
      );
    });

    testWidgets('renders Back and Sign In actions when callbacks are provided',
        (tester) async {
      await tester.pumpWidget(_wrap(
        EmergencyGuidesHero(onBack: () {}, onSignIn: () {}),
      ));

      expect(find.text('Back'), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);
    });
  });

  group('EmergencySituationCard', () {
    testWidgets('renders title text', (tester) async {
      await tester.pumpWidget(_wrap(const EmergencySituationCard()));

      expect(find.text('Emergency Situation?'), findsOneWidget);
    });

    testWidgets('renders call-995 instruction via RichText', (tester) async {
      await tester.pumpWidget(_wrap(const EmergencySituationCard()));

      // "995" is a TextSpan inside a RichText widget; use byWidgetPredicate to
      // inspect the plain text of the rendered RichText.
      final richTextFinder = find.byWidgetPredicate((widget) {
        if (widget is RichText) {
          return widget.text.toPlainText().contains('995');
        }
        return false;
      });
      expect(richTextFinder, findsOneWidget);
    });
  });

  group('ImportantReminderCard', () {
    testWidgets('renders "Important Reminder" title', (tester) async {
      await tester.pumpWidget(_wrap(const ImportantReminderCard()));

      expect(find.text('Important Reminder'), findsOneWidget);
    });

    testWidgets('renders body text', (tester) async {
      await tester.pumpWidget(_wrap(const ImportantReminderCard()));

      expect(
        find.textContaining('Always call 995 for emergencies'),
        findsOneWidget,
      );
    });
  });

  // -------------------------------------------------------------------------
  // Learning feature widgets
  // -------------------------------------------------------------------------

  group('LearnBanner', () {
    testWidgets('renders "Learn" title', (tester) async {
      await tester.pumpWidget(
        _wrap(const LearnBanner(completedLessons: 3, totalLessons: 10)),
      );

      expect(find.text('Learn'), findsOneWidget);
    });

    testWidgets('renders lesson count text', (tester) async {
      await tester.pumpWidget(
        _wrap(const LearnBanner(completedLessons: 3, totalLessons: 10)),
      );

      // The banner shows "3/10" as the progress counter.
      expect(find.text('3/10'), findsOneWidget);
    });

    testWidgets('renders with zero lessons without throwing', (tester) async {
      await tester.pumpWidget(
        _wrap(const LearnBanner(completedLessons: 0, totalLessons: 0)),
      );

      expect(find.text('Learn'), findsOneWidget);
    });
  });

  group('CourseCard', () {
    testWidgets('renders course title', (tester) async {
      final course = _dummyCourse();

      await tester.pumpWidget(_wrap(
        CourseCard(
          course: course,
          completedCount: 0,
          totalCount: 5,
          progressFraction: 0.0,
          onTap: () {},
        ),
      ));

      expect(find.text('CPR Basics'), findsOneWidget);
    });

    testWidgets('renders course description', (tester) async {
      final course = _dummyCourse();

      await tester.pumpWidget(_wrap(
        CourseCard(
          course: course,
          completedCount: 0,
          totalCount: 5,
          progressFraction: 0.0,
          onTap: () {},
        ),
      ));

      expect(find.text('Learn how to perform CPR correctly.'), findsOneWidget);
    });

    testWidgets('renders difficulty chip', (tester) async {
      final course = _dummyCourse();

      await tester.pumpWidget(_wrap(
        CourseCard(
          course: course,
          completedCount: 0,
          totalCount: 5,
          progressFraction: 0.0,
          onTap: () {},
        ),
      ));

      expect(find.text('Beginner'), findsOneWidget);
    });

    testWidgets('shows progress row when completedCount > 0', (tester) async {
      final course = _dummyCourse();

      await tester.pumpWidget(_wrap(
        CourseCard(
          course: course,
          completedCount: 2,
          totalCount: 5,
          progressFraction: 0.4,
          onTap: () {},
        ),
      ));

      expect(find.text('2/5 completed'), findsOneWidget);
    });
  });

  group('QuizHeader', () {
    testWidgets('renders lesson title', (tester) async {
      await tester.pumpWidget(_wrap(
        QuizHeader(
          lessonTitle: 'Chest Compressions',
          currentIndex: 0,
          total: 5,
          colorScheme: ThemeData.light().colorScheme,
          onBack: () {},
        ),
      ));

      expect(find.text('Chest Compressions'), findsOneWidget);
    });

    testWidgets('renders "Lesson Quiz" subtitle', (tester) async {
      await tester.pumpWidget(_wrap(
        QuizHeader(
          lessonTitle: 'Chest Compressions',
          currentIndex: 0,
          total: 5,
          colorScheme: ThemeData.light().colorScheme,
          onBack: () {},
        ),
      ));

      expect(find.text('Lesson Quiz'), findsOneWidget);
    });

    testWidgets('renders back button', (tester) async {
      await tester.pumpWidget(_wrap(
        QuizHeader(
          lessonTitle: 'Chest Compressions',
          currentIndex: 0,
          total: 5,
          colorScheme: ThemeData.light().colorScheme,
          onBack: () {},
        ),
      ));

      expect(find.text('Back to Course'), findsOneWidget);
    });
  });

  // -------------------------------------------------------------------------
  // Practice feature widgets
  // -------------------------------------------------------------------------

  group('TrialStatChip', () {
    testWidgets('renders label text', (tester) async {
      await tester.pumpWidget(_wrap(
        const TrialStatChip(
          icon: Icons.timer,
          label: 'Time',
          value: '1:30',
          color: Colors.blue,
        ),
      ));

      expect(find.text('Time'), findsOneWidget);
    });

    testWidgets('renders value text', (tester) async {
      await tester.pumpWidget(_wrap(
        const TrialStatChip(
          icon: Icons.timer,
          label: 'Time',
          value: '1:30',
          color: Colors.blue,
        ),
      ));

      expect(find.text('1:30'), findsOneWidget);
    });
  });

  // -------------------------------------------------------------------------
  // Profile feature widgets
  // -------------------------------------------------------------------------

  group('NotificationSectionCard', () {
    testWidgets('renders title text', (tester) async {
      await tester.pumpWidget(_wrap(
        const NotificationSectionCard(
          title: 'Reminders',
          child: Text('Child content'),
        ),
      ));

      expect(find.text('Reminders'), findsOneWidget);
    });

    testWidgets('renders child widget', (tester) async {
      await tester.pumpWidget(_wrap(
        const NotificationSectionCard(
          title: 'Reminders',
          child: Text('Child content'),
        ),
      ));

      expect(find.text('Child content'), findsOneWidget);
    });
  });
}
