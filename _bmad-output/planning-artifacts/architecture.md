---
stepsCompleted: [1, 2, 3, 4, 5, 6, 7, 8]
lastStep: 8
status: 'complete'
completedAt: '2026-02-07'
inputDocuments:
  - '_bmad-output/planning-artifacts/prd.md'
  - '_bmad-output/brainstorming/brainstorming-session-2026-02-06.md'
  - 'docs/QUICK_START.md'
  - 'docs/SUPABASE_SETUP.md'
  - 'docs/WEEK_AB_IMPLEMENTATION.md'
  - 'features/common/claude.md'
  - 'features/course/claude.md'
  - 'features/main/claude.md'
  - 'features/onboarding/claude.md'
  - 'features/schedule/claude.md'
  - 'features/sharing/claude.md'
  - 'features/supply/claude.md'
workflowType: 'architecture'
project_name: 'dansmonsac'
user_name: 'Kevin'
date: '2026-02-07'
---

# Architecture Decision Document

_This document builds collaboratively through step-by-step discovery. Sections are appended as we work through each architectural decision together._

## Project Context Analysis

### Requirements Overview

**Functional Requirements (43 FRs across 10 domains):**

| Domain | FRs | Architectural Impact |
|--------|-----|---------------------|
| Bag Preparation & Checklist | FR1-FR5 | Core value loop — local DB query + UI state |
| Streak & Habit Tracking | FR6-FR10 | New entity, school-day detection from timetable, local persistence + sync |
| Notifications & Reminders | FR11-FR15 | Contextual content computation, conditional 2nd reminder with auto-cancel |
| Timetable Management | FR16-FR19 | Existing — extends with import/share (already built) |
| Supply Management | FR20-FR22 | Existing + new suggested supplies utility extraction |
| Personalization & Premium | FR23-FR27 | New IAP module, cross-platform store integration, purchase restoration |
| Parent-Child Linking | FR28-FR32 | New anonymous pairing data model, reuses 6-char code pattern |
| Analytics & Measurement | FR33-FR35 | Firebase Analytics SDK, zero-PII constraint, offline buffering |
| Onboarding & Setup | FR36-FR40 | Existing flow + enhancements (suggested supplies, school year config) |
| Accessibility | FR41-FR43 | Cross-cutting — dynamic type, screen reader, touch targets |

**Non-Functional Requirements (23 NFRs):**

- **Performance (NFR1-NFR5):** Checklist interactions < 100ms, supply list load < 500ms, cold start < 3s, transitions < 300ms, notification scheduling < 1s. All reinforce local-DB-first architecture.
- **Security & Privacy (NFR6-NFR12):** Zero PII from students (device_id only), HTTPS only, no PII in analytics, non-guessable pairing codes, store-signed receipt validation only, no third-party tracking/advertising SDKs.
- **Reliability (NFR13-NFR18):** Streak data survives app lifecycle, all core features work offline, local notifications within +/-1min, sync queue survives restart, local DB is authoritative, graceful Drift migrations.
- **Accessibility (NFR19-NFR23):** WCAG AA contrast (4.5:1), dynamic type support, 44x44pt touch targets, screen reader navigation on core flows, no color-only information.

### Scale & Complexity

- **Primary domain:** Mobile cross-platform (Flutter iOS + Android)
- **Complexity level:** Medium
- **Estimated new architectural components:** 4 (Streak, IAP/Premium, Firebase Analytics, Parent-Child Linking foundations)
- **Existing components to extend:** 3 (Notifications, Onboarding, Supply suggestions)

### Technical Constraints & Dependencies

