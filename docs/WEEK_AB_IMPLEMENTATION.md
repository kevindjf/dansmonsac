# Implémentation des Semaines A/B - Guide Complet

## 📋 Vue d'ensemble

Ce document décrit l'implémentation du système de semaines A/B pour l'application DansMonSac, permettant aux utilisateurs de définir des cours différents pour les semaines A et B.

## ✅ Ce qui a été implémenté

### 1. Base de données Supabase

**Fichier:** `docs/supabase_migration_weeks_ab.sql`

**Modifications apportées:**
- ✅ Ajout de `week_type` à `calendar_courses` (valeurs: 'A', 'B', 'BOTH')
- ✅ Ajout de `day_of_week` à `calendar_courses` (1=Lundi, 7=Dimanche)
- ✅ Ajout de `school_year_start_date` à `users_preferences`
- ✅ Fonction SQL `get_current_week_type()` pour calculer la semaine actuelle
- ✅ Fonction SQL `get_courses_for_date()` pour récupérer les cours d'un jour
- ✅ Fonction SQL `get_supplies_for_tomorrow()` pour récupérer les fournitures de demain
- ✅ Vue `v_calendar_courses_detailed` pour simplifier les requêtes

**Pour appliquer ces changements:**
```sql
-- Dans Supabase SQL Editor, exécutez le contenu de:
docs/supabase_migration_weeks_ab.sql
```

### 2. Modèles Dart

**Fichier:** `features/schedule/lib/models/calendar_course.dart`

**Modifications:**
- ✅ Ajout de l'enum `WeekType` (A, B, BOTH)
- ✅ Ajout du champ `weekType` à `CalendarCourse`
- ✅ Ajout du champ `dayOfWeek` à `CalendarCourse`
- ✅ Mise à jour de `fromJson()` et `toJson()` pour supporter les nouveaux champs

### 3. Utilitaires

**Fichier:** `features/common/lib/src/utils/week_utils.dart`

**Fonctionnalités:**
- ✅ `getCurrentWeekType()` - Calcule si on est en semaine A ou B
- ✅ `shouldShowCourseForDate()` - Vérifie si un cours doit être affiché
- ✅ `getDayOfWeek()` - Retourne le numéro du jour (1-7)
- ✅ `getDayName()` - Retourne le nom du jour en français
- ✅ `getDayAbbreviation()` - Retourne l'abréviation du jour (L, M, M, J, V, S, D)
- ✅ `getTomorrow()` et `getToday()` - Helpers pour les dates

### 4. Controllers et State

**Fichiers modifiés:**
- ✅ `features/schedule/lib/presentation/add/controller/add_calendar_couse_state.dart`
  - Ajout de `weekType` et `dayOfWeek`
- ✅ `features/schedule/lib/presentation/add/controller/add_calendar_course_controller.dart`
  - Ajout de `weekTypeChanged()` et `dayOfWeekChanged()`
  - Mise à jour de `store()` pour inclure les nouveaux champs

## 🚧 Ce qui reste à implémenter

### 1. Interface utilisateur - Ajout de cours

**Fichier à modifier:** `features/schedule/lib/presentation/add/add_calendar_course_page.dart`

**À ajouter avant le bouton "Ajouter":**

