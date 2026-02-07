/// Default supplies utility for French school subjects
///
/// Provides reusable data structure for default subjects and their supplies,
/// used across onboarding and course creation flows.
class DefaultSubject {
  final String name;
  final List<String> supplies;
  final String category;

  const DefaultSubject({
    required this.name,
    required this.supplies,
    required this.category,
  });
}

/// Utility class providing default French school subjects with supplies
class DefaultSupplies {
  DefaultSupplies._(); // Private constructor - static class only

  /// Returns all default French school subjects with supplies
  ///
  /// Returns a list of 6 subjects (Mathématiques, Français, Histoire-Géographie,
  /// Sciences, Anglais, EPS) with their associated supplies and categories.
  static List<DefaultSubject> getDefaultSubjects() {
    return List.unmodifiable(_frenchSchoolSubjects);
  }

  /// Returns supplies for a specific subject name (case-insensitive match)
  ///
  /// Returns null if subject not found.
  /// Matching is case-insensitive and preserves French accents.
  ///
  /// Example:
  /// ```dart
  /// final supplies = DefaultSupplies.getSuppliesBySubjectName('Mathématiques');
  /// // Returns: ['Cahier de maths', 'Calculatrice', 'Règle', 'Compas']
  /// ```
  static List<String>? getSuppliesBySubjectName(String name) {
    if (name.isEmpty) return null;

    final normalizedName = name.toLowerCase();

    try {
      final subject = _frenchSchoolSubjects.firstWhere(
        (s) => s.name.toLowerCase() == normalizedName,
      );
      return List.unmodifiable(subject.supplies);
    } catch (_) {
      return null;
    }
  }

  // Private: actual data storage
  static const List<DefaultSubject> _frenchSchoolSubjects = [
    DefaultSubject(
      name: 'Mathématiques',
      supplies: ['Cahier de maths', 'Calculatrice', 'Règle', 'Compas'],
      category: 'core',
    ),
    DefaultSubject(
      name: 'Français',
      supplies: ['Cahier de français', 'Dictionnaire', 'Bescherelle'],
      category: 'core',
    ),
    DefaultSubject(
      name: 'Histoire-Géographie',
      supplies: ['Cahier d\'histoire-géo', 'Crayons de couleur'],
      category: 'core',
    ),
    DefaultSubject(
      name: 'Sciences',
      supplies: ['Cahier de sciences', 'Blouse'],
      category: 'science',
    ),
    DefaultSubject(
      name: 'Anglais',
      supplies: ['Cahier d\'anglais', 'Dictionnaire anglais'],
      category: 'language',
    ),
    DefaultSubject(
      name: 'EPS',
      supplies: ['Tenue de sport', 'Baskets', 'Serviette'],
      category: 'physical',
    ),
  ];
}
