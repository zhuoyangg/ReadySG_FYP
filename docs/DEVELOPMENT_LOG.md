# Development Log

A chronological record of ReadySG development, organised by project phase in accordance with the work plan.

---

## Phase 1 — Research and Requirements (Weeks 1–6, Oct–Nov 2025)

### Objectives
- Conduct literature review on emergency preparedness, cognitive load theory, gamification in education, and offline-first mobile architecture
- Evaluate existing applications: myResponder (SCDF) and iFirstAid as comparative baselines
- Select technology stack and define project scope

### Outcomes
- Technology stack selected: Flutter/Dart, Supabase (PostgreSQL + Auth), Hive, GoRouter, Provider, flutter_map (OpenStreetMap)
- Comparative analysis conducted for myResponder and iFirstAid; gaps identified (Section 2.3 of report)
- Project proposal submitted and approved

---

## Phase 2 — Architecture and Database Design (Weeks 7–9, Nov–Dec 2025)

### Objectives
- Define layered application architecture
- Design Supabase database schema
- Establish Architecture Decision Record (ADR) documentation process

### Outcomes
- Four-layer architecture established: Presentation → State (Provider) → Repository → Storage (Hive + Supabase)
- Nine-table Supabase schema designed: `profiles`, `courses`, `lessons`, `quizzes`, `user_progress`, `emergency_guides`, `aed_locations`, `badges`, `user_badges`
- Offline-first data contract defined: Hive cache-first read path with background Supabase synchronisation; UI remains usable on sync failure if cache exists
- ADR-001 to ADR-006 established covering core architectural choices (state management, video hosting, map provider, dev platform, environment variables, design system)

---

## Phase 3 — Prototype Development (Weeks 10–12, Dec 2025)

### Objectives
- Implement a runnable prototype demonstrating the dual-mode concept and offline-first architecture
- Submit Preliminary Project Report

### Outcomes
- Flutter project scaffolded with Supabase backend integration and Hive local database initialisation (12 typed boxes)
- Supabase authentication implemented (email/password sign-up and sign-in) with Hive session cache and auto-login on restart
- Dual-mode theme system implemented (Peaceful: blue-green palette; Emergency: red-dark palette) using Material 3
- GoRouter navigation shell with authentication-aware redirect logic implemented
- Initial emergency guides screen implemented as proof-of-concept
- Preliminary Project Report submitted

---

## Phase 4 — Core Feature Development (Weeks 13–16, Jan 2026)

### Learning Module
- Implemented Course → Lesson (slide viewer) → Quiz → Result navigation flow
- Lesson content stored as JSONB slide arrays in Supabase; supported slide types: `text`, `image`, `video`, `tip`, `quiz_prompt` (auto-appended at runtime)
- Double-decode guard implemented in `LessonModel.slides` getter to handle legacy double-encoded cached data (ADR-013)
- Quiz flow navigation: both legs (lesson→quiz and quiz-result→lesson) use `pushReplacement` to maintain `[Home, CourseDetail, Screen]` back-stack invariant (ADR-027)
- Quiz progress tracking: per-user score, points, and first-completion idempotency guard
- `CoursesProvider` established as single source of truth for courses, lessons, and progress (ADR-014)

### Emergency Guides
- Ten emergency guides implemented with offline-first cache warming at application startup
- Stress-optimised UX: persistent CALL 995 floating action button, 72 dp minimum touch targets, collapsible step cards, haptic feedback (ADR-018)
- Guest emergency access: unauthenticated users reach guides and AED locator via `/emergency-guest` without sign-in requirement (ADR-022)
- `EmergencyGuideModel` TypeAdapter hand-written for fine-grained JSONB serialisation control (ADR-016)

### AED Locator
- Supabase Edge Function (`sync-aed`, Deno/TypeScript) implemented to ingest 9,644 AED locations from data.gov.sg
- Paginated fetch loop (1,000 records/page) with batch Hive write using `putAll` (ADR-019)
- Map view: `flutter_map` with OpenStreetMap tiles and `MarkerClusterLayerWidget` for dense marker consolidation at lower zoom levels (ADR-020)
- List view: sorted by Haversine distance from live GPS position via `geolocator` position stream (ADR-021)
- GPS permission denial handled separately from AED data sync failure (ADR-036)

