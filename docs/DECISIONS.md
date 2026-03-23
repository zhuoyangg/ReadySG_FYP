# Architecture Decision Records (ADRs)

Consolidated record of all technical decisions made during ReadySG development.
Each ADR documents the context, decision, rationale, and alternatives considered.

---

## Phase 2 — Foundation

### ADR-001: Provider over Bloc/Riverpod
- **Phase:** 2 (Nov 2025)
- **Context:** Needed a state management solution for a coursework project
- **Decision:** Use Provider with ChangeNotifier
- **Rationale:** Simpler to understand, well-documented, sufficient for this app's complexity, clearer for university coursework evaluation
- **Alternatives:** Bloc (too verbose for coursework), Riverpod (newer, less established documentation at time of decision)

### ADR-002: YouTube for video hosting
- **Phase:** 2 (Nov 2025)
- **Context:** Lesson slides can include video content
- **Decision:** Store YouTube video IDs; render inline via `youtube_player_iframe` (superseded external-launch approach from prototype)
- **Rationale:** Unlimited free hosting, no Supabase Storage costs; inline playback keeps user in the lesson flow
- **Alternatives:** Supabase Storage (costs money at scale), external url_launcher (breaks lesson flow)

### ADR-003: OpenStreetMap over Google Maps
- **Phase:** 2 (Nov 2025)
- **Context:** AED locator needs a map provider
- **Decision:** Use `flutter_map` with OpenStreetMap tiles
- **Rationale:** No API key required, completely free, meets project constraint of free-tier only
- **Alternatives:** Google Maps (requires API key, billing account)

### ADR-004: Windows desktop for development
- **Phase:** 2 (Nov 2025)
- **Context:** Need a fast development loop; mobile emulators are slow
- **Decision:** Add Windows desktop support for development and testing
- **Rationale:** Fastest compile and hot-reload cycle; GPS and notification features degrade gracefully on Windows
- **Alternatives:** Android emulator only (slower iteration)

### ADR-005: flutter_dotenv for environment variables
- **Phase:** 2 (Nov 2025)
- **Context:** Supabase URL and anon key must not be committed to version control
- **Decision:** Use `flutter_dotenv` with `.env` file (gitignored)
- **Rationale:** Simple, well-supported, standard Flutter practice
- **Alternatives:** Dart defines (compile-time only), hardcoded (security risk)

### ADR-006: Material 3 design system
- **Phase:** 2 (Nov 2025)
- **Context:** Need a design system for a dual-theme application
- **Decision:** Use Material 3 with `useMaterial3: true`
- **Rationale:** Modern, well-supported by Flutter, good theming support for Peaceful/Emergency dual-theme
- **Alternatives:** Material 2 (deprecated), custom design system (excessive effort for coursework scope)

---

## Phase 4 — Authentication

### ADR-007: Offline-first auth with Hive session cache
- **Phase:** 4 (Jan 2026)
- **Context:** User should stay logged in across app restarts without network
- **Decision:** Cache user session in Hive; check Hive first on app start, then validate with Supabase in background
- **Rationale:** Enables offline access to cached content immediately; Supabase session refresh happens silently
- **Alternatives:** Always require network for auth check (poor offline UX)

### ADR-008: Auto-profile creation with `.maybeSingle()`
- **Phase:** 4 (Jan 2026)
- **Context:** Users who signed up via Supabase Auth may not have a `profiles` table row
- **Decision:** Use `.maybeSingle()` instead of `.single()` when querying profiles; auto-create missing profiles on sign-in
- **Rationale:** Handles partial users gracefully; no manual database maintenance needed
- **Alternatives:** Require profiles to be created during sign-up only (fragile if sign-up flow is interrupted)

---

## Phase 4 — Navigation

### ADR-009: Mode persistence via Hive settingsBox
- **Phase:** 4 (Jan 2026)
- **Context:** App mode (Peaceful/Emergency) should persist across restarts
- **Decision:** Store current mode in Hive `settingsBox` under `AppConstants.currentModeKey`
- **Rationale:** Consistent with other Hive-based persistence; no network dependency
- **Alternatives:** SharedPreferences (another dependency), ephemeral only (poor UX)

