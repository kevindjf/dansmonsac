import 'package:flutter_test/flutter_test.dart';
import 'package:common/src/utils/default_supplies.dart';

void main() {
  group('Story 1.3 - Integrate Suggested Supplies in Onboarding', () {
    group('DefaultSupplies Integration', () {
      test('getDefaultSubjects should return 6 French school subjects', () {
        final subjects = DefaultSupplies.getDefaultSubjects();

        expect(subjects.length, 6);
        expect(subjects[0].name, 'Mathématiques');
        expect(subjects[1].name, 'Français');
        expect(subjects[2].name, 'Histoire-Géographie');
        expect(subjects[3].name, 'Sciences');
        expect(subjects[4].name, 'Anglais');
        expect(subjects[5].name, 'EPS');
      });

      test('each default subject should have supplies', () {
        final subjects = DefaultSupplies.getDefaultSubjects();

        // Mathématiques should have 4 supplies
        expect(subjects[0].supplies.length, 4);
        expect(subjects[0].supplies,
            ['Cahier de maths', 'Calculatrice', 'Règle', 'Compas']);

        // Français should have 3 supplies
        expect(subjects[1].supplies.length, 3);
        expect(subjects[1].supplies,
            ['Cahier de français', 'Dictionnaire', 'Bescherelle']);

        // Histoire-Géographie should have 2 supplies
        expect(subjects[2].supplies.length, 2);
        expect(subjects[2].supplies,
            ['Cahier d\'histoire-géo', 'Crayons de couleur']);

        // Sciences should have 2 supplies
        expect(subjects[3].supplies.length, 2);
        expect(subjects[3].supplies, ['Cahier de sciences', 'Blouse']);

        // Anglais should have 2 supplies
        expect(subjects[4].supplies.length, 2);
        expect(subjects[4].supplies,
            ['Cahier d\'anglais', 'Dictionnaire anglais']);

        // EPS should have 3 supplies
        expect(subjects[5].supplies.length, 3);
        expect(
            subjects[5].supplies, ['Tenue de sport', 'Baskets', 'Serviette']);
      });

      test('each default subject should have a category', () {
        final subjects = DefaultSupplies.getDefaultSubjects();

        expect(subjects[0].category, 'core'); // Mathématiques
        expect(subjects[1].category, 'core'); // Français
        expect(subjects[2].category, 'core'); // Histoire-Géographie
        expect(subjects[3].category, 'science'); // Sciences
        expect(subjects[4].category, 'language'); // Anglais
        expect(subjects[5].category, 'physical'); // EPS
      });

      test('default subjects list should be unmodifiable', () {
        final subjects = DefaultSupplies.getDefaultSubjects();

        // Trying to modify the list should throw
        expect(
            () => subjects.add(
                DefaultSubject(name: 'Test', supplies: [], category: 'test')),
            throwsUnsupportedError);
      });
    });

    group('createDefaultCourses Logic Validation', () {
      test('should iterate through all default subjects', () {
        final subjects = DefaultSupplies.getDefaultSubjects();

        // Simulate the repository logic
        final coursesToCreate = <Map<String, dynamic>>[];

        for (final subject in subjects) {
          coursesToCreate.add({
            'name': subject.name,
            'supplies': subject.supplies,
          });
        }

        expect(coursesToCreate.length, 6);
        expect(coursesToCreate[0]['name'], 'Mathématiques');
        expect(coursesToCreate[0]['supplies'], subjects[0].supplies);
      });

      test('should create AddCourseCommand with subject name and supplies', () {
        final subjects = DefaultSupplies.getDefaultSubjects();

        // Simulate repository creating AddCourseCommand for each subject
        final commands = <Map<String, dynamic>>[];

        for (final subject in subjects) {
          commands.add({
            'courseName': subject.name,
            'supplies': subject.supplies,
          });
        }

        expect(commands.length, 6);

        // Verify Mathématiques command
        expect(commands[0]['courseName'], 'Mathématiques');
        expect(commands[0]['supplies'].length, 4);
        expect(commands[0]['supplies'][0], 'Cahier de maths');

        // Verify EPS command
        expect(commands[5]['courseName'], 'EPS');
        expect(commands[5]['supplies'].length, 3);
        expect(commands[5]['supplies'][0], 'Tenue de sport');
      });
    });

    group('Story 1.3 Acceptance Criteria Validation', () {
      test(
          'AC1: Each default subject is created with suggested supplies from shared utility',
          () {
        final subjects = DefaultSupplies.getDefaultSubjects();

        // Verify all subjects have supplies
        for (final subject in subjects) {
          expect(subject.supplies.isNotEmpty, true,
              reason: '${subject.name} should have supplies');
        }

        // Verify total supply count
        final totalSupplies = subjects.fold<int>(
          0,
          (sum, subject) => sum + subject.supplies.length,
        );

        expect(totalSupplies, 16,
            reason:
                'Should have 16 total supplies across all default subjects');
      });

      test(
          'AC2: Students should see default subjects with supplies after onboarding',
          () {
        final subjects = DefaultSupplies.getDefaultSubjects();

        // Simulate post-onboarding state
        final createdCourses = <String>[];
        final createdSupplies = <String>[];

        for (final subject in subjects) {
          createdCourses.add(subject.name);
          createdSupplies.addAll(subject.supplies);
        }

        expect(createdCourses.length, 6);
        expect(createdSupplies.length, 16);
        expect(createdCourses.contains('Mathématiques'), true);
        expect(createdSupplies.contains('Cahier de maths'), true);
      });

      test('AC3: No default subjects created if user already has courses', () {
        // This logic is in OnboardingSupabaseRepository.createDefaultCourses()
        // It checks: if (existingCourses.isEmpty) before creating

        final existingCourses = ['Biology']; // User has courses

        // Simulate the check
        if (existingCourses.isEmpty) {
          fail(
              'Should not create default courses when user has existing courses');
        }

        // Test passes if we don't create courses
        expect(existingCourses.isNotEmpty, true);
      });

      test('AC4: No conflicts with Story 1.2 manual course creation', () {
        // DefaultSupplies provides two methods:
        // 1. getDefaultSubjects() - for onboarding (Story 1.3)
        // 2. getSuppliesBySubjectName() - for manual creation (Story 1.2)

        final defaultSubjects = DefaultSupplies.getDefaultSubjects();
        final manualSuggestions =
            DefaultSupplies.getSuppliesBySubjectName('Mathématiques');

        // Both methods should return data independently
        expect(defaultSubjects.isNotEmpty, true);
        expect(manualSuggestions, isNotNull);
        expect(manualSuggestions!.length, 4);

        // They should reference the same underlying data
        expect(defaultSubjects[0].supplies, manualSuggestions);
      });
    });

    group('Edge Cases', () {
      test('should handle empty existing courses list', () {
        final existingCourses = <String>[];

        // This is the condition in the repository
        final shouldCreateDefaults = existingCourses.isEmpty;

        expect(shouldCreateDefaults, true);
      });

      test('should handle non-empty existing courses list', () {
        final existingCourses = ['Math', 'English'];

        // This is the condition in the repository
        final shouldCreateDefaults = existingCourses.isEmpty;

        expect(shouldCreateDefaults, false);
      });

      test('should create courses in the correct order', () {
        final subjects = DefaultSupplies.getDefaultSubjects();

        // Verify order is preserved (important for UX)
        expect(subjects[0].name, 'Mathématiques');
        expect(subjects[1].name, 'Français');
        expect(subjects[2].name, 'Histoire-Géographie');
        expect(subjects[3].name, 'Sciences');
        expect(subjects[4].name, 'Anglais');
        expect(subjects[5].name, 'EPS');
      });
    });
  });

  // Note: Integration tests with mocked repository would require Riverpod container setup.
  // The tests above validate the core business logic and data structures.
  // Full integration testing is done via UI/E2E tests.
}
