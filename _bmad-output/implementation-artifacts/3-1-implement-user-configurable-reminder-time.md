# Story 3.1: Implement User-Configurable Reminder Time

Status: ready-for-dev

## Story

As a student,
I want to set my preferred bag preparation reminder time,
so that I receive notifications at the most convenient moment for me.

## Acceptance Criteria

1. **AC1 — Time Picker in Settings**: Given I am in the app settings, when I access the reminder time configuration, I should see a time picker to select my preferred bag preparation time.
2. **AC2 — Default Time**: Default time should be 7:00 PM (19:00) if not previously set.
3. **AC3 — Local Persistence**: When I save the setting, the time should be persisted to local preferences via `PreferencesService`.
4. **AC4 — Notification Uses Configured Time**: The notification scheduler should use this configured time for the primary reminder.
5. **AC5 — Immediate Effect**: When I change the reminder time, the new time should take effect immediately — all scheduled notifications should be rescheduled.
6. **AC6 — Second Reminder Preview**: The second reminder time should be displayed as user_time + 1 hour (informational, for Epic 3 Story 3.2).
7. **AC7 — Configurable Delay Constant**: The second reminder delay should be defined as a configurable constant (`secondReminderDelay = Duration(hours: 1)`) in `NotificationService`, fixed to 1 hour in V2.

## Tasks / Subtasks

- [ ] Task 1: Verify and enhance Settings time picker (AC: 1, 2, 3, 5)
  - [ ] 1.1 Read current `settings_page.dart` time picker implementation
  - [ ] 1.2 Ensure time picker calls `PreferencesService.setPackTime()` on save
  - [ ] 1.3 Ensure `NotificationService.updateNotificationIfEnabled()` is called after save with injected dependencies (repository, database, currentStreak)
  - [ ] 1.4 Add display of second reminder time preview below the time picker (e.g., "Rappel de suivi : 20h00" if primary is 19h00)
- [ ] Task 2: Define second reminder delay constant (AC: 7)
  - [ ] 2.1 Add `static const Duration secondReminderDelay = Duration(hours: 1)` in `NotificationService`
  - [ ] 2.2 Fix existing reminder scheduling from 1h30m to 1h to match architecture spec
  - [ ] 2.3 Ensure `_scheduleUpcomingNotifications()` uses this constant instead of hardcoded Duration
- [ ] Task 3: Verify onboarding time setup integration (AC: 1, 4)
  - [ ] 3.1 Confirm onboarding hour setup page calls `PreferencesService.setPackTime()`
  - [ ] 3.2 Confirm onboarding triggers notification scheduling after time is set
- [ ] Task 4: Verify end-to-end notification rescheduling (AC: 4, 5)
  - [ ] 4.1 Confirm `_scheduleUpcomingNotifications()` reads `packTime` from `PreferencesService.getPackTime()`
  - [ ] 4.2 Confirm `cancelAllNotifications()` is called before rescheduling
  - [ ] 4.3 Verify vacation mode and no-school-day logic still works after changes

## Dev Notes

### CRITICAL: Most Infrastructure Already Exists

**PreferencesService** (`features/common/lib/src/services/preferences_service.dart`):
- `setPackTime(TimeOfDay time)` — already implemented, stores `_keyPackTimeHour` and `_keyPackTimeMinute`
- `getPackTime()` — already returns `TimeOfDay(hour: 19, minute: 0)` as default
- `setNotificationsEnabled(bool)` / `getNotificationsEnabled()` — already implemented

**NotificationService** (`features/common/lib/src/services/notification_service.dart`):
- `_scheduleUpcomingNotifications()` — already reads `packTime` from PreferencesService
- `updateNotificationIfEnabled()` — already accepts repository, database, currentStreak params
- Notification ID architecture: primary 1001-1014, reminder 1015-1028
- **BUG TO FIX**: Current reminder delay is `Duration(hours: 1, minutes: 30)` but architecture spec says 1 hour. Fix to `Duration(hours: 1)`.

**Settings Page** (`features/main/lib/presentation/home/settings_page.dart`):
- Time picker already exists and calls `PreferencesService.setPackTime()`
- Already calls `NotificationService.updateNotificationIfEnabled()` after save
- Uses dependency injection pattern with `ref.read(calendarCourseRepositoryProvider)` and `ref.read(databaseProvider)`