### ADR-010: GoRouter with refreshListenable for auth guards
- **Phase:** 4 (Jan 2026)
- **Context:** Need authentication-aware routing with redirect logic
- **Decision:** GoRouter with `refreshListenable: authProvider` and a static `resolveRedirect()` method
- **Rationale:** Testable redirect logic (pure function); automatic re-evaluation on auth state change
- **Alternatives:** Navigator 2.0 manually (complex), auto_route (heavier dependency)

### ADR-011: IndexedStack for tab state preservation
- **Phase:** 4 (Jan 2026)
- **Context:** Bottom navigation tabs should maintain their state when switching
- **Decision:** Use `IndexedStack` in `HomeScreen` to keep all tab pages alive
- **Rationale:** Prevents data re-fetching and scroll position loss on tab switch
- **Alternatives:** Rebuild pages on tab switch (poor UX, unnecessary network calls)

---

## Phase 4 — Learning Module

### ADR-012: JSONB slide content in lessons table
- **Phase:** 4 (Jan 2026)
- **Context:** Lesson content needs to support multiple slide types (text, image, video, tip)
- **Decision:** Store slide content as a JSONB array in `lessons.content` column; decode in Flutter
- **Rationale:** Flexible schema-less content; easy to add new slide types; single table for all lesson data
- **Alternatives:** Separate slides table with foreign keys (more complex queries, more joins)

### ADR-013: Double-decode guard for stale Hive data
- **Phase:** 4 (Jan 2026)
- **Context:** JSON content was double-encoded when cached in Hive (String → String of String)
- **Decision:** `slides` getter decodes twice if first `jsonDecode` returns a String; repository checks `row['content'] is String` before encoding
- **Rationale:** Defensive fix that handles both fresh and stale cached data without requiring a Hive wipe
- **Alternatives:** Force Hive clear on every update (loses offline data), schema version bump only (does not fix already-cached data)

### ADR-014: CoursesProvider as single source of truth
- **Phase:** 4 (Jan 2026)
- **Context:** Courses, lessons, and progress need a unified state manager
- **Decision:** `CoursesProvider` loads courses, lessons, and progress together; exposes `totalCompletedLessons`, `findLesson()`
- **Rationale:** Single provider avoids split-brain state; consumers always receive consistent data
- **Alternatives:** Separate providers per entity (coordination complexity)

### ADR-015: LessonsProvider kept thin for quiz flow
- **Phase:** 4 (Jan 2026)
- **Context:** `QuizScreen`/`QuizResultScreen` were built against `LessonsProvider`
- **Decision:** Keep `LessonsProvider` as a thin cache-reader for quiz flow compatibility only
- **Rationale:** Avoids rewriting quiz screens; `LessonsProvider` reads from the same Hive boxes
- **Alternatives:** Refactor quiz screens to use `CoursesProvider` (unnecessary churn)

---

## Phase 4 — Emergency Guides

### ADR-016: Hand-written TypeAdapter for EmergencyGuideModel
- **Phase:** 4 (Jan 2026)
- **Context:** `build_runner` generates TypeAdapters, but manual control was needed for JSONB handling
- **Decision:** Write `EmergencyGuideModel` TypeAdapter by hand in `.g.dart`
- **Rationale:** Finer control over serialisation of the `contentJson` field
- **Alternatives:** Generated adapter with custom logic (mixing manual and generated code is fragile)

### ADR-017: Same double-decode guard as LessonModel
- **Phase:** 4 (Jan 2026)
- **Context:** Emergency guide content uses the same JSONB storage pattern as lessons
- **Decision:** Apply identical double-decode guard in `EmergencyGuideModel.slides` getter
- **Rationale:** Consistent defensive behaviour across both content types
- **Alternatives:** Separate handling (code duplication, inconsistent behaviour)

### ADR-018: Stress-optimised emergency UX
- **Phase:** 4 (Jan 2026)
- **Context:** Emergency guides are accessed during crisis situations with elevated cognitive load
- **Decision:** Large typography (`bodyLarge`, 16 sp, 1.75 line height), haptic feedback, 72 dp touch targets, progressive disclosure (step 1 open, remainder collapsed), persistent CALL 995 FAB
- **Rationale:** Users under stress have reduced fine motor control and cognitive capacity
- **Alternatives:** Standard Material sizing (too small for stress-time use)

