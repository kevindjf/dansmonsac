# Module Onboarding

## Description
Module de configuration initiale de l'application. Guide l'utilisateur à travers les étapes de paramétrage : année scolaire, heure de notification, import optionnel d'emploi du temps, et permission de notifications.

## Responsabilités
- Écran de bienvenue
- Configuration de l'année scolaire (week A/B)
- Explication des semaines A/B
- Configuration de l'heure de préparation du sac
- Import d'emploi du temps (optionnel, via code ou QR)
- Demande de permission de notifications
- Création des cours par défaut

## Architecture
- **Pattern Repository** avec `OnboardingRepository` et `OnboardingSupabaseRepository`
- **Flow linéaire** : Welcome → SchoolYear → WeekExplanation → SetupTime → ImportStep → NotificationPermission
- **Gestion d'erreurs** via `Either<Failure, T>`

## State Management
- **Riverpod** avec `@riverpod` annotations
- Controllers :
  - `SchoolYearOnboardingController` - Configuration semaine A/B
  - `SetupTimeOnboardingController` - Heure de notification
  - `CourseOnboardingController` - Création cours par défaut

## Fichiers clés
- `presentation/welcome/welcome_page.dart` - Écran de bienvenue
- `presentation/school_year/school_year_page.dart` - Configuration année scolaire
- `presentation/week_explanation/week_explanation_page.dart` - Explication semaines A/B
- `presentation/hour/setup_time_page.dart` - Configuration heure de notification
- `presentation/import/import_step_page.dart` - Import via code/QR (avec scanner)
- `presentation/notifications/notification_permission_page.dart` - Permission notifications
- `repositories/onboarding_repository.dart` - Interface repository
- `data/default_courses.dart` - Liste des cours par défaut

## Dépendances principales
- `flutter_riverpod` / `riverpod_annotation`
- `supabase_flutter`
- `dartz`
- `mobile_scanner` - Scanner QR code
- `common` (PreferencesService, navigation)
- `sharing` (ImportController pour l'import d'emploi du temps)

## Notes
- L'import step permet de scanner un QR code ou entrer manuellement un code à 6 caractères
- Le bouton "Commencer" après NotificationPermission marque l'onboarding comme terminé
- Le scanner QR utilise la caméra (permissions requises dans Info.plist et AndroidManifest.xml)
