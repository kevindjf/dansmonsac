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

## Git Workflow pour Stories BMAD (IMPORTANT)

- **REGLE CRITIQUE** : Chaque story BMAD doit avoir sa propre branche Git dediee
- **Avant de commencer une story** :
  1. Verifier si une branche dediee existe pour la story
  2. Si NON, **demander a Kevin de creer la branche** avant de commencer l'implementation
  3. Ne JAMAIS implementer une story sur une branche partagee avec d'autres features

- **Naming convention pour branches story** :
  - Format : `feature/{story-key}`
  - Exemple : `feature/1-1-extract-default-supplies-utility`
  - Le story-key correspond au nom du fichier story (sans .md)

- **Pourquoi c'est important** :
  - Facilite les code reviews (seuls les fichiers de la story sont modifies)
  - Permet des commits atomiques par story
  - Evite la confusion entre stories multiples
  - Simplifie le tracking git des changements

- **Workflow complet pour une story** :
  ```bash
  # Kevin cree la branche
  git checkout staging
  git checkout -b feature/1-2-supply-suggestions

  # Agent implemente la story
  # ... code changes ...

  # Agent commite atomiquement
  git add <fichiers de la story uniquement>
  git commit -m "Story 1.2: Implement supply suggestions at course creation"

  # Merge dans staging quand story est done
  git checkout staging
  git merge --ff-only feature/1-2-supply-suggestions
  ```

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
- Backend : Supabase (pour partage uniquement)
- Pattern Repository avec `Either<Failure, T>` (dartz)
- **Base de donnees locale** : Drift (SQLite) pour architecture local-first

## Architecture Local-First

Le projet utilise une architecture 100% locale avec partage manuel vers Supabase :

### Composants cles

1. **AppDatabase** (`features/common/lib/src/database/app_database.dart`)
   - Tables : Courses, Supplies, CalendarCourses, DailyChecks, BagCompletions, PremiumStatus
   - Chaque entite a un `remoteId` nullable (pour debugging)
   - Schema version 4

2. **Providers** (`features/common/lib/src/providers/database_provider.dart`)
   - `databaseProvider` : instance AppDatabase

3. **MigrationService** (`features/common/lib/src/services/migration_service.dart`)
   - Migration une seule fois au demarrage (Supabase → Drift)
   - Idempotente avec verification `remoteId`

### Flux de donnees

```
UI → Controller → Local Database (Drift)
                       ↓
           (Aucune sync automatique)

Partage manual :
UI → ShareController → ScheduleSerializer → Supabase (shared_schedules table)

Import :
UI → ImportController → Supabase fetch → Drift insert
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
