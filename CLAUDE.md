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

## Architecture

- Projet modulaire avec feature packages dans `features/` (common, main, course, schedule, supply, onboarding, sharing, splash)
- State management : Riverpod avec `@riverpod` annotations + code generation
- Backend : Supabase
- Pattern Repository avec `Either<Failure, T>` (dartz)

## Regles UI

- **Edge-to-edge** : toujours utiliser `MediaQuery.of(context).viewPadding.bottom` dans les bottom sheets
- **Bottom sheets** : preferer `showModalBottomSheet` aux `AlertDialog` pour les formulaires
- **Theme sombre** : accent `0xFFB9A0FF`, background `0xFF212121`, surface `0xFF424242`