---

## Phase 4 — AED Locator

### ADR-019: Paginated Supabase fetch (1,000 records/page)
- **Phase:** 4 (Jan 2026)
- **Context:** 9,644 AED locations need to be synced from Supabase; default row limit is 1,000
- **Decision:** Loop with `.range(from, from+999)` fetching 1,000 rows per page; batch write to Hive with `putAll`
- **Rationale:** Works within Supabase default limits without server configuration changes
- **Alternatives:** Increase server row limit (requires Supabase config access), single large query (hits default limit)

### ADR-020: MarkerClusterLayerWidget for AED clustering
- **Phase:** 4 (Jan 2026)
- **Context:** 9,644 markers on a map causes rendering performance issues at low zoom
- **Decision:** Use `flutter_map_marker_cluster`; cluster circles with count; individual markers at zoom 18
- **Rationale:** Standard solution for dense marker sets; good UX at all zoom levels
- **Alternatives:** Manual clustering (complex), no clustering (unreadable at low zoom)

### ADR-021: StreamSubscription for live distance updates
- **Phase:** 4 (Jan 2026)
- **Context:** AED distances should update as the user moves
- **Decision:** `AEDProvider` subscribes to `Geolocator.getPositionStream(distanceFilter: 10)` while the AED screen is visible; subscription paused on app background
- **Rationale:** Real-time distance sorting without manual refresh; 10 m filter prevents excessive updates
- **Alternatives:** Manual refresh button only (stale data)

### ADR-022: Guest route whitelisting in GoRouter redirect
- **Phase:** 4 (Jan 2026)
- **Context:** Unauthenticated users should access emergency features without requiring login
- **Decision:** GoRouter redirect checks `isGuestAccessible` for `/emergency-guest` and all `/guide/*` paths; allows access unconditionally
- **Rationale:** Emergency information should never be gated behind login
- **Alternatives:** Separate unauthenticated app instance (too complex)

---

## Phase 5 — Gamification

### ADR-023: AppClock static service for testable time
- **Phase:** 5 (Feb 2026)
- **Context:** Daily challenges, streaks, and spaced practice depend on the current time; time-dependent logic must be deterministically testable
- **Decision:** All time reads use `AppClock.now()` instead of `DateTime.now()`; `AppClock.setOverride()` injects a fixed time in tests
- **Rationale:** Deterministic testing; debug controls for manual QA of time-dependent features
- **Alternatives:** Mock `DateTime` globally (fragile), no time abstraction (untestable)

### ADR-024: Spaced practice Hive-only (no Supabase sync)
- **Phase:** 5 (Feb 2026)
- **Context:** Spaced practice schedules track per-user review intervals
- **Decision:** Store `SpacedPracticeModel` in Hive only; no Supabase sync
- **Rationale:** Local device concern; reduces backend complexity; review schedules are personal to the device
- **Alternatives:** Sync to Supabase (cross-device consistency, but unnecessary for coursework scope)

### ADR-025: Earned badge IDs as JSON in settingsBox
- **Phase:** 5 (Feb 2026)
- **Context:** Need to track which badges a user has earned locally
- **Decision:** Store as JSON-encoded list in `settingsBox` keyed `earned_badges_$userId`
- **Rationale:** Avoids a separate `UserBadgeModel` TypeAdapter; simple for local caching
- **Alternatives:** `UserBadgeModel` with Hive TypeAdapter (more ceremony for a simple list)

### ADR-026: QuickQuizScreen via Navigator.push, not GoRouter
- **Phase:** 5 (Feb 2026)
- **Context:** Quick quiz passes `List<QuizModel>` as constructor arguments
- **Decision:** Use `Navigator.push` from `PracticeScreen`
- **Rationale:** GoRouter cannot pass complex objects via path parameters; deep-linking is not needed for the practice quiz
- **Alternatives:** Serialise quiz IDs to path params (complex, unnecessary)

---

## Phase 5 — Content and UX

