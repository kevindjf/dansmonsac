# Story 2.11: Create Detailed Streak Week View

Status: ready-for-dev

<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

As a student,
I want to see a detailed weekly view of my streak progress when I tap the streak counter,
So that I can visualize which days I prepared my bag and stay motivated to maintain my habit.

## Acceptance Criteria

### AC1: Navigate to streak detail page on tap
**Given** I am on the home screen and the streak counter widget is visible
**When** I tap on the streak counter widget
**Then** I should navigate to a dedicated streak detail page
**And** the page should load in under 500ms (NFR2)

### AC2: Display weekly progress row
**Given** I am on the streak detail page
**When** the page loads
**Then** I should see a row of 7 circles representing the current week (Lun-Dim)
**And** each circle should display the abbreviated day name below it (Lun, Mar, Mer, Jeu, Ven, Sam, Dim)
**And** the current day should be visually distinguishable

### AC3: Show completed days with green checkmark
**Given** I have prepared my bag on certain school days this week
**When** the weekly row is displayed
**Then** days with a BagCompletion entry should show a filled green circle with a checkmark
**And** the visual should clearly communicate "completed"

### AC4: Show missed school days as empty circles
**Given** a school day has passed without bag preparation this week
**When** the weekly row is displayed
**Then** that day should show an empty circle (neutral tone, no guilt)
**And** future school days that haven't happened yet should also show empty circles

### AC5: Show non-school days as greyed out
**Given** weekends or days without scheduled courses exist in the week
**When** the weekly row is displayed
**Then** those days should show greyed-out/inactive circles
**And** they should be clearly distinct from missed school days and completed days

### AC6: Display motivational streak message
**Given** I am on the streak detail page
**When** the page loads
**Then** I should see a fire/flame visual element (emoji or icon)
**And** I should see a motivational message based on my current streak:
  - Streak > 0: "Tu as un streak de X jours !" + "Prepare ton sac chaque jour pour garder ton streak !"
  - Streak = 0 (never started): "Commence ton streak aujourd'hui !" + "Prepare ton sac chaque jour pour creer une habitude !"
  - Streak = 0 (after break): "Recommence ton streak !" + "Tu avais un streak de X jours, bat ton record !"

### AC7: Back navigation
**Given** I am on the streak detail page
**When** I tap the back button or swipe back
**Then** I should return to the home screen
**And** the streak counter widget should still show the correct streak count

## Tasks / Subtasks

- [ ] Task 1: Create StreakDetailPage widget (AC: 1, 2, 6, 7)
  - [ ] Create `features/streak/lib/presentation/pages/streak_detail_page.dart`
  - [ ] Add Scaffold with AppBar and back navigation
  - [ ] Add fire/flame visual element (emoji or Icon)
  - [ ] Add motivational message section with streak-dependent text
  - [ ] Use theme colors and accessibility standards (44x44pt, WCAG AA)

- [ ] Task 2: Create WeeklyStreakRow widget (AC: 2, 3, 4, 5)
  - [ ] Create `features/streak/lib/presentation/widgets/weekly_streak_row.dart`
  - [ ] Display 7 day circles (Lun-Dim) in a Row
  - [ ] Accept weekly data: list of day statuses (completed, missed, inactive, future)
  - [ ] Green filled circle + checkmark for completed days
  - [ ] Empty circle for missed school days and future days
  - [ ] Greyed-out circle for non-school days (weekends, holidays)
  - [ ] Day labels below each circle (Lun, Mar, Mer, Jeu, Ven, Sam, Dim)

- [ ] Task 3: Add `weeklyStreakDataProvider` to Riverpod DI (AC: 2, 3, 4, 5)
  - [ ] Create data model `WeekDayStatus` (enum: completed, missed, inactive, future)
  - [ ] Create data model `WeeklyStreakData` (list of 7 WeekDayStatus + day labels)
  - [ ] Add `weeklyStreakDataProvider` in `riverpod_di.dart` that:
    - Gets current week's Monday-Sunday dates
    - For each day: checks BagCompletions, isSchoolDay, and whether it's past/future
    - Returns `WeeklyStreakData`
  - [ ] Run `build_runner` to regenerate `riverpod_di.g.dart`

- [ ] Task 4: Wire navigation from StreakCounterWidget (AC: 1, 7)
  - [ ] Replace the TODO in `StreakCounterWidget.onTap` with navigation to `StreakDetailPage`
  - [ ] Use `Navigator.push` with `MaterialPageRoute`
  - [ ] Ensure back navigation works correctly

- [ ] Task 5: Update exports and module barrel file (AC: 1)
  - [ ] Add `StreakDetailPage` export to `streak.dart`
  - [ ] Add `WeeklyStreakRow` export to `streak.dart`

