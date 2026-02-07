# Story 1.1: Extract Default Supplies Utility

Status: done

<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

As a developer,
I want to extract DefaultCourses data to a shared utility module,
so that supply suggestions can be reused across onboarding and course creation flows.

## Acceptance Criteria

**AC1: Create shared utility in common module**

**Given** the DefaultCourses data exists in the onboarding module (`features/onboarding/lib/src/data/default_courses.dart`)
**When** I create the file `features/common/lib/src/utils/default_supplies.dart`
**Then** it should contain a reusable data structure with default subjects and their associated supplies
**And** the data structure should include subject name, typical supplies list, and subject category
**And** the file should export a public API for accessing default supplies by subject name

**AC2: Refactor onboarding module to use shared utility**

**Given** the utility is created
**When** the onboarding module is refactored
**Then** it should import and use the new shared utility from common
**And** no functionality should break in the existing onboarding flow
**And** `flutter pub run build_runner build --delete-conflicting-outputs` should complete successfully
**And** all existing tests should pass

## Tasks / Subtasks

- [x] Create `features/common/lib/src/utils/default_supplies.dart` with improved data structure (AC: #1)
  - [x] Define strongly-typed model class for default subject data (name, supplies list, category)
  - [x] Extract existing data from `DefaultCourses.frenchSchoolSubjects` and convert to new structure
  - [x] Add public API methods: `getDefaultSubjects()`, `getSuppliesBySubjectName(String name)`
  - [x] Export from `features/common/lib/src/utils.dart`

- [x] Update onboarding module to use shared utility (AC: #2)
  - [x] Add dependency on common utils in onboarding module
  - [x] Refactor `OnboardingSupabaseRepository.createDefaultCourses()` to use new utility
  - [x] Remove old `features/onboarding/lib/src/data/default_courses.dart` file
  - [x] Update imports in all affected files

- [x] Run build_runner and verify no regressions (AC: #2)
  - [x] Execute `flutter pub run build_runner build --delete-conflicting-outputs`
  - [x] Verify build completes successfully with no errors
  - [x] Run existing onboarding tests to ensure no functionality broke
  - [x] Manually test onboarding flow: verify default courses are created correctly

## Dev Notes

### Epic Context

**Epic 1: Onboarding Enhancement with Suggested Supplies**
- This story is the **foundation** for the entire epic
- Extracts reusable supply data that will be used in Story 1.2 (supply suggestions at course creation) and Story 1.3 (onboarding integration)
- **Critical technical debt resolution**: DefaultCourses is currently locked in the onboarding module, making it inaccessible to other modules like course creation

### Current Implementation Analysis

**Current Location:** `features/onboarding/lib/src/data/default_courses.dart`
```dart
class DefaultCourses {
  static const List<Map<String, dynamic>> frenchSchoolSubjects = [
    {'name': 'Mathématiques', 'supplies': ['Cahier de maths', 'Calculatrice', 'Règle', 'Compas']},
    {'name': 'Français', 'supplies': ['Cahier de français', 'Dictionnaire', 'Bescherelle']},
    {'name': 'Histoire-Géographie', 'supplies': ['Cahier d\'histoire-géo', 'Crayons de couleur']},
    {'name': 'Sciences', 'supplies': ['Cahier de sciences', 'Blouse']},
    {'name': 'Anglais', 'supplies': ['Cahier d\'anglais', 'Dictionnaire anglais']},
    {'name': 'EPS', 'supplies': ['Tenue de sport', 'Baskets', 'Serviette']},
  ];
}
```

**Current Usage:** `features/onboarding/lib/src/repositories/onboarding_supabase_repository.dart:66`
```dart
for (final course in DefaultCourses.frenchSchoolSubjects) {
  await courseRepository.store(AddCourseCommand(
    course['name'] as String,
    (course['supplies'] as List).cast<String>(),
  ));
}
```

**Problems with current implementation:**
1. Uses `Map<String, dynamic>` (untyped) → requires type casting at usage sites
2. Locked in onboarding module → inaccessible to course module for Story 1.2
3. No subject category information → limits future extensibility
4. No public API → direct access to internal constant

### Architecture Requirements

**Module Structure:** [Architecture.md Section: Project Structure & Boundaries]
- New file location: `features/common/lib/src/utils/default_supplies.dart`
- Export from: `features/common/lib/src/utils.dart`
- Pattern: Utility classes in `common/utils/` are static and stateless

**Naming Conventions:** [Architecture.md Section: Implementation Patterns]
- File name: `default_supplies.dart` (snake_case) ✓
- Class name: `DefaultSupplies` (PascalCase) ✓
- Method names: camelCase (e.g., `getDefaultSubjects()`) ✓

**Code Generation:**
- No `@riverpod` annotations needed → no build_runner changes for this file
- BUT onboarding module refactor might touch other files → run build_runner at end

### Technical Requirements

**Strongly-Typed Data Model:**
Create a proper Dart class instead of `Map<String, dynamic>`:
```dart
class DefaultSubject {
  final String name;
  final List<String> supplies;
  final String category; // e.g., 'core', 'science', 'physical'

  const DefaultSubject({
    required this.name,
    required this.supplies,
    required this.category,
  });
}
```

**Public API Design:**
```dart
class DefaultSupplies {
  /// Returns all default French school subjects with supplies
  static List<DefaultSubject> getDefaultSubjects() { ... }

  /// Returns supplies for a specific subject name (case-insensitive match)
  /// Returns null if subject not found
  static List<String>? getSuppliesBySubjectName(String name) { ... }

  // Private: actual data storage
  static const List<DefaultSubject> _frenchSchoolSubjects = [ ... ];
}
```

**Export from utils.dart:**
Add to `features/common/lib/src/utils.dart`:
```dart
export 'utils/default_supplies.dart';
```

### File Structure Requirements

**Files to CREATE:**
- `features/common/lib/src/utils/default_supplies.dart` - New shared utility

**Files to MODIFY:**
- `features/common/lib/src/utils.dart` - Add export
- `features/onboarding/lib/src/repositories/onboarding_supabase_repository.dart:66` - Update import and usage
- `features/onboarding/lib/src/repositories/onboarding_supabase_repository.dart:13` - Remove old import

**Files to DELETE:**
- `features/onboarding/lib/src/data/default_courses.dart` - No longer needed

**Grep results show these files import DefaultCourses:**
```
features/onboarding/lib/src/repositories/onboarding_supabase_repository.dart:13
features/onboarding/lib/src/repositories/onboarding_repository.dart (interface - no import)
features/onboarding/lib/src/presentation/notifications/notification_permission_page.dart (false positive - different context)
```

Only `onboarding_supabase_repository.dart` needs refactoring.

### Testing Requirements

**Unit Tests:**
- Create `features/common/test/utils/default_supplies_test.dart`
  - Test `getDefaultSubjects()` returns expected count (6 subjects)
  - Test `getSuppliesBySubjectName('Mathématiques')` returns correct supplies
  - Test `getSuppliesBySubjectName('mathematics')` case-insensitive match works
  - Test `getSuppliesBySubjectName('NonExistent')` returns null
  - Test all subject names and supplies match original data

**Integration Tests:**
- Verify onboarding flow still creates default courses correctly
- Check that courses are created in Drift database with correct supplies
- Ensure Supabase sync works (via SyncManager)

**Regression Testing:**
- Run existing onboarding tests: Ensure no failures
- Manual test: Complete onboarding flow, verify 6 default courses appear
- Manual test: Check course list shows all subjects with correct supplies

### Implementation Guidance

**Step-by-Step Plan:**

1. **Create new utility** (Red phase for TDD):
   - Write failing tests first in `features/common/test/utils/default_supplies_test.dart`
   - Create `default_supplies.dart` with empty implementations
   - Run tests → should fail

2. **Implement utility** (Green phase):
   - Define `DefaultSubject` class with const constructor
   - Populate `_frenchSchoolSubjects` with all 6 subjects from original data
   - Add categories: 'core' for Math/French/History, 'science' for Sciences, 'language' for Anglais, 'physical' for EPS
   - Implement `getDefaultSubjects()` → return copy of list
   - Implement `getSuppliesBySubjectName()` → case-insensitive lookup
   - Run tests → should pass

3. **Export from utils.dart**:
   - Add export statement to `features/common/lib/src/utils.dart`

4. **Refactor onboarding repository** (Green phase continues):
   - Change import in `onboarding_supabase_repository.dart` line 13:
     - FROM: `import '../data/default_courses.dart';`
     - TO: `import 'package:common/src/utils.dart';`
   - Update `createDefaultCourses()` method line 66:
     - FROM: `for (final course in DefaultCourses.frenchSchoolSubjects) {`
     - TO: `for (final subject in DefaultSupplies.getDefaultSubjects()) {`
   - Update line 67-68:
     - FROM: `course['name'] as String` and `(course['supplies'] as List).cast<String>()`
     - TO: `subject.name` and `subject.supplies` (no casting needed!)

5. **Delete old file**:
   - Remove `features/onboarding/lib/src/data/default_courses.dart`

6. **Run build_runner**:
   - `flutter pub run build_runner build --delete-conflicting-outputs`
   - Verify no errors

7. **Run tests and manual verification**:
   - Run unit tests for new utility
   - Run existing onboarding tests
   - Manual test: onboarding flow

### Known Gotchas & Edge Cases

1. **Case-insensitive matching:** Subject names in course creation UI might not match exact case → implement `toLowerCase()` comparison
2. **Accents in French:** Ensure UTF-8 encoding preserved (e.g., "Mathématiques", "Géographie")
3. **Build runner:** If any file in onboarding module uses `@riverpod`, build_runner must succeed
4. **Import path:** Use `package:common/src/utils.dart` NOT `../../common/lib/src/utils.dart`

### Previous Story Intelligence

N/A - This is the first story in Epic 1.

### Git Intelligence

Recent commits show:
- `1011a2d` - Import page design variants (not related)
- `ebdec01` - Push all modifications (not specific)
- `3df3f3d` - Build runner command added (good reference - same command needed here!)
- `3f5441a` - Offline-first architecture infrastructure (relevant - maintain sync patterns)
- `34b9569` - Architecture design (source of requirements)

**Patterns observed:**
- Project uses build_runner regularly for code generation
- Offline-first pattern is critical (SyncManager, PendingOperations)
- Recent work on architecture consistency

### References

**All technical details cited:**

- [Source: _bmad-output/planning-artifacts/epics.md#Epic 1: Story 1.1]
- [Source: _bmad-output/planning-artifacts/architecture.md#Implementation Patterns & Consistency Rules]
- [Source: _bmad-output/planning-artifacts/architecture.md#Module Architecture]
- [Source: CLAUDE.md#Code Generation]
- [Source: features/onboarding/lib/src/data/default_courses.dart:2-29]
- [Source: features/onboarding/lib/src/repositories/onboarding_supabase_repository.dart:66-71]

## Dev Agent Record

### Agent Model Used

Story created by: claude-sonnet-4-5-20250929 (Dev Agent Amelia)
Story implemented by: claude-sonnet-4-5-20250929 (Dev Agent Amelia)

### Debug Log References

None - Implementation completed without blocking issues

### Completion Notes List

✅ **TDD Red-Green-Refactor cycle followed:**
- RED: Created comprehensive unit tests (13 tests) first - all failed as expected
- GREEN: Implemented DefaultSubject model and DefaultSupplies utility - all tests passed
- REFACTOR: Code is clean, strongly-typed, eliminates casting needs

✅ **Implementation completed:**
- Created strongly-typed `DefaultSubject` model with const constructor
- Implemented `DefaultSupplies` utility with public API methods
- Added 6 French school subjects with categories (core, science, language, physical)
- Case-insensitive subject name lookup working correctly
- All French accents preserved (UTF-8)

✅ **Refactoring completed:**
- Onboarding repository now uses `DefaultSupplies.getDefaultSubjects()`
- Eliminated all type casting (`as String`, `.cast<String>()`)
- Code is cleaner and type-safe

✅ **Tests passing:**
- 13/13 unit tests passed for default_supplies utility
- All tests verify data integrity and API functionality
- Build runner completed successfully (4 outputs generated)

✅ **All acceptance criteria met:**
- AC1: Shared utility created with reusable data structure ✓
- AC2: Onboarding refactored, old file deleted, build_runner passed ✓

### File List

**Files created:**
- features/common/lib/src/utils/default_supplies.dart
- features/common/test/utils/default_supplies_test.dart

**Files modified:**
- features/common/lib/src/utils.dart (added export)
- features/onboarding/lib/src/repositories/onboarding_supabase_repository.dart (refactored to use new utility)

**Files deleted:**
- features/onboarding/lib/src/data/default_courses.dart

### Change Log

- 2026-02-07: Story created with comprehensive context and implementation guidance
- 2026-02-07: Story implemented - TDD approach, all tests passing, ready for review
- 2026-02-07: Code review completed - Kevin validated implementation manually, status updated to done

### Review Notes

**Code Review Findings (2026-02-07):**
- Implementation quality validated by Kevin (product owner)
- Code follows architecture patterns correctly
- Tests comprehensive (13/13 passing)
- Acceptance criteria met

**Git Workflow Issue Identified:**
- Story was implemented on branch `features/new-sharing-screen` (shared branch with other changes)
- 59 modified files in branch, only 5 related to this story
- **Action for future stories:** Create dedicated git branch per story (e.g., `feature/1-1-extract-default-supplies-utility`)
- **Rule added:** If agent cannot create branch, ask Kevin to create it before starting implementation

**Recommendation for Next Stories:**
1. Always create dedicated feature branch from `staging` before starting
2. Branch naming: `feature/{story-key}` (e.g., `feature/1-2-supply-suggestions`)
3. Keep branches focused on single story for clean reviews
4. Commit atomically after completing each story
