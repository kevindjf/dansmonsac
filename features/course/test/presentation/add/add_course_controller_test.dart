import 'package:flutter_test/flutter_test.dart';
import 'package:course/models/suggested_supply.dart';
import 'package:common/src/utils/default_supplies.dart';

void main() {
  group('Supply Suggestions - DefaultSupplies Integration', () {
    group('Known Subjects', () {
      test('should return suggestions for "Mathématiques"', () {
        final supplies =
            DefaultSupplies.getSuppliesBySubjectName('Mathématiques');
        expect(supplies, isNotNull);
        expect(supplies!.length, 4);
        expect(supplies[0], 'Cahier de maths');
        expect(supplies[1], 'Calculatrice');
        expect(supplies[2], 'Règle');
        expect(supplies[3], 'Compas');
      });

      test('should return suggestions for "Français"', () {
        final supplies = DefaultSupplies.getSuppliesBySubjectName('Français');
        expect(supplies, isNotNull);
        expect(supplies!.length, 3);
        expect(supplies[0], 'Cahier de français');
        expect(supplies[1], 'Dictionnaire');
        expect(supplies[2], 'Bescherelle');
      });

      test('should return suggestions for "Histoire-Géographie"', () {
        final supplies =
            DefaultSupplies.getSuppliesBySubjectName('Histoire-Géographie');
        expect(supplies, isNotNull);
        expect(supplies!.length, 2);
        expect(supplies[0], 'Cahier d\'histoire-géo');
        expect(supplies[1], 'Crayons de couleur');
      });

      test('should return suggestions for "Sciences"', () {
        final supplies = DefaultSupplies.getSuppliesBySubjectName('Sciences');
        expect(supplies, isNotNull);
        expect(supplies!.length, 2);
        expect(supplies[0], 'Cahier de sciences');
        expect(supplies[1], 'Blouse');
      });

      test('should return suggestions for "Anglais"', () {
        final supplies = DefaultSupplies.getSuppliesBySubjectName('Anglais');
        expect(supplies, isNotNull);
        expect(supplies!.length, 2);
        expect(supplies[0], 'Cahier d\'anglais');
        expect(supplies[1], 'Dictionnaire anglais');
      });

      test('should return suggestions for "EPS"', () {
        final supplies = DefaultSupplies.getSuppliesBySubjectName('EPS');
        expect(supplies, isNotNull);
        expect(supplies!.length, 3);
        expect(supplies[0], 'Tenue de sport');
        expect(supplies[1], 'Baskets');
        expect(supplies[2], 'Serviette');
      });
    });

    group('Case Insensitivity', () {
      test('should match "mathématiques" (lowercase)', () {
        final supplies =
            DefaultSupplies.getSuppliesBySubjectName('mathématiques');
        expect(supplies, isNotNull);
        expect(supplies!.length, 4);
        expect(supplies[0], 'Cahier de maths');
      });

      test('should match "MATHÉMATIQUES" (uppercase)', () {
        final supplies =
            DefaultSupplies.getSuppliesBySubjectName('MATHÉMATIQUES');
        expect(supplies, isNotNull);
        expect(supplies!.length, 4);
        expect(supplies[0], 'Cahier de maths');
      });

      test('should match "MaThÉmAtIqUeS" (mixed case)', () {
        final supplies =
            DefaultSupplies.getSuppliesBySubjectName('MaThÉmAtIqUeS');
        expect(supplies, isNotNull);
        expect(supplies!.length, 4);
      });
    });

    group('Accent Insensitivity', () {
      test('should match "mathematiques" (no accents)', () {
        final supplies =
            DefaultSupplies.getSuppliesBySubjectName('mathematiques');
        expect(supplies, isNotNull);
        expect(supplies!.length, 4);
        expect(supplies[0], 'Cahier de maths');
      });

      test('should match "francais" (no accent)', () {
        final supplies = DefaultSupplies.getSuppliesBySubjectName('francais');
        expect(supplies, isNotNull);
        expect(supplies!.length, 3);
        expect(supplies[0], 'Cahier de français');
      });

      test('should match "Histoire-Geographie" (no accents)', () {
        final supplies =
            DefaultSupplies.getSuppliesBySubjectName('Histoire-Geographie');
        expect(supplies, isNotNull);
        expect(supplies!.length, 2);
      });
    });

    group('Aliases', () {
      test('should match "maths" alias to "Mathématiques"', () {
        final supplies = DefaultSupplies.getSuppliesBySubjectName('maths');
        expect(supplies, isNotNull);
        expect(supplies!.length, 4);
        expect(supplies[0], 'Cahier de maths');
      });

      test('should match "math" alias to "Mathématiques"', () {
        final supplies = DefaultSupplies.getSuppliesBySubjectName('math');
        expect(supplies, isNotNull);
        expect(supplies!.length, 4);
      });

      test('should match "MATHS" (uppercase alias)', () {
        final supplies = DefaultSupplies.getSuppliesBySubjectName('MATHS');
        expect(supplies, isNotNull);
        expect(supplies!.length, 4);
      });

      test('should match "hg" alias to "Histoire-Géographie"', () {
        final supplies = DefaultSupplies.getSuppliesBySubjectName('hg');
        expect(supplies, isNotNull);
        expect(supplies!.length, 2);
      });

      test('should match "svt" alias to "Sciences"', () {
        final supplies = DefaultSupplies.getSuppliesBySubjectName('svt');
        expect(supplies, isNotNull);
        expect(supplies!.length, 2);
      });

      test('should match "sport" alias to "EPS"', () {
        final supplies = DefaultSupplies.getSuppliesBySubjectName('sport');
        expect(supplies, isNotNull);
        expect(supplies!.length, 3);
        expect(supplies[0], 'Tenue de sport');
      });
    });

    group('Unknown Subjects', () {
      test('should return null for unknown subject', () {
        final supplies =
            DefaultSupplies.getSuppliesBySubjectName('Unknown Subject');
        expect(supplies, isNull);
      });

      test('should return null for empty string', () {
        final supplies = DefaultSupplies.getSuppliesBySubjectName('');
        expect(supplies, isNull);
      });
    });
  });

  group('SuggestedSupply Model', () {
    test('should create supply with correct properties', () {
      final supply = SuggestedSupply(
        name: 'Test Supply',
        isChecked: true,
        isModified: false,
      );

      expect(supply.name, 'Test Supply');
      expect(supply.isChecked, true);
      expect(supply.isModified, false);
    });

    test('should copyWith correctly', () {
      final supply = SuggestedSupply(
        name: 'Original',
        isChecked: true,
        isModified: false,
      );

      final updated = supply.copyWith(isChecked: false);

      expect(updated.name, 'Original');
      expect(updated.isChecked, false);
      expect(updated.isModified, false);
    });

    test('should copyWith name and mark as modified', () {
      final supply = SuggestedSupply(
        name: 'Original',
        isChecked: true,
        isModified: false,
      );

      final updated = supply.copyWith(
        name: 'Modified',
        isModified: true,
      );

      expect(updated.name, 'Modified');
      expect(updated.isChecked, true);
      expect(updated.isModified, true);
    });

    test('should implement equality correctly', () {
      final supply1 = SuggestedSupply(
        name: 'Test',
        isChecked: true,
        isModified: false,
      );

      final supply2 = SuggestedSupply(
        name: 'Test',
        isChecked: true,
        isModified: false,
      );

      expect(supply1, equals(supply2));
    });

    test('should not be equal if properties differ', () {
      final supply1 = SuggestedSupply(
        name: 'Test',
        isChecked: true,
        isModified: false,
      );

      final supply2 = SuggestedSupply(
        name: 'Test',
        isChecked: false,
        isModified: false,
      );

      expect(supply1, isNot(equals(supply2)));
    });
  });

  group('Supply Suggestions Conversion Logic', () {
    test(
        'should convert DefaultSupplies to SuggestedSupply list with default checked state',
        () {
      final supplies =
          DefaultSupplies.getSuppliesBySubjectName('Mathématiques');
      expect(supplies, isNotNull);

      // Simulate controller logic
      final suggestions = supplies!
          .map((name) => SuggestedSupply(
                name: name,
                isChecked: true,
                isModified: false,
              ))
          .toList();

      expect(suggestions.length, 4);
      expect(suggestions.every((s) => s.isChecked), true);
      expect(suggestions.every((s) => !s.isModified), true);
      expect(suggestions[0].name, 'Cahier de maths');
    });

    test('should filter checked supplies correctly', () {
      final suggestions = [
        SuggestedSupply(name: 'Supply 1', isChecked: true),
        SuggestedSupply(name: 'Supply 2', isChecked: false),
        SuggestedSupply(name: 'Supply 3', isChecked: true),
        SuggestedSupply(name: 'Supply 4', isChecked: false),
      ];

      final checkedSupplies = suggestions
          .where((supply) => supply.isChecked)
          .map((supply) => supply.name)
          .toList();

      expect(checkedSupplies.length, 2);
      expect(checkedSupplies[0], 'Supply 1');
      expect(checkedSupplies[1], 'Supply 3');
    });
  });

  // Note: Controller tests require Riverpod container setup with mocked repository.
  // The unit tests above validate core business logic (DefaultSupplies, model, filtering).
  // Controller integration testing is done manually via UI testing.
}
