/// Utilitaires de validation pour les inputs utilisateur
class Validators {
  static const int maxCourseNameLength = 50;
  static const int maxSupplyNameLength = 100;
  static const int maxRoomNameLength = 30;

  /// Valide le nom d'un cours
  static String? validateCourseName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Le nom du cours ne peut pas etre vide';
    }
    if (value.trim().length > maxCourseNameLength) {
      return 'Le nom du cours ne peut pas depasser $maxCourseNameLength caracteres';
    }
    return null;
  }

  /// Valide le nom d'une fourniture
  static String? validateSupplyName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Le nom de la fourniture ne peut pas etre vide';
    }
    if (value.trim().length > maxSupplyNameLength) {
      return 'Le nom ne peut pas depasser $maxSupplyNameLength caracteres';
    }
    return null;
  }

  /// Valide le nom d'une salle (optionnel)
  static String? validateRoomName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Room is optional
    }
    if (value.trim().length > maxRoomNameLength) {
      return 'Le nom de salle ne peut pas depasser $maxRoomNameLength caracteres';
    }
    return null;
  }

  /// Nettoie une chaîne (trim)
  static String clean(String value) => value.trim();
}
