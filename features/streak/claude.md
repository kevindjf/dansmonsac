# Streak Module

## Description
Streak tracking module for bag preparation. Calculates and displays the number of consecutive days where the student prepared their bag, creating motivation through habit formation.

## Responsibilities
- Calculate current streak (consecutive preparation days)
- Access bag completion history (BagCompletions)
- Record bag preparation completions
- Detect school days vs non-school days (weekends, holidays)
- Manage streak breaks and resets

## Architecture
- **Repository Pattern** with `StreakRepository` for business logic
- **Error handling** via `Either<Failure, T>` (dartz package)
- **Data source**: Drift `BagCompletions` table (local, synced via SyncManager)
- **Models**:
  - `StreakData` - Streak data (count, last completion, history)

## State Management
- **Riverpod** with `@riverpod` annotations
- Providers:
  - `streakRepositoryProvider` - Repository instance
  - `currentStreakProvider` - Current streak (counter)

## Key Files
- `repository/streak_repository.dart` - Streak calculation logic
- `di/riverpod_di.dart` - Riverpod providers
- `models/streak_data.dart` - Streak data model
- `presentation/widgets/streak_counter_widget.dart` - Counter display widget (Story 2.5)
- `presentation/controller/streak_controller.dart` - UI controller (Story 2.5)

## Main Dependencies
- `flutter_riverpod` / `riverpod_annotation`
- `dartz` (Either<Failure, T>)
- `common` (for `AppDatabase`, `LogService`, `handleErrors`, `Failure`, `PreferenceRepository`)

## Drift Tables (via common/AppDatabase)
- `BagCompletions` - Completed preparation history (id, date, completedAt, deviceId)
  - Used to calculate current streak
  - One entry per day where bag was prepared
- `DailyChecks` - Supplies checked per day (not directly used in streak, but serves to detect completion)

## Streak Logic
**Current streak calculation:**
1. Retrieve all BagCompletions sorted by date DESC
2. Filter only school days (ignore weekends/holidays via timetable)
3. Count consecutive days from today
4. If a school day is missing → streak broken → reset to 0

**School days vs non-school days:**
- A day is considered a "school day" if the timetable contains at least one course for that day
- Weekends without courses do NOT break the streak
- Holidays without courses do NOT break the streak

## Associated Stories
- **Story 2.2**: Create Streak Module Foundation (current - foundation)
- **Story 2.3**: Implement Daily Checklist Persistence (DailyChecks)
- **Story 2.4**: Implement Streak Calculation Logic (full calculation)
- **Story 2.5**: Create Streak Counter UI Widget (UI)
- **Story 2.6**: Implement Bag Ready Confirmation (trigger streak increment)

## Offline-First
- All operations work offline (local Drift)
- BagCompletions synchronized with Supabase via SyncManager (common)
- No network dependency to calculate or display streak

## Implementation Rules (CRITICAL)
- **Logging**: ALWAYS use `LogService`, NEVER `print()`
- **Error handling**: Use `handleErrors()` for all async operations
- **Naming**: snake_case for files, PascalCase for classes, camelCase for variables
- **Tests**: 100% tests required before marking a task complete
- **Code generation**: Run `build_runner` after modifying `@riverpod` annotations