### ADR-027: pushReplacement for both legs of quiz loop
- **Phase:** 5 (Feb 2026)
- **Context:** Quiz navigation (lesson→quiz→result→back-to-lesson) needs a consistent back stack
- **Decision:** Both "Start Quiz" (lesson→quiz) and "Back to Lesson" (result→lesson) use `context.pushReplacement`
- **Rationale:** Maintains `[Home, CourseDetail, Screen]` invariant; CourseDetail always in back stack; no stack growth across multiple quiz loops
- **Alternatives:** Regular push (stack grows with each quiz attempt)

### ADR-028: Optimistic Hive points write
- **Phase:** 5 (Feb 2026)
- **Context:** Points should display immediately on quiz result, not after Supabase sync
- **Decision:** `ProgressRepository.completeLesson()` updates `usersBox` immediately; Supabase sync happens in background
- **Rationale:** Instant feedback; Supabase sync failure does not affect UX
- **Alternatives:** Wait for Supabase confirmation (slow, breaks offline)

### ADR-029: Daily challenge 5-type rotation
- **Phase:** 5 (Feb 2026)
- **Context:** Daily challenges need to rotate predictably without server involvement
- **Decision:** 5 `_ChallengeSpec` types selected by `dayOfYear % 5`; bonus awarded idempotently via `daily_challenge_bonus_$userId_$date` Hive flag
- **Rationale:** Deterministic, no server involvement, idempotent (cannot double-award)
- **Alternatives:** Random selection (non-deterministic, harder to test), server-driven (unnecessary complexity)

---

## Phase 5 — Testing and Hardening

### ADR-030: RepositoryResult\<T\> typed sync errors
- **Phase:** 5 (Feb 2026)
- **Context:** Repository sync methods were throwing exceptions; callers needed to distinguish error types
- **Decision:** Introduced `RepositoryResult<T>` with `success(data)` and `failure(RepositoryError)` variants; `RepositoryError.type` enum with `network`, `auth`, `schema`, `unknown` values
- **Rationale:** Type-safe error handling; callers pattern-match without try-catch; fake repositories return controlled failures in tests
- **Alternatives:** Continue throwing exceptions (less explicit error handling)

### ADR-031: Split destructive AED reset SQL
- **Phase:** 5 (Feb 2026)
- **Context:** `aed_schema.sql` contained `DROP TABLE CASCADE` which could accidentally destroy production data
- **Decision:** Created separate `aed_schema_reset.sql` for destructive operations; default `aed_schema.sql` is idempotent (`CREATE IF NOT EXISTS`)
- **Rationale:** Prevents accidental data loss; default script is safe to re-run
- **Alternatives:** Single script with comments (too easy to accidentally run destructive parts)

---

## Phase 6 — UI/UX Overhaul

### ADR-032: AppSemanticColors ThemeExtension with colorScheme-derived fallback
- **Phase:** 6 (Mar 2026)
- **Context:** 145+ hardcoded colour references across 17 screens required tokenisation
- **Decision:** `AppSemanticColors` ThemeExtension with 9 semantic tokens; fallback derives from `colorScheme` (not hardcoded Peaceful values)
- **Rationale:** Emergency theme renders correctly if ThemeExtension is missing (e.g., in tests); mode-aware colours throughout
- **Alternatives:** Hardcoded fallback to Peaceful values (broken in Emergency mode widget tests)

### ADR-033: ReadyOfflineBanner as persistent strip
- **Phase:** 6 (Mar 2026)
- **Context:** Need to communicate "showing cached data" when sync fails but cached data exists
- **Decision:** Persistent banner strip (not SnackBar) triggered by `provider.syncFailed && provider.hasData`
- **Rationale:** SnackBars auto-dismiss; offline state may persist indefinitely and users need ongoing awareness
- **Alternatives:** SnackBar (auto-dismisses, user misses it), dialog (too intrusive)

### ADR-034: Colors allowlist
- **Phase:** 6 (Mar 2026)
- **Context:** Some `Colors.*` references should not be tokenised
- **Decision:** Allowlist: `Colors.white`, `Colors.black`, `Colors.transparent`; tip slide `_bgColor()`/`_accentColor()` (content-driven from JSON); AED user-location dot `Colors.blue` (standard GPS indicator)
- **Rationale:** These colours are structural, content-driven, or standard convention
- **Alternatives:** Tokenise everything (unnecessary complexity for content-driven and structural colours)

