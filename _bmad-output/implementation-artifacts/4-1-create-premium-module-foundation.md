# Story 4.1: Create Premium Module Foundation

Status: ready-for-dev

## Story

As a developer,
I want to create the new `features/premium/` module with proper structure,
so that all premium-related functionality is organized and follows existing patterns.

## Acceptance Criteria

1. **AC1 — Module Structure**: `features/premium/` follows the standard module structure: `lib/presentation/`, `lib/repository/`, `lib/di/`, with a `pubspec.yaml` depending on `common` and `in_app_purchase` plugin, and a `claude.md` documenting the module.
2. **AC2 — Base Repository**: `premium_repository.dart` is created with methods for purchase, restoration, and status checking, using the `Either<Failure, T>` pattern and interacting with the `in_app_purchase` plugin.
3. **AC3 — Riverpod Providers**: `riverpod_di.dart` exports `@riverpod` annotated providers for premium functionality. A `premiumStatusProvider` is created in `common` for global access. Running `build_runner` generates the provider code successfully.

## Tasks / Subtasks

- [ ] Task 1: Create premium module directory structure (AC: 1)
  - [ ] 1.1 Create `features/premium/` with subdirectories: `lib/presentation/controller/`, `lib/presentation/widgets/`, `lib/repository/`, `lib/di/`
  - [ ] 1.2 Create `features/premium/pubspec.yaml` with dependency on `common` (path) and `in_app_purchase` (pub.dev)
  - [ ] 1.3 Create `features/premium/claude.md` documenting module purpose, IAP integration, key files
  - [ ] 1.4 Add `features/premium/` to root `pubspec.yaml` path dependencies if needed (check how other modules are referenced)
- [ ] Task 2: Create PremiumRepository (AC: 2)
  - [ ] 2.1 Create `features/premium/lib/repository/premium_repository.dart`
  - [ ] 2.2 Implement abstract class or direct repo with methods: `checkPurchaseStatus()`, `purchasePremium()`, `restorePurchase()`, `isPremium()`
  - [ ] 2.3 Use `Either<Failure, T>` pattern from dartz (match existing repos)
  - [ ] 2.4 Integrate with `in_app_purchase` plugin for store interaction
  - [ ] 2.5 Use `AppDatabase` methods: `getPremiumStatus()`, `setPurchased()`, `setLinkedParent()`
  - [ ] 2.6 Add `LogService` logging at every step (never `print()`)
- [ ] Task 3: Create Riverpod providers (AC: 3)
  - [ ] 3.1 Create `features/premium/lib/di/riverpod_di.dart` with `@riverpod` annotated `premiumRepositoryProvider`
  - [ ] 3.2 Create `features/common/lib/src/providers/premium_provider.dart` with `premiumStatusProvider` that resolves: `hasPurchased == true || linkedParentId != null`
  - [ ] 3.3 The `premiumStatusProvider` must watch the database and auto-invalidate on PremiumStatus table changes
  - [ ] 3.4 Run `build_runner` in both `features/premium/` and `features/common/` to generate `.g.dart` files
- [ ] Task 4: Verify integration (AC: 1, 2, 3)
  - [ ] 4.1 Ensure `build_runner` completes without errors
  - [ ] 4.2 Ensure the project compiles (`flutter analyze` passes)
  - [ ] 4.3 Verify `premiumStatusProvider` is importable from other feature modules

## Dev Notes

### CRITICAL: PremiumStatus Table Already Exists

The Drift database **already has** a `PremiumStatus` table created at schema v3. DO NOT create a new table or migration.

**Existing table** (`features/common/lib/src/database/app_database.dart`, lines 91-102):
```dart
@DataClassName('PremiumStatusEntity')
class PremiumStatus extends Table {
  TextColumn get id => text()();
  BoolColumn get hasPurchased => boolean().withDefault(const Constant(false))();
  TextColumn get linkedParentId => text().nullable()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  @override
  Set<Column> get primaryKey => {id};
}
```

**Existing database methods** (lines 337-359):
- `getPremiumStatus()` — returns single `PremiumStatusEntity`
- `insertPremiumStatus(PremiumStatusCompanion)` — insert
- `updatePremiumStatus(PremiumStatusCompanion)` — update
- `setPurchased(bool)` — set purchase flag
- `setLinkedParent(String?)` — set parent linking

**Current schema version**: 4. Background image path columns (`timetableBackgroundPath`, `monSacBackgroundPath`) will be added in Story 4.4 via migration v5.

### Module Structure to Create

```
features/premium/
├── lib/
│   ├── presentation/
│   │   ├── controller/
│   │   │   └── premium_controller.dart    (Story 4.2)
│   │   └── widgets/
│   │       └── (Story 4.4-4.5)
│   ├── repository/
│   │   └── premium_repository.dart        ← THIS STORY
│   └── di/
│       └── riverpod_di.dart               ← THIS STORY
├── pubspec.yaml                           ← THIS STORY
└── claude.md                              ← THIS STORY
```

