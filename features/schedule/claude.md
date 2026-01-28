# Module Schedule

## Description
Module de gestion de l'emploi du temps. Permet d'ajouter des séances de cours au calendrier hebdomadaire et de calculer les fournitures nécessaires pour le lendemain.

## Responsabilités
- CRUD des séances (CalendarCourse)
- Affichage du calendrier hebdomadaire
- Calcul des fournitures du lendemain (TomorrowSupply)
- Gestion des semaines A/B

## Architecture
- **Pattern Repository** avec `CalendarCourseRepository` et `CalendarCourseSupabaseRepository`
- **Gestion d'erreurs** via `Either<Failure, T>`
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
- `repository/calendar_course_repository.dart` - Interface + implémentation Supabase
- `di/riverpod_di.dart` - Provider `calendarCourseRepositoryProvider`
- `presentation/add/add_calendar_course_page.dart` - Modal d'ajout de séance
- `presentation/calendar/controller/calendar_controller.dart` - Liste des séances
- `presentation/supply_list/controller/tomorrow_supply_controller.dart` - Fournitures du jour

## Dépendances principales
- `flutter_riverpod` / `riverpod_annotation`
- `supabase_flutter`
- `dartz`
- `common` (handleErrors, PreferenceRepository)
- `course` (pour lier les séances aux cours)

## Tables Supabase
- `calendar_courses` - Séances de l'emploi du temps
  - id, device_id, course_id, room_name
  - start_time_hour, start_time_minute, end_time_hour, end_time_minute
  - week_type (BOTH/A/B), day_of_week (1-7)

## Notes
- Le `TomorrowSupplyController` invalide son cache lors d'un import pour recalculer les fournitures
- `WeekType` enum : BOTH (toutes les semaines), A, B