### ADR-035: syncFailed + hasData pattern on all sync providers
- **Phase:** 6 (Mar 2026)
- **Context:** Screens need to distinguish "no data + error" from "cached data + sync failed"
- **Decision:** All 4 background-sync providers expose `syncFailed` and `hasData` booleans
- **Rationale:** Enables 3-state rendering: skeleton loading, total error, degraded (cached data + `ReadyOfflineBanner`)
- **Alternatives:** Single error flag (cannot distinguish "show cached data" from "total failure")

### ADR-036: AED locationError tracked separately from data sync failure
- **Phase:** 6 (Mar 2026)
- **Context:** AED screen can fail independently via data sync failure or GPS permission denial
- **Decision:** Separate `_locationError`/`hasLocationError` fields in `AEDProvider`; map shows "Location Unavailable" + Open Settings when GPS denied
- **Rationale:** GPS denial is distinct from data sync; AED list remains accessible without location; separate UX for each failure mode
- **Alternatives:** Single error state (cannot show AED data when only GPS fails)

### ADR-037: Recent activity as a local append-only event feed
- **Phase:** 6 (Mar 2026)
- **Context:** Dashboard recent activity could not accurately represent daily challenge rewards, badge unlocks, quick quizzes, or review outcomes when reconstructed from lesson progress alone
- **Decision:** Introduce `RecentActivityService` backed by Hive `settingsBox` as a local append-only event feed; log events at actual completion points
- **Rationale:** Real event timestamps are more accurate than inferred progress history; supports multiple activity types without added backend complexity
- **Alternatives:** Keep deriving from `UserProgressModel` only (insufficient event coverage), add a remote activity table immediately (extra backend surface)

### ADR-038: Inline YouTube video via youtube_player_iframe
- **Phase:** 6 (Mar 2026)
- **Context:** Video slides originally used `url_launcher` to open YouTube externally, breaking the lesson flow
- **Decision:** Replace external launch with `youtube_player_iframe ^4.0.1`; `_VideoSlide` is a `StatefulWidget` holding a `YoutubePlayerController`; always exposes "Open on YouTube" fallback
- **Rationale:** Inline playback keeps the user in the lesson flow; WebView is already available on Android/iOS
- **Alternatives:** Keep external launch (breaks lesson flow), `video_player` with hosted files (storage cost)

### ADR-039: Local asset images for lesson slides
- **Phase:** 6 (Mar 2026)
- **Context:** Lesson image slides used external CDN URLs that proved unreliable when loaded anonymously
- **Decision:** Migrate all lesson image slides to local assets under `assets/images/lessons/`; `_ImageSlide` routes to `Image.asset` vs `Image.network` based on URL prefix
- **Rationale:** Local assets are always available offline, never break due to CDN changes, and load instantly
- **Alternatives:** Supabase Storage (operational cost), Wikimedia direct (SVG rendering unreliable), external CDNs (unreliable for anonymous access)

---

## Phase 6 — Hardening and Sync

### ADR-040: Supabase-backed recent activity with server-side canonical ordering
- **Phase:** 6 (Mar 2026)
- **Context:** Local append-only feed was sufficient for single-device offline UX; cross-device sync required server ordering; emulator clock drift caused recency list anomalies
- **Decision:** Mirror recent-activity entries to Supabase `recent_activity` table on refresh; treat Supabase server timestamps (`created_at`) as canonical ordering; preserve original `activity_at` for display
- **Rationale:** Preserves offline-first local event log while enabling cross-device sync and removing dependence on unreliable client clocks
- **Alternatives:** Keep recent activity purely local (no cross-device history), trust client timestamps for ordering (breaks with clock skew)

### ADR-041: Practice points as a separate metric
- **Phase:** 6 (Mar 2026)
- **Context:** Practice screen displayed `profiles.total_points`, mixing lesson completions and challenge bonuses into a label describing practice-only progress
- **Decision:** Derive practice points from recent-activity entries of type `quickQuiz` and `timeTrial` only; keep overall account points on dashboard and profile
- **Rationale:** Aligns the metric with the UI label; avoids schema churn by deriving from already-logged activity data
- **Alternatives:** Continue showing total profile points in Practice (misleading), add a dedicated `practice_points` column to `profiles` (extra migration)