### Key Files Created
`main.dart`, `app.dart`, `hive_config.dart`, `supabase_config.dart`, `app_router.dart`, `auth_repository.dart`, `auth_provider.dart`, `login_screen.dart`, `signup_screen.dart`, `course_model.dart`, `course_repository.dart`, `courses_provider.dart`, `lesson_model.dart`, `lesson_repository.dart`, `quiz_model.dart`, `quiz_screen.dart`, `quiz_result_screen.dart`, `progress_repository.dart`, `emergency_guide_model.dart`, `emergency_guide_repository.dart`, `emergency_guides_provider.dart`, `emergency_guide_detail_screen.dart`, `aed_location_model.dart`, `aed_repository.dart`, `aed_provider.dart`, `location_service.dart`, `aed_locator_screen.dart`, `sync-aed/index.ts`, `guest_emergency_screen.dart`

---

## Phase 5 — Gamification, Content and Testing (Weeks 17–20, Feb 2026)

### Gamification System
- Badge system: 6 badge definitions across `milestone`, `streak`, and `quiz` categories seeded in Supabase; earned badge IDs cached as JSON string in Hive `settingsBox` (ADR-025)
- Spaced practice scheduling: fixed-interval progression (1→3→7→14→30 days) per completed lesson, stored locally in Hive with no Supabase sync (ADR-024)
- Daily challenges: 5 rotating types selected deterministically via `dayOfYear % 5`, idempotently awarded via Hive flag key (ADR-029)
- Points system: optimistic Hive write before background Supabase synchronisation for instant UI feedback (ADR-028)
- Local notifications: daily review reminder (20:00) and streak nudge (23:00) via `flutter_local_notifications v20`; platform-gated (no-op on Windows)
- `AppClock` static service introduced to abstract `DateTime.now()` for deterministic unit testing of time-dependent logic (ADR-023)
- `RecentActivityService`: local append-only event feed stored in Hive `settingsBox`; mirrored to Supabase `recent_activity` table for cross-device sync (ADR-037, ADR-040)
- Practice points derived separately from quick-quiz and time-trial activity entries, not from `profiles.total_points` (ADR-041)

### Content Expansion
- Seed data fully rewritten: 5 courses, 23 lessons, 115 quiz questions with Singapore-specific emergency content
- Emergency guides fully rewritten: 10 guides in concise quick-reference format covering CPR, choking, burns, bleeding, stroke, fractures, seizures, drowning, fire, and AED use
- Inline YouTube video player integrated via `youtube_player_iframe ^4.0.1`; always exposes "Open on YouTube" fallback (ADR-038)
- All lesson image slides migrated to local asset paths under `assets/images/lessons/` for guaranteed offline availability (ADR-039)

### Testing and Hardening
- `RepositoryResult<T>` typed error-handling contract introduced across all repository sync methods; `RepositoryError.type` enum enables provider error differentiation without try-catch (ADR-030)
- GoRouter redirect logic extracted as `AppRouter.resolveRedirect()` pure static function for unit testability; coupled Navigator dependency removed
- Automated test suite: 19 tests across 6 files covering routing, AED provider cache/sync, emergency guides provider, spaced practice interval logic, and form validators
- `SyncQueueService` implemented for offline mutation durability: lesson progress, points, streak, and badge awards queue locally and flush when backend access returns
- Explicit Row-Level Security policies added to Supabase for `profiles` and `user_progress` tables (`supabase/sql/auth_security_schema.sql`)
- Destructive AED reset SQL separated into `aed_schema_reset.sql`; default `aed_schema.sql` is idempotent (ADR-031)

### Key Files Created
`app_clock.dart`, `badge_model.dart`, `spaced_practice_model.dart`, `badge_repository.dart`, `spaced_practice_repository.dart`, `gamification_provider.dart`, `spaced_practice_provider.dart`, `notification_service.dart`, `dashboard_screen.dart`, `practice_screen.dart`, `quick_quiz_screen.dart`, `time_trial_screen.dart`, `recent_activity_service.dart`, `sync_queue_service.dart`, `signed_in_state_refresh_service.dart`, `app_router_redirect_test.dart`, `aed_provider_test.dart`, `emergency_guides_provider_test.dart`, `spaced_practice_model_test.dart`, `validators_test.dart`

---

## Phase 6 — UI/UX Overhaul and Submission (Weeks 21–24, Mar 2026)

