# Fix: getTomorrowCourses() retourne 0 cours

## Problème

Les logs montraient :
```
⚠️ CalendarCourseRepository.getTomorrowCourses: Course db7a40ac-... not found, skipping
🐛 TomorrowSupplyController: Loaded 0 courses for tomorrow
```

Alors que la DB locale contenait 29 CalendarCourses et que 5 étaient trouvés pour demain.

## Cause racine

### Architecture des tables Drift

```dart
// Table Courses
class Courses extends Table {
  TextColumn get id => text()();           // ID local (UUID généré par Drift)
  TextColumn get remoteId => text().nullable()();  // ID Supabase
  ...
}

// Table CalendarCourses
class CalendarCourses extends Table {
  TextColumn get id => text()();
  TextColumn get courseId => text();  // Référence vers un Course
  ...
}
```

### Le bug dans le flux d'import

1. **Import de cours** (`ImportController._executeImport` ligne 216-228) :
   - `courseRepo.store()` insère dans **Supabase uniquement** (pas dans Drift!)
   - Retourne l'**ID Supabase** du cours créé
   - Stocke cet ID dans `courseNameToId`

2. **Import de CalendarCourses** (ligne 282-303) :
   - Utilise `courseNameToId[courseName]` (qui contient l'ID Supabase)
   - Crée `CalendarCourse` avec `courseId = ID Supabase`
   - `calendarRepo.addCalendarCourse()` insère dans **Drift**

3. **Résultat** :
   - Dans Drift : `CalendarCourse.courseId` = ID Supabase
   - Dans Drift : `Course.id` = ID local (différent)
   - Dans Drift : `Course.remoteId` = ID Supabase ✅

4. **Le JOIN échouait** :
   ```dart
   // Ancienne query (buggée)
   final coursesQuery = database.select(database.courses)
     ..where((c) => c.id.isIn(courseIds));  // ❌ Cherche uniquement sur id local
   ```

## Solution appliquée

### Modification de `getTomorrowCourses()`

**Fichier**: `features/schedule/lib/repository/calendar_course_repository.dart`

**Changements** (lignes 265-310) :

```dart
// Query 2: Batch load courses
// IMPORTANT: CalendarCourse.courseId peut être soit un ID local, soit un remoteId
final courseIds = calendarCourses.map((c) => c.courseId).toSet().toList();

// ✅ Cherche sur DEUX champs : id OU remoteId
final coursesQuery = database.select(database.courses)
  ..where((c) => c.id.isIn(courseIds) | c.remoteId.isIn(courseIds));

// ✅ Crée DEUX maps pour lookup flexible
final coursesById = <String, CourseEntity>{};
final coursesByRemoteId = <String, CourseEntity>{};
for (var c in await coursesQuery.get()) {
  coursesById[c.id] = c;
  if (c.remoteId != null) {
    coursesByRemoteId[c.remoteId!] = c;
  }
}

// ✅ Helper function pour chercher dans les deux maps
CourseEntity? findCourse(String courseId) {
  return coursesById[courseId] ?? coursesByRemoteId[courseId];
}

// ... plus tard dans le code ...

// ✅ Utilise findCourse() au lieu de coursesMap[]
for (final calendarCourse in calendarCourses) {
  final course = findCourse(calendarCourse.courseId);

  if (course == null) {
    LogService.w('...: Course ${calendarCourse.courseId} not found, skipping');
    continue;
  }
  // ...
}
```

### Bonus : Fix des supplies

Le code des supplies a aussi été corrigé pour mapper correctement par remoteId :

```dart
// Group supplies by courseId (supplies.courseId peut aussi être remoteId)
final suppliesByCourse = <String, List<SupplyEntity>>{};
for (final supply in allSupplies) {
  // ✅ Trouve le course entity pour obtenir son ID local
  final course = findCourse(supply.courseId);
  if (course != null) {
    suppliesByCourse.putIfAbsent(course.id, () => []).add(supply);
  }
}
```

## Test

### Commandes de test

```bash
# 1. Recompiler l'app
flutter run

# 2. Observer les logs
# Devrait maintenant afficher :
# 🐛 CalendarCourseRepository.getTomorrowCourses: Batch loaded 5 courses...
# 🐛 TomorrowSupplyController: Loaded 5 courses for tomorrow  (au lieu de 0)
```

### Vérification manuelle

1. Ouvrir l'app
2. Aller sur la page "Demain" (TomorrowSupply)
3. Vérifier que les cours apparaissent correctement
4. Les warnings "Course ... not found" ne devraient plus apparaître

## Impact

### Fichiers modifiés
- ✅ `features/schedule/lib/repository/calendar_course_repository.dart` (lignes 265-320)

### Compatibilité
- ✅ **Backwards compatible** : Supporte à la fois les anciens IDs locaux ET les nouveaux remoteIds
- ✅ Aucun changement de schéma DB requis
- ✅ Aucune migration de données requise

### Performance
- ✅ Pas d'impact : toujours 3 queries batch (calendar, courses, supplies)
- ✅ Complexité identique : O(n) avec n = nombre de cours

## Problème architectural sous-jacent

### Root cause

`CourseSupabaseRepository` n'utilise **PAS** la DB Drift locale. Il fait uniquement des appels directs à Supabase :

```dart
// ❌ PAS d'insertion dans Drift!
Future<Either<Failure, CourseWithSupplies>> store(AddCourseCommand command) {
  return handleErrors(() async {
    // Insert dans Supabase
    final courseInsertResponse = await supabaseClient
        .from('courses')
        .insert({'course_name': command.courseName})
        .select('id')
        .single();

    // ❌ Aucune écriture dans Drift!

    return CourseWithSupplies(id: courseInsertResponse['id'], ...);
  });
}
```

### Solution long-terme (TODO)

Refactoriser `CourseSupabaseRepository` pour suivre le pattern **offline-first** comme `CalendarCourseSupabaseRepository` :

1. **Double-write** : Écrire dans Drift PUIS dans Supabase
2. **Utiliser Drift comme source de vérité** : Lire depuis Drift uniquement
3. **Gérer remoteId** : Mapper correctement les IDs locaux ↔ Supabase

**Fichier à refactoriser** : `features/course/lib/repository/course_supabase_repository.dart`

## Références

- Issue originale : Logs montrant "Course ... not found, skipping"
- Pattern utilisé : Double-write Drift + Supabase (comme dans CalendarCourseRepository)
- Architecture offline-first : Voir `OFFLINE_ARCHITECTURE.md`