### ADR-042: Emergency guides and AED data as startup-priority offline cache
- **Phase:** 6 (Mar 2026)
- **Context:** Submission hardening clarified that offline emergency guidance is the application's primary value proposition
- **Decision:** Warm emergency guide and AED caches at app startup, immediately after Hive initialisation; decouple from learning-mode sync preferences
- **Rationale:** The application's core emergency value is access to life-saving guidance and AED locations during poor or absent connectivity
- **Alternatives:** Equal cache priority across all content domains (does not reflect the product's emergency purpose)

---

## Phase 6 — Presentation Architecture

### ADR-043: SRP widget extraction for all large screen files
- **Phase:** 6 (Mar 2026)
- **Context:** All major screen files had grown to 500–1,400 lines with private widget classes mixed into the screen file
- **Decision:** Extract every private widget class into a dedicated file in `feature/presentation/widgets/`; screen file handles state orchestration only (~100–350 lines)
- **Rationale:** Single Responsibility Principle at file level; each file has one reason to change; enables targeted widget tests
- **Alternatives:** Keep private classes in screen files (hard to navigate and test), partial extraction (inconsistent)

### ADR-044: Shimmer skeleton loading via shared ReadySkeleton components
- **Phase:** 6 (Mar 2026)
- **Context:** Loading states showed raw progress indicators, giving no structural preview and creating layout shifts
- **Decision:** Add `shimmer: ^3.0.0`; create shared `ReadySkeleton` components (`ReadySkeletonBox`, `ReadySkeletonCard`, `ReadySkeletonList`, `ReadySkeletonGrid`); wire into AED list, Emergency Guides, Courses, and Badges loading states
- **Rationale:** Skeleton screens reduce perceived load time and prevent layout shift; shared components ensure consistency across features
- **Alternatives:** Keep raw spinners (jarring layout shift), per-screen custom shimmer (duplicated, inconsistent)

### ADR-045: GoRouter CustomTransitionPage for drill-down routes
- **Phase:** 6 (Mar 2026)
- **Context:** All route navigations used the default platform transition; drill-down routes benefit from directional feedback
- **Decision:** Convert 7 drill-down routes to `CustomTransitionPage` with a right-to-left `SlideTransition` (300 ms, easeInOut); top-level tab and auth routes retain default transitions
- **Rationale:** Directional slide reinforces navigation depth; 300 ms matches Material 3 motion guidelines; tabs on default avoids animated tab switches
- **Alternatives:** Default everywhere (no directional feedback), slide all routes (wrong for tab navigation)

### ADR-046: Sign-up only becomes authenticated when Supabase returns a real session
- **Phase:** 6 (Mar 2026)
- **Context:** Supabase sign-up can return a created user without an authenticated session when email confirmation is enabled; the app was treating that state as logged in
- **Decision:** Only set authenticated app state when `response.session` exists; store sign-up profile hints in auth metadata; let first verified sign-in create the fallback `profiles` row
- **Rationale:** Prevents unverified accounts from entering protected routes while keeping email-confirmation sign-up a valid flow
- **Alternatives:** Route based on `response.user` alone (incorrectly authenticates unverified users)

### ADR-047: Debug diagnostics restricted to debug builds
- **Phase:** 6 (Mar 2026)
- **Context:** Time-travel controls and notification diagnostics were useful for validation but should not ship in release builds
- **Decision:** Guard all diagnostic controls with `kDebugMode`; release builds ignore persisted debug-toggle values
- **Rationale:** Preserves fast validation workflows without exposing internal tooling to end users
- **Alternatives:** Leave controls in release (confusing, submission risk), delete tooling completely (slows validation)

### ADR-048: Synced recent activity preserves both completion time and server ordering
- **Phase:** 6 (Mar 2026)
- **Context:** Cross-device sync needed server-based ordering to survive device clock skew, but `created_at` alone made "completed x ago" reflect sync time rather than actual action time
- **Decision:** Mirror original completion timestamp into `activity_at`; keep `created_at` as canonical sync-order key; sort by server-created time, display original completion time
- **Rationale:** Preserves user-meaningful timestamps without reintroducing cross-device ordering bugs
- **Alternatives:** Use `created_at` for both ordering and display (loses actual completion time)

---

*Total ADRs: 48*