### Reference Module: Streak

Follow the **Streak module** pattern exactly (`features/streak/`):

**Repository pattern** (`features/streak/lib/repository/streak_repository.dart`):
```dart
class StreakRepository {
  final AppDatabase _database;
  StreakRepository(this._database);

  Future<Either<Failure, int>> getCurrentStreak() async {
    return handleErrors(() async {
      // ... implementation
    });
  }
}
```

**DI pattern** (`features/streak/lib/di/riverpod_di.dart`):
```dart
@riverpod
StreakRepository streakRepository(Ref ref) {
  final database = ref.watch(databaseProvider);
  return StreakRepository(database);
}
```

### Anti-Patterns to Avoid

- **DO NOT** create a new PremiumStatus database table — it already exists in schema v3
- **DO NOT** add database migration — background columns are for Story 4.4
- **DO NOT** implement the full purchase flow UI — that's Story 4.2
- **DO NOT** implement image picker — that's Story 4.4
- **DO NOT** implement background rendering — that's Story 4.5
- **DO NOT** use `print()` — use `LogService.d()`, `LogService.i()`, `LogService.e()`
- **DO NOT** add Supabase parent link queries — that's Story 4.6/5.4
- **DO NOT** forget `updatedAt` field in any `PremiumStatusCompanion` creation (see MEMORY.md critical pattern)

### Premium Status Provider Design

**Location**: `features/common/lib/src/providers/premium_provider.dart`

```dart
@riverpod
Future<bool> premiumStatus(Ref ref) async {
  final database = ref.watch(databaseProvider);
  final status = await database.getPremiumStatus();
  if (status == null) return false;
  return status.hasPurchased || status.linkedParentId != null;
}
```

This provider:
- Lives in `common` so all feature modules can access it
- Returns `bool` — true if premium (purchased OR parent-linked)
- Watches `databaseProvider` for dependency tracking
- Returns `false` if no PremiumStatus record exists yet
- Works fully offline (reads from local Drift database)

### in_app_purchase Plugin Notes

**Package**: `in_app_purchase` (official Flutter plugin)
- Handles both App Store (iOS) and Google Play (Android)
- Non-consumable purchase type for the 0.99€ unlock
- Uses store-signed receipts for validation (NFR11 — no custom payment processing)
- Supports purchase restoration natively

**For Story 4.1**: The repository should define the method signatures and basic initialization, but the full purchase flow implementation is in Story 4.2.

### pubspec.yaml Template

Follow the pattern from other feature modules (e.g., `features/streak/pubspec.yaml`):
```yaml
name: premium
description: Premium personalization & monetization module
publish_to: 'none'

environment:
  sdk: '>=3.0.0 <4.0.0'
  flutter: '>=3.0.0'

dependencies:
  flutter:
    sdk: flutter
  common:
    path: ../common
  in_app_purchase: ^3.1.0
  dartz: ^0.10.1
  riverpod_annotation: ^2.3.5

dev_dependencies:
  build_runner: ^2.4.6
  riverpod_generator: ^2.3.9
```

Check actual versions used in other feature module pubspec.yaml files to match exactly.

### Cross-Story Context (Epic 4)

| Story | Depends on 4.1 | What it adds |
|-------|----------------|--------------|
| 4.2 | Uses PremiumRepository | Full purchase flow UI + store interaction |
| 4.3 | Uses PremiumRepository | Restore purchase logic |
| 4.4 | Uses premium module | Background image picker + `image_picker` dependency |
| 4.5 | Uses premium provider | Applies backgrounds to timetable/Mon Sac screens |
| 4.6 | Uses premium provider | Centralizes premium resolution logic (purchase OR parent) |

### Cross-Epic Context

- **Epic 5 Story 5.4**: Sets `linkedParentId` when parent links to child → `premiumStatusProvider` returns true
- **Epic 6 Story 6.5**: Logs `premium_purchased`, `premium_restored`, `background_changed` analytics events

### Project Structure Notes

- Feature modules in `features/` directory, each self-contained
- All modules depend on `common` for shared infrastructure (database, providers, services)
- Riverpod with `@riverpod` annotations + `build_runner` code generation
- Dark theme: accent `0xFFB9A0FF`, background `0xFF212121`, surface `0xFF424242`
- `Either<Failure, T>` pattern with `handleErrors()` wrapper from dartz

### References

- [Source: _bmad-output/planning-artifacts/epics.md#Epic-4, Story 4.1]
- [Source: _bmad-output/planning-artifacts/architecture.md#Premium-Module]
- [Source: features/common/lib/src/database/app_database.dart#PremiumStatus, lines 91-102, 337-359]
- [Source: features/streak/lib/repository/streak_repository.dart — reference pattern]
- [Source: features/streak/lib/di/riverpod_di.dart — reference DI pattern]

## Dev Agent Record

### Agent Model Used

### Debug Log References

### Completion Notes List

### File List
