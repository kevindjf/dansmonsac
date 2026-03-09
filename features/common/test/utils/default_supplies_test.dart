import 'package:flutter_test/flutter_test.dart';
import 'package:common/src/utils/default_supplies.dart';

void main() {
  group('DefaultSupplies', () {
    group('getDefaultSubjects', () {
      test('should return 6 default French school subjects', () {
        final subjects = DefaultSupplies.getDefaultSubjects();

        expect(subjects.length, 6);
      });

      test('should return subjects with correct names', () {
        final subjects = DefaultSupplies.getDefaultSubjects();
        final names = subjects.map((s) => s.name).toList();

        expect(names, contains('Mathématiques'));
        expect(names, contains('Français'));
        expect(names, contains('Histoire-Géographie'));
        expect(names, contains('Sciences'));
        expect(names, contains('Anglais'));
        expect(names, contains('EPS'));
      });

      test('should return subjects with supplies lists', () {
        final subjects = DefaultSupplies.getDefaultSubjects();

        for (final subject in subjects) {
          expect(subject.supplies, isNotEmpty);
          expect(subject.supplies, isA<List<String>>());
        }
      });

      test('should return subjects with categories', () {
        final subjects = DefaultSupplies.getDefaultSubjects();

        for (final subject in subjects) {
          expect(subject.category, isNotEmpty);
          expect(subject.category, isA<String>());
        }
      });

      test('should preserve original supplies data for Mathématiques', () {
        final subjects = DefaultSupplies.getDefaultSubjects();
        final math = subjects.firstWhere((s) => s.name == 'Mathématiques');

        expect(math.supplies, contains('Cahier de maths'));
        expect(math.supplies, contains('Calculatrice'));
        expect(math.supplies, contains('Règle'));
        expect(math.supplies, contains('Compas'));
        expect(math.supplies.length, 4);
      });

      test('should preserve original supplies data for all subjects', () {
        final subjects = DefaultSupplies.getDefaultSubjects();

        // Français
        final french = subjects.firstWhere((s) => s.name == 'Français');
        expect(french.supplies, contains('Cahier de français'));
        expect(french.supplies, contains('Dictionnaire'));
        expect(french.supplies, contains('Bescherelle'));

        // Histoire-Géographie
        final history =
            subjects.firstWhere((s) => s.name == 'Histoire-Géographie');
        expect(history.supplies, contains('Cahier d\'histoire-géo'));
        expect(history.supplies, contains('Crayons de couleur'));

        // Sciences
        final sciences = subjects.firstWhere((s) => s.name == 'Sciences');
        expect(sciences.supplies, contains('Cahier de sciences'));
        expect(sciences.supplies, contains('Blouse'));

        // Anglais
        final english = subjects.firstWhere((s) => s.name == 'Anglais');
        expect(english.supplies, contains('Cahier d\'anglais'));
        expect(english.supplies, contains('Dictionnaire anglais'));

        // EPS
        final eps = subjects.firstWhere((s) => s.name == 'EPS');
        expect(eps.supplies, contains('Tenue de sport'));
        expect(eps.supplies, contains('Baskets'));
        expect(eps.supplies, contains('Serviette'));
      });
    });

    group('getSuppliesBySubjectName', () {
      test('should return correct supplies for exact match "Mathématiques"',
          () {
        final supplies =
            DefaultSupplies.getSuppliesBySubjectName('Mathématiques');

        expect(supplies, isNotNull);
        expect(supplies, contains('Cahier de maths'));
        expect(supplies, contains('Calculatrice'));
        expect(supplies, contains('Règle'));
        expect(supplies, contains('Compas'));
      });

      test(
          'should return correct supplies for case-insensitive match "mathématiques"',
          () {
        final supplies =
            DefaultSupplies.getSuppliesBySubjectName('mathématiques');

        expect(supplies, isNotNull);
        expect(supplies, contains('Cahier de maths'));
        expect(supplies, contains('Calculatrice'));
      });

      test(
          'should return correct supplies for case-insensitive match "FRANÇAIS"',
          () {
        final supplies = DefaultSupplies.getSuppliesBySubjectName('FRANÇAIS');

        expect(supplies, isNotNull);
        expect(supplies, contains('Cahier de français'));
        expect(supplies, contains('Dictionnaire'));
      });

      test('should return null for non-existent subject', () {
        final supplies =
            DefaultSupplies.getSuppliesBySubjectName('NonExistent');

        expect(supplies, isNull);
      });

      test('should return null for empty string', () {
        final supplies = DefaultSupplies.getSuppliesBySubjectName('');

        expect(supplies, isNull);
      });

      test('should handle accents correctly in case-insensitive search', () {
        final supplies1 =
            DefaultSupplies.getSuppliesBySubjectName('Histoire-Géographie');
        final supplies2 =
            DefaultSupplies.getSuppliesBySubjectName('histoire-géographie');

        expect(supplies1, isNotNull);
        expect(supplies2, isNotNull);
        expect(supplies1, equals(supplies2));
      });
    });

    group('DefaultSubject model', () {
      test('should be immutable with const constructor', () {
        const subject = DefaultSubject(
          name: 'Test',
          supplies: ['Item 1', 'Item 2'],
          category: 'test',
        );

        expect(subject.name, 'Test');
        expect(subject.supplies, ['Item 1', 'Item 2']);
        expect(subject.category, 'test');
      });
    });
  });
}
