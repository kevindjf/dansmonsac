# Story 2.4: Implement Streak Calculation Logic

Status: ready-for-dev

## Story

As a student,
I want the app to accurately track my consecutive school days of bag preparation,
So that my streak count reflects my actual habit and motivates me to continue.

## Acceptance Criteria

### AC1: Streak calculation using BagCompletions and timetable data
**Given** I complete my bag preparation today (all supplies checked)
**When** the system calculates my streak
**Then** it should query `BagCompletions` table for consecutive school-day entries
**And** it should use the timetable data to determine which days are school days (have classes)
**And** weekends, holidays, and days without classes should be ignored in the count

### AC2: Streak increments on consecutive school days
**Given** I have completed bag prep for 5 consecutive school days
**When** I complete today's bag prep
**Then** my streak should increment to 6
**And** a new row should be inserted in `BagCompletions` with today's date and completedAt timestamp

### AC3: Streak persists during pending completion
**Given** I completed bag prep yesterday (Monday)
**When** today is Tuesday and I haven't completed it yet
**Then** my streak should still show yesterday's count (not broken yet)
**And** the streak should only break if the day ends without completion

### AC4: Streak breaks and resets with previous streak storage
**Given** I have a 10-day streak
**When** I skip a school day (don't complete bag prep)
**Then** my streak should reset to 0
**And** the previous streak length (10) should be stored for display in the reset message

### AC5: Weekends don't break streaks
**Given** I complete bag prep on Friday
**When** the weekend passes with no school
**Then** my streak should not break over the weekend
**And** when I complete bag prep on Monday, my streak should continue from Friday

### AC6: Offline streak calculation
**Given** streak data is calculated
**When** the data is persisted
**Then** all streak calculations should work fully offline using local Drift database (NFR14)
**And** BagCompletions should sync to Supabase when connectivity is available

## Tasks / Subtasks

- [ ] Task 1: Enhance StreakRepository with school-day detection (AC: 1, 3, 5)
  - [ ] Add method to query calendar_courses for tomorrow's classes
  - [ ] Create isSchoolDay(DateTime date) helper method
  - [ ] Implement logic to detect weekends, holidays, and empty timetable days

- [ ] Task 2: Implement consecutive school-day streak calculation (AC: 1, 2, 5)
  - [ ] Update getCurrentStreak() to filter by school days only
  - [ ] Query BagCompletions in descending date order
  - [ ] Skip non-school days when counting consecutive days
  - [ ] Handle edge cases (first day, single completion, gaps)

- [ ] Task 3: Implement streak break detection (AC: 3, 4)
  - [ ] Add getPreviousStreak() method to retrieve last broken streak
  - [ ] Add method to detect broken streaks (missed school day)
  - [ ] Store previous streak length when break occurs
  - [ ] Add resetStreak() method to handle streak resets

- [ ] Task 4: Integrate with schedule/course modules (AC: 1, 5)
  - [ ] Query calendar_courses table for date-based class detection
  - [ ] Use WeekUtils for week A/B detection
  - [ ] Handle timezone and date normalization consistently

- [ ] Task 5: Create comprehensive unit tests
  - [ ] Test streak calculation with school days only
  - [ ] Test weekend skip logic
  - [ ] Test streak break and reset
  - [ ] Test consecutive school-day counting
  - [ ] Test edge cases (holidays, empty timetable, first week)
  - [ ] Test offline operation
  - [ ] Verify all tests pass (100% pass rate)

- [ ] Task 6: Update Riverpod providers
  - [ ] Update currentStreakProvider with new calculation logic
  - [ ] Add previousStreakProvider for break messages
  - [ ] Run build_runner to regenerate providers

## Dev Notes

### Architecture Patterns (From architecture.md)

**Streak Module (Created in Story 2.2):**
```
features/streak/
├── lib/
│   ├── repository/
│   │   └── streak_repository.dart  (ENHANCE in this story)
│   ├── di/
│   │   └── riverpod_di.dart  (UPDATE providers)
│   ├── presentation/
│   │   ├── controller/
│   │   └── widgets/
│   └── models/
│       └── streak_data.dart  (NEW - to add)
├── test/
│   └── repository/
│       └── streak_repository_test.dart  (EXPAND tests)
└── pubspec.yaml
```

**Critical Naming Conventions (MANDATORY):**
- Dart files: snake_case (e.g., `streak_repository.dart`)
- Classes: PascalCase (e.g., `StreakRepository`)
- Variables/functions: camelCase (e.g., `getCurrentStreak()`, `isSchoolDay()`)

**Repository Pattern (MANDATORY):**
- Use `Either<Failure, T>` from dartz for all repository methods
- Use `handleErrors()` wrapper for all async operations
- Use `LogService` for logging, NEVER `print()`

**Code Generation:**
- Use `@riverpod` annotations for providers
- Run `flutter pub run build_runner build --delete-conflicting-outputs` after changes
- Generated files: `riverpod_di.g.dart`

### Foundation from Previous Stories

**Story 2.1: Drift Schema v3 Migration (DONE)**
- BagCompletions table created and ready
- Database operations available:
  - `getAllBagCompletions()` → List<BagCompletionEntity>
  - `getBagCompletionByDate(DateTime)` → BagCompletionEntity?
  - `getBagCompletionsInRange(DateTime, DateTime)` → List<BagCompletionEntity>
  - `insertBagCompletion(BagCompletionsCompanion)` → int
  - `deleteBagCompletion(String)` → int

**Story 2.2: Streak Module Foundation (DONE)**
- StreakRepository created with foundation methods:
  - `getCurrentStreak()` - currently returns count of ALL completions (needs enhancement)
  - `getBagCompletionHistory()` - returns list of completion dates
  - `markBagComplete(DateTime)` - creates bag completion entry
- Riverpod providers: streakRepositoryProvider, currentStreakProvider
- Comprehensive unit tests (10/10 passing)

**Story 2.3: Daily Checklist Persistence (DONE)**
- DailyChecks table integrated with UI
- DailyCheckRepository with Either<Failure, T> pattern
- DailyCheckController for state management
- SyncManager integration for background sync
- list_supply_page.dart updated to use Drift

**Current StreakRepository Implementation (Story 2.2):**
```dart
// features/streak/lib/repository/streak_repository.dart
class StreakRepository {
  final AppDatabase _database;
  final PreferenceRepository _preferenceRepository;

  StreakRepository(this._database, this._preferenceRepository);

  Future<Either<Failure, int>> getCurrentStreak() async {
    return handleErrors(() async {
      final completions = await _database.getAllBagCompletions();
      // CURRENT: Returns total count (WRONG - needs school-day filtering)
      return completions.length;
    });
  }

  Future<Either<Failure, List<DateTime>>> getBagCompletionHistory() async {
    return handleErrors(() async {
      final completions = await _database.getAllBagCompletions();
      return completions.map((c) => c.date).toList();
    });
  }

  Future<Either<Failure, void>> markBagComplete(DateTime date) async {
    return handleErrors(() async {
      final deviceId = await _preferenceRepository.getUserId();
      final normalizedDate = DateTime(date.year, date.month, date.day);

      // Check for duplicate
      final existing = await _database.getBagCompletionByDate(normalizedDate);
      if (existing != null) {
        LogService.d('Bag already marked complete for ${normalizedDate.toIso8601String()}');
        return;
      }

      // Insert new completion
      await _database.insertBagCompletion(
        BagCompletionsCompanion.insert(
          id: const Uuid().v4(),
          date: normalizedDate,
          completedAt: DateTime.now(),
          deviceId: deviceId,
        ),
      );

      LogService.i('Bag marked complete for ${normalizedDate.toIso8601String()}');
    });
  }
}
```

**What Needs to Change in This Story:**
1. **getCurrentStreak()** - Must filter by school days, calculate consecutive days, skip weekends/holidays
2. **Add new methods:**
   - `isSchoolDay(DateTime date)` - Check if date has classes in timetable
   - `getPreviousStreak()` - Retrieve last broken streak
   - `detectBrokenStreak()` - Check if streak was broken (missed school day)
   - `resetStreak()` - Reset streak and store previous value
3. **Integrate with schedule module** - Query calendar_courses table

### School Day Detection Logic

**Timetable Data Structure (From architecture.md):**
- Table: `calendar_courses` (Drift)
- Columns: id, courseId, dayOfWeek, startTime, endTime, weekType (A/B/both)
- Week A/B system: WeekUtils.getWeekType(DateTime) determines current week

**Algorithm: isSchoolDay(DateTime date)**
```dart
Future<bool> isSchoolDay(DateTime date) async {
  final normalizedDate = DateTime(date.year, date.month, date.day);

  // 1. Get day of week (1=Monday, 7=Sunday)
  final dayOfWeek = date.weekday;

  // 2. Weekend check (Saturday=6, Sunday=7)
  if (dayOfWeek == 6 || dayOfWeek == 7) {
    return false;  // Weekends are never school days
  }

  // 3. Get week type (A/B/both)
  final weekType = WeekUtils.getWeekType(date);

  // 4. Query calendar_courses for this day and week
  final courses = await _database.getCalendarCoursesByDay(
    dayOfWeek,
    weekType,
  );

  // 5. If no courses found, not a school day
  return courses.isNotEmpty;
}
```

**Key Points:**
- Weekends always return false (no calculation needed)
- Empty timetable days return false (no classes = no school)
- Week A/B alternation handled by WeekUtils
- Holidays detected automatically (no classes in timetable for that day)

### Consecutive School-Day Streak Algorithm

**High-Level Logic:**
```
1. Get all BagCompletions sorted by date (descending)
2. Start from today, work backwards
3. For each date:
   - Check if it's a school day (call isSchoolDay)
   - If school day AND has completion → increment streak
   - If school day AND no completion → break (streak ends)
   - If not school day → skip (don't break streak)
4. Return final streak count
```

**Detailed Algorithm:**
```dart
Future<Either<Failure, int>> getCurrentStreak() async {
  return handleErrors(() async {
    // 1. Get all bag completions
    final completions = await _database.getAllBagCompletions();

    // 2. Create a set of completed dates for fast lookup
    final completedDates = completions.map((c) {
      final d = c.date;
      return DateTime(d.year, d.month, d.day);
    }).toSet();

    // 3. Start from today, work backwards
    var currentDate = DateTime.now();
    currentDate = DateTime(currentDate.year, currentDate.month, currentDate.day);

    int streak = 0;

    // 4. Count consecutive school days with completions
    while (true) {
      // Check if currentDate is a school day
      final isSchool = await isSchoolDay(currentDate);

      if (!isSchool) {
        // Not a school day (weekend/holiday) → skip, don't break streak
        currentDate = currentDate.subtract(const Duration(days: 1));
        continue;
      }

      // It's a school day - check if completed
      if (completedDates.contains(currentDate)) {
        // Completed! Increment streak
        streak++;
        currentDate = currentDate.subtract(const Duration(days: 1));
      } else {
        // School day but not completed → streak breaks
        break;
      }

      // Safety: Don't go back more than 365 days
      if (streak > 365) {
        LogService.w('Streak calculation exceeded 365 days, stopping');
        break;
      }
    }

    LogService.d('Current streak calculated: $streak consecutive school days');
    return streak;
  });
}
```

**Edge Cases Handled:**
- **First completion ever:** Streak = 1 (loop breaks after first school day with completion)
- **Weekend between completions:** Weekend skipped, streak continues (Friday → Monday)
- **Holiday between completions:** Holiday skipped, streak continues
- **Today not completed yet:** Loop stops at today if today is a school day and not completed (streak shows yesterday's count)
- **Safety limit:** 365-day max to prevent infinite loops

### Streak Break Detection & Previous Streak Storage

**When Does a Streak Break?**
- A school day passes without a BagCompletion entry
- The streak resets to 0
- The previous streak length must be stored for the "encouraging reset message"

**Storage Strategy:**
- Use SharedPreferences to store `previous_streak_length` (simple int)
- Or create a new Drift table `StreakHistory` (overkill for MVP, defer to V2.5)
- **Decision: Use PreferencesService for simplicity**

**Methods to Add:**
```dart
// Get previous streak (for reset message)
Future<Either<Failure, int>> getPreviousStreak() async {
  return handleErrors(() async {
    final previousStreak = await PreferencesService.getPreviousStreak();
    return previousStreak ?? 0;
  });
}

// Save previous streak before reset
Future<Either<Failure, void>> savePreviousStreak(int streakLength) async {
  return handleErrors(() async {
    await PreferencesService.setPreviousStreak(streakLength);
    LogService.i('Previous streak saved: $streakLength');
  });
}

// Detect if streak was broken (missed a school day)
Future<Either<Failure, bool>> detectBrokenStreak() async {
  return handleErrors(() async {
    // Logic:
    // 1. Get current streak
    // 2. Get yesterday's date
    // 3. If yesterday was a school day AND no completion → streak broken

    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final normalizedYesterday = DateTime(yesterday.year, yesterday.month, yesterday.day);

    // Check if yesterday was a school day
    final wasSchoolDay = await isSchoolDay(normalizedYesterday);
    if (!wasSchoolDay) {
      return false;  // Not a school day, can't be broken
    }

    // Check if there's a completion for yesterday
    final completion = await _database.getBagCompletionByDate(normalizedYesterday);
    if (completion != null) {
      return false;  // Completed yesterday, not broken
    }

    // It was a school day and not completed → streak broken!
    LogService.w('Streak broken: yesterday was a school day but no completion found');
    return true;
  });
}
```

### Integration with Schedule Module (Read-Only)

**Module Communication Rule (From architecture.md):**
> Modules never communicate directly. All communication goes through `common` (Riverpod providers, Drift DB, services).

**For Story 2.4:**
- **Read-only access** to `calendar_courses` Drift table (via AppDatabase)
- **No direct dependency** on schedule module code
- **No providers** from schedule module needed
- **Just database queries** via AppDatabase.getCalendarCoursesByDay()

**Database Query Needed:**
```dart
// In AppDatabase (features/common/lib/src/database/app_database.dart)
// This query may already exist, check first!

Future<List<CalendarCourseEntity>> getCalendarCoursesByDay(
  int dayOfWeek,
  String weekType,  // 'A', 'B', or 'both'
) async {
  final query = select(calendarCourses)
    ..where((tbl) => tbl.dayOfWeek.equals(dayOfWeek))
    ..where((tbl) =>
      tbl.weekType.equals(weekType) |
      tbl.weekType.equals('both')
    );

  return await query.get();
}
```

**If this query doesn't exist:** Add it to AppDatabase in `features/common/lib/src/database/app_database.dart`.

### WeekUtils Integration

**Location:** `features/common/lib/src/utils/week_utils.dart` (assumed, verify exact path)

**Key Methods:**
- `WeekUtils.getWeekType(DateTime date)` → Returns 'A', 'B', or 'both'
- Uses school year start date from PreferencesService
- Handles week alternation automatically

**Usage in isSchoolDay():**
```dart
final weekType = WeekUtils.getWeekType(date);
// Then use weekType to query calendar_courses
```

**Integration Notes:**
- WeekUtils is in `common` module (accessible to streak module)
- No direct imports needed (use via common module)
- Week A/B logic already battle-tested in V1

### Performance Optimization

**NFR2: Tomorrow's supply list load < 500ms**
- Streak calculation must not block UI
- getCurrentStreak() should complete in < 100ms for typical cases

**Optimization Strategies:**
1. **Limit backwards scan:** Stop after finding first break (don't scan entire history)
2. **Cache school day checks:** If checking same date multiple times, cache result
3. **Batch database queries:** Get all completions and courses in one query each
4. **Early exit:** If no completions exist, return 0 immediately

**Example Optimized getCurrentStreak():**
```dart
Future<Either<Failure, int>> getCurrentStreak() async {
  return handleErrors(() async {
    // Quick exit: No completions = streak 0
    final allCompletions = await _database.getAllBagCompletions();
    if (allCompletions.isEmpty) {
      LogService.d('No completions found, streak = 0');
      return 0;
    }

    // Create fast lookup set
    final completedDates = allCompletions.map((c) {
      final d = c.date;
      return DateTime(d.year, d.month, d.day);
    }).toSet();

    // Start counting from today
    var currentDate = DateTime.now();
    currentDate = DateTime(currentDate.year, currentDate.month, currentDate.day);

    int streak = 0;
    int daysScanned = 0;

    while (daysScanned < 365) {  // Max 1 year back
      final isSchool = await isSchoolDay(currentDate);

      if (!isSchool) {
        // Skip non-school days (don't increment daysScanned counter)
        currentDate = currentDate.subtract(const Duration(days: 1));
        continue;
      }

      // It's a school day
      if (completedDates.contains(currentDate)) {
        streak++;
        currentDate = currentDate.subtract(const Duration(days: 1));
        daysScanned++;
      } else {
        // Streak broken
        break;
      }
    }

    LogService.d('Streak calculated in $daysScanned days scanned: $streak');
    return streak;
  });
}
```

**Typical Performance (estimated):**
- 10-day streak: ~10 date checks + 2 DB queries = ~20ms
- 30-day streak: ~30 date checks + 2 DB queries = ~50ms
- No streak: 1 date check + 1 DB query = ~5ms

**Well under 100ms target.**

### Previous Story Intelligence

**Learnings from Story 2.1 (Drift Schema v3):**
- BagCompletions table structure validated
- Date normalization pattern established (start of day)
- Range queries use `isBiggerOrEqualValue` and `isSmallerOrEqualValue`
- 16 comprehensive tests passing

**Learnings from Story 2.2 (Streak Module Foundation):**
- StreakRepository pattern established
- PreferenceRepository used for device ID (don't hardcode)
- handleErrors() wrapper used for all async operations
- LogService.d/i/w/e used throughout (no print statements)
- Comprehensive unit tests required (10+ tests)
- build_runner executed after @riverpod changes
- Code review fixes: deviceId from PreferenceRepository, no redundant try-catch, correct imports

**Learnings from Story 2.3 (Daily Checklist Persistence):**
- Drift database operations are fast (< 100ms)
- Date normalization to start of day is critical
- SyncManager integration pattern established
- Offline-first architecture validated
- 15/15 tests passing after code review fixes

**Code Review Patterns to Apply:**
- Never hardcode values (use PreferenceRepository, configuration)
- No redundant try-catch inside handleErrors() wrapper
- Use correct imports (riverpod not flutter_riverpod for repository)
- Comprehensive test coverage before marking story complete
- Update sprint-status.yaml when done

### Testing Requirements

**All tests must pass 100% before marking story complete:**

1. **Unit Tests - StreakRepository:**
   - Test getCurrentStreak() with various scenarios:
     - No completions (streak = 0)
     - Single completion (streak = 1)
     - Consecutive school days (streak = N)
     - Weekend between completions (streak continues)
     - Holiday between completions (streak continues)
     - Missed school day (streak breaks)
   - Test isSchoolDay():
     - Weekend returns false
     - School day with classes returns true
     - School day without classes returns false
     - Week A/B alternation handled correctly
   - Test getPreviousStreak()
   - Test savePreviousStreak()
   - Test detectBrokenStreak()
   - Test error handling with Either pattern
   - Test LogService usage (verify no print statements)

2. **Integration Tests - Full Streak Workflow:**
   - Test complete bag → mark completion → recalculate streak
   - Test streak persists through app restart
   - Test streak calculation with real timetable data
   - Test offline operation (no network required)
   - Test performance < 100ms for typical cases

3. **Edge Case Tests:**
   - First week of school (no history)
   - Very long streak (100+ days)
   - Irregular timetable (some days have classes, some don't)
   - School year boundary (week A/B reset)
   - Daylight saving time transitions

**Test Pattern (use in-memory database):**
```dart
void main() {
  late AppDatabase database;
  late StreakRepository repository;
  late MockPreferenceRepository mockPreferenceRepo;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    mockPreferenceRepo = MockPreferenceRepository();
    repository = StreakRepository(database, mockPreferenceRepo);

    // Setup mock device ID
    when(() => mockPreferenceRepo.getUserId())
        .thenAnswer((_) async => 'test-device-id');
  });

  tearDown(() async {
    await database.close();
  });

  group('getCurrentStreak', () {
    test('should return 0 when no completions', () async {
      // Test implementation
    });

    test('should return 1 after single completion', () async {
      // Test implementation
    });

    test('should count consecutive school days only', () async {
      // Test implementation
    });

    test('should skip weekends when counting streak', () async {
      // Test implementation
    });

    test('should break streak on missed school day', () async {
      // Test implementation
    });
  });

  group('isSchoolDay', () {
    test('should return false for weekends', () async {
      // Test implementation
    });

    test('should return true for school day with classes', () async {
      // Test implementation
    });

    test('should return false for empty timetable day', () async {
      // Test implementation
    });
  });

  group('streak break detection', () {
    test('should detect broken streak', () async {
      // Test implementation
    });

    test('should store previous streak on break', () async {
      // Test implementation
    });
  });
}
```

**Minimum Test Count:** 15+ tests covering all scenarios.

### Project Structure Notes

**Files to Modify:**
1. **`features/streak/lib/repository/streak_repository.dart`**
   - Enhance getCurrentStreak() with school-day filtering
   - Add isSchoolDay(DateTime) method
   - Add getPreviousStreak() method
   - Add savePreviousStreak(int) method
   - Add detectBrokenStreak() method

2. **`features/streak/lib/di/riverpod_di.dart`**
   - Update currentStreakProvider to use enhanced logic
   - Add previousStreakProvider for reset messages
   - Run build_runner to regenerate providers

3. **`features/common/lib/src/database/app_database.dart`** (if needed)
   - Add getCalendarCoursesByDay() query (if doesn't exist)

4. **`features/common/lib/src/services/preferences_service.dart`** (if needed)
   - Add getPreviousStreak() and setPreviousStreak() methods

**Files to Create:**
1. **`features/streak/lib/models/streak_data.dart`** (optional)
   - Data class for streak information
   - Fields: currentStreak, previousStreak, lastCompletionDate

2. **`features/streak/test/repository/streak_repository_test.dart`** (expand existing)
   - Add new test groups for school-day logic
   - Add edge case tests
   - Ensure 100% pass rate

**No New Module Required:**
All work happens in existing `streak` module created in Story 2.2.

### Dependencies

**Existing Dependencies (Already in Project):**
- `drift: ^2.28.2` ✓
- `riverpod_annotation: ^2.6.1` ✓
- `dartz: ^0.10.1` ✓
- `uuid: ^4.5.1` ✓
- `mocktail: ^1.0.4` (for testing) ✓

**No New Dependencies Required.**

### References

**Source Documents:**
- [Architecture: Data Architecture](../../_bmad-output/planning-artifacts/architecture.md#data-architecture) - BagCompletions table, Drift operations
- [Architecture: Module Architecture](../../_bmad-output/planning-artifacts/architecture.md#module-architecture) - Streak module structure
- [Architecture: Implementation Patterns](../../_bmad-output/planning-artifacts/architecture.md#implementation-patterns--consistency-rules) - Naming conventions, repository pattern
- [PRD: Streak & Habit Tracking](../../_bmad-output/planning-artifacts/prd.md#streak--habit-tracking) - FR6-FR10
- [Epics: Story 2.4](../../_bmad-output/planning-artifacts/epics.md#story-24-implement-streak-calculation-logic) - Lines 515-552
- [Story 2.1](./2-1-drift-schema-v3-migration.md) - Drift Schema v3 Migration (provides BagCompletions table)
- [Story 2.2](./2-2-create-streak-module-foundation.md) - Streak module foundation (repository pattern reference)
- [Story 2.3](./2-3-implement-daily-checklist-persistence.md) - Daily checklist persistence (integration reference)

**Critical Constraints:**
- **FR6:** System can track consecutive school days where student completed bag preparation
- **FR7:** System can distinguish school days from non-school days using timetable data
- **FR9:** System can detect broken streak and display encouraging reset message with previous streak length
- **FR10:** System can persist streak data locally and sync when connected
- **NFR2:** Tomorrow's supply list must load in under 500ms (streak calculation included)
- **NFR13:** Streak data must persist through normal app lifecycle — zero data loss
- **NFR14:** All core features (including streak) must function fully offline
- **Offline-first:** Local Drift database is authoritative

### Known Edge Cases

1. **First Day of School:**
   - Student has no history
   - isSchoolDay() should work correctly
   - getCurrentStreak() returns 0 or 1 (if completed today)

2. **Long Weekend (3-4 days):**
   - Friday → Monday (skip Sat/Sun)
   - Streak should continue if completed on Friday and Monday
   - Test with 3-day weekend (holiday Monday)

3. **School Holiday (Full Week):**
   - No classes for entire week
   - All days return false from isSchoolDay()
   - Streak should not break during holiday week

4. **Week A/B Boundary:**
   - Student has classes on Week A only (some days)
   - Week B same days should return false from isSchoolDay()
   - Streak should not break on Week B empty days

5. **Daylight Saving Time:**
   - Date normalization handles this (start of day)
   - No timezone conversion issues
   - Drift stores local time by default

6. **Very Long Streak (100+ days):**
   - Performance test: Should complete in < 100ms
   - Safety limit: 365-day max scan prevents infinite loops
   - No memory issues (queries are paginated)

7. **Timetable Changes Mid-Year:**
   - Student adds/removes courses
   - Historical streak remains valid (based on historical timetable)
   - Future streak uses updated timetable

8. **Empty Timetable:**
   - Student hasn't set up timetable yet
   - Every day returns false from isSchoolDay()
   - Streak calculation returns 0 (no school days to count)

### Validation Checklist

Before marking story complete, verify:

- [ ] StreakRepository enhanced with getCurrentStreak() school-day filtering
- [ ] isSchoolDay(DateTime) method implemented and tested
- [ ] getPreviousStreak() method implemented
- [ ] savePreviousStreak(int) method implemented
- [ ] detectBrokenStreak() method implemented
- [ ] Integration with calendar_courses table working
- [ ] WeekUtils.getWeekType() integrated correctly
- [ ] Weekend skip logic working (Friday → Monday streak continues)
- [ ] Holiday skip logic working (non-school days don't break streak)
- [ ] Streak break detection working (missed school day resets to 0)
- [ ] Previous streak storage working (for reset messages)
- [ ] All async operations wrapped with handleErrors()
- [ ] LogService used for all logging (no print() statements)
- [ ] @riverpod annotations updated in providers
- [ ] build_runner executed successfully (.g.dart files regenerated)
- [ ] All tests passing (15+ tests, 100% pass rate)
- [ ] Performance < 100ms for typical cases (10-30 day streaks)
- [ ] Offline operation verified (no network required)
- [ ] State persists through app restart
- [ ] No compilation errors
- [ ] No circular dependencies introduced
- [ ] Code follows all naming conventions (snake_case, PascalCase, camelCase)
- [ ] flutter analyze passes (no new warnings)
- [ ] sprint-status.yaml updated (story status = done)

## Dev Agent Record

### Agent Model Used

{{agent_model_name_version}}

### Debug Log References

### Completion Notes List

### File List
