// ignore_for_file: avoid_print

import 'package:common/src/database/app_database.dart';
import 'package:common/src/services/preferences_service.dart';
import 'package:common/src/utils/week_utils.dart';
import 'package:drift/native.dart';

/// Script de diagnostic pour vérifier pourquoi getTomorrowCourses() ne retourne rien
void main() async {
  print('🔍 Diagnostic: Pourquoi pas de cours pour demain?\n');

  // 1. Vérifier le mode vacances
  print('1️⃣ Mode vacances:');
  final isVacationMode = await PreferencesService.isVacationModeActive();
  print('   Mode vacances actif: $isVacationMode');
  if (isVacationMode) {
    final endDate = await PreferencesService.getVacationModeEndDate();
    print('   ⚠️  PROBLÈME: Le mode vacances est activé jusqu\'au $endDate');
    print('   👉 Solution: Désactive-le dans les paramètres!');
    print('');
  }

  // 2. Vérifier la date de demain et le calcul
  final tomorrow = DateTime.now().add(const Duration(days: 1));
  final tomorrowDayOfWeek = tomorrow.weekday;
  print('2️⃣ Date de demain:');
  print(
      '   Date: ${tomorrow.year}-${tomorrow.month.toString().padLeft(2, '0')}-${tomorrow.day.toString().padLeft(2, '0')}');
  print(
      '   Jour de semaine: $tomorrowDayOfWeek (1=Lun, 2=Mar, 3=Mer, 4=Jeu, 5=Ven, 6=Sam, 7=Dim)');

  // 3. Vérifier le calcul de semaine A/B
  final schoolYearStart = await PreferencesService.getSchoolYearStart();
  final weekType = WeekUtils.getCurrentWeekType(schoolYearStart, tomorrow);
  print('');
  print('3️⃣ Semaine A/B:');
  print('   Début année scolaire: ${schoolYearStart.toIso8601String()}');
  print('   Semaine calculée: $weekType');

  // 4. Vérifier les cours dans la base de données
  final database = AppDatabase.forTesting(
      NativeDatabase.memory()); // Pas le bon, mais pour la structure
  print('');
  print('4️⃣ Requête SQL à exécuter:');
  print('   SELECT * FROM calendar_courses');
  print('   WHERE day_of_week = $tomorrowDayOfWeek');
  print(
      '   AND (week_type = \'BOTH\' OR week_type = \'AB\' OR week_type = \'$weekType\')');
  print('');
  print('📋 Pour vérifier manuellement:');
  print('   1. Ouvre l\'app en mode debug');
  print(
      '   2. Regarde les logs pour "CalendarCourseRepository.getTomorrowCourses"');
  print('   3. Vérifie que dayOfWeek et weekType correspondent à tes cours');
  print('');
  print('🔧 Causes possibles:');
  print('   ❌ Mode vacances activé (vérifie étape 1)');
  print(
      '   ❌ Semaine A/B incorrecte (tes cours sont pour semaine A mais on est en B)');
  print('   ❌ dayOfWeek incorrect dans calendar_courses');
  print('   ❌ weekType dans calendar_courses ne correspond pas');

  await database.close();
}