- [ ] Task 6: Write tests (AC: 1, 2, 3, 4, 5, 6, 7)
  - [ ] Test WeeklyStreakRow displays 7 day circles
  - [ ] Test completed day shows green checkmark
  - [ ] Test missed school day shows empty circle
  - [ ] Test non-school day shows greyed-out circle
  - [ ] Test future day shows empty circle
  - [ ] Test StreakDetailPage displays fire emoji/icon
  - [ ] Test StreakDetailPage displays motivational message for streak > 0
  - [ ] Test StreakDetailPage displays encouraging message for streak = 0
  - [ ] Test StreakDetailPage displays "after break" message when previousStreak > 0
  - [ ] Test back navigation from StreakDetailPage
  - [ ] Test tap on StreakCounterWidget navigates to StreakDetailPage

## Dev Notes

### Architecture Context

**What Already Exists (DO NOT RECREATE):**

The `StreakRepository` already has all the backend data needed for this view:

```dart
// Already implemented in features/streak/lib/repository/streak_repository.dart:

/// Get current streak count
Future<Either<Failure, int>> getCurrentStreak()  // ← EXISTS

/// Get all bag completion history
Future<Either<Failure, List<DateTime>>> getBagCompletionHistory()  // ← EXISTS

/// Check if a date is a school day (PRIVATE - needs to be exposed or logic duplicated)
Future<bool> _isSchoolDay(DateTime date)  // ← EXISTS but PRIVATE

/// Get previous streak (before last break)
Future<Either<Failure, int>> getPreviousStreak()  // ← EXISTS (Story 2.4/2.7)
```

**Key decision: Exposing `_isSchoolDay()`**

The `_isSchoolDay()` method is currently private. For the weekly view, we need to check each day's school status. Options:
1. **Make `_isSchoolDay()` public** — Simplest, allows provider to call it directly
2. **Add a new method `getWeeklyStatus()`** to StreakRepository — Encapsulates the logic, returns pre-computed weekly data
3. **Duplicate the logic in the provider** — NOT recommended

**Recommended: Option 2** — Add `getWeeklyStreakData()` to `StreakRepository` that returns the full weekly status in one call. This keeps the repository as the single source of truth for streak logic.

```dart
// NEW method to add to StreakRepository:

/// Gets the weekly streak data for the current week
/// Returns a list of 7 WeekDayStatus entries (Monday to Sunday)
Future<Either<Failure, List<WeekDayStatus>>> getWeeklyStreakData() {
  return handleErrors(() async {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final statuses = <WeekDayStatus>[];

    final completions = await _database.getAllBagCompletions();
    final completedDates = completions.map((c) {
      final d = c.date;
      return DateTime(d.year, d.month, d.day);
    }).toSet();

    for (int i = 0; i < 7; i++) {
      final date = DateTime(monday.year, monday.month, monday.day + i);
      final today = DateTime(now.year, now.month, now.day);

      if (date.isAfter(today)) {
        statuses.add(WeekDayStatus.future);
      } else if (!await _isSchoolDay(date)) {
        statuses.add(WeekDayStatus.inactive);
      } else if (completedDates.contains(date)) {
        statuses.add(WeekDayStatus.completed);
      } else {
        statuses.add(WeekDayStatus.missed);
      }
    }

    return statuses;
  });
}
```

**What PreferencesService provides (from Story 2.4/2.7):**
- `PreferencesService.getPreviousStreak()` → `int` (defaults to 0)

### Existing Providers Available

```dart
// Already in features/streak/lib/di/riverpod_di.dart:
streakRepositoryProvider    // ← Repository access
currentStreakProvider        // ← Current streak count (AsyncValue<int>)
previousStreakProvider       // ← Previous streak before break (AsyncValue<int>)
brokenStreakProvider         // ← Whether streak is broken (AsyncValue<bool>)
```

### UI Design Reference (Duolingo-inspired)

**Layout:**
```
┌───────────────────────────────────┐
│  ←  Ton streak                    │  ← AppBar
├───────────────────────────────────┤
│                                   │
│           🔥 (large)              │
│                                   │
│  ┌─────────────────────────────┐  │
│  │ ✅  ○  ○  ○  ○  ◌  ◌      │  │  ← Weekly row
│  │ Lun Mar Mer Jeu Ven Sam Dim │  │
│  └─────────────────────────────┘  │
│                                   │
│   Tu as un streak de 1 jour !     │  ← Title
│                                   │
│   Prepare ton sac chaque jour     │  ← Subtitle
│   pour garder ton streak !        │
│                                   │
└───────────────────────────────────┘
```

