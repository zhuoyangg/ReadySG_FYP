# ReadySG

An offline-first Flutter app for emergency preparedness in Singapore. Teaches first aid and emergency response through courses, quizzes, and spaced practice. Includes step-by-step emergency guides, an AED locator map, and one-tap emergency call shortcuts.

Two modes:
- **Peaceful Mode** — courses, quizzes, badges, streaks, daily challenges
- **Emergency Mode** — emergency guides (CPR, AED, choking, burns), AED map, emergency call shortcuts

Guest access is available for emergency features — no account required.

Test account credentials:
email: test@example.com
password: 123123
---

## Prerequisites

| Tool | Version |
|------|---------|
| Flutter SDK | ≥ 3.11.0 (stable channel) |
| Dart SDK | Bundled with Flutter |
| Android emulator or physical device | API 21+ |

Verify your setup:
```bash
flutter doctor
```

---

## Running the App

```bash
# Install dependencies
flutter pub get

# Run on a connected device or emulator
flutter run
```

The `.env` file is bundled with the repo and pre-configured with live Supabase credentials and seed data. No database setup or API keys are needed.

To list available devices:
```bash
flutter devices
flutter run -d <device-id>
```

---

## Running Tests

```bash
flutter test
flutter analyze
```
