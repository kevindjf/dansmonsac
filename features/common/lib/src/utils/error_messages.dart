import '../models/network/network_failure.dart';

/// Messages d'erreur localisés selon le type de Failure
class ErrorMessages {
  /// Retourne un message utilisateur selon le type de Failure
  static String getMessageForFailure(Failure failure) {
    if (failure is NetworkFailure) {
      return 'Probleme de connexion. Verifiez votre internet et reessayez.';
    } else if (failure is ValidationFailure) {
      return 'Donnees invalides: ${failure.message}';
    } else if (failure is DatabaseFailure) {
      return 'Erreur de base de donnees. Reessayez plus tard.';
    } else {
      return 'Une erreur inattendue est survenue. Reessayez plus tard.';
    }
  }

  // Messages spécifiques
  static const String courseNotFound = 'Cours introuvable';
  static const String supplyNotFound = 'Fourniture introuvable';
  static const String syncFailed =
      'Synchronisation echouee. Vos donnees seront synchronisees plus tard.';
  static const String operationNotAllowed = 'Operation non autorisee';
  static const String invalidInput = 'Saisie invalide';
}
