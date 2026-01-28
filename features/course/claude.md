# Module Course

## Description
Module de gestion des cours (matières). Permet d'ajouter, lister et supprimer des cours avec leurs fournitures associées.

## Responsabilités
- CRUD des cours (Create, Read, Delete)
- Association cours ↔ fournitures
- Affichage de la liste des cours avec leurs fournitures

## Architecture
- **Pattern Repository** avec classe abstraite `CourseRepository` et implémentation `CourseSupabaseRepository`
- **Gestion d'erreurs** via `Either<Failure, T>` (package dartz)
- **Models** :
  - `CourseWithSupplies` - Cours avec sa liste de fournitures
  - `AddCourseCommand` - Commande pour créer un cours

## State Management
- **Riverpod** avec `@riverpod` annotations
- Controllers :
  - `CoursesController` - Gestion de la liste des cours
  - `AddCourseController` - Logique d'ajout de cours

## Fichiers clés
- `repository/course_repository.dart` - Interface abstraite
- `repository/course_supabase_repository.dart` - Implémentation Supabase
- `di/riverpod_di.dart` - Provider `courseRepositoryProvider`
- `presentation/list/courses_page.dart` - Page de liste des cours
- `presentation/add/add_course_page.dart` - Modal d'ajout de cours

## Dépendances principales
- `flutter_riverpod` / `riverpod_annotation`
- `supabase_flutter`
- `dartz`
- `common` (pour `handleErrors`, `Failure`, `PreferenceRepository`)

## Tables Supabase
- `courses` - Stockage des cours (id, device_id, name)
- `supplies` - Fournitures liées aux cours (id, course_id, name)
