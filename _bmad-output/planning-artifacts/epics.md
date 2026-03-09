---
stepsCompleted: ['step-01-validate-prerequisites', 'step-02-design-epics', 'step-03-create-stories']
inputDocuments:
  - '_bmad-output/planning-artifacts/prd.md'
  - '_bmad-output/planning-artifacts/architecture.md'
---

# dansmonsac - Epic Breakdown

## Overview

This document provides the complete epic and story breakdown for dansmonsac, decomposing the requirements from the PRD, UX Design if it exists, and Architecture requirements into implementable stories.

## Requirements Inventory

### Functional Requirements

**FR1**: Student can view a list of all supplies needed for the next school day, grouped by subject

**FR2**: Student can check/uncheck individual supplies as they pack their bag

**FR3**: Student can see a clear "Bag Ready" confirmation when all supplies for tomorrow are checked

**FR4**: System can determine tomorrow's subjects from the student's timetable

**FR5**: System can detect no-class days (weekend, holiday, empty timetable) and suppress the checklist

**FR6**: System can track consecutive school days where the student completed bag preparation

**FR7**: System can distinguish school days from non-school days using timetable data (streak counts school-day evenings only)

**FR8**: Student can view their current streak count

**FR9**: System can detect a broken streak and display an encouraging reset message with the previous streak length

**FR10**: System can persist streak data locally and sync when connected

**FR11**: Student can set their preferred bag preparation time

**FR12**: System can send a contextual notification at the student's chosen time showing tomorrow's subjects and supply count

**FR13**: System can send a second reminder notification if the bag is not marked as done within a configurable delay after the first

**FR14**: System can auto-cancel the second reminder if the student completes their bag before it triggers

**FR15**: System can suppress all notifications when there are no classes the next day

**FR16**: Student can create and manage their weekly timetable with subjects, time slots, rooms, and week type (A/B/both)

**FR17**: Student can import a timetable from another student via share code or QR code

**FR18**: Student can share their timetable with other students via share code or QR code

**FR19**: System can handle week A/B alternation based on school year start date

**FR20**: Student can add, edit, and delete supplies associated with each subject

**FR21**: System can suggest common supplies when a student creates a new subject

**FR22**: Student can accept, modify, or dismiss suggested supplies during subject creation

**FR23**: Student can purchase a personalization upgrade (in-app purchase)

**FR24**: Premium student can set a custom background image (from photo gallery or device storage) for the timetable screen

**FR25**: Premium student can set a custom background image for the "Mon Sac" (bag preparation) screen

**FR26**: System can verify and restore premium purchase status across app reinstalls

**FR27**: System can unlock premium personalization for a student whose linked parent has an active parent subscription

**FR28**: Student can generate a pairing code for parent linking

**FR29**: Parent can enter a pairing code to link to a student's device

**FR30**: Parent can assign a first name to each linked child (stored parent-side only)

**FR31**: Pairing code can be used a maximum of 2-3 times (multiple parents/guardians)

**FR32**: Student remains fully anonymous — no personal data transmitted during pairing

**FR33**: System can track key user events anonymously (app open, bag check completed, streak milestone, premium purchase, onboarding completion)

**FR34**: System can report analytics without collecting any personally identifiable information

**FR35**: System can buffer analytics events when offline and upload when connectivity returns

**FR36**: Student can complete initial setup without creating an account (no email, no name, no password)

**FR37**: Student can configure school year parameters (week A/B start date) during onboarding

**FR38**: Student can set their preferred notification time during onboarding

**FR39**: Student can optionally import a timetable during onboarding via code or QR scan

**FR40**: System can create default subjects with suggested supplies for new users

**FR41**: Student can use the app with system-level font size adjustments (dynamic type)

**FR42**: Student can navigate and complete core flows (checklist, streak view, bag ready) using screen reader (VoiceOver/TalkBack)

**FR43**: All interactive elements provide sufficient touch target size for young users

### NonFunctional Requirements

**NFR1**: Checklist interactions (check/uncheck supply) must feel instant — under 100ms response (local DB operation)

**NFR2**: Tomorrow's supply list must load in under 500ms (local Drift query)

**NFR3**: App cold start must complete in under 3 seconds on mid-range devices (2020+)

**NFR4**: Screen transitions must complete in under 300ms

