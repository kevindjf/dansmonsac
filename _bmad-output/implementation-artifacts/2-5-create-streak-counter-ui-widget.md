# Story 2.5: Create Streak Counter UI Widget

Status: done

## Story

As a student,
I want to see my current streak count prominently displayed on the home screen,
So that I am constantly reminded of my progress and motivated to maintain my habit.

## Acceptance Criteria

### AC1: Streak counter displays current streak with fire emoji
**Given** I am on the home screen
**When** the streak counter widget loads
**Then** it should display my current streak count (e.g., "🔥 12 jours de suite!")
**And** the count should be fetched from the streak repository via Riverpod provider
**And** the UI should load in under 500ms (NFR2)

### AC2: Streak > 0 shows motivational icon
**Given** my streak is greater than 0
**When** the counter is displayed
**Then** it should show a fire emoji (🔥)
**And** the text should be clear and readable (meeting NFR19 contrast ratio)

### AC3: Streak = 0 shows encouraging message
**Given** my streak is 0
**When** the counter is displayed
**Then** it should show an encouraging message ("Commence ton streak aujourd'hui!")
**And** the message should be motivational, not discouraging

### AC4: Auto-refresh on bag completion
**Given** I complete my bag preparation
**When** the BagCompletions table is updated
**Then** the streak counter should automatically refresh to show the updated count
**And** the update should happen via Riverpod provider invalidation

### AC5: Minimum tap target size (accessibility)
**Given** the streak counter is displayed
**When** I attempt to tap it
**Then** the tap target should be at least 44x44pt (NFR21)

## Tasks / Subtasks

- [x] Task 1: Create StreakCounterWidget (AC: 1, 2, 3, 5)
  - [x] Create `features/streak/lib/presentation/widgets/streak_counter_widget.dart`
  - [x] Implement ConsumerWidget watching `currentStreakProvider`
  - [x] Display fire emoji + count when streak > 0
  - [x] Display encouraging message when streak = 0
  - [x] Add minimum 44x44pt constraints for accessibility
  - [x] Handle loading state with CircularProgressIndicator
  - [x] Handle error state with error icon and message

- [x] Task 2: Make widget tappable (AC: 5)
  - [x] Wrap in GestureDetector with minimum tap target
  - [x] Show placeholder snackbar (detailed view = future story)

- [x] Task 3: Export widget via barrel file (AC: 1)
  - [x] Update `features/streak/lib/streak.dart` to export widget and providers

- [x] Task 4: Integrate in list_supply_page.dart (AC: 1, 4)
  - [x] Add import for `streak_counter_widget.dart` and `riverpod_di.dart`
  - [x] Place `StreakCounterWidget` in header section of "Mon sac"
  - [x] Widget auto-refreshes via Riverpod `ref.watch(currentStreakProvider)`

- [x] Task 5: Create comprehensive unit tests (AC: 1, 2, 3, 4, 5)
  - [x] Test loading indicator displays during fetch
  - [x] Test fire emoji + count display when streak > 0
  - [x] Test singular "jour" when streak = 1
  - [x] Test encouraging message when streak = 0
  - [x] Test tappable behavior (snackbar)
  - [x] Test minimum 44x44pt constraints
  - [x] Test error state display

## Dev Notes

### Architecture Context

**Widget Type:** ConsumerWidget (Riverpod)
- Watches `currentStreakProvider` for reactive updates
- No local state needed - fully driven by provider
- Error/loading states handled via `AsyncValue.when()`

**Design Decisions:**
- Used `Container` with `BoxConstraints(minHeight: 44, minWidth: 44)` for accessibility
- Fire emoji as `Text('🔥')` rather than Icon for cross-platform consistency
- Singular/plural French: "jour de suite" vs "jours de suite"
- Secondary color with alpha for subtle background

**Theme Integration:**
- Uses `Theme.of(context).colorScheme.secondary` for accent color
- Alpha 0.1 background, 0.3 border for subtle appearance
- Rounded corners (12px) matching app design language

### Project Structure Notes

**Module:** `features/streak/` (created in Story 2.2)
- Widget placed in `lib/presentation/widgets/` following module convention
- Exported via `streak.dart` barrel file for external use
- Tests in `test/presentation/widgets/`

### References

- [Epics: Story 2.5](../../_bmad-output/planning-artifacts/epics.md#story-25-create-streak-counter-ui-widget) - Lines 554-587
- [Story 2.2](./2-2-create-streak-module-foundation.md) - Streak module foundation (providers)
- [Architecture: Implementation Patterns](../../_bmad-output/planning-artifacts/architecture.md#implementation-patterns--consistency-rules) - Naming conventions

**Critical Constraints:**
- **FR8:** Student can view their current streak count
- **NFR2:** Tomorrow's supply list must load in under 500ms (streak widget included)
- **NFR19:** WCAG AA contrast ratio (4.5:1 minimum)
- **NFR21:** All interactive elements must have minimum 44x44pt touch targets

## Dev Agent Record

### Agent Model Used

Claude Sonnet 4.5 (claude-sonnet-4-5-20250929)

### Debug Log References

N/A

### Completion Notes List

**All Acceptance Criteria Verified:**

- **AC1: Streak counter displays current streak** - Widget watches `currentStreakProvider` and displays "🔥 X jours de suite!"
- **AC2: Streak > 0 shows fire emoji** - Fire emoji displayed with bold count text in accent color
- **AC3: Streak = 0 shows encouraging message** - "Commence ton streak aujourd'hui!" displayed
- **AC4: Auto-refresh on bag completion** - Riverpod `ref.watch()` ensures automatic refresh when provider is invalidated
- **AC5: Minimum tap target** - `BoxConstraints(minHeight: 44, minWidth: 44)` enforced on Container

**Test Results:** 7/7 tests passing (100%)

**Commit:** `14ec8b2` - "Story 2.5: Create Streak Counter UI Widget"
**Branch:** `feature/2-5-create-streak-counter-ui-widget` (merged into staging)

### File List

**Created Files:**
- `features/streak/lib/presentation/widgets/streak_counter_widget.dart` - ConsumerWidget displaying streak count with fire emoji, loading, and error states
- `features/streak/test/presentation/widgets/streak_counter_widget_test.dart` - 7 comprehensive widget tests

**Modified Files:**
- `features/streak/lib/streak.dart` - Added exports for widget and providers
- `features/main/lib/presentation/home/list_supply_page.dart` - Added StreakCounterWidget in header section, imports for streak module