**Circle states:**
- ✅ Completed: Filled green circle (`Colors.green`) with white checkmark icon
- ○ Missed/Future: Empty circle with light border (`Colors.grey.shade400`)
- ◌ Inactive (non-school): Filled grey circle (`Colors.grey.shade700`) or very faint

**Key design decisions:**
- Page, not dialog or bottom sheet — this is a full detail view
- Fire emoji large (48-64px) centered at top
- Weekly row in a Card or Container with subtle border
- French text throughout
- Use `Theme.of(context).colorScheme.secondary` for accent
- Min touch targets: 44x44pt (NFR21)
- WCAG AA contrast (NFR19)

### Streak Module File Structure (After This Story)

```
features/streak/
├── lib/
│   ├── presentation/
│   │   ├── pages/
│   │   │   └── streak_detail_page.dart          ← NEW
│   │   ├── controller/           (empty - not needed yet)
│   │   └── widgets/
│   │       ├── streak_counter_widget.dart  (existing - MODIFY onTap)
│   │       ├── streak_break_dialog.dart    (existing from 2.7)
│   │       └── weekly_streak_row.dart       ← NEW
│   ├── repository/
│   │   └── streak_repository.dart  (existing - ADD getWeeklyStreakData())
│   ├── models/
│   │   └── week_day_status.dart             ← NEW
│   ├── di/
│   │   ├── riverpod_di.dart   ← MODIFY (add weeklyStreakDataProvider)
│   │   └── riverpod_di.g.dart ← REGENERATE via build_runner
│   └── streak.dart            ← MODIFY (add new exports)
├── test/
│   └── presentation/
│       ├── pages/
│       │   └── streak_detail_page_test.dart     ← NEW
│       └── widgets/
│           ├── streak_counter_widget_test.dart   (existing)
│           ├── streak_break_dialog_test.dart     (existing from 2.7)
│           └── weekly_streak_row_test.dart        ← NEW
└── pubspec.yaml
```

### Critical Naming Conventions (MANDATORY)

- Dart files: snake_case (`streak_detail_page.dart`, `weekly_streak_row.dart`)
- Classes: PascalCase (`StreakDetailPage`, `WeeklyStreakRow`, `WeekDayStatus`)
- Variables/functions: camelCase (`weeklyStreakData`, `getWeeklyStreakData()`)
- Enums: PascalCase name, camelCase values (`WeekDayStatus.completed`)
- Use `LogService` for logging — NEVER `print()`
- Use `handleErrors()` for all async operations in repository

### Previous Story Intelligence

**Story 2.5 (Streak Counter Widget) — Key learnings:**
- ConsumerWidget pattern with `AsyncValue.when()` works well
- Theme-based styling, min 44x44pt constraints
- 7 tests with provider overrides via `ProviderScope`
- Current `onTap` has a TODO placeholder for navigation to detail view

**Story 2.7 (Streak Break Detection) — Key learnings:**
- `previousStreakProvider` and `brokenStreakProvider` available
- Dialog pattern for streak break messages
- 9 widget tests passing

**Git commits show:**
- `af7a5f9` — Story 2.7 docs update
- `a32948b` — Streak counter widget and bag ready

### Dark Theme Colors (From CLAUDE.md)

- Accent: `0xFFB9A0FF`
- Background: `0xFF212121`
- Surface: `0xFF424242`
- Use `Theme.of(context).colorScheme.secondary` — not hardcoded values
- Green for completed: `Colors.green` or `Color(0xFF4CAF50)`
- Grey for inactive: `Colors.grey.shade700`

### Testing Requirements

**Minimum 11 tests:**

**Widget Tests (WeeklyStreakRow):**
1. Displays 7 day circles
2. Completed day shows green checkmark
3. Missed school day shows empty circle
4. Non-school day (inactive) shows greyed-out circle
5. Future day shows empty circle

**Widget Tests (StreakDetailPage):**
6. Displays fire emoji/icon
7. Shows motivational message when streak > 0
8. Shows encouraging message when streak = 0
9. Shows "after break" message when previousStreak > 0 and currentStreak = 0
10. Back navigation works

**Integration Test:**
11. Tap on StreakCounterWidget navigates to StreakDetailPage

**Test Setup:**
```dart
// For WeeklyStreakRow tests
await tester.pumpWidget(
  MaterialApp(
    theme: ThemeData.dark(),
    home: Scaffold(
      body: WeeklyStreakRow(
        statuses: [
          WeekDayStatus.completed,
          WeekDayStatus.missed,
          WeekDayStatus.future,
          WeekDayStatus.future,
          WeekDayStatus.future,
          WeekDayStatus.inactive,
          WeekDayStatus.inactive,
        ],
      ),
    ),
  ),
);

// For StreakDetailPage tests
await tester.pumpWidget(
  ProviderScope(
    overrides: [
      currentStreakProvider.overrideWith((ref) => Future.value(5)),
      previousStreakProvider.overrideWith((ref) => Future.value(0)),
      weeklyStreakDataProvider.overrideWith((ref) => Future.value([...])),
    ],
    child: MaterialApp(home: StreakDetailPage()),
  ),
);
```