**Existing Stack (V1 — immovable):**
- Flutter/Dart with modular feature packages (8 modules in `features/`)
- Riverpod with `@riverpod` annotations + build_runner code generation
- Repository pattern with `Either<Failure, T>` (dartz)
- Supabase backend (6 tables: courses, supplies, course_supplies, courses_user, calendar_courses, users_preferences)
- Drift (SQLite) local database — schema version 2 with PendingOperations queue
- SyncManager for offline-first sync
- Week A/B system (WeekUtils, WeekType enum)
- Sharing via 6-char codes + QR + deep links (dansmonsac://share/CODE)
- flutter_local_notifications for push reminders

**New Dependencies Required (V2):**
- firebase_core + firebase_analytics (anonymous event tracking, offline buffering)
- in_app_purchase (student 0.99€ non-consumable — native store validation + restoration)
- image_picker (premium custom backgrounds from photo gallery)

**Known Technical Debt:**
- QR scanner logic duplicated in 2 locations (onboarding + settings)
- DefaultCourses data locked in onboarding module — needs extraction to shared utility

### Cross-Cutting Concerns Identified

1. **Offline-first invariant** — All V2 features (streak, checklist, notifications, premium status cache) must function fully without network. Existing Drift + SyncManager pattern applies.
2. **Privacy invariant (zero PII)** — Affects every component: analytics events, pairing model, IAP receipts, notification content. Must be verified at each integration point.
3. **Notification orchestration** — Computing tomorrow's schedule + supply count, scheduling contextual primary notification, conditional 2nd reminder with auto-cancel on bag completion — forms a cohesive sub-system.
4. **Premium status resolution** — Student is premium if `hasStorePurchase(0.99€) || isLinkedToParent()`. Parent-unlocks-child requires no IAP check on student side, only parent-link verification.
5. **Code generation pipeline** — Every Riverpod provider or Drift table change requires `build_runner`. Must be part of development workflow.
6. **Phased delivery independence** — V2a (streak + analytics), V2b (IAP + double reminder), V2c (parent linking) must be architecturally decoupled to ship independently.

## Starter Template & Dependencies Evaluation

### Primary Technology Domain

Brownfield Flutter mobile app — existing architecture is mature and well-structured. No starter template needed. V2 extends the existing foundation.

### Existing Foundation (Conserved)

| Aspect | Technology | Status |
|--------|-----------|--------|
| Framework | Flutter/Dart | Conserved |
| State management | Riverpod + `@riverpod` + codegen | Conserved |
| Architecture | Feature modules + Repository + Either<Failure, T> | Conserved |
| Local DB | Drift (SQLite) schema v2 | Conserved — incremental migrations |
| Backend | Supabase (PostgreSQL) | Conserved |
| Local notifications | flutter_local_notifications | Conserved — logic to enrich |
| Sharing | QR + 6-char codes + deep links | Conserved |

### New Dependencies for V2

| Dependency | Purpose | Phase | Rationale |
|-----------|---------|-------|-----------|
| `firebase_core` + `firebase_analytics` | Anonymous event tracking | V2a | Industry standard for mobile analytics. Zero-PII compatible. Native offline buffering. Requires google-services.json (Android) + GoogleService-Info.plist (iOS). |
| `in_app_purchase` | Student personalization 0.99€ | V2b | Official Flutter plugin. Non-consumable purchase with native store validation and restoration. No backend needed for this use case. |
| `image_picker` | Premium custom backgrounds | V2b | Official Flutter plugin. Mature, well-maintained. Accesses photo gallery for background image selection. |

### IAP Strategy Decision

**Student premium (0.99€ non-consumable) — V2b:**
- Use `in_app_purchase` official plugin (native StoreKit + Google Play Billing)
- Store handles purchase record and restoration natively — no custom backend
- Client-side validation acceptable for a 0.99€ educational app

**Parent subscription (1.99-2.99€/year) — V2.5:**
- IAP solution to be decided at V2.5 scope (RevenueCat or other)
- Separate decision, not coupled to student IAP

**Parent-unlocks-child premium — V2.5:**
- No IAP verification needed on student side
- Premium status resolved by parent-link check: `isPremium = hasStorePurchase || isLinkedToParent`
- Decoupled from store APIs entirely

## Core Architectural Decisions

### Decision Priority Analysis

**Critical Decisions (Block Implementation):**
1. Data architecture — new Drift tables and Supabase schema
2. Module architecture — new feature modules placement
3. Notification sub-system design
4. Analytics integration pattern
5. Parent-child linking data model
6. Premium background storage strategy

**Deferred Decisions (Post-V2):**
- Parent subscription IAP solution (V2.5)
- FCM setup for parent push notifications (V2.5)
- CI/CD pipeline (future — manual build sufficient for solo dev)

### Data Architecture

**Drift Schema v3 — New Tables:**

| Table | Key Columns | Phase | Purpose |
|-------|------------|-------|---------|
| `DailyChecks` | date, supplyId, courseId, isChecked | V2a | Persist daily checklist state per supply |
| `BagCompletions` | date, completedAt | V2a | One row per completed day — streak history |
| `PremiumStatus` | hasPurchased, linkedParentId | V2b/V2c | Cache premium status for offline use |

**Supabase Schema Extension:**

| Table | Key Columns | Phase | Purpose |
|-------|------------|-------|---------|
| `parent_links` | pairing_code (VARCHAR(6)), student_device_id, parent_device_id, uses_count, created_at | V2c | Anonymous parent-child pairing |

**Data Flow — Bag Completion:**
1. Student checks supplies in UI → `DailyChecks` rows updated (isChecked = true)
2. All supplies for tomorrow checked → insert row in `BagCompletions`
3. Streak calculated from `BagCompletions` history (consecutive school days)
4. `BagCompletions` insert triggers 2nd notification cancellation

**Migration Strategy:**
- Drift schema v2 → v3 via incremental migration
- New tables only (no modification of existing tables)
- Backward compatible — V1 data untouched

### Module Architecture

**New Feature Modules (V2):**

```
features/
├── common/        (enriched: NotificationScheduler, AnalyticsService, premium provider)
├── streak/        (NEW V2a — streak logic, UI, BagCompletions/DailyChecks)
├── premium/       (NEW V2b — IAP, premium status, background images)
├── parenting/     (NEW V2c — pairing codes, parent-child linking)
├── main/          (existing — enrich checklist UI with DailyChecks persistence)
├── course/        (existing)
├── schedule/      (existing)
├── supply/        (existing)
├── onboarding/    (existing — enrich with suggested supplies)
├── sharing/       (existing)
└── splash/        (existing)
```

**Module Dependencies (new):**
- `streak` depends on `common` (DB, analytics)
- `premium` depends on `common` (analytics, premium provider)
- `parenting` depends on `common` (analytics, code generator pattern from sharing)
- `main` depends on `streak` (checklist completion triggers streak update)

### Notification Sub-System

**`NotificationScheduler` in `common/` module:**
- Queries tomorrow's timetable via existing repositories
- Computes supply count for tomorrow
- Composes contextual notification text: "Demain tu as [subjects]. [N] fournitures à préparer."
- Schedules primary notification at user's chosen time
- Schedules conditional 2nd notification at user_time + 1h
- Auto-cancels 2nd notification when `BagCompletions` receives entry for today
- Suppresses all notifications when no classes tomorrow (detected from timetable data)

**Notification IDs:**
- Primary notification: fixed ID (e.g., 1001) — replaced daily
- Second reminder: fixed ID (e.g., 1002) — cancelled by bag completion

### Analytics Integration

**`AnalyticsService` in `common/` — centralized with domain extensions:**

- Base `_log()` method is private — single point touching Firebase Analytics
- Domain extensions organize events by feature area
- Typed methods prevent accidental PII leakage — no free-form string parameters

**Extensions:**
- `AnalyticsBag` — logCompleted, logSupplyChecked
- `AnalyticsStreak` — logMilestone, logBroken
- `AnalyticsPremium` — logPurchased, logBackgroundChanged
- `AnalyticsOnboarding` — logStepCompleted, logImportUsed

**Privacy enforcement:** All event methods are closed (typed parameters only). No method accepts arbitrary strings that could contain PII.

### Parent-Child Linking (V2c Foundations)

**Pairing Flow:**
1. Student generates 6-char pairing code (reuses sharing code pattern)
2. Code stored in Supabase `parent_links` with student_device_id
3. Parent enters code → parent_device_id added to row, uses_count incremented
4. Max 2-3 uses per code (multiple parents/guardians)
5. Parent assigns child's first name locally (SharedPreferences) — never sent to server

**Privacy invariant maintained:**
- Student side: zero PII at all times
- Parent side: child name stored locally only
- Supabase: only device_id pairs + pairing code — no personal data

### Premium Background Storage

**Local storage only (device app directory):**
- Purchase 0.99€ unlocks the capability to customize backgrounds
- Image copied from gallery to app's local storage directory
- Path reference stored in Drift (PremiumStatus or users_preferences)
- Not synced to cloud — consistent with privacy-first philosophy
- Lost on reinstall (acceptable for 0.99€ — user can re-select)

### Decision Impact Analysis

**Implementation Sequence:**
1. V2a: Drift v3 migration (DailyChecks + BagCompletions) → streak module → Firebase Analytics + AnalyticsService → enhanced notification text
2. V2b: premium module (IAP + image_picker) → double reminder logic → NotificationScheduler enrichment
3. V2c: parenting module → Supabase parent_links table → pairing code generation

**Cross-Component Dependencies:**
- `streak` module reads from `schedule`/`course` data (tomorrow's subjects) — read-only dependency
- `NotificationScheduler` reads from `streak` (bag completion state) — for auto-cancel
- `premium` provider in `common` is consumed by UI modules — for conditional rendering
- `AnalyticsService` is consumed by all new modules — fire-and-forget, no coupling

## Implementation Patterns & Consistency Rules

### Established Patterns (V1 — Mandatory for All Agents)

| Category | Convention | Example |
|----------|-----------|---------|
| Dart files | snake_case | `add_course_controller.dart` |
| Classes | PascalCase | `AddCourseController` |
| Variables/functions | camelCase | `courseId`, `fetchCourses()` |
| Drift tables (class) | PascalCase | `class Courses` |
| Drift columns | snake_case | `course_name`, `device_id` |
| Supabase tables | snake_case | `calendar_courses`, `parent_links` |
| Supabase columns | snake_case | `student_device_id`, `uses_count` |
| Module structure | `features/{module}/lib/{presentation, repository, models, di}` | Existing pattern |
| State management | `@riverpod` annotations + codegen | Generates `*.g.dart` |
| Error handling | `Either<Failure, T>` + `handleErrors()` | Repository pattern |
| Services | Static classes in `common` | `LogService.d()`, `PreferencesService` |
| Logging | `LogService` (never `print()`) | `LogService.e('msg', error, stack)` |
| Validation | `Validators` in `common` | `Validators.validateCourseName()` |
| Error messages | `ErrorMessages.getMessageForFailure()` | Centralized |

### New Patterns for V2

#### Analytics Event Naming

All Firebase Analytics events and parameters use **snake_case**:

**Events:**
- `bag_completed`, `supply_checked`
- `streak_milestone`, `streak_broken`
- `premium_purchased`, `background_changed`
- `onboarding_completed`, `import_used`

**Parameters:**
- `supply_count`, `streak_length`, `step_name`, `previous_streak`

**Anti-pattern:** Never use camelCase (`bagCompleted`) or PascalCase (`BagCompleted`) for analytics events.

#### New Module Internal Structure

All new modules (streak, premium, parenting) follow the existing module pattern:

```
features/{module}/
├── lib/
│   ├── presentation/
│   │   ├── controller/
│   │   │   ├── {module}_controller.dart
│   │   │   └── {module}_state.dart
│   │   └── widgets/
│   │       └── {descriptive_name}_widget.dart
│   ├── repository/
│   │   └── {module}_repository.dart
│   ├── models/
│   │   └── {model_name}.dart
│   └── di/
│       └── riverpod_di.dart
├── pubspec.yaml
└── claude.md
```

**Each new module MUST include a `claude.md`** documenting its responsibilities, architecture, key files, and dependencies.

#### Notification ID Ranges

To prevent ID collisions between notification categories:

| Range | Usage | Phase |
|-------|-------|-------|
| 1000-1099 | Daily notifications (primary reminder, double reminder) | V2a/V2b |
| 1100-1199 | Streak notifications (milestones) | V2a |
| 1200-1299 | Reserved for parent notifications | V2.5 |

#### Premium Status Access Pattern

Single Riverpod provider in `common`, consumed uniformly:

```dart
// Correct — always use the provider
final isPremium = ref.watch(premiumStatusProvider);

// Anti-pattern — never check IAP directly in a widget
final purchased = await InAppPurchase.instance.isAvailable(); // WRONG
```

Premium status resolution: `isPremium = hasStorePurchase || isLinkedToParent`

#### Drift Migration Convention

- Each migration increments `schemaVersion` by 1 (v2 → v3)
- Migrations in `AppDatabase.migration` with `case` per version number
- Never delete or modify existing tables in a V2 migration — add only
- New tables must include appropriate indexes
- Run `build_runner` after any Drift table change

### Enforcement Guidelines

**All AI Agents MUST:**

1. Follow existing V1 naming conventions — no exceptions
2. Use `LogService` for all logging — never `print()` or `debugPrint()`
3. Use `handleErrors()` wrapper for all repository async operations
4. Run `build_runner` after modifying any `@riverpod` or Drift annotation
5. Use `AnalyticsService` extensions for event tracking — never call Firebase directly
6. Check `premiumStatusProvider` for premium state — never query IAP directly in UI
7. Include `claude.md` in every new feature module
8. Use `Validators` for input validation — never inline validation logic
9. Use `ErrorMessages.getMessageForFailure()` for user-facing errors
10. Respect edge-to-edge UI rules with `viewPadding.bottom` in bottom sheets

## Project Structure & Boundaries

### Complete Project Directory Structure

```
dansmonsac/
├── lib/
│   └── main.dart                              # App entry point
├── .env                                       # Supabase credentials (gitignored)
├── .env.example                               # Template
├── pubspec.yaml                               # Root dependencies
│
├── features/
│   ├── common/lib/src/
│   │   ├── database/
│   │   │   ├── app_database.dart              # Drift DB — schema v2 → v3
│   │   │   └── app_database.g.dart            # Generated
│   │   ├── services/
│   │   │   ├── log_service.dart
│   │   │   ├── notification_service.dart      # V1 notification logic
│   │   │   ├── preferences_service.dart
│   │   │   ├── rating_service.dart
│   │   │   ├── analytics_service.dart         # NEW V2a — centralized Firebase Analytics
│   │   │   └── notification_scheduler.dart    # NEW V2a — contextual + double reminder
│   │   ├── providers/
│   │   │   ├── database_provider.dart
│   │   │   ├── sync_manager_provider.dart
│   │   │   └── premium_provider.dart          # NEW V2b — isPremium Riverpod provider
│   │   ├── sync/
│   │   │   └── sync_manager.dart
│   │   ├── repository/
│   │   │   └── repository_helper.dart
│   │   ├── models/
│   │   ├── navigation/
│   │   │   └── routes.dart
│   │   ├── ui/
│   │   ├── utils/
│   │   │   ├── validators.dart
│   │   │   ├── error_messages.dart
│   │   │   └── default_supplies.dart          # NEW V2a — extracted from onboarding
│   │   └── di/
│   │
│   ├── streak/                                # NEW MODULE V2a
│   │   ├── lib/
│   │   │   ├── presentation/
│   │   │   │   ├── controller/
│   │   │   │   │   ├── streak_controller.dart
│   │   │   │   │   └── streak_state.dart
│   │   │   │   └── widgets/
│   │   │   │       ├── streak_counter_widget.dart
│   │   │   │       └── bag_ready_widget.dart
│   │   │   ├── repository/
│   │   │   │   └── streak_repository.dart
│   │   │   ├── models/
│   │   │   │   └── streak_data.dart
│   │   │   └── di/
│   │   │       └── riverpod_di.dart
│   │   ├── pubspec.yaml
│   │   └── claude.md
│   │
│   ├── premium/                               # NEW MODULE V2b
│   │   ├── lib/
│   │   │   ├── presentation/
│   │   │   │   ├── controller/
│   │   │   │   │   ├── premium_controller.dart
│   │   │   │   │   └── premium_state.dart
│   │   │   │   └── widgets/
│   │   │   │       └── background_picker_widget.dart
│   │   │   ├── repository/
│   │   │   │   └── premium_repository.dart
│   │   │   ├── models/
│   │   │   │   └── premium_status.dart
│   │   │   └── di/
│   │   │       └── riverpod_di.dart
│   │   ├── pubspec.yaml
│   │   └── claude.md
│   │
│   ├── parenting/                             # NEW MODULE V2c
│   │   ├── lib/
│   │   │   ├── presentation/
│   │   │   │   ├── controller/
│   │   │   │   │   ├── pairing_controller.dart
│   │   │   │   │   └── pairing_state.dart
│   │   │   │   └── widgets/
│   │   │   │       └── pairing_code_widget.dart
│   │   │   ├── repository/
│   │   │   │   └── pairing_repository.dart
│   │   │   ├── models/
│   │   │   │   └── parent_link.dart
│   │   │   └── di/
│   │   │       └── riverpod_di.dart
│   │   ├── pubspec.yaml
│   │   └── claude.md
│   │
│   ├── main/                                  # EXISTING — enriched
│   ├── course/                                # EXISTING — unchanged
│   ├── schedule/                              # EXISTING — unchanged
│   ├── supply/                                # EXISTING — unchanged
│   ├── onboarding/                            # EXISTING — enriched (suggested supplies)
│   ├── sharing/                               # EXISTING — unchanged
│   └── splash/                                # EXISTING — unchanged
│
├── android/
│   └── app/src/main/
│       ├── AndroidManifest.xml
│       └── google-services.json               # NEW V2a — Firebase config
├── ios/
│   └── Runner/
│       ├── Info.plist
│       └── GoogleService-Info.plist            # NEW V2a — Firebase config
└── docs/

```

### Requirements to Structure Mapping

| FR Domain | Module(s) | Key Files |
|-----------|----------|-----------|
| FR1-FR5 Bag & Checklist | `main`, `streak` | `list_supply_page.dart`, `streak_controller.dart` |
| FR6-FR10 Streak | `streak` | `streak_repository.dart`, `streak_counter_widget.dart` |
| FR11-FR15 Notifications | `common` | `notification_scheduler.dart`, `notification_service.dart` |
| FR16-FR19 Timetable | `schedule` (existing) | Unchanged |
| FR20-FR22 Supplies | `supply`, `common` | `default_supplies.dart` (extraction) |
| FR23-FR27 Premium | `premium`, `common` | `premium_controller.dart`, `premium_provider.dart` |
| FR28-FR32 Parent linking | `parenting` | `pairing_controller.dart`, `pairing_repository.dart` |
| FR33-FR35 Analytics | `common` | `analytics_service.dart` + extensions |
| FR36-FR40 Onboarding | `onboarding` (enriched) | Suggested supplies integration |
| FR41-FR43 Accessibility | Cross-cutting | All UI widgets |

### Architectural Boundaries

**Module Communication Rule:** Modules never communicate directly. All inter-module communication goes through `common` (Riverpod providers, Drift DB, services).

**Data Boundaries:**
- Drift DB is the single source of truth for local data (accessed via `databaseProvider`)
- Supabase is the sync target (accessed via repositories with `handleErrors()`)
- Each repository owns its table(s) — no cross-repository table access

**Integration Points:**

| From | To | Mechanism | Direction |
|------|----|-----------|-----------|
| `streak` | `schedule`/`course` data | Riverpod providers (read-only) | Read |
| `main` (checklist) | `streak` (bag completion) | Drift DB insert → provider invalidation | Write |
| `NotificationScheduler` | `streak` (completion state) | Drift DB query | Read |
| `NotificationScheduler` | `schedule` (tomorrow's courses) | Drift DB query | Read |
| All modules | `AnalyticsService` | Static method calls (fire-and-forget) | Write |
| UI modules | `premiumStatusProvider` | Riverpod watch | Read |

**External Integration Points:**

| Service | Purpose | Config Files | Phase |
|---------|---------|-------------|-------|
| Supabase | Data sync + parent_links | `.env` | Existing + V2c |
| Firebase Analytics | Anonymous event tracking | `google-services.json`, `GoogleService-Info.plist` | V2a |
| App Store / Google Play | IAP 0.99€ non-consumable | Store console config | V2b |

## Architecture Validation Results

### Coherence Validation ✅

**Decision Compatibility:**
All technology choices are compatible. Flutter + Drift + Supabase + Riverpod is the proven V1 stack. New additions (Firebase Analytics, in_app_purchase, image_picker) are standard Flutter plugins with no conflicts. Offline-first architecture is preserved — all V2 features work locally.

**Pattern Consistency:**
New modules follow identical patterns to existing ones. AnalyticsService with extensions follows the same static class pattern as LogService. NotificationScheduler in common follows the same placement as NotificationService. All naming conventions are consistent.

**Structure Alignment:**
Project structure supports all decisions. Module boundaries are clear. No circular dependencies. Common module serves as the integration hub, consistent with V1 architecture.

### Requirements Coverage Validation ✅

**Functional Requirements:** 43/43 FRs fully covered

| FR Range | Status | Architecture Support |
|----------|--------|---------------------|
| FR1-FR5 | ✅ | DailyChecks table + streak module |
| FR6-FR10 | ✅ | BagCompletions history + streak calculation |
| FR11-FR15 | ✅ | NotificationScheduler + double reminder + auto-cancel |
| FR16-FR19 | ✅ | Existing (unchanged) |
| FR20-FR22 | ✅ | default_supplies.dart extraction |
| FR23-FR27 | ✅ | premium module + in_app_purchase + local images |
| FR28-FR32 | ✅ | parenting module + parent_links Supabase |
| FR33-FR35 | ✅ | AnalyticsService + extensions |
| FR36-FR40 | ✅ | Onboarding enrichment |
| FR41-FR43 | ✅ | Cross-cutting UI patterns |

**Non-Functional Requirements:** 23/23 NFRs addressed

| NFR Range | Status | Architecture Support |
|-----------|--------|---------------------|
| NFR1-NFR5 (Performance) | ✅ | All critical operations are local Drift queries |
| NFR6-NFR12 (Privacy/Security) | ✅ | Zero PII enforced by typed AnalyticsService + anonymous pairing |
| NFR13-NFR18 (Reliability) | ✅ | Streak survives restart (Drift), offline-first, sync queue persists |
| NFR19-NFR23 (Accessibility) | ✅ | UI patterns defined in enforcement guidelines |

### Gap Analysis Results

**Gaps Found and Resolved:**

1. **(Important — Resolved) Premium provider parent-link check:** The `premiumProvider` must include a Supabase check at app launch and on network reconnect to detect if a parent has linked to the student's device. Simple query: `parent_links.where(student_device_id == myDeviceId).count > 0`. Result cached in Drift `PremiumStatus` table for offline access.

2. **(Important — Resolved) BagCompletions sync to Supabase:** `BagCompletions` must be synced to Supabase via existing SyncManager pattern — this is required for V2.5 parent visibility ("bag ready" status). `DailyChecks` remains local-only (parent only needs done/not-done, not per-supply detail).

3. **(Minor) DefaultCourses extraction:** Moving `DefaultCourses` from onboarding to `common/utils/default_supplies.dart` requires import updates in onboarding module. Low impact, no architectural risk.

**No Critical Gaps Found.**

### Architecture Completeness Checklist

**✅ Requirements Analysis**
- [x] Project context thoroughly analyzed
- [x] Scale and complexity assessed
- [x] Technical constraints identified
- [x] Cross-cutting concerns mapped

**✅ Architectural Decisions**
- [x] Critical decisions documented (6 decisions)
- [x] Technology stack fully specified
- [x] Integration patterns defined
- [x] Performance considerations addressed
- [x] Privacy invariant enforced at every integration point

**✅ Implementation Patterns**
- [x] Naming conventions established (V1 + V2 additions)
- [x] Structure patterns defined (module template)
- [x] Communication patterns specified (via common only)
- [x] Process patterns documented (error handling, logging, validation)
- [x] Enforcement guidelines documented (10 mandatory rules)

**✅ Project Structure**
- [x] Complete directory structure defined
- [x] Component boundaries established
- [x] Integration points mapped
- [x] Requirements to structure mapping complete

### Architecture Readiness Assessment

**Overall Status:** READY FOR IMPLEMENTATION

**Confidence Level:** High

**Key Strengths:**
- Brownfield extension — builds on proven V1 architecture without rewrites
- Clear phased delivery (V2a → V2b → V2c) with architectural independence
- Privacy-first enforced structurally (typed analytics, anonymous pairing, local-only PII)
- Offline-first maintained for all new features
- Single integration hub (common) prevents module coupling

**Areas for Future Enhancement:**
- Parent notification system (FCM) — deferred to V2.5
- Parent subscription IAP solution — deferred to V2.5
- CI/CD pipeline — deferred, manual build sufficient for now
- QR scanner deduplication (existing tech debt) — not V2 blocking

### Implementation Handoff

**AI Agent Guidelines:**
- Follow all architectural decisions exactly as documented
- Use implementation patterns consistently across all components
- Respect project structure and boundaries
- Refer to this document for all architectural questions
- Each new module must include a `claude.md` documenting its purpose

**Implementation Priority (V2a first):**
1. Drift v3 migration — add DailyChecks + BagCompletions tables
2. Create streak module (repository, controller, widgets)
3. Integrate DailyChecks persistence in main/list_supply_page.dart
4. Add Firebase Analytics + AnalyticsService with extensions
5. Enhance NotificationScheduler with contextual text
6. Extract DefaultCourses to common/utils/default_supplies.dart
