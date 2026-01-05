/// Utilitaires pour gérer les semaines A/B
class WeekUtils {
  /// Calcule si une date donnée est en semaine A ou B
  /// basée sur la date de début de l'année scolaire (première semaine A)
  static String getCurrentWeekType(DateTime schoolYearStart, [DateTime? checkDate]) {
    final date = checkDate ?? DateTime.now();

    // Calculer le nombre de semaines écoulées depuis le début de l'année scolaire
    final weeksDiff = date.difference(schoolYearStart).inDays ~/ 7;

    // Si le nombre de semaines est pair, c'est semaine A, sinon semaine B
    return weeksDiff % 2 == 0 ? 'A' : 'B';
  }

  /// Vérifie si un cours doit être affiché pour une date donnée
  /// en fonction de son type de semaine (A, B, ou BOTH)
  static bool shouldShowCourseForDate(
    String courseWeekType,
    DateTime schoolYearStart,
    DateTime date,
  ) {
    if (courseWeekType == 'BOTH') {
      return true;
    }

    final currentWeek = getCurrentWeekType(schoolYearStart, date);
    return courseWeekType == currentWeek;
  }

  /// Retourne le jour de la semaine (1=Lundi, 7=Dimanche)
  /// pour une date donnée
  static int getDayOfWeek(DateTime date) {
    // DateTime.weekday retourne 1=Lundi, 7=Dimanche (ISO 8601)
    return date.weekday;
  }

  /// Retourne le nom du jour en français
  static String getDayName(int dayOfWeek) {
    switch (dayOfWeek) {
      case 1:
        return 'Lundi';
      case 2:
        return 'Mardi';
      case 3:
        return 'Mercredi';
      case 4:
        return 'Jeudi';
      case 5:
        return 'Vendredi';
      case 6:
        return 'Samedi';
      case 7:
        return 'Dimanche';
      default:
        return '';
    }
  }

  /// Retourne l'abréviation du jour
  static String getDayAbbreviation(int dayOfWeek) {
    switch (dayOfWeek) {
      case 1:
        return 'L';
      case 2:
        return 'M';
      case 3:
        return 'M';
      case 4:
        return 'J';
      case 5:
        return 'V';
      case 6:
        return 'S';
      case 7:
        return 'D';
      default:
        return '';
    }
  }

  /// Retourne la date du lendemain
  static DateTime getTomorrow() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day + 1);
  }

  /// Retourne la date d'aujourd'hui à minuit
  static DateTime getToday() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }
}