### Project Structure Notes

**Files to Create:**
1. `features/streak/lib/models/week_day_status.dart` — Enum for day status
2. `features/streak/lib/presentation/pages/streak_detail_page.dart` — Detail page
3. `features/streak/lib/presentation/widgets/weekly_streak_row.dart` — Week row widget
4. `features/streak/test/presentation/pages/streak_detail_page_test.dart` — Page tests
5. `features/streak/test/presentation/widgets/weekly_streak_row_test.dart` — Row tests

**Files to Modify:**
1. `features/streak/lib/repository/streak_repository.dart` — Add `getWeeklyStreakData()`
2. `features/streak/lib/di/riverpod_di.dart` — Add `weeklyStreakDataProvider`
3. `features/streak/lib/presentation/widgets/streak_counter_widget.dart` — Replace onTap TODO with navigation
4. `features/streak/lib/streak.dart` — Add new exports

**Run After Modifications:**
```bash
cd features/streak && flutter pub run build_runner build --delete-conflicting-outputs
```

### Dependencies

**Existing Dependencies (No New Dependencies Required):**
- `flutter_riverpod` / `riverpod_annotation` — for providers
- `dartz` — for Either<Failure, T>
- `common` — for LogService, PreferencesService, AppDatabase

### Performance Requirements

- Page load < 500ms (NFR2)
- `getWeeklyStreakData()` should complete in < 200ms (only 7 days to check)
- Smooth navigation transition

### Accessibility Requirements

- All text meets WCAG AA contrast ratio 4.5:1 (NFR19)
- All interactive elements ≥ 44x44pt tap target (NFR21)
- Screen reader: page content announced clearly (NFR22)
- Support dynamic type / system font scaling (NFR20)
- Day circles should have semantic labels for screen readers

### References

- [Epic 2](../../_bmad-output/planning-artifacts/epics.md#epic-2-daily-bag-preparation-with-smart-streak-system) — Epic definition
- [Story 2.5](./2-5-create-streak-counter-ui-widget.md) — StreakCounterWidget (has onTap TODO)
- [Story 2.7](./2-7-implement-streak-break-detection-reset.md) — Break detection providers
- [Story 2.4](./2-4-implement-streak-calculation-logic.md) — Streak calculation and _isSchoolDay logic
- [Architecture: Module Architecture](../../_bmad-output/planning-artifacts/architecture.md#module-architecture) — Streak module structure
- [PRD: Streak & Habit Tracking](../../_bmad-output/planning-artifacts/prd.md#streak--habit-tracking) — Visual streak tracking

**Critical Constraints:**
- **NFR2:** Page load in under 500ms
- **NFR13:** Streak data must persist through normal app lifecycle
- **NFR14:** All core features must function fully offline
- **NFR19:** WCAG AA contrast ratio 4.5:1
- **NFR21:** Min 44x44pt touch targets
- **NFR22:** Screen reader navigable
- **Offline-first:** All data from local Drift DB + SharedPreferences

### Validation Checklist

- [ ] `WeekDayStatus` enum created with: completed, missed, inactive, future
- [ ] `getWeeklyStreakData()` method added to StreakRepository
- [ ] `weeklyStreakDataProvider` added to riverpod_di.dart
- [ ] `build_runner` executed successfully
- [ ] `WeeklyStreakRow` widget created with 7-day circles
- [ ] Completed days show green circle + checkmark
- [ ] Missed days show empty circle (neutral)
- [ ] Non-school days show greyed-out circle
- [ ] Future days show empty circle
- [ ] Day labels displayed (Lun-Dim)
- [ ] `StreakDetailPage` created with fire emoji, weekly row, messages
- [ ] Motivational messages adapt to streak state
- [ ] Navigation from StreakCounterWidget to StreakDetailPage works
- [ ] Back navigation works
- [ ] All new widgets exported from streak.dart
- [ ] 11+ tests passing
- [ ] No print() statements — uses LogService if needed
- [ ] No compilation errors
- [ ] Offline operation verified (all logic uses local data)
- [ ] Theme colors used (not hardcoded)
- [ ] Accessibility: 44x44pt targets, WCAG AA contrast, screen reader labels

## Dev Agent Record

### Agent Model Used

{{agent_model_name_version}}

### Debug Log References

### Completion Notes List

### File List