**NFR5**: Notification scheduling (compute tomorrow's subjects + schedule local push) must complete in under 1 second

**NFR6**: Zero personally identifiable information collected from students — device_id is the only identifier

**NFR7**: All network communication must use HTTPS (TLS 1.2+)

**NFR8**: Supabase data encrypted at rest (Supabase default)

**NFR9**: Firebase Analytics events must never contain PII (no name, email, phone, or location)

**NFR10**: Pairing codes must be non-guessable (6-char alphanumeric, limited to 2-3 uses)

**NFR11**: IAP validation must use store-signed receipts only — no custom payment processing

**NFR12**: No third-party tracking or advertising SDKs permitted in the app

**NFR13**: Streak data must persist through normal app lifecycle — zero data loss on app restart, update, or background kill

**NFR14**: All core features (checklist, streak, notifications) must function fully offline without internet

**NFR15**: Local notifications must fire within ±1 minute of the scheduled time (OS-dependent)

**NFR16**: Sync queue (PendingOperations) must survive app restart and resume on next connectivity

**NFR17**: Local database (Drift) is authoritative — if sync conflict occurs, local data takes precedence until conflict resolution is implemented

**NFR18**: App must handle Drift database migration gracefully between versions without data loss

**NFR19**: All text must meet WCAG AA contrast ratio (4.5:1 minimum), especially in dark theme

**NFR20**: App must support dynamic type / system font scaling on iOS and Android

**NFR21**: All interactive elements must have minimum 44x44pt touch targets

**NFR22**: Core flows (checklist, streak, bag ready) must be navigable via VoiceOver (iOS) and TalkBack (Android)

**NFR23**: Information must not rely on color alone — always provide text or icon alternatives

### Additional Requirements

**Architecture Requirements:**

- **Drift Schema v3 Migration**: New tables required — `DailyChecks` (date, supplyId, courseId, isChecked), `BagCompletions` (date, completedAt), `PremiumStatus` (hasPurchased, linkedParentId)

- **Supabase Schema Extension**: New table `parent_links` (pairing_code VARCHAR(6), student_device_id, parent_device_id, uses_count, created_at) for anonymous parent-child pairing

- **New Feature Modules**: Create `features/streak/` (V2a), `features/premium/` (V2b), `features/parenting/` (V2c) following existing module pattern with `claude.md` documentation

- **Firebase Analytics Integration**: Add firebase_core + firebase_analytics dependencies, create `AnalyticsService` in common with domain extensions (AnalyticsBag, AnalyticsStreak, AnalyticsPremium, AnalyticsOnboarding)

- **NotificationScheduler**: Enhance in common module to compute tomorrow's subjects, supply count, schedule primary notification at user time, schedule conditional 2nd reminder at user_time + 1h with auto-cancel on bag completion

- **IAP Integration**: Add in_app_purchase dependency for student 0.99€ non-consumable purchase with native store validation and restoration

- **Premium Background Storage**: Store custom background images locally in app directory (not synced to cloud), path reference in Drift PremiumStatus table

- **Default Supplies Extraction**: Extract DefaultCourses data from onboarding module to `common/utils/default_supplies.dart` for reuse

- **Premium Status Provider**: Create `premiumStatusProvider` in common — resolves as `isPremium = hasStorePurchase || isLinkedToParent` with Supabase parent_links check at launch

- **BagCompletions Sync**: Sync BagCompletions to Supabase via existing SyncManager (required for V2.5 parent visibility), DailyChecks remains local-only

- **Phased Implementation**: V2a (streak + analytics), V2b (IAP + double reminder), V2c (parent linking foundations) must be architecturally decoupled to ship independently

**Implementation Patterns & Constraints:**

- Follow all existing V1 naming conventions (snake_case files, PascalCase classes, camelCase variables)
- Use `LogService` for all logging (never `print()`)
- Use `handleErrors()` wrapper for all repository async operations
- Run `build_runner` after modifying any `@riverpod` or Drift annotations
- Use `AnalyticsService` extensions for event tracking (never call Firebase directly)
- Check `premiumStatusProvider` for premium state (never query IAP directly in UI)
- Include `claude.md` in every new feature module
- Use `Validators` for input validation
- Use `ErrorMessages.getMessageForFailure()` for user-facing errors
- Respect edge-to-edge UI rules with `viewPadding.bottom` in bottom sheets
- Analytics events use snake_case (e.g., `bag_completed`, `streak_milestone`)
- Notification ID ranges: 1000-1099 (daily), 1100-1199 (streak), 1200-1299 (parent reserved)

**Privacy & Security Constraints:**

- Zero PII from students enforced structurally (typed AnalyticsService methods prevent accidental leakage)
- Anonymous pairing maintains student anonymity (parent names child locally only, never on student side or server)
- Offline-first maintained for all new features (streak, checklist state, notifications)
- Firebase Analytics configuration files required: `android/app/src/main/google-services.json` and `ios/Runner/GoogleService-Info.plist`

### FR Coverage Map

**Epic 1 - Onboarding Enhancement:**
- FR21: System suggests common supplies when student creates a new subject
- FR22: Student can accept, modify, or dismiss suggested supplies
- FR40: System creates default subjects with suggested supplies for new users

**Epic 2 - Daily Bag Preparation with Streak:**
- FR1: View supplies for next school day grouped by subject
- FR2: Check/uncheck supplies as packing
- FR3: See "Bag Ready" confirmation
- FR4: System determines tomorrow's subjects from timetable
- FR5: Detect no-class days and suppress checklist
- FR6: Track consecutive school days with completed bag prep
- FR7: Distinguish school days from non-school days for streak
- FR8: View current streak count
- FR9: Detect broken streak with encouraging reset message
- FR10: Persist streak data locally and sync
- FR12: Send contextual notification with subjects and supply count
- FR15: Suppress notifications when no classes tomorrow

**Epic 3 - Enhanced Notifications:**
- FR11: Set preferred bag preparation time
- FR13: Send second reminder if bag not done after delay
- FR14: Auto-cancel second reminder if bag completed

**Epic 4 - Premium Personalization:**
- FR23: Purchase personalization upgrade (IAP)
- FR24: Premium student sets custom background for timetable
- FR25: Premium student sets custom background for "Mon Sac"
- FR26: Verify and restore premium purchase status

**Epic 5 - Parent-Child Linking:**
- FR27: Unlock premium for student with linked parent subscription
- FR28: Student generates pairing code
- FR29: Parent enters pairing code to link
- FR30: Parent assigns child's first name (parent-side only)
- FR31: Pairing code usable 2-3 times max
- FR32: Student remains anonymous during pairing

**Epic 6 - Analytics:**
- FR33: Track key user events anonymously
- FR34: Report analytics without PII
- FR35: Buffer analytics events offline

**Epic 7 - Accessibility:**
- FR41: System-level font size adjustments
- FR42: Screen reader navigation for core flows
- FR43: Sufficient touch target sizes

**Existing V1 (No Epic Needed):**
- FR16-FR19: Timetable management (already implemented)
- FR20: Supply CRUD (already implemented)
- FR36-FR39: Onboarding base flow (already implemented)

## Epic List

### Epic 1: Onboarding Enhancement with Suggested Supplies

New students can set up their school subjects faster with intelligent supply suggestions, reducing onboarding friction and ensuring they start with complete supply lists.

**FRs covered:** FR21, FR22, FR40

**Implementation Notes:** Extract DefaultCourses data from onboarding module to `common/utils/default_supplies.dart` for reuse across onboarding and course creation flows. Standalone improvement to existing onboarding.

---

### Epic 2: Daily Bag Preparation with Smart Streak System

Students can prepare their bag with a persistent daily checklist and build positive habits through a school-day streak counter that creates motivation and celebrates consistency.

**FRs covered:** FR1, FR2, FR3, FR4, FR5, FR6, FR7, FR8, FR9, FR10, FR12, FR15

**Implementation Notes:** Core value loop (checklist → bag ready → streak increment). New Drift tables: `DailyChecks`, `BagCompletions`. New `streak` module with repository, controller, widgets. Enhanced notification with contextual text. Offline-first. **Standalone:** Complete bag preparation + streak experience.

---

### Epic 3: Enhanced Retention with Double Reminder

Students never miss bag preparation thanks to a smart second reminder that fires only when needed and auto-cancels when the task is complete.

**FRs covered:** FR11, FR13, FR14

**Implementation Notes:** `NotificationScheduler` enrichment in common. Second notification at user_time + 1h with supply count. Auto-cancel mechanism when `BagCompletions` entry created. **Standalone:** Builds on Epic 2's notifications but Epic 2 works without it.

---

### Epic 4: Premium Personalization & Monetization

Students can express their personality by customizing the app with personal background images, creating emotional attachment while validating the first revenue stream.

**FRs covered:** FR23, FR24, FR25, FR26

**Implementation Notes:** New `premium` module. In-app purchase integration (0.99€ non-consumable). `image_picker` for custom backgrounds. Local storage for images (privacy-first). `premiumStatusProvider` in common. **Standalone:** Complete monetization system.

---

### Epic 5: Anonymous Parent-Child Linking Foundations

Parents can link to their child's bag preparation progress while preserving complete student anonymity, laying the foundation for future parent premium features.

**FRs covered:** FR27, FR28, FR29, FR30, FR31, FR32

**Implementation Notes:** New `parenting` module. Supabase `parent_links` table. Reuses existing 6-char code pattern. Parent names child locally only. Premium unlock: `isPremium = hasStorePurchase || isLinkedToParent`. **Standalone:** Complete pairing system (parent notifications deferred to V2.5).

---

### Epic 6: Analytics & Measurement Infrastructure

Product owner can measure user engagement, retention, and conversion to make data-driven product decisions and improve student success.

**FRs covered:** FR33, FR34, FR35

**Implementation Notes:** Firebase Analytics integration (firebase_core + firebase_analytics). `AnalyticsService` in common with typed domain extensions. Zero-PII enforcement. Offline buffering. Config files: google-services.json (Android), GoogleService-Info.plist (iOS). **Standalone:** Complete tracking system.

---

### Epic 7: Accessibility & Inclusive Design

All students, including those with visual impairments or dyslexia, can use the app fully through dynamic type support, screen reader compatibility, and optimized touch targets.

**FRs covered:** FR41, FR42, FR43

**NFRs covered:** NFR19, NFR20, NFR21, NFR22, NFR23

**Implementation Notes:** Cross-cutting UI improvements. Dynamic type support. VoiceOver/TalkBack navigation. 44x44pt minimum touch targets. WCAG AA contrast ratios (4.5:1). Color-independent information design. **Standalone:** Improves existing and new features.

## Epic 1: Onboarding Enhancement with Suggested Supplies

New students can set up their school subjects faster with intelligent supply suggestions, reducing onboarding friction and ensuring they start with complete supply lists.

### Story 1.1: Extract Default Supplies Utility

As a developer,
I want to extract DefaultCourses data to a shared utility module,
So that supply suggestions can be reused across onboarding and course creation flows.

**Acceptance Criteria:**

**Given** the DefaultCourses data exists in the onboarding module
**When** I create the file `common/utils/default_supplies.dart`
**Then** it should contain a reusable data structure with default subjects and their associated supplies
**And** the data structure should include subject name, typical supplies list, and subject category
**And** the file should export a public API for accessing default supplies by subject name

**Given** the utility is created
**When** the onboarding module is refactored
**Then** it should import and use the new shared utility
**And** no functionality should break in the existing onboarding flow
**And** `flutter pub run build_runner build --delete-conflicting-outputs` should complete successfully

### Story 1.2: Implement Supply Suggestions at Course Creation

As a student,
I want the app to suggest common supplies when I create a new subject,
So that I don't have to manually think of every supply item and can start with a complete list.

**Acceptance Criteria:**

**Given** I am on the "Add Course" screen
**When** I enter a subject name that matches a known subject (e.g., "Mathématiques", "Français", "Histoire-Géographie")
**Then** the system should display a list of suggested supplies for that subject
**And** each suggested supply should have a checkbox (checked by default)
**And** I should be able to uncheck supplies I don't need

**Given** suggested supplies are displayed
**When** I modify the text of a suggested supply
**Then** the modified text should be saved instead of the default
**And** the supply should remain in the list

**Given** suggested supplies are displayed
**When** I uncheck a supply
**Then** that supply should not be added to the course when I save
**And** the unchecked state should be visually clear

**Given** I enter a subject name that doesn't match any known subject
**When** the system cannot find suggestions
**Then** no suggestions should be displayed
**And** I should be able to add supplies manually as before (existing V1 flow)

**Given** I have accepted/modified the suggested supplies
**When** I save the course
**Then** all checked supplies should be created and associated with the course in Drift
**And** the supplies should sync to Supabase via SyncManager
**And** the course should appear in my timetable with the supplies ready to use

### Story 1.3: Integrate Suggested Supplies in Onboarding

As a new student setting up the app for the first time,
I want the onboarding to create default subjects with suggested supplies automatically,
So that I can start using the app immediately with a pre-populated supply list.

**Acceptance Criteria:**

**Given** I am completing the onboarding flow
**When** the system creates default subjects (e.g., for 6ème students)
**Then** each default subject should be created with its associated suggested supplies from the shared utility
**And** all supplies should be automatically saved to Drift and queued for Supabase sync

**Given** default subjects are created during onboarding
**When** I navigate to the course list after onboarding
**Then** I should see the default subjects (e.g., Mathématiques, Français, Histoire-Géo, etc.)
**And** each subject should have supplies already associated
**And** I should be able to view and edit these supplies in the existing V1 supply management UI

**Given** the onboarding creates default subjects
**When** I choose to skip default subjects (if that option exists)
**Then** no default subjects or supplies should be created
**And** I should be able to create subjects manually later

**Given** the suggested supplies feature is implemented
**When** I complete the onboarding and then create a new course manually
**Then** the supply suggestion feature from Story 1.2 should work correctly
**And** there should be no conflicts or duplicate data

## Epic 2: Daily Bag Preparation with Smart Streak System

Students can prepare their bag with a persistent daily checklist and build positive habits through a school-day streak counter that creates motivation and celebrates consistency.

### Story 2.1: Drift Schema v3 Migration

As a developer,
I want to migrate the Drift database schema from v2 to v3 with new tables for streak and checklist persistence,
So that the foundation for bag preparation tracking and streak calculation is in place.

**Acceptance Criteria:**

**Given** the current Drift schema is at version 2
**When** I implement the migration to version 3
**Then** three new tables should be created: `DailyChecks`, `BagCompletions`, `PremiumStatus`
**And** the `DailyChecks` table should have columns: id, date, supplyId, courseId, isChecked, createdAt
**And** the `BagCompletions` table should have columns: id, date, completedAt, deviceId
**And** the `PremiumStatus` table should have columns: id, hasPurchased, linkedParentId, updatedAt

**Given** the migration is implemented
**When** the app runs on a device with schema v2
**Then** the migration should execute automatically on app startup
**And** all existing data (courses, supplies, calendar_courses) should remain intact
**And** no data loss should occur during migration

**Given** the migration is complete
**When** I run `flutter pub run build_runner build --delete-conflicting-outputs`
**Then** the build should complete successfully
**And** `app_database.g.dart` should be regenerated with new table definitions

**Given** the new schema is in place
**When** I query the database
**Then** all three new tables should be accessible via the database provider
**And** appropriate indexes should be created for date-based queries

### Story 2.2: Create Streak Module Foundation

As a developer,
I want to create the new `features/streak/` module with proper structure and dependencies,
So that streak-related logic is organized following the existing architecture patterns.

**Acceptance Criteria:**

**Given** the project has existing feature modules
**When** I create `features/streak/`
**Then** it should follow the standard module structure: lib/presentation/, lib/repository/, lib/models/, lib/di/
**And** it should have a `pubspec.yaml` with dependencies on common and other required modules
**And** it should have a `claude.md` documenting the module's purpose, architecture, and key files

**Given** the module structure is created
**When** I implement the base repository
**Then** `streak_repository.dart` should be created with methods for streak calculation and BagCompletions access
**And** it should use the `Either<Failure, T>` pattern from dartz
**And** it should use `handleErrors()` wrapper for all async operations

**Given** the repository is implemented
**When** I create the Riverpod providers
**Then** `riverpod_di.dart` should export `@riverpod` annotated providers for the repository
**And** running `build_runner` should generate the provider code successfully

**Given** the module is complete
**When** the main app imports the streak module
**Then** the module should compile without errors
**And** the providers should be accessible via Riverpod

### Story 2.3: Implement Daily Checklist Persistence

As a student,
I want my daily checklist state to be saved automatically as I check supplies,
So that I can close the app and return later without losing my progress.

**Acceptance Criteria:**

**Given** I am viewing the supply list for tomorrow
**When** I check a supply item
**Then** a row should be inserted/updated in the `DailyChecks` table with date=tomorrow, supplyId, courseId, isChecked=true
**And** the change should persist to Drift immediately (< 100ms per NFR1)
**And** the checkmark UI should update instantly

**Given** I have checked some supplies
**When** I close the app and reopen it
**Then** all my checked supplies should still show as checked
**And** the checklist state should be restored from `DailyChecks` table

**Given** I am viewing the checklist
**When** I uncheck a previously checked supply
**Then** the `DailyChecks` row for that supply should update isChecked=false
**And** the UI should reflect the unchecked state immediately

**Given** the day changes (midnight passes)
**When** I open the app the next day
**Then** yesterday's checklist state should remain in the database for history
**And** today's checklist should start fresh with no items checked
**And** the system should query based on date to show the correct day's state

**Given** checklist data is saved locally
**When** network connectivity is available
**Then** checklist completion events should be queued for sync to Supabase via SyncManager
**And** offline operation should not be affected if sync fails

### Story 2.4: Implement Streak Calculation Logic

As a student,
I want the app to accurately track my consecutive school days of bag preparation,
So that my streak count reflects my actual habit and motivates me to continue.

**Acceptance Criteria:**

**Given** I complete my bag preparation today (all supplies checked)
**When** the system calculates my streak
**Then** it should query `BagCompletions` table for consecutive school-day entries
**And** it should use the timetable data to determine which days are school days (have classes)
**And** weekends, holidays, and days without classes should be ignored in the count

**Given** I have completed bag prep for 5 consecutive school days
**When** I complete today's bag prep
**Then** my streak should increment to 6
**And** a new row should be inserted in `BagCompletions` with today's date and completedAt timestamp

**Given** I completed bag prep yesterday (Monday)
**When** today is Tuesday and I haven't completed it yet
**Then** my streak should still show yesterday's count (not broken yet)
**And** the streak should only break if the day ends without completion

**Given** I have a 10-day streak
**When** I skip a school day (don't complete bag prep)
**Then** my streak should reset to 0
**And** the previous streak length (10) should be stored for display in the reset message

**Given** I complete bag prep on Friday
**When** the weekend passes with no school
**Then** my streak should not break over the weekend
**And** when I complete bag prep on Monday, my streak should continue from Friday

**Given** streak data is calculated
**When** the data is persisted
**Then** all streak calculations should work fully offline using local Drift database (NFR14)
**And** BagCompletions should sync to Supabase when connectivity is available

### Story 2.5: Create Streak Counter UI Widget

As a student,
I want to see my current streak count prominently displayed on the home screen,
So that I am constantly reminded of my progress and motivated to maintain my habit.

**Acceptance Criteria:**

**Given** I am on the home screen
**When** the streak counter widget loads
**Then** it should display my current streak count (e.g., "🔥 12 jours de suite!")
**And** the count should be fetched from the streak repository via Riverpod provider
**And** the UI should load in under 500ms (NFR2)

**Given** my streak is greater than 0
**When** the counter is displayed
**Then** it should show a fire emoji (🔥) or similar motivational icon
**And** the text should be clear and readable (meeting NFR19 contrast ratio)

**Given** my streak is 0
**When** the counter is displayed
**Then** it should show an encouraging message (e.g., "Commence ton streak aujourd'hui!")
**And** the message should be motivational, not discouraging

**Given** I complete my bag preparation
**When** the BagCompletions table is updated
**Then** the streak counter should automatically refresh to show the updated count
**And** the update should happen via Riverpod provider invalidation
**And** there should be a visual feedback (animation or flash) indicating the streak increased

**Given** the streak counter is displayed
**When** I tap on it
**Then** it should navigate to a detailed streak view showing history or explanation
**And** the tap target should be at least 44x44pt (NFR21)

### Story 2.6: Implement "Bag Ready" Confirmation

As a student,
I want to see a clear and satisfying confirmation when I complete my bag preparation,
So that I feel accomplished and confident that my bag is ready for tomorrow.

**Acceptance Criteria:**

**Given** I am checking off supplies for tomorrow
**When** I check the last unchecked supply
**Then** the system should detect that all supplies for tomorrow are now checked
**And** a "Bag Ready" confirmation screen should appear immediately

**Given** the "Bag Ready" confirmation appears
**When** I view the screen
**Then** it should display a clear message (e.g., "Ton sac est prêt pour demain! 🎒")
**And** it should show the date for which the bag is prepared (e.g., "Prêt pour mardi 12 mars")
**And** it should display my updated streak count

**Given** the "Bag Ready" confirmation is triggered
**When** the confirmation is shown
**Then** a new row should be inserted in `BagCompletions` table with date=tomorrow, completedAt=now
**And** this insertion should trigger streak recalculation
**And** the streak counter should update in real-time

**Given** I see the "Bag Ready" confirmation
**When** I tap the dismiss button or swipe to close
**Then** the confirmation should close and return me to the previous screen
**And** my checklist should still show all items as checked

**Given** I complete my bag preparation
**When** the "Bag Ready" confirmation triggers the second notification scheduled for later
**Then** the second reminder notification should be automatically cancelled (Story 3.3 dependency)

**Given** the "Bag Ready" screen is displayed
**When** the app is in accessibility mode (screen reader)
**Then** the confirmation should be announced clearly via VoiceOver/TalkBack (NFR22)
**And** all interactive elements should be accessible

### Story 2.7: Implement Streak Break Detection & Reset

As a student,
I want to see an encouraging message when my streak breaks,
So that I feel motivated to start again rather than discouraged.

**Acceptance Criteria:**

**Given** I had a streak of 15 school days
**When** a school day ends and I haven't completed my bag preparation
**Then** the system should detect the streak is broken
**And** the next time I open the app, I should see a streak break message

**Given** my streak has broken
**When** the break message is displayed
**Then** it should show my previous streak length (e.g., "Tu avais un streak de 15 jours!")
**And** it should include an encouraging message (e.g., "Recommence aujourd'hui et bat ton record!")
**And** the tone should be positive and motivational, not guilt-inducing

**Given** the streak break message is shown
**When** I acknowledge the message
**Then** my current streak should reset to 0
**And** the previous streak length should be stored in the database for future reference
**And** I should be returned to the home screen

**Given** my streak is reset to 0
**When** I complete my next bag preparation
**Then** my streak should start fresh at 1
**And** the streak counter should update accordingly

**Given** I have broken multiple streaks in the past
**When** I view my streak history (if such a screen exists)
**Then** I should be able to see my best streak and previous streaks
**And** this data should motivate me to beat my personal best

### Story 2.8: Implement Tomorrow's Schedule Detection

As a developer,
I want the system to accurately determine which courses the student has tomorrow,
So that the checklist and notifications show the correct supplies needed.

**Acceptance Criteria:**

**Given** the student has a timetable configured
**When** the system calculates tomorrow's schedule
**Then** it should query the existing `calendar_courses` Drift table for tomorrow's date
**And** it should respect the week type (A/B/both) using the existing WeekUtils
**And** the query should complete in under 500ms (NFR2)

**Given** tomorrow is a school day with classes
**When** the system retrieves tomorrow's courses
**Then** it should return a list of courses with their associated supplies
**And** supplies should be grouped by subject/course
**And** the list should be ordered by time (first class first)

**Given** tomorrow is a weekend
**When** the system checks for tomorrow's courses
**Then** it should return an empty list
**And** no checklist should be displayed
**And** no notifications should be scheduled (FR15)

**Given** tomorrow is a weekday but the student has no classes (holiday, day off)
**When** the system checks the timetable
**Then** it should detect no classes and return an empty list
**And** the system should suppress the checklist and notifications

**Given** the student's timetable uses week A/B alternation
**When** the system determines tomorrow's schedule
**Then** it should correctly calculate whether tomorrow is week A or week B
**And** it should only return courses marked for that week or "both"

**Given** tomorrow's schedule changes (student edits timetable)
**When** the checklist is recalculated
**Then** the supply list should update immediately to reflect the new schedule
**And** previously checked supplies for removed courses should be cleared

### Story 2.9: Enhance Notification with Contextual Text

As a student,
I want my evening reminder notification to tell me what I need to prepare,
So that I know exactly what's needed without opening the app first.

**Acceptance Criteria:**

**Given** I have set my bag preparation reminder time to 7pm
**When** 7pm arrives and I have classes tomorrow
**Then** a notification should fire with contextual content
**And** the notification title should include tomorrow's date or day name (e.g., "Prépare ton sac pour demain")
**And** the notification body should list tomorrow's subjects (e.g., "Demain tu as Maths, Français et Histoire-Géo. 9 fournitures à préparer.")

**Given** I have many courses tomorrow (more than 3-4)
**When** the notification is composed
**Then** the subject list should be summarized (e.g., "Demain tu as 6 matières. 15 fournitures à préparer.")
**And** the full detail should be visible when I open the app

**Given** tomorrow is a weekend or holiday
**When** the notification scheduling runs
**Then** no notification should be sent (FR15)
**And** the notification scheduler should detect this via Story 2.8's tomorrow schedule detection

**Given** I have classes tomorrow
**When** the notification content is generated
**Then** it should use the existing `NotificationService` in the common module
**And** it should query tomorrow's courses from Story 2.8
**And** it should count the total supplies needed by summing supplies across all tomorrow's courses

**Given** the notification is scheduled
**When** it fires at my chosen time
**Then** the notification should appear within ±1 minute of the scheduled time (NFR15)
**And** tapping the notification should open the app to the checklist screen

**Given** I have already completed my bag preparation for tomorrow
**When** the primary notification time arrives
**Then** the notification should still fire (to remind/confirm)
**And** the notification text could optionally indicate "Ton sac est déjà prêt!" if BagCompletions exists

### Story 2.10: Integrate Streak with Bag Completion Workflow

As a developer,
I want to ensure the entire flow from checklist to streak increment works seamlessly end-to-end,
So that students experience a cohesive and reliable bag preparation habit loop.

**Acceptance Criteria:**

**Given** all previous stories in Epic 2 are implemented
**When** I perform an end-to-end test of the bag preparation workflow
**Then** the following sequence should work flawlessly:
1. Open app, see tomorrow's supply checklist (Story 2.3)
2. Check supplies one by one, each persists immediately (Story 2.3)
3. Check the last supply, "Bag Ready" confirmation appears (Story 2.6)
4. Streak counter increments by 1 (Story 2.4, Story 2.5)
5. Second notification scheduled for later is auto-cancelled (Story 2.6 + Epic 3)

**Given** the workflow is complete
**When** the student closes and reopens the app
**Then** the checklist should still show all items as checked (Story 2.3)
**And** the streak counter should display the updated count (Story 2.5)
**And** the "Bag Ready" state should persist until the next day

**Given** a new day begins (midnight passes)
**When** the student opens the app
**Then** yesterday's checklist state should be archived
**And** today's checklist should be fresh with no items checked
**And** tomorrow's schedule should be recalculated (Story 2.8)
**And** notifications should be rescheduled for today's preparation time (Story 2.9)

**Given** the entire Epic 2 feature set is live
**When** the student uses the app over multiple days
**Then** streak calculation should be accurate across weekends and holidays (Story 2.4)
**And** notifications should only fire on days with upcoming classes (Story 2.9, FR15)
**And** all data should sync to Supabase when online while working fully offline (NFR14)

**Given** the integration is complete
**When** I run the full test suite
**Then** all unit tests for streak calculation should pass
**And** all integration tests for the bag completion workflow should pass
**And** no performance regressions should occur (all NFR1-NFR5 targets met)

## Epic 3: Enhanced Retention with Double Reminder

Students never miss bag preparation thanks to a smart second reminder that fires only when needed and auto-cancels when the task is complete.

### Story 3.1: Implement User-Configurable Reminder Time

As a student,
I want to set my preferred bag preparation time,
So that the reminder fits my evening routine.

**Acceptance Criteria:**

**Given** I am in the app settings or onboarding
**When** I access the reminder time configuration
**Then** I should see a time picker to select my preferred bag preparation time
**And** the default time should be 7:00 PM if not previously set

**Given** I select a reminder time (e.g., 8:30 PM)
**When** I save the setting
**Then** the time should be persisted to local preferences (PreferencesService in common)
**And** the notification scheduler should use this time for the primary reminder

**Given** I have configured my reminder time
**When** I change it to a different time
**Then** the new time should take effect immediately
**And** any scheduled notifications should be rescheduled with the new time

**Given** the reminder time is set
**When** the app calculates the second reminder time
**Then** it should automatically be set to user_time + 1 hour (e.g., 8:30 PM → 9:30 PM)
**And** the second reminder delay should be configurable in the architecture but fixed in V2

### Story 3.2: Implement Double Reminder Logic

As a student,
I want to receive a second reminder if I haven't prepared my bag after the first one,
So that I don't forget even if I'm distracted.

**Acceptance Criteria:**

**Given** my primary reminder time is 7:00 PM
**When** the notification scheduler runs for tomorrow's bag preparation
**Then** it should schedule TWO local notifications:
1. Primary reminder at 7:00 PM with contextual text (Epic 2 Story 2.9)
2. Second reminder at 8:00 PM with urgent text (e.g., "Tu as encore X fournitures à préparer pour demain!")

**Given** both notifications are scheduled
**When** the primary reminder fires at 7:00 PM
**Then** it should appear with tomorrow's subjects and supply count
**And** the second reminder should remain scheduled for 8:00 PM

**Given** the primary reminder has fired
**When** the student does not complete their bag preparation
**Then** the second reminder should fire at 8:00 PM as scheduled
**And** the second reminder should include the supply count (e.g., "Tu as encore 9 fournitures à préparer!")
**And** the tone should be more urgent but still encouraging

**Given** the second reminder fires
**When** the student taps the notification
**Then** the app should open directly to the checklist screen
**And** the student should be able to complete their bag preparation

**Given** the second reminder is scheduled
**When** tomorrow has no classes (weekend, holiday)
**Then** the second reminder should also be suppressed (FR15)
**And** no second reminder should fire

### Story 3.3: Implement Auto-Cancel on Bag Completion

As a student,
I want the second reminder to be automatically cancelled if I complete my bag preparation after the first reminder,
So that I don't receive unnecessary notifications.

**Acceptance Criteria:**

**Given** the primary reminder has fired at 7:00 PM
**When** I complete my bag preparation at 7:30 PM (before the second reminder)
**Then** the "Bag Ready" confirmation should appear (Epic 2 Story 2.6)
**And** the second reminder scheduled for 8:00 PM should be automatically cancelled

**Given** I complete my bag preparation before any reminders fire
**When** the bag completion is detected
**Then** both the primary and second reminders for today should be cancelled
**And** no notifications should fire that evening

**Given** the second reminder is cancelled
**When** the scheduled time (8:00 PM) arrives
**Then** no notification should appear
**And** the notification ID should be cleared from the scheduled notifications list

**Given** I complete my bag preparation after the second reminder fires
**When** the "Bag Ready" confirmation is shown
**Then** no further reminders should be scheduled for today
**And** tomorrow's reminders should be scheduled normally

**Given** the auto-cancel mechanism is implemented
**When** bag completion triggers the cancellation
**Then** the cancellation should use the notification service in common
**And** the specific notification ID for the second reminder should be cancelled (ID range 1000-1099 per architecture)

## Epic 4: Premium Personalization & Monetization

Students can express their personality by customizing the app with personal background images, creating emotional attachment while validating the first revenue stream.

### Story 4.1: Create Premium Module Foundation

As a developer,
I want to create the new `features/premium/` module with proper structure,
So that all premium-related functionality is organized and follows existing patterns.

**Acceptance Criteria:**

**Given** the project has existing feature modules
**When** I create `features/premium/`
**Then** it should follow the standard module structure: lib/presentation/, lib/repository/, lib/models/, lib/di/
**And** it should have a `pubspec.yaml` with dependencies on common and `in_app_purchase` plugin
**And** it should have a `claude.md` documenting the module's purpose, IAP integration, and key files

**Given** the module structure is created
**When** I implement the base repository
**Then** `premium_repository.dart` should be created with methods for purchase, restoration, and status checking
**And** it should use the `Either<Failure, T>` pattern
**And** it should interact with the `in_app_purchase` plugin

**Given** the repository is implemented
**When** I create the Riverpod providers
**Then** `riverpod_di.dart` should export `@riverpod` annotated providers for premium functionality
**And** a `premiumStatusProvider` should be created in common for global access
**And** running `build_runner` should generate the provider code successfully

### Story 4.2: Integrate In-App Purchase for 0.99€

As a student,
I want to purchase the personalization upgrade for 0.99€,
So that I can unlock custom background features.

**Acceptance Criteria:**

**Given** I am on the premium/personalization screen
**When** the screen loads
**Then** it should display the premium features (custom backgrounds for timetable and Mon Sac)
**And** it should show the price (0.99€) fetched from the store
**And** it should show a "Buy" button if I haven't purchased

**Given** I tap the "Buy" button
**When** the purchase flow initiates
**Then** the native store payment sheet (App Store or Google Play) should appear
**And** the purchase should be processed through the store's native IAP system

**Given** the purchase is successful
**When** the store confirms the transaction
**Then** the purchase should be recorded locally in the `PremiumStatus` Drift table (hasPurchased=true)
**And** the `premiumStatusProvider` should update to reflect premium status
**And** a success message should be displayed to the student
**And** the premium features should immediately become available

**Given** the purchase fails (cancelled, insufficient funds, etc.)
**When** the store returns an error
**Then** an appropriate error message should be displayed
**And** the student should remain on the premium screen with the option to retry

**Given** the purchase is completed
**When** the app is online
**Then** a Firebase Analytics event `premium_purchased` should be logged (Epic 6)
**And** the event should include no PII (NFR9)

**Given** the IAP system is implemented
**When** store receipts are validated
**Then** validation should use store-signed receipts only (NFR11)
**And** no custom payment processing should be used

### Story 4.3: Implement Purchase Restoration

As a student,
I want to restore my premium purchase if I reinstall the app or switch devices,
So that I don't have to pay again.

**Acceptance Criteria:**

**Given** I previously purchased premium on this Apple ID / Google account
**When** I reinstall the app or install on a new device
**Then** I should see a "Restore Purchase" button on the premium screen

**Given** I tap "Restore Purchase"
**When** the restoration process runs
**Then** the app should query the store for previous purchases
**And** if a valid 0.99€ non-consumable purchase is found, it should be restored

**Given** the restoration is successful
**When** the purchase is verified
**Then** the `PremiumStatus` table should be updated (hasPurchased=true)
**And** the `premiumStatusProvider` should update
**And** a success message should be displayed (e.g., "Achat restauré!")
**And** premium features should become available immediately

**Given** no previous purchase is found
**When** the restoration completes
**Then** a message should inform the student (e.g., "Aucun achat trouvé")
**And** the student should remain on the premium screen with the option to purchase

**Given** the restoration process is running
**When** the store is queried
**Then** the process should complete within 5 seconds
**And** a loading indicator should be displayed during the process

### Story 4.4: Implement Background Image Picker

As a premium student,
I want to select a custom background image from my photo gallery,
So that I can personalize my app experience.

**Acceptance Criteria:**

**Given** I have premium status (hasPurchased=true or linkedParentId exists)
**When** I access the background customization screen
**Then** I should see options to customize the timetable background and Mon Sac background separately

**Given** I tap "Change Timetable Background"
**When** the image picker opens
**Then** it should use the `image_picker` Flutter plugin
**And** I should be able to browse my photo gallery
**And** I should be able to select an image

**Given** I select an image
**When** the image is chosen
**Then** the app should copy the image to the app's local storage directory
**And** the file path should be saved in the `PremiumStatus` Drift table (new column: timetableBackgroundPath)
**And** the image should not be synced to Supabase (privacy-first, local only)

**Given** the image is saved
**When** I return to the customization screen
**Then** I should see a preview of my selected background
**And** I should have the option to change it again or remove it

**Given** I am not a premium user
**When** I access the background customization screen
**Then** I should see a message prompting me to purchase premium
**And** the image picker should not be accessible

### Story 4.5: Apply Custom Backgrounds to Screens

As a premium student,
I want my custom background images to appear on the timetable and Mon Sac screens,
So that my app reflects my personal style.

**Acceptance Criteria:**

**Given** I have set a custom timetable background
**When** I navigate to the timetable/calendar screen
**Then** my custom background should be displayed behind the timetable content
**And** the background should be loaded from the local file path stored in `PremiumStatus`
**And** the timetable content should remain readable over the background (ensure contrast or overlay)

**Given** I have set a custom Mon Sac background
**When** I navigate to the supply checklist screen
**Then** my custom background should be displayed behind the checklist
**And** the checklist items should remain clearly visible and usable

**Given** I have not set a custom background (or I removed it)
**When** I view the timetable or Mon Sac screens
**Then** the default background (solid color or gradient) should be displayed
**And** the app should function normally

**Given** my custom background image is lost (e.g., file deleted, storage cleared)
**When** the app tries to load the background
**Then** it should gracefully fallback to the default background
**And** no crash or error should occur

**Given** I reinstall the app
**When** I restore my premium purchase
**Then** my premium status is restored BUT my custom backgrounds are lost (local storage only)
**And** I should be able to re-select images (acceptable for 0.99€)

### Story 4.6: Implement Premium Status Provider

As a developer,
I want a centralized Riverpod provider that determines premium status,
So that all parts of the app can check premium access consistently.

**Acceptance Criteria:**

**Given** the `premiumStatusProvider` is implemented in common
**When** the provider is queried
**Then** it should return `true` if `hasPurchased == true` OR `linkedParentId != null`
**And** it should return `false` otherwise

**Given** the student purchases premium
**When** the `PremiumStatus` table is updated
**Then** the `premiumStatusProvider` should automatically invalidate and refresh
**And** all UI watching the provider should update immediately

**Given** a parent links to the student's account (Epic 5)
**When** the `linkedParentId` is set in `PremiumStatus`
**Then** the `premiumStatusProvider` should resolve as premium (true)
**And** the student should have access to premium features without purchasing

**Given** the app launches
**When** the provider initializes
**Then** it should check Supabase for parent linking status (query `parent_links` table with student_device_id)
**And** if a parent is linked, update `linkedParentId` in local `PremiumStatus` table
**And** this check should happen on app launch and on network reconnect

**Given** the app is offline
**When** the premium status is checked
**Then** it should use the cached value from the local `PremiumStatus` Drift table
**And** premium features should work fully offline (NFR14)

## Epic 5: Anonymous Parent-Child Linking Foundations

Parents can link to their child's bag preparation progress while preserving complete student anonymity, laying the foundation for future parent premium features.

### Story 5.1: Create Parenting Module and Supabase Parent Links Table

As a developer,
I want to create the `features/parenting/` module and the Supabase `parent_links` table,
So that the foundation for anonymous parent-child linking is in place.

**Acceptance Criteria:**

**Given** the project has existing feature modules
**When** I create `features/parenting/`
**Then** it should follow the standard module structure: lib/presentation/, lib/repository/, lib/models/, lib/di/
**And** it should have a `pubspec.yaml` with dependencies on common
**And** it should have a `claude.md` documenting the anonymous pairing system

**Given** the module is created
**When** I implement the Supabase schema
**Then** a new table `parent_links` should be created with columns:
- id (UUID primary key)
- pairing_code (VARCHAR(6), unique, indexed)
- student_device_id (TEXT, indexed)
- parent_device_id (TEXT, nullable initially)
- uses_count (INTEGER, default 0, max 2-3)
- created_at (TIMESTAMP)
- linked_at (TIMESTAMP, nullable)
**And** no personal data (names, emails) should be stored in this table (NFR6)

**Given** the table is created
**When** I implement the repository
**Then** `pairing_repository.dart` should have methods for:
- generatePairingCode()
- checkPairingCodeExists()
- linkParentToCode()
- incrementUsesCount()
**And** all methods should use `Either<Failure, T>` pattern

### Story 5.2: Implement Pairing Code Generation (Student Side)

As a student,
I want to generate a pairing code that my parent can use to link to my account,
So that my parent can see my bag preparation status while I remain anonymous.

**Acceptance Criteria:**

**Given** I am on the settings or parent linking screen
**When** I tap "Generate Pairing Code"
**Then** the app should generate a random 6-character alphanumeric code (reuse existing code pattern from sharing module)
**And** the code should be non-guessable (random, not sequential) (NFR10)

**Given** the code is generated
**When** the code is saved
**Then** a new row should be inserted in Supabase `parent_links` table with:
- pairing_code = generated code
- student_device_id = my device ID
- parent_device_id = null
- uses_count = 0
**And** the insert should be queued via SyncManager if offline

**Given** the code is created
**When** I view the pairing screen
**Then** the 6-character code should be displayed prominently (large, readable font)
**And** I should have the option to share the code via text, messaging, or show it to my parent directly
**And** the code should remain valid until used 2-3 times (as per FR31)

**Given** I generate a pairing code
**When** the code is displayed
**Then** it should NOT contain any personal information about me (no name, no email) (FR32)
**And** my anonymity should be fully preserved

### Story 5.3: Implement Pairing Code Entry (Data Model Only)

As a developer,
I want to create the data model for parent code entry and linking,
So that the architecture supports future parent app features.

**Acceptance Criteria:**

**Given** the `parent_links` table exists
**When** a parent enters a pairing code (future parent app)
**Then** the system should query Supabase for the code
**And** if the code exists and uses_count < 3, allow the linking

**Given** a valid code is entered by a parent
**When** the linking is confirmed
**Then** the `parent_links` row should update:
- parent_device_id = parent's device ID
- uses_count = uses_count + 1
- linked_at = current timestamp
**And** the student_device_id should remain unchanged (preserves anonymity)

**Given** the code has been used 3 times
**When** a 4th parent tries to use the code
**Then** the linking should be rejected
**And** an error message should indicate the code is no longer valid

**Given** the parent names the child on their side (future parent app)
**When** the name is entered
**Then** the name should be stored in the parent's local device storage (SharedPreferences) ONLY
**And** the name should NEVER be sent to Supabase or the student's device (FR30)
**And** the student remains fully anonymous

### Story 5.4: Implement Premium Unlock via Parent Link

As a student,
I want to automatically get premium features if my parent has a premium subscription,
So that I can customize my app without paying myself.

**Acceptance Criteria:**

**Given** a parent has linked to my student account
**When** the app checks my premium status
**Then** the `premiumStatusProvider` should query the `parent_links` table for my student_device_id
**And** if a row exists with parent_device_id set, premium should be unlocked (FR27)

**Given** my parent is linked but doesn't have premium yet (V2.5 future)
**When** my parent subscribes to parent premium
**Then** my student account should automatically unlock premium features
**And** I should see a notification or message indicating "Premium unlocked by parent"

**Given** premium is unlocked via parent link
**When** I access premium features (custom backgrounds)
**Then** I should have full access without purchasing myself
**And** the background customization should work identically to Story 4.4-4.5

**Given** the parent link check is implemented
**When** the app is offline
**Then** the check should use cached `linkedParentId` from local `PremiumStatus` Drift table
**And** premium features should continue to work offline

**Given** the app launches or regains connectivity
**When** the premium status is refreshed
**Then** the app should query Supabase `parent_links` to check if a new parent has linked
**And** if a new parent is found, update `linkedParentId` in local `PremiumStatus`
**And** invalidate `premiumStatusProvider` to refresh UI

### Story 5.5: Add Parent Linking UI to Student App

As a student,
I want to access the parent linking feature from the settings screen,
So that I can generate a code and share it with my parent.

**Acceptance Criteria:**

**Given** I am on the settings screen
**When** I view the menu options
**Then** I should see a "Parent Linking" or "Lien avec un parent" option
**And** the option should be accessible to all students (not premium-only)

**Given** I tap the "Parent Linking" option
**When** the screen opens
**Then** I should see an explanation of the feature:
- Parents can see your bag preparation status
- You remain fully anonymous
- Parents can unlock premium for you
**And** I should see a "Generate Code" button

**Given** I tap "Generate Code"
**When** the code is generated (Story 5.2)
**Then** the code should be displayed prominently
**And** I should have options to:
- Copy the code to clipboard
- Share via messaging apps
- Show the code to my parent directly (QR code optional)

**Given** I have already generated a code
**When** I return to the parent linking screen
**Then** I should see my existing code
**And** I should see how many times it has been used (e.g., "Utilisé 1 fois sur 3")
**And** I should have the option to generate a new code (invalidates the old one)

**Given** a parent has linked using my code
**When** I view the parent linking screen
**Then** I should see a confirmation message (e.g., "Un parent est connecté")
**And** I should NOT see the parent's name or any identifying information (preserves anonymity)

## Epic 6: Analytics & Measurement Infrastructure

Product owner can measure user engagement, retention, and conversion to make data-driven product decisions and improve student success.

### Story 6.1: Firebase Analytics Setup and Configuration

As a developer,
I want to integrate Firebase Analytics into the app,
So that we can start tracking user events while respecting privacy constraints.

**Acceptance Criteria:**

**Given** the app is a Flutter project
**When** I add Firebase Analytics dependencies
**Then** `firebase_core` and `firebase_analytics` should be added to `pubspec.yaml`
**And** the packages should be compatible with the existing Flutter version

**Given** Firebase dependencies are added
**When** I configure Firebase for Android
**Then** `google-services.json` should be placed in `android/app/`
**And** Firebase should be initialized in the Android app lifecycle

**Given** Firebase dependencies are added
**When** I configure Firebase for iOS
**Then** `GoogleService-Info.plist` should be placed in `ios/Runner/`
**And** Firebase should be initialized in the iOS app lifecycle

**Given** Firebase is configured
**When** the app launches
**Then** Firebase Analytics should initialize automatically
**And** no personally identifiable information (PII) should be collected (NFR9)
**And** device_id should be the only identifier used

**Given** Firebase is initialized
**When** the app is offline
**Then** Analytics events should be buffered locally
**And** events should be uploaded automatically when connectivity returns (FR35, NFR9)

### Story 6.2: Create AnalyticsService with Domain Extensions

As a developer,
I want a centralized AnalyticsService with typed domain extensions,
So that analytics events are consistent, safe, and cannot accidentally leak PII.

**Acceptance Criteria:**

**Given** the common module exists
**When** I create `analytics_service.dart`
**Then** it should have a private `_log()` method that is the single point touching Firebase Analytics
**And** the `_log()` method should accept event name and parameters map

**Given** the base AnalyticsService is created
**When** I implement domain extensions
**Then** the following extension classes should be created:
- `AnalyticsBag` (bag preparation events)
- `AnalyticsStreak` (streak events)
- `AnalyticsPremium` (IAP events)
- `AnalyticsOnboarding` (onboarding events)

**Given** domain extensions exist
**When** I implement typed methods in each extension
**Then** all methods should have closed, typed parameters (no free-form strings)
**And** methods should prevent accidental PII leakage by design

**Given** the AnalyticsService is complete
**When** any part of the app needs to log an event
**Then** it should call a typed method from the appropriate extension (e.g., `AnalyticsBag.logCompleted()`)
**And** it should NEVER call Firebase Analytics directly

**Given** all analytics events use snake_case naming
**When** events are logged
**Then** event names should follow the pattern: `bag_completed`, `streak_milestone`, `premium_purchased` (per architecture)
**And** parameter names should also use snake_case: `supply_count`, `streak_length`, `step_name`

### Story 6.3: Instrument Bag Preparation Events

As a product owner,
I want to track bag preparation completion events,
So that I can measure daily active usage and habit formation.

**Acceptance Criteria:**

**Given** a student completes their bag preparation
**When** the "Bag Ready" confirmation is triggered (Epic 2 Story 2.6)
**Then** the event `bag_completed` should be logged via `AnalyticsBag.logCompleted()`
**And** parameters should include:
- supply_count (int): number of supplies checked
- date (string): the date for which the bag was prepared
- time_taken (int): seconds between first check and completion (optional)

**Given** a student checks an individual supply
**When** the supply is marked as checked
**Then** the event `supply_checked` should be logged via `AnalyticsBag.logSupplyChecked()`
**And** parameters should include:
- supply_category (string): type of supply if available (e.g., "notebook", "textbook")
- course_type (string): subject category (e.g., "math", "language")

**Given** analytics events are logged
**When** the events are sent to Firebase
**Then** no PII should be included (NFR9)
**And** device_id should be the only identifier
**And** no student names, emails, or location data should be present

### Story 6.4: Instrument Streak Events

As a product owner,
I want to track streak milestones and breaks,
So that I can understand user engagement and habit retention.

**Acceptance Criteria:**

**Given** a student reaches a streak milestone (e.g., 5, 10, 20, 30 days)
**When** the milestone is detected
**Then** the event `streak_milestone` should be logged via `AnalyticsStreak.logMilestone()`
**And** parameters should include:
- streak_length (int): the milestone reached (e.g., 10)
- milestone_type (string): "bronze", "silver", "gold" (optional categorization)

**Given** a student's streak breaks
**When** the break is detected (Epic 2 Story 2.7)
**Then** the event `streak_broken` should be logged via `AnalyticsStreak.logBroken()`
**And** parameters should include:
- previous_streak (int): the streak length before breaking

**Given** a student starts a new streak after a break
**When** they complete their first bag prep after breaking
**Then** the event `streak_restarted` should be logged via `AnalyticsStreak.logRestarted()`
**And** parameters should include:
- previous_best (int): their best streak to date

### Story 6.5: Instrument Premium Purchase Events

As a product owner,
I want to track premium purchases and conversions,
So that I can measure monetization success and optimize the premium offering.

**Acceptance Criteria:**

**Given** a student successfully purchases premium (Epic 4 Story 4.2)
**When** the purchase is confirmed by the store
**Then** the event `premium_purchased` should be logged via `AnalyticsPremium.logPurchased()`
**And** parameters should include:
- price (string): "0.99"
- currency (string): "EUR"
- product_id (string): the IAP product identifier

**Given** a student changes their background image
**When** the custom background is saved (Epic 4 Story 4.4)
**Then** the event `background_changed` should be logged via `AnalyticsPremium.logBackgroundChanged()`
**And** parameters should include:
- screen (string): "timetable" or "mon_sac"

**Given** a student restores their premium purchase
**When** the restoration is successful (Epic 4 Story 4.3)
**Then** the event `premium_restored` should be logged via `AnalyticsPremium.logRestored()`

### Story 6.6: Instrument Onboarding Events

As a product owner,
I want to track onboarding completion and drop-off rates,
So that I can optimize the first-time user experience.

**Acceptance Criteria:**

**Given** a student starts the onboarding flow
**When** the onboarding screen loads
**Then** the event `onboarding_started` should be logged via `AnalyticsOnboarding.logStarted()`

**Given** a student completes an onboarding step
**When** they proceed to the next step
**Then** the event `onboarding_step_completed` should be logged via `AnalyticsOnboarding.logStepCompleted()`
**And** parameters should include:
- step_name (string): "school_year_selection", "notification_time", "timetable_import", etc.
- step_number (int): ordinal position in the flow

**Given** a student completes the entire onboarding flow
**When** they reach the home screen for the first time
**Then** the event `onboarding_completed` should be logged via `AnalyticsOnboarding.logCompleted()`

**Given** a student imports a timetable via code/QR during onboarding
**When** the import is successful
**Then** the event `import_used` should be logged via `AnalyticsOnboarding.logImportUsed()`
**And** parameters should include:
- import_method (string): "code" or "qr"

## Epic 7: Accessibility & Inclusive Design

All students, including those with visual impairments or dyslexia, can use the app fully through dynamic type support, screen reader compatibility, and optimized touch targets.

### Story 7.1: Implement Dynamic Type Support

As a student with visual impairment or dyslexia,
I want the app to respect my system font size settings,
So that I can read all text comfortably.

**Acceptance Criteria:**

**Given** I have configured a larger font size in my device settings (iOS or Android)
**When** I open the app
**Then** all text should scale according to my system font size preference (NFR20)
**And** the text should remain readable and not be cut off

**Given** I have increased my font size significantly (e.g., 150%-200%)
**When** I view the checklist screen
**Then** all supply names, course names, and buttons should scale appropriately
**And** the layout should adjust to accommodate larger text (wrapping, expanded containers)

**Given** I have decreased my font size
**When** I view any screen
**Then** the text should scale down appropriately
**And** the UI should remain visually balanced

**Given** dynamic type is enabled
**When** I view the streak counter widget
**Then** the streak count number should scale with dynamic type
**And** it should remain centered and visually prominent

**Given** dynamic type is implemented
**When** I change my system font size while the app is open
**Then** the app should respond to the change immediately (hot reload)
**And** all screens should update their text sizing

### Story 7.2: Add Screen Reader Labels and Hints

As a blind or visually impaired student,
I want to navigate the app using VoiceOver (iOS) or TalkBack (Android),
So that I can use all core features independently.

**Acceptance Criteria:**

**Given** I have VoiceOver or TalkBack enabled
**When** I navigate to the supply checklist screen
**Then** each supply item should have a clear label read aloud (e.g., "Cahier de Mathématiques, non coché")
**And** the checkbox state should be announced (checked or unchecked)

**Given** I am using a screen reader
**When** I tap on a supply checkbox
**Then** the action should be announced (e.g., "Cahier de Mathématiques, coché")
**And** the checkbox state should update and be announced

**Given** I am using a screen reader
**When** I view the "Bag Ready" confirmation screen
**Then** the confirmation message should be announced automatically
**And** the streak count should be read aloud clearly

**Given** I am using a screen reader
**When** I navigate the home screen
**Then** the streak counter should have a semantic label (e.g., "Ton streak actuel : 12 jours de suite")
**And** it should be focusable and readable

**Given** I am using a screen reader
**When** I navigate to the premium background customization screen
**Then** all buttons and options should have clear labels
**And** the "Buy" button should announce the price and action

**Given** core flows are accessible (FR42, NFR22)
**When** I complete the bag preparation workflow using only a screen reader
**Then** I should be able to:
- Navigate the checklist
- Check all supplies
- Receive the "Bag Ready" confirmation
- View my updated streak count
All without needing visual feedback

### Story 7.3: Optimize Touch Target Sizes

As a student with motor difficulties or using a small screen,
I want all interactive elements to be large enough to tap easily,
So that I don't accidentally tap the wrong thing.

**Acceptance Criteria:**

**Given** any interactive element exists in the app
**When** I view the element
**Then** its touch target should be at least 44x44pt (iOS) or 48x48dp (Android) (NFR21, FR43)

**Given** I am viewing the supply checklist
**When** I look at the checkboxes
**Then** each checkbox should have a touch target of at least 44x44pt
**And** there should be sufficient spacing between checkboxes to prevent accidental taps

**Given** I am viewing the streak counter on the home screen
**When** I tap on it
**Then** the entire widget should be tappable (not just the text)
**And** the tap target should be at least 44x44pt

**Given** I am on the premium screen
**When** I view the "Buy" button
**Then** the button should have a large, easy-to-tap target (minimum 44x44pt)
**And** the button should have clear visual boundaries

**Given** I am viewing the notification settings
**When** I interact with the time picker or any control
**Then** all controls should meet minimum touch target sizes
**And** controls should be easy to manipulate without precision

### Story 7.4: Verify WCAG AA Contrast Ratios

As a student with low vision or color blindness,
I want all text and UI elements to have sufficient contrast,
So that I can read and use the app comfortably.

**Acceptance Criteria:**

**Given** the app uses a dark theme
**When** I view any screen
**Then** all text should meet WCAG AA contrast ratio of at least 4.5:1 against its background (NFR19)
**And** this applies to all text: body, buttons, labels, input fields

**Given** I view the supply checklist
**When** supplies are displayed
**Then** the text should have sufficient contrast against the background
**And** if a custom background is used (Epic 4), an overlay or shadow should ensure text remains readable

**Given** I view the "Bag Ready" confirmation screen
**When** the confirmation message appears
**Then** the text should be clearly readable with high contrast
**And** any decorative elements should not interfere with readability

**Given** I view the streak counter widget
**When** the streak count is displayed
**Then** the number and accompanying text should have high contrast
**And** the fire emoji or icon should be clearly visible

**Given** information is conveyed using color
**When** I view any UI element
**Then** color should NOT be the only way to convey information (NFR23)
**And** text, icons, or patterns should provide redundant cues
**And** this applies to checked/unchecked states, success/error messages, etc.

**Given** the app is tested for accessibility
**When** I run accessibility audits (iOS Accessibility Inspector, Android Accessibility Scanner)
**Then** all contrast issues should be flagged and fixed
**And** the app should pass WCAG AA standards for contrast

<!-- for each AC on this story -->

**Given** {{precondition}}
**When** {{action}}
**Then** {{expected_outcome}}
**And** {{additional_criteria}}

<!-- End story repeat -->
