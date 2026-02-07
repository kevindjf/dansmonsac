# Module Streak

## Description
Module de suivi des streaks (séries) de préparation de sac. Permet de calculer et afficher le nombre de jours consécutifs où l'élève a préparé son sac, créant ainsi une motivation par la formation d'habitudes.

## Responsabilités
- Calcul du streak actuel (jours consécutifs de préparation)
- Accès à l'historique des préparations de sac (BagCompletions)
- Enregistrement des complétions de préparation de sac
- Détection des jours d'école vs jours sans cours (weekends, vacances)
- Gestion de la rupture de streak et reset

## Architecture
- **Pattern Repository** avec `StreakRepository` pour la logique métier
- **Gestion d'erreurs** via `Either<Failure, T>` (package dartz)
- **Data source** : Table Drift `BagCompletions` (locale, synchro via SyncManager)
- **Models** :
  - `StreakData` - Données de streak (count, last completion, history)

## State Management
- **Riverpod** avec `@riverpod` annotations
- Providers :
  - `streakRepositoryProvider` - Instance du repository
  - `currentStreakProvider` - Streak actuel (compteur)

## Fichiers clés
- `repository/streak_repository.dart` - Logique de calcul de streak
- `di/riverpod_di.dart` - Providers Riverpod
- `models/streak_data.dart` - Model de données de streak
- `presentation/widgets/streak_counter_widget.dart` - Widget d'affichage du compteur (Story 2.5)
- `presentation/controller/streak_controller.dart` - Contrôleur UI (Story 2.5)

## Dépendances principales
- `flutter_riverpod` / `riverpod_annotation`
- `dartz` (Either<Failure, T>)
- `common` (pour `AppDatabase`, `LogService`, `handleErrors`, `Failure`)

## Tables Drift (via common/AppDatabase)
- `BagCompletions` - Historique des préparations complétées (id, date, completedAt, deviceId)
  - Utilisé pour calculer le streak actuel
  - Une entrée par jour où le sac a été préparé
- `DailyChecks` - Fournitures cochées par jour (non utilisé directement dans streak, mais sert à détecter la complétion)

## Logique de Streak
**Calcul du streak actuel :**
1. Récupérer toutes les BagCompletions triées par date DESC
2. Filtrer uniquement les jours d'école (ignorer weekends/vacances via timetable)
3. Compter les jours consécutifs depuis aujourd'hui
4. Si un jour d'école est manquant → streak rompu → reset à 0

**Jours d'école vs non-école :**
- Un jour est considéré "jour d'école" si le timetable contient au moins un cours pour ce jour
- Weekends sans cours ne cassent PAS le streak
- Vacances sans cours ne cassent PAS le streak

## Stories associées
- **Story 2.2** : Create Streak Module Foundation (current - foundation)
- **Story 2.3** : Implement Daily Checklist Persistence (DailyChecks)
- **Story 2.4** : Implement Streak Calculation Logic (calcul complet)
- **Story 2.5** : Create Streak Counter UI Widget (UI)
- **Story 2.6** : Implement Bag Ready Confirmation (trigger streak increment)

## Offline-First
- Toutes les opérations fonctionnent offline (Drift local)
- BagCompletions synchronisé avec Supabase via SyncManager (common)
- Pas de dépendance réseau pour calculer ou afficher le streak

## Règles d'implémentation (CRITICAL)
- **Logging** : TOUJOURS utiliser `LogService`, JAMAIS `print()`
- **Error handling** : Utiliser `handleErrors()` pour toutes les opérations async
- **Naming** : snake_case pour fichiers, PascalCase pour classes, camelCase pour variables
- **Tests** : 100% de tests requis avant de marquer une task complète
- **Code generation** : Exécuter `build_runner` après modifications des `@riverpod` annotations
