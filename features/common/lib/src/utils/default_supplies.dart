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

  /// Returns supplies for a specific subject name
  ///
  /// Returns null if subject not found.
  /// Matching is case-insensitive, accent-insensitive, and supports aliases.
  ///
  /// Examples:
  /// ```dart
  /// DefaultSupplies.getSuppliesBySubjectName('Mathématiques'); // ✓
  /// DefaultSupplies.getSuppliesBySubjectName('mathematiques'); // ✓ (no accent)
  /// DefaultSupplies.getSuppliesBySubjectName('maths');         // ✓ (alias)
  /// DefaultSupplies.getSuppliesBySubjectName('MATH');          // ✓ (uppercase alias)
  /// ```
  static List<String>? getSuppliesBySubjectName(String name) {
    if (name.isEmpty) return null;

    final normalized = _normalize(name);

    // Try exact match first (normalized)
    try {
      final subject = _frenchSchoolSubjects.firstWhere(
        (s) => _normalize(s.name) == normalized,
      );
      return List.unmodifiable(subject.supplies);
    } catch (_) {}

    // Try aliases
    final canonicalName = _subjectAliases[normalized];
    if (canonicalName != null) {
      try {
        final subject = _frenchSchoolSubjects.firstWhere(
          (s) => _normalize(s.name) == _normalize(canonicalName),
        );
        return List.unmodifiable(subject.supplies);
      } catch (_) {}
    }

    return null;
  }

  /// Normalize string by removing accents and converting to lowercase
  static String _normalize(String text) {
    const withAccents = 'àâäéèêëïîôùûüÿçÀÂÄÉÈÊËÏÎÔÙÛÜŸÇ';
    const withoutAccents = 'aaaeeeeiioouuycAAAEEEEIIOUUUYC';

    var result = text;
    for (var i = 0; i < withAccents.length; i++) {
      result = result.replaceAll(withAccents[i], withoutAccents[i]);
    }

    return result.toLowerCase().trim();
  }

  /// Map of aliases to canonical subject names
  static const Map<String, String> _subjectAliases = {
    'maths': 'Mathématiques',
    'math': 'Mathématiques',
    'mathematiques': 'Mathématiques',
    'francais': 'Français',
    'hg': 'Histoire-Géographie',
    'histoire': 'Histoire-Géographie',
    'geographie': 'Histoire-Géographie',
    'geo': 'Histoire-Géographie',
    'svt': 'Sciences',
    'science': 'Sciences',
    'physique': 'Sciences',
    'biologie': 'Sciences',
    'anglais': 'Anglais',
    'english': 'Anglais',
    'sport': 'EPS',
  };

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
