# Module Schedule

## Description
Module de gestion de l'emploi du temps. Permet d'ajouter des séances de cours au calendrier hebdomadaire et de calculer les fournitures nécessaires pour le lendemain.

## Responsabilités
- CRUD des séances (CalendarCourse)
- Affichage du calendrier hebdomadaire
- Calcul des fournitures du lendemain (TomorrowSupply)
- Gestion des semaines A/B

## Architecture
- **Pattern Repository** avec `CalendarCourseRepository` et `CalendarCourseSupabaseRepository` (nom historique, utilise Drift uniquement)
- **Gestion d'erreurs** via `Either<Failure, T>`
- **Stockage local** : Drift (SQLite) uniquement, aucune sync Supabase
- **Model** :
  - `CalendarCourse` - Séance avec cours, salle, horaires, jour, type de semaine

## State Management
- **Riverpod** avec `@riverpod` annotations
- Controllers :
  - `CalendarController` - Gestion des séances du calendrier
  - `AddCalendarCourseController` - Logique d'ajout de séance
  - `TomorrowSupplyController` - Calcul des fournitures du lendemain

## Fichiers clés
- `models/calendar_course.dart` - Modèle de séance
- `repository/calendar_course_repository.dart` - Interface + implémentation Drift (local-first)
- `di/riverpod_di.dart` - Provider `calendarCourseRepositoryProvider`
- `presentation/add/add_calendar_course_page.dart` - Modal d'ajout de séance
- `presentation/calendar/controller/calendar_controller.dart` - Liste des séances
- `presentation/supply_list/controller/tomorrow_supply_controller.dart` - Fournitures du jour

## Dépendances principales
- `flutter_riverpod` / `riverpod_annotation`
- `drift` - Base de données locale
- `uuid` - Génération d'IDs locaux
- `clock` - Gestion du temps (testable)
- `dartz`
- `common` (handleErrors, AppDatabase, PreferencesService, WeekUtils)
- `course` (pour lier les séances aux cours)

## Table Drift
- `CalendarCourses` - Séances de l'emploi du temps (local uniquement)
  - id, remoteId, courseId, roomName
  - startHour, startMinute, endHour, endMinute
  - weekType (BOTH/A/B), dayOfWeek (1-7)

## Notes
- Le `TomorrowSupplyController` invalide son cache lors d'un import pour recalculer les fournitures
- `WeekType` enum : BOTH (toutes les semaines), A, B
- Batch queries optimisées pour éviter N+1 (voir getTomorrowCourses)
