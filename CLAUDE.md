# DansMonSac - Instructions Claude

## Build & Release

- **Avant chaque build release** (`flutter build appbundle`, `flutter build ipa`, etc.), toujours incrementer la version dans `pubspec.yaml` :
  - Format : `version: MAJOR.MINOR.PATCH+BUILD` (ex: `1.0.3+3`)
  - Le **build number** (`+N`) doit etre incremente a chaque upload sur le store (Android versionCode / iOS build number)
  - Le **versionName** (`MAJOR.MINOR.PATCH`) doit etre incremente selon la nature des changements (patch = bugfix, minor = feature, major = breaking)

## Plugins natifs (Android 16 ko)

- Google Play exige que les libs natives (.so) soient alignees sur 16 ko
- Avant d'ajouter un plugin avec du code natif (camera, scanner, ML, audio, video, crypto), verifier qu'il supporte l'alignement 16 ko
- Les plugins purement Dart ne sont pas concernes
- En cas de doute, tester en upload test interne sur Play Console

## Git Workflow

- **Branches** :
  - `main` : branche de production, toujours stable
  - `staging` : branche de pre-production, contient les modifications validees en cours
  - `feature/*` ou `fix/*` : branches de travail pour chaque modification

- **Avant toute modification de code**, creer une nouvelle branche a partir de `staging` :
  ```bash
  git checkout staging
  git checkout -b feature/nom-de-la-feature
  ```

- **Commits** : commiter regulierement sur la branche de travail

- **Merge dans staging** : une fois la feature terminee, merger la branche dans `staging` en fast-forward :
  ```bash
  git checkout staging
  git merge --ff-only feature/nom-de-la-feature
  ```
  Si le fast-forward echoue, rebaser la branche sur staging d'abord :
  ```bash
  git checkout feature/nom-de-la-feature
  git rebase staging
  ```

- **Merge dans main** : uniquement quand tout est valide sur staging, merger staging dans main :
  ```bash
  git checkout main
  git merge staging
  ```

- **Ne jamais commiter directement sur `main` ou `staging`**

## Environment Setup

- **Credentials** : Les credentials Supabase sont dans `.env` (gitignored)
- **Template** : Copier `.env.example` vers `.env` et remplir les valeurs
- **Variables requises** :
  ```
  SUPABASE_URL=https://xxx.supabase.co
  SUPABASE_ANON_KEY=eyJhbGci...
  ```

## Architecture

- Projet modulaire avec feature packages dans `features/` (common, main, course, schedule, supply, onboarding, sharing, splash)
- State management : Riverpod avec `@riverpod` annotations + code generation
- Backend : Supabase
- Pattern Repository avec `Either<Failure, T>` (dartz)
- **Base de donnees locale** : Drift (SQLite) pour offline-first

## Architecture Offline-First

Le projet utilise une architecture offline-first avec synchronisation automatique :

### Composants cles

1. **AppDatabase** (`features/common/lib/src/database/app_database.dart`)
   - Tables : Courses, Supplies, CalendarCourses, PendingOperations
   - Chaque entite a un `remoteId` pour mapper avec Supabase
   - Schema version 2

2. **SyncManager** (`features/common/lib/src/sync/sync_manager.dart`)
   - Ecoute les changements de connectivite
   - Synchronise automatiquement quand le reseau revient
   - Queue des operations dans `PendingOperations`

3. **Providers** (`features/common/lib/src/providers/database_provider.dart`)
   - `databaseProvider` : instance AppDatabase
   - `syncManagerProvider` : instance SyncManager
   - `syncStatusProvider` : stream du statut de sync

### Flux de donnees

```
UI → Controller → Local Database → SyncManager → Supabase
                       ↓
              PendingOperations (queue)
```

## Utilitaires

### Logging (`features/common/lib/src/services/log_service.dart`)

Utiliser `LogService` au lieu de `print()` :
```dart
LogService.d('Debug message');     // Debug (dev only)
LogService.i('Info message');      // Info
LogService.w('Warning message');   // Warning
LogService.e('Error message', error, stackTrace);  // Error
```

### Validation (`features/common/lib/src/utils/validators.dart`)

```dart
// Valider les inputs
final error = Validators.validateCourseName(name);  // max 50 chars
final error = Validators.validateSupplyName(name);  // max 100 chars
final error = Validators.validateRoomName(name);    // max 30 chars

// Nettoyer (trim)
final cleaned = Validators.clean(input);
```

### Messages d'erreur (`features/common/lib/src/utils/error_messages.dart`)

```dart
// Convertir Failure en message utilisateur
final message = ErrorMessages.getMessageForFailure(failure);
```

## Regles UI

- **Edge-to-edge** : toujours utiliser `MediaQuery.of(context).viewPadding.bottom` dans les bottom sheets
- **Bottom sheets** : preferer `showModalBottomSheet` aux `AlertDialog` pour les formulaires
- **Theme sombre** : accent `0xFFB9A0FF`, background `0xFF212121`, surface `0xFF424242`

## Code Generation

Apres modification des fichiers avec annotations `@riverpod` ou des tables Drift :
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

Ou pour le module common specifiquement :
```bash
cd features/common && flutter pub run build_runner build --delete-conflicting-outputs
```
