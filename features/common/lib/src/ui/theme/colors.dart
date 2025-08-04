import 'package:flutter/material.dart';

class AppColors {
  AppColors._(); // Constructeur privé pour empêcher l'instanciation

// Couleurs primaires
  static const Color primary =
      Color.fromARGB(255, 33, 0, 78); // Violet foncé pour le bouton principal
  static const Color primaryLight =
      Color(0xFF3F3B8E); // Version plus claire pour les hover ou variantes
  static const Color primaryDark =
      Color(0xFF7B1FA2); // Version plus foncée pour du contraste
  static const Color accent =
      Color(0xFFB9A0FF); // Bouton secondaire (violet clair)

// Couleurs sémantiques
  static const Color success = Color(0xFF4CAF50); // Vert classique pour valider
  static const Color error = Color(0xFFE53935); // Rouge pour erreurs
  static const Color warning = Color(0xFFFFC107); // Jaune pour avertissements
  static const Color info = Color(0xFF2196F3); // Bleu pour informations

// Couleurs neutres
  static const Color background = Color(0xFFF3F3F3); // Fond clair
  static const Color surface =
      Color(0xFFFFFFFF); // Surface claire pour cartes ou pop-ups
  static const Color cardBackground = Color(
      0xFFCBC8FF); // Violet un peu plus foncé pour différencier les cartes
  static const Color textButton =
      Color(0xFFFFFFFF); // Texte blanc pour les boutons

  // Texte
  static const Color textHint = Color(0xFF9E9E9E); // Texte d'indication
  static const Color textPrimary = Color(0xFF333333); // Texte principal
  static const Color textSecondary =
      Color(0x663F3B8E); // Texte secondaire (moins saturé)

  // Niveaux de gris
  static const Color grey50 = Color(0xFFFAFAFA);
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey400 = Color(0xFFBDBDBD);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey700 = Color(0xFF616161);
  static const Color grey800 = Color(0xFF424242);
  static const Color grey900 = Color(0xFF212121);

  // Divider
  static const Color divider =
      Color(0xFFBDBDBD); // Lignes de séparation discrètes
}