### Design Token System
- `AppSemanticColors` `ThemeExtension` introduced with 9 named semantic tokens: `success`, `warning`, `danger`, `points`, `streak`, `progress`, `achievement`, `callBanner`, `subtleText`; fallback derives from `colorScheme` rather than hardcoded Peaceful values (ADR-032)
- `AppTokens` spacing and sizing constants applied throughout all screens
- All 17 screens migrated from hardcoded colour values to semantic tokens; `Colors.white`, `Colors.black`, `Colors.transparent`, tip-slide content colours, and AED GPS-dot `Colors.blue` maintained as allowlisted exceptions (ADR-034)
- `ReadyOfflineBanner` persistent strip introduced: triggered by `provider.syncFailed && provider.hasData`; replaces SnackBar for indefinite offline states (ADR-033)
- All four background-sync providers (`CoursesProvider`, `EmergencyGuidesProvider`, `GamificationProvider`, `AEDProvider`) extended with `syncFailed`/`hasData` boolean flags for three-state rendering (ADR-035)

### Shared Component Library
- 9 shared widgets in `lib/shared/widgets/`: `ReadyEmptyState`, `ReadyErrorState`, `ReadyLoadingState`, `ReadySectionHeader`, `ReadyOptionTile`, `ReadyStatChip`, `ReadyScoreBadge`, `ReadyOfflineBanner`, `CallHelpPage`
- `ReadySkeleton` shimmer loading components (`ReadySkeletonBox`, `ReadySkeletonCard`, `ReadySkeletonList`, `ReadySkeletonGrid`) via `shimmer: ^3.0.0` (ADR-044); wired into AED list, Emergency Guides, Courses, and Badges loading states

### Presentation Layer SRP Decomposition
- All major screen files refactored to single-responsibility: screen files handle state orchestration only (~100–350 lines); UI sections extracted into dedicated files (ADR-043)
- 50+ widget files extracted across all feature modules into `feature/presentation/widgets/` directories
- Total presentation layer line count reduced from approximately 8,000 to 3,000 lines across decomposed screens

### Animation and Transition Polish
- `AnimatedSwitcher` (300 ms fade) applied on `CoursesScreen` and `EmergencyGuidesScreen` for smooth loading→content→error state transitions
- Hero animation: course category icon transitions from `CourseCard` to `CourseDetailScreen` header using `Hero(tag: 'course_icon_${course.id}')`
- GoRouter `CustomTransitionPage` with 300 ms right-to-left `SlideTransition` (easeInOut) applied to all drill-down routes; top-level tab and auth routes retain default platform transitions (ADR-045)

### Hardening and Security
- Authentication hardened: authenticated app state set only when Supabase returns a real session; email-confirmation-only sign-ups remain on the auth flow until verified (ADR-046)
- Debug diagnostics (marker time-travel controls, notification test delivery) restricted to debug builds; release builds ignore persisted debug toggle values (ADR-047)
- Emergency guides and AED data promoted to startup-priority offline cache, warmed immediately after Hive initialisation (ADR-042)
- Profile points sync migrated from direct column write to Supabase RPC (`supabase/sql/profile_points_rpc.sql`)
- `CoursesProvider` cold-start recovery: re-syncs catalog from Supabase when Hive cache is empty, regardless of prior sync flag; resets in-memory state on user change

### Final Automated Test Suite
- Test suite expanded to 51 tests across 9 files; all passing at submission
- `widget_smoke_test.dart`: 21 characterisation smoke tests for 8 extracted presentation widgets
- `time_ago_formatter_test.dart`: 7 tests for relative date formatting edge cases
- `courses_provider_test.dart`: 2 tests for cache-clear re-sync and user-switch data isolation
- `flutter analyze`: zero issues

### Manual Validation (Android)
- Full learning flow: courses → lesson slides → quiz → result → progress saved
- Offline emergency guide access after cache warm (airplane mode)
- Guest emergency access without sign-in
- AED locator with GPS permission granted and denied; list accessible in both states
- Daily challenge idempotency: bonus points awarded once per day
- Mode toggle confirmation both directions; tab layout updates on confirmation
- Quiz navigation back-stack invariant: result screen back button → CourseDetail
- Real-clock notification delivery at 20:00 and 23:00 on Android device
- iOS validation not performed (Windows-only development environment)

---

*Final submission: Week 24, 23 March 2026*
