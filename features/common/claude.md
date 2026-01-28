# Module Common

## Description
Module utilitaire partagé entre tous les autres modules de l'application. Il contient les services, modèles, widgets et helpers communs.

## Responsabilités
- Services partagés (PreferencesService, NotificationService)
- Modèles de base (Failure, NetworkFailure)
- Widgets UI réutilisables
- Helpers pour les repositories (handleErrors)
- Navigation et routing (RouterDelegate)
- Injection de dépendances partagées

## Architecture
- **Pattern Repository** avec gestion d'erreurs via `Either<Failure, T>` (package dartz)
- **Services statiques** pour les préférences et notifications
- **Dependency Injection** via Riverpod

## State Management
- **Riverpod** pour l'injection de dépendances (`@riverpod` annotations)

## Fichiers clés
- `services/preferences_service.dart` - Gestion des SharedPreferences
- `repository/repository_helper.dart` - Helper `handleErrors()` pour wrapper les appels async
- `di/riverpod_di.dart` - Providers Riverpod partagés
- `navigation/routes.dart` - Configuration du routing

## Règles UI
- **Edge-to-edge** : Lors de la création d'une vue (`Scaffold`, page plein écran), toujours vérifier que le contenu respecte les safe areas (`SafeArea`, `viewPadding`, `viewInsets`).
- **Bottom sheets** : Toujours inclure `MediaQuery.of(context).viewPadding.bottom` dans le padding inférieur pour que le contenu ne soit pas masqué par la barre de navigation système.

## Dépendances principales
- `flutter_riverpod` / `riverpod_annotation`
- `shared_preferences`
- `dartz` (Either pour la gestion d'erreurs)
- `supabase_flutter`