### What Actually Needs to Be Done

This story is primarily **verification and enhancement**, not new feature creation:
1. **Verify** existing time picker flow works end-to-end (settings + onboarding)
2. **Add** second reminder time preview in settings UI
3. **Define** `secondReminderDelay` constant and fix 1h30m → 1h
4. **Verify** notification rescheduling works immediately on time change

### Anti-Patterns to Avoid

- **DO NOT** create a new time picker widget — use existing one in settings_page.dart
- **DO NOT** create new preference keys — `_keyPackTimeHour` and `_keyPackTimeMinute` already exist
- **DO NOT** modify the notification ID ranges — 1001-1014 (primary) and 1015-1028 (reminder) are correct
- **DO NOT** add Supabase calls — this is 100% local/offline
- **DO NOT** remove the streak-based reminder condition yet — Story 3.2 will handle the double reminder logic
- **DO NOT** add time estimates or predictions

### Dependency Injection Pattern (MUST follow)

All calls to `NotificationService.updateNotificationIfEnabled()` must pass:
```dart
await NotificationService.updateNotificationIfEnabled(
  repository: ref.read(calendarCourseRepositoryProvider),
  database: ref.read(databaseProvider),
  currentStreak: currentStreak,
);
```

### Second Reminder Preview UI

In settings, below the time picker, add a subtitle showing the computed second reminder time:
```dart
// Example: If pack time is 19:00
// Display: "Rappel de suivi à 20h00 si le sac n'est pas prêt"
final secondTime = TimeOfDay(
  hour: (packTime.hour + 1) % 24,
  minute: packTime.minute,
);
```
Use the same dark theme style as surrounding settings items. Accent color: `0xFFB9A0FF`.

### File Changes Expected

| File | Change Type | Description |
|------|-------------|-------------|
| `features/common/lib/src/services/notification_service.dart` | Modify | Add `secondReminderDelay` constant, fix 1h30m → 1h |
| `features/main/lib/presentation/home/settings_page.dart` | Modify | Add second reminder time preview subtitle |
| No new files needed | — | All infrastructure exists |

### Project Structure Notes

- All notification logic in `features/common/` module
- Settings UI in `features/main/` module
- Onboarding time setup in `features/onboarding/` module
- Pattern: Riverpod providers with `@riverpod` annotations + code generation
- Dark theme: accent `0xFFB9A0FF`, background `0xFF212121`, surface `0xFF424242`

### Cross-Story Context (Epic 3)

- **Story 3.2** (Double Reminder Logic): Will use the `secondReminderDelay` constant defined here to schedule the actual second notification. Will change the reminder condition from streak-based to always-on.
- **Story 3.3** (Auto-Cancel on Bag Completion): Will cancel the second reminder when `BagCompletions` entry is created. Uses notification IDs 1015-1028.

### Previous Story Intelligence

**From Story 2.9** (Contextual Notifications):
- `buildTomorrowNotificationContent()` builds contextual text with subjects and supply count
- French pluralization: 1 subject listed, 2 listed with "et", 3-4 listed, 5+ summarized
- Supply: "0 fournitures", "1 fourniture", "2+ fournitures"

**From Story 2.8** (Tomorrow's Schedule Detection):
- LESSON: Do NOT add premature weekend optimization — let data drive behavior
- Week A/B support is already integrated

**From Git History**:
- Vacation mode was recently added (`4ea3449`) — notification scheduling already skips vacation days
- All tests pass on current codebase

### References

- [Source: _bmad-output/planning-artifacts/epics.md#Epic-3, lines 790-816]
- [Source: _bmad-output/planning-artifacts/architecture.md#NotificationScheduler, lines 204-217]
- [Source: _bmad-output/planning-artifacts/prd.md#Push-Notification-Strategy, lines 233-238]
- [Source: features/common/lib/src/services/notification_service.dart]
- [Source: features/common/lib/src/services/preferences_service.dart]
- [Source: features/main/lib/presentation/home/settings_page.dart]

## Dev Agent Record

### Agent Model Used

### Debug Log References

### Completion Notes List

### File List
