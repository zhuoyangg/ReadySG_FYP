# Testing Documentation

Test strategy, inventory, and results for ReadySG.

---

## Test Strategy

ReadySG uses three complementary layers:

1. **Unit tests** — pure logic (validators, formatters, model methods)
2. **Provider integration tests** — fake repositories returning controlled `RepositoryResult` values; no widget scaffolding required
3. **Widget characterisation tests** — build-verification smoke tests for extracted presentation widgets
4. **Manual integration tests** — device/emulator flows not reachable by automated tests (GPS dialogs, airplane-mode transitions, notification delivery, real-device rendering)

**Commands:**
```bash
flutter test
flutter test --reporter expanded
flutter analyze
```

---

## Automated Test Inventory

### `test/app_router_redirect_test.dart` — 6 tests
- Loading state routes to `/loading`
- Unauthenticated access to protected route redirects to `/login`
- Unauthenticated access to guest-accessible route (`/emergency-guest`, `/guide/*`) is permitted
- Authenticated user on auth-only route (`/login`) redirects to `/home`
- Authenticated user on any other route passes through unchanged
- Null redirect when authenticated and on a non-auth route

### `test/aed_provider_test.dart` — 5 tests
- Cached AEDs load and notify listeners immediately from Hive
- Sync failure sets `syncFailed` without clearing cached data
- `refreshLocation()` updates `userPosition`
- Refresh-time location fetch triggered on pull-to-refresh
- Live location stream position updates propagate correctly

### `test/emergency_guides_provider_test.dart` — 3 tests
- Guide cache-first load: cached guides notify immediately
- Sync failure leaves cached data intact and sets `syncFailed`
- Empty cache with sync failure triggers error state

### `test/courses_provider_test.dart` — 2 tests
- Cache-clear re-sync: provider re-fetches catalog from repository when Hive cache is empty
- User-switch data isolation: provider resets in-memory state when authenticated user changes

### `test/spaced_practice_model_test.dart` — 2 tests
- Interval progression: `nextInterval()` advances through 1→3→7→14→30 steps correctly
- Interval cap: any value at or beyond 30 stays at 30

### `test/validators_test.dart` — 5 tests
- Email: valid format accepted; invalid formats rejected
- Password: minimum length and complexity rules enforced
- Confirm-password: mismatch detected
- Username: empty and whitespace-only values rejected
- Full name: empty value rejected

### `test/widget_test.dart` — 1 test
- App bootstrap: unauthenticated launch settles to login screen

### `test/time_ago_formatter_test.dart` — 7 tests
- Future timestamp returns "just now"
- Sub-minute difference returns "just now"
- Minute-level differences formatted as "X min ago"
- Hour-level differences formatted as "X hr ago"
- Day-level differences formatted as "X day(s) ago"
- `dateKey` zero-pads single-digit month and day
- `startOfDay` truncates time component correctly

### `test/widget_smoke_test.dart` — 21 tests
Build-verification smoke tests for 8 extracted presentation widgets. Each test confirms the widget renders without throwing and that expected text content is present. All tests use a minimal `_wrap()` helper (MaterialApp + Scaffold + ThemeData.light()); no Provider mocking required.

| Widget | Tests |
|--------|-------|
| `EmergencyGuidesHero` | 3 — heading text, guest action, sign-in action |
| `EmergencySituationCard` | 2 — title, description |
| `ImportantReminderCard` | 2 — title text |
| `LearnBanner` | 3 — title, progress counts |
| `CourseCard` | 4 — title, description, difficulty chip, lesson count |
| `QuizHeader` | 3 — progress text, question counter |
| `TrialStatChip` | 2 — label, value |
| `NotificationSectionCard` | 2 — title, children |

---

## Test Results

| Metric | Value |
|--------|-------|
| Total test files | 9 |
| Total test cases | 51 |
| Result | All passing |
| Last confirmed run | 22 March 2026 |
| `flutter analyze` | No issues found |

---

## Manual Integration Test Results

All 12 manual scenarios passed on the validated build (22 March 2026, Android emulator API 33 and physical Android device).

| ID | Scenario | Result |
|----|----------|--------|
| MT1 | Fresh account → first course → quiz completion | Pass |
| MT2 | Offline emergency guide access after cache warm | Pass |
| MT3 | Guest emergency access without sign-in | Pass |
| MT4 | AED locator with GPS permission granted | Pass |
| MT5 | AED locator with GPS permission denied | Pass |
| MT6 | Daily challenge idempotency (bonus awarded once) | Pass |
| MT7 | Mode toggle confirmation both directions | Pass |
| MT8 | Quiz navigation back-stack invariant | Pass |
| MT9 | Spaced practice interval advancement (1→3 days) | Pass |
| MT10 | User data isolation across sign-out/sign-in | Pass |
| MT11 | Real-clock notification delivery at 20:00 | Pass |
| MT12 | Offline AED cache on airplane mode | Pass |

**iOS validation:** not performed. Windows-only development environment prevents iOS device testing. Flutter cross-platform guarantees are relied upon for platform-independent code paths; device-specific behaviours (location permissions, notification delivery on iOS) remain unverified.

---

## Defects Found and Resolved

| ID | Defect | Severity | Resolution |
|----|--------|----------|-----------|
| D1 | JSON double-encoding: stale Hive data crashed lesson viewer | High | Double-decode guard in `LessonModel.slides`; source fix in `lesson_repository.dart` |
| D2 | Router redirect coupled to Navigator — untestable | Medium | Extracted `resolveRedirect()` as pure static function; 6 unit tests added |
| D3 | GPS failure conflated with AED data sync failure | Medium | Separated `locationError` from `syncFailed` in `AEDProvider` |
| D4 | Daily challenge bonus awarded multiple times on app restart | Medium | Idempotent Hive key `daily_challenge_bonus_$userId_$date` |
| D5 | AED live location refresh lost after screen decomposition | High | Restored screen-scoped `StreamSubscription` with lifecycle pause/resume |
| D6 | `CourseDetailScreen` `SliverAppBar` overflow on long titles | Low | Increased `expandedHeight`; corrected CPR accent colour |