```dart
// Sélecteur de jour de la semaine
DropdownButtonFormField<int>(
  decoration: InputDecoration(
    labelText: "Jour de la semaine",
    filled: false,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),
  value: state.dayOfWeek,
  items: [
    DropdownMenuItem(value: 1, child: Text('Lundi')),
    DropdownMenuItem(value: 2, child: Text('Mardi')),
    DropdownMenuItem(value: 3, child: Text('Mercredi')),
    DropdownMenuItem(value: 4, child: Text('Jeudi')),
    DropdownMenuItem(value: 5, child: Text('Vendredi')),
    DropdownMenuItem(value: 6, child: Text('Samedi')),
    DropdownMenuItem(value: 7, child: Text('Dimanche')),
  ],
  onChanged: (int? value) {
    if (value != null) {
      ref
        .read(addCalendarCourseControllerProvider.notifier)
        .dayOfWeekChanged(value);
    }
  },
),
SizedBox(height: 16),

// Sélecteur de type de semaine
DropdownButtonFormField<WeekType>(
  decoration: InputDecoration(
    labelText: "Semaine",
    filled: false,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),
  value: state.weekType,
  items: [
    DropdownMenuItem(value: WeekType.A, child: Text('Semaine A uniquement')),
    DropdownMenuItem(value: WeekType.B, child: Text('Semaine B uniquement')),
    DropdownMenuItem(value: WeekType.BOTH, child: Text('Les deux semaines')),
  ],
  onChanged: (WeekType? value) {
    if (value != null) {
      ref
        .read(addCalendarCourseControllerProvider.notifier)
        .weekTypeChanged(value);
    }
  },
),
SizedBox(height: 32),
```

### 2. Onboarding - Date de rentrée

**Fichier à modifier:** `features/onboarding/lib/src/presentation/hour/setup_time_page.dart`

**À ajouter:** Un sélecteur de date pour `school_year_start_date`

```dart
// Ajouter après la sélection de l'heure de préparation du sac
ListTile(
  title: Text('Date de début de l\'année scolaire'),
  subtitle: Text('Première semaine A: ${formatDate(_schoolYearStartDate)}'),
  trailing: Icon(Icons.calendar_today),
  onTap: () async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _schoolYearStartDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _schoolYearStartDate = picked;
      });
    }
  },
),
```

**Mettre à jour le repository:** `features/onboarding/lib/src/repositories/onboarding_supabase_repository.dart`

```dart
@override
Future<Either<Failure, void>> storePackTime(PackTimeCommand command) async {
  return handleErrors(() async {
    final deviceId = await preferenceRepository.getUserId();

    final data = {
      'device_id': deviceId,
      'hour': command.hour,
      'minute': command.minute,
      'school_year_start_date': command.schoolYearStartDate.toIso8601String(), // AJOUTER
    };

    await supabaseClient
        .from('users_preferences')
        .upsert(data, onConflict: 'device_id');

    return preferenceRepository.storeFinishOnboarding();
  });
}
```

### 3. Calendrier avec données réelles

**Fichier à créer:** `features/main/lib/presentation/home/controller/calendar_controller.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schedule/repository/calendar_course_repository.dart';
import 'package:schedule/models/calendar_course.dart';
import 'package:common/src/repository/preference_repository.dart';
import 'package:common/src/utils/week_utils.dart';

// Provider pour récupérer les cours du jour
final todayCoursesProvider = FutureProvider<List<CalendarCourse>>((ref) async {
  final repository = ref.watch(calendarCourseRepositoryProvider);
  final prefRepository = ref.watch(preferenceRepositoryProvider);

  // Récupérer tous les cours
  final result = await repository.fetchCalendarCourses();

  return result.fold(
    (failure) => [],
    (allCourses) {
      final today = DateTime.now();
      final todayDayOfWeek = WeekUtils.getDayOfWeek(today);

      // TODO: Récupérer school_year_start_date depuis users_preferences
      final schoolYearStart = DateTime(2024, 9, 2); // À remplacer
      final currentWeek = WeekUtils.getCurrentWeekType(schoolYearStart);

      // Filtrer les cours pour aujourd'hui
      return allCourses.where((course) {
        if (course.dayOfWeek != todayDayOfWeek) return false;
        if (course.weekType == WeekType.BOTH) return true;
        return course.weekType.value == currentWeek;
      }).toList()
        ..sort((a, b) {
          final aMinutes = a.startTime.hour * 60 + a.startTime.minute;
          final bMinutes = b.startTime.hour * 60 + b.startTime.minute;
          return aMinutes.compareTo(bMinutes);
        });
    },
  );
});
```

**Fichier à modifier:** `features/main/lib/presentation/home/calendar_page.dart`

Remplacer les données hardcodées par:

