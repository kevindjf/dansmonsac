# Module Supply

## Description
Module de gestion des fournitures scolaires. Permet d'ajouter et supprimer des fournitures associées aux cours.

## Responsabilités
- CRUD des fournitures (Create, Delete)
- Association fourniture ↔ cours

## Architecture
- **Pattern Repository** avec `SupplyRepository` et `SupplySupabaseRepository`
- **Gestion d'erreurs** via `Either<Failure, T>`
- **Models** :
  - `Supply` - Modèle de fourniture (id, name, courseId)
  - `AddSupplyCommand` - Commande pour créer une fourniture

## State Management
- **Riverpod** avec `@riverpod` annotations
- Controller :
  - `AddSupplyController` - Logique d'ajout de fourniture

## Fichiers clés
- `models/supply.dart` - Modèle de fourniture
- `models/command/add_supply_command.dart` - Commande d'ajout
- `repository/supply_repository.dart` - Interface abstraite
- `repository/supply_supabase_repository.dart` - Implémentation Supabase
- `di/riverpod_di.dart` - Provider `supplyRepositoryProvider`
- `presentation/add/add_supply_page.dart` - Modal d'ajout de fourniture
- `presentation/add/controller/add_supply_controller.dart` - Logique d'ajout

## Dépendances principales
- `flutter_riverpod` / `riverpod_annotation`
- `supabase_flutter`
- `dartz`
- `common` (handleErrors, PreferenceRepository)

## Table Supabase
- `supplies`
  - id (UUID), course_id (FK), name, created_at

## Notes
- Les fournitures sont toujours liées à un cours
- L'affichage des fournitures se fait dans le module `course` (ContentSuppliesHolder)
- Le module `schedule` utilise les fournitures pour calculer le sac du lendemain
