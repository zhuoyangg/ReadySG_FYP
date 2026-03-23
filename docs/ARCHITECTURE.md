# System Architecture

Technical reference for the ReadySG application architecture.

---

## 1. Layered Architecture

```
Flutter App
  ├── Presentation Layer  (screens + extracted widget files)
  ├── State Layer         (ChangeNotifier Providers, one per feature)
  ├── Repository Layer    (typed RepositoryResult<T> returns)
  └── Storage Layer
        ├── Hive          (local cache — offline-first)
        └── Supabase      (remote — auth + PostgreSQL)
```

**Core stack:**
- Flutter + Provider + GoRouter
- Hive for local persistence and offline-first cache
- Supabase for authentication and remote data sync
- flutter_map + OpenStreetMap for AED map rendering
- flutter_local_notifications for scheduled reminders

---

## 2. Data Flow

### Read path (cache-first)
1. Provider requests data from Repository
2. Repository returns Hive-cached content immediately when present
3. Background Supabase fetch initiated
4. On success: Hive cache updated, UI notified
5. On failure: `syncFailed` flag set; cached data remains fully usable

### Write path (optimistic)
1. Write to Hive immediately
2. Notify UI from local state
3. Attempt remote sync to Supabase in background
4. Failed writes queue via `SyncQueueService` and are flushed on reconnect

---

## 3. Feature Architecture

### Authentication
- Repository handles Supabase sign-in/up and fallback profile creation via `.maybeSingle()`
- Sign-up transitions into authenticated state only when Supabase returns a real session; email-confirmation accounts remain on the auth flow until verified
- `AuthProvider.checkAuthStatus()` called at startup: reads Hive session, validates with Supabase in background, triggers GoRouter redirect
- Auth refresh pulls the latest remote profile fields (points, streak) back into Hive after dashboard/practice load
- RLS policies for `profiles` and `user_progress` checked in via `supabase/sql/auth_security_schema.sql`

### Learning
- Hierarchy: Course → Lesson (JSONB slides) → Quiz → Result
- Slide types: `text`, `image`, `video`, `tip`, `quiz_prompt` (auto-appended at runtime)
- `LessonModel.slides` getter applies a double-decode guard for stale cached data
- `CoursesProvider` is the single source of truth for courses, lessons, and progress; resets in-memory state on user change
- `LessonsProvider` kept thin for quiz flow compatibility only
- Quiz cache cleared and deduplicated by `sort_order` during sync to evict stale entries
- Image slides: route to `Image.asset` for paths starting with `assets/`; fallback broken-image icon for network failures
- Video slides: inline `YoutubePlayerScaffold` via `youtube_player_iframe`; always exposes "Open on YouTube" fallback

### Emergency Guides
- Cache warmed at startup (after Hive initialisation) so offline-critical content is retained before connectivity drops
- Same double-decode guard as `LessonModel` applied in `EmergencyGuideModel.slides`
- Guest access: GoRouter redirect permits unauthenticated access to `/emergency-guest` and all `/guide/*` paths unconditionally

### AED Locator
- Data pipeline: data.gov.sg → Supabase Edge Function (`sync-aed`) → `aed_locations` table → Hive cache
- Paginated fetch: `.range(from, from+999)` loop until short-count response; batch `putAll` to Hive
- Screen keeps a live `StreamSubscription` to `Geolocator.getPositionStream(distanceFilter: 10)` while visible; paused on app background
- GPS denial tracked independently from data sync failure via `locationError`/`hasLocationError` on `AEDProvider`
- AED defaults to list view on first open; map view loaded on explicit toggle

### Profile and Preferences
- Profile feature owns `ProfileScreen`, `ProfileSettingsScreen`, `ProfileNotificationsScreen`
- App preferences persisted in Hive `settingsBox`
- Notification diagnostics exposed only in debug builds via `kDebugMode` guard

### Gamification and Practice
- Badge conditions evaluated after each quiz completion; earned badge IDs cached as JSON in `settingsBox` keyed `earned_badges_$userId`
- Spaced practice schedules stored locally in Hive only; no Supabase sync
- Daily challenge type selected by `dayOfYear % 5`; bonus idempotent via `daily_challenge_bonus_$userId_$date` flag
- Local reminders carry a payload consumed at app start or notification tap to route users back to the home shell
- Recent activity backed by `RecentActivityService`: local Hive append-only feed mirrored to Supabase `recent_activity`; server `created_at` used as canonical sort key; original `activity_at` preserved for display
- Practice points derived from quick-quiz and time-trial activity entries; distinct from `profiles.total_points`