```dart
@override
Widget build(BuildContext context, WidgetRef ref) {
  final todayCourses = ref.watch(todayCoursesProvider);

  return todayCourses.when(
    data: (courses) => Stack(
      children: [
        Column(
          // ... existant ...
          Expanded(
            child: courses.isEmpty
              ? Center(child: Text('Aucun cours aujourd\'hui'))
              : ListView.builder(
                  itemCount: courses.length,
                  itemBuilder: (context, index) {
                    final course = courses[index];
                    return CourseCard(course: course); // Créer ce widget
                  },
                ),
          ),
        ],
      ],
    ),
    loading: () => Center(child: CircularProgressIndicator()),
    error: (error, _) => Center(child: Text('Erreur: $error')),
  );
}
```

### 4. Liste des fournitures pour demain

**Fichier à créer:** `features/main/lib/presentation/home/controller/supplies_controller.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:course/repository/course_repository.dart';
import 'package:schedule/repository/calendar_course_repository.dart';
import 'package:supply/models/supply.dart';
import 'package:common/src/utils/week_utils.dart';

class SupplyForTomorrow {
  final Supply supply;
  final String courseName;
  bool isChecked;

  SupplyForTomorrow({
    required this.supply,
    required this.courseName,
    this.isChecked = false,
  });
}

// Provider pour les fournitures de demain
final tomorrowSuppliesProvider = FutureProvider<List<SupplyForTomorrow>>((ref) async {
  final calendarRepo = ref.watch(calendarCourseRepositoryProvider);
  final courseRepo = ref.watch(courseRepositoryProvider);

  // Récupérer les cours du calendrier
  final calendarResult = await calendarRepo.fetchCalendarCourses();

  return calendarResult.fold(
    (failure) => [],
    (allCalendarCourses) async {
      final tomorrow = WeekUtils.getTomorrow();
      final tomorrowDayOfWeek = WeekUtils.getDayOfWeek(tomorrow);

      // TODO: Récupérer school_year_start_date
      final schoolYearStart = DateTime(2024, 9, 2);
      final tomorrowWeek = WeekUtils.getCurrentWeekType(schoolYearStart, tomorrow);

      // Filtrer les cours de demain
      final tomorrowCourses = allCalendarCourses.where((course) {
        if (course.dayOfWeek != tomorrowDayOfWeek) return false;
        if (course.weekType == WeekType.BOTH) return true;
        return course.weekType.value == tomorrowWeek;
      }).toList();

      // Récupérer les fournitures pour ces cours
      final Map<String, SupplyForTomorrow> suppliesMap = {};

      for (final calendarCourse in tomorrowCourses) {
        final coursesResult = await courseRepo.fetchCourses();

        coursesResult.fold(
          (failure) => null,
          (allCourses) {
            final course = allCourses.firstWhere(
              (c) => c.id == calendarCourse.courseId,
              orElse: () => null,
            );

            if (course != null) {
              for (final supply in course.supplies) {
                final key = '${supply.id}_${course.name}';
                if (!suppliesMap.containsKey(key)) {
                  suppliesMap[key] = SupplyForTomorrow(
                    supply: supply,
                    courseName: course.name,
                  );
                }
              }
            }
          },
        );
      }

      return suppliesMap.values.toList()
        ..sort((a, b) => a.courseName.compareTo(b.courseName));
    },
  );
});
```

**Fichier à modifier:** `features/main/lib/presentation/home/list_supply_page.dart`

Remplacer les données hardcodées par:

```dart
@override
Widget build(BuildContext context, WidgetRef ref) {
  final supplies = ref.watch(tomorrowSuppliesProvider);

  return supplies.when(
    data: (suppliesList) => Stack(
      children: [
        Column(
          children: [
            Container(
              // ... header existant avec nombre de fournitures ...
              Text(
                "${suppliesList.where((s) => s.isChecked).length}/${suppliesList.length} fournitures",
                // ...
              ),
            ),
            Expanded(
              child: suppliesList.isEmpty
                ? Center(child: Text('Aucune fourniture nécessaire demain'))
                : ListView.builder(
                    itemCount: suppliesList.length,
                    itemBuilder: (context, index) {
                      final item = suppliesList[index];
                      return CheckboxListTile(
                        title: Text(item.supply.name),
                        subtitle: Text(item.courseName),
                        value: item.isChecked,
                        onChanged: (value) {
                          // Gérer le changement d'état
                        },
                      );
                    },
                  ),
            ),
          ],
        ),
      ],
    ),
    loading: () => Center(child: CircularProgressIndicator()),
    error: (error, _) => Center(child: Text('Erreur: $error')),
  );
}
```

## 🗄️ Configuration Supabase requise

1. **Exécuter la migration:**
```bash
# Dans Supabase SQL Editor:
-- Copiez et exécutez le contenu de docs/supabase_migration_weeks_ab.sql
```

2. **Définir la date de rentrée:**
```sql
-- Exemple: début de l'année scolaire le 2 septembre 2024
UPDATE users_preferences
SET school_year_start_date = '2024-09-02'
WHERE device_id = 'VOTRE_DEVICE_ID';
```

## 📝 Exemples d'utilisation

### Ajouter un cours uniquement en semaine A

```dart
// L'utilisateur sélectionne:
// - Jour: Lundi
// - Semaine: Semaine A uniquement
// - Cours: Mathématiques
// - Salle: A101
// - Heure: 8h00 - 10h00
```

### Ajouter un cours pour les deux semaines

```dart
// L'utilisateur sélectionne:
// - Jour: Mardi
// - Semaine: Les deux semaines
// - Cours: Anglais
// - Salle: B205
// - Heure: 14h00 - 16h00
```

## 🧪 Tests

### Tester le calcul de semaine

```dart
import 'package:common/src/utils/week_utils.dart';

void testWeekCalculation() {
  final schoolStart = DateTime(2024, 9, 2); // Lundi 2 sept 2024 = Semaine A

  // 2 sept 2024 = Semaine A (0 semaines écoulées)
  print(WeekUtils.getCurrentWeekType(schoolStart, DateTime(2024, 9, 2))); // 'A'

  // 9 sept 2024 = Semaine B (1 semaine écoulée)
  print(WeekUtils.getCurrentWeekType(schoolStart, DateTime(2024, 9, 9))); // 'B'

  // 16 sept 2024 = Semaine A (2 semaines écoulées)
  print(WeekUtils.getCurrentWeekType(schoolStart, DateTime(2024, 9, 16))); // 'A'
}
```

## 🐛 Problèmes connus et solutions

### Problème: Les cours n'apparaissent pas dans le calendrier

**Solution:** Vérifier que:
1. La date de début d'année scolaire est bien définie dans `users_preferences`
2. Les cours ont bien un `day_of_week` et `week_type` définis
3. Le calcul de semaine est correct pour la date actuelle

### Problème: Les fournitures ne s'affichent pas

**Solution:** Vérifier que:
1. Les cours de demain existent bien dans la base de données
2. Les cours ont bien des fournitures associées via `course_supplies`
3. La logique de filtrage par semaine A/B est correcte

## 📚 Prochaines étapes recommandées

1. ✅ Appliquer la migration SQL sur Supabase
2. 🔲 Mettre à jour l'UI d'ajout de cours (sélecteurs jour/semaine)
3. 🔲 Ajouter le sélecteur de date de rentrée dans l'onboarding
4. 🔲 Implémenter l'affichage des cours réels dans le calendrier
5. 🔲 Implémenter la liste des fournitures de demain
6. 🔲 Tester avec des données réelles
7. 🔲 Ajouter la possibilité de modifier/supprimer des cours

## 💡 Améliorations futures

- Afficher l'indicateur de semaine actuelle (A ou B) dans l'interface
- Permettre de changer la date de début d'année scolaire
- Ajouter des notifications pour la préparation du sac
- Gérer les vacances scolaires (pas de semaine A ou B)
- Export/import de l'emploi du temps