---

## 4. Provider Error State Pattern

All background-sync providers expose:
```dart
bool get syncFailed;
bool get hasData;
```

**Screen rendering rule:**
- `isLoading && !hasData` → `ReadyLoadingState` (shimmer skeleton)
- `!hasData && (syncFailed || error != null)` → `ReadyErrorState`
- `hasData` → show data + `ReadyOfflineBanner(visible: syncFailed && hasData)`

---

## 5. Design System

### Semantic tokens
`AppSemanticColors` ThemeExtension with 9 tokens accessible via `AppSemanticColors.of(context)`:

| Token | Purpose |
|-------|---------|
| `success` | Positive feedback, quiz pass |
| `warning` | Caution states |
| `danger` | Errors, emergency callouts |
| `points` | XP and score highlights |
| `streak` | Streak counter |
| `progress` | Progress bars |
| `achievement` | Badge unlocks |
| `callBanner` | CALL 995 persistent banner |
| `subtleText` | De-emphasised labels |

**Allowlisted exceptions** (not tokenised): `Colors.white`, `Colors.black`, `Colors.transparent`; tip-slide `_bgColor()`/`_accentColor()` (content-driven from JSON); AED GPS-dot `Colors.blue`.

### Shared widget layer
`lib/shared/widgets/`: `ReadyEmptyState`, `ReadyErrorState`, `ReadyLoadingState`, `ReadySectionHeader`, `ReadyOptionTile`, `ReadyStatChip`, `ReadyScoreBadge`, `ReadyOfflineBanner`, `CallHelpPage`, `ReadySkeletonBox`, `ReadySkeletonCard`, `ReadySkeletonList`, `ReadySkeletonGrid`

### Presentation layer structure
- Screen file: state orchestration and top-level `build()` only (~100–350 lines)
- Extracted widgets: one file per logical UI section in `feature/presentation/widgets/`
- Shared display utilities (colour maps, icon maps) in `feature/presentation/utils/`

### Navigation transitions
| Route type | Transition |
|-----------|-----------|
| Top-level tabs (home, auth, emergency-guest) | Default platform transition |
| Drill-down routes (course, lesson, quiz, guide, badges) | `CustomTransitionPage` — 300 ms right-to-left `SlideTransition` (easeInOut) |
| Course category icon | `Hero` animation from `CourseCard` to `CourseDetailScreen` header |

---

## 6. Routing

GoRouter instance created once in `_AppViewState.initState()` with `refreshListenable: authProvider`.

**Redirect logic** (`AppRouter.resolveRedirect()` — pure static function):
1. `isLoading` → `/loading`
2. Unauthenticated + `isGuestAccessible` (`/emergency-guest`, `/guide/*`) → allow
3. Unauthenticated → `/login`
4. Authenticated on auth-only route (`/login`, `/signup`) → `/home`

**Named routes:**
`/loading`, `/login`, `/signup`, `/home`, `/courses`, `/course/:courseId`, `/lesson/:id`, `/quiz/:lessonId`, `/quiz-result`, `/completed-lessons`, `/badges`, `/emergency-guides`, `/guide/:id`, `/emergency-guest`, `/aed`, `/profile-settings`, `/profile-notifications`

---

## 7. Hive Schema

**Schema version:** 5

| TypeId | Model | Key Pattern |
|--------|-------|------------|
| 0 | `UserModel` | userId |
| 1 | `LessonModel` | lessonId |
| 2 | `QuizModel` | quizId |
| 3 | `UserProgressModel` | `${userId}_${lessonId}` |
| 4 | `EmergencyGuideModel` | guideId |
| 5 | `AEDLocationModel` | aedId |
| 7 | `BadgeModel` | badgeId |
| 10 | `SpacedPracticeModel` | `${userId}_${lessonId}_sp` |
| 11 | `CourseModel` | courseId |

**Untyped boxes (settingsBox):** mode key, earned badges JSON, daily counters, challenge bonus flags, recent activity JSON, app preferences

---

## 8. Supabase Schema

Nine tables: `profiles`, `courses`, `lessons`, `quizzes`, `user_progress`, `emergency_guides`, `aed_locations`, `badges`, `user_badges`

Row-Level Security enforced:
- `profiles`: authenticated user reads/writes own row only
- `user_progress`: authenticated user reads/writes own rows only
- `user_badges`: authenticated user reads own rows; service role inserts on award
- `badges`, `courses`, `lessons`, `quizzes`, `emergency_guides`, `aed_locations`: publicly readable by authenticated users

SQL schema files in `supabase/sql/`.
