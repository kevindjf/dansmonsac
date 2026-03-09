# Module Sharing

## Description
Module de partage d'emploi du temps entre utilisateurs. Permet de générer un code de partage, d'afficher un QR code, et d'importer l'emploi du temps d'un ami via code ou deep link.

## Responsabilités
- Génération de code de partage (6 caractères)
- Affichage QR code pour partage
- Upload manuel des données vers Supabase (via bouton "Partager")
- Import d'emploi du temps via code (fetch Supabase → insert Drift)
- Gestion des conflits lors de l'import
- Deep links (`dansmonsac://share/CODE`)

## Flux de Partage (Local → Supabase)
1. User clique "Partager"
2. ShareController → ScheduleSerializer lit toutes les données de Drift (courses, supplies, calendar_courses)
3. Serialization en SharedScheduleData (JSON)
4. Upload vers Supabase table `shared_schedules` (upsert par code)
5. QR code généré avec deep link

## Flux d'Import (Supabase → Local)
1. User scanne QR ou entre code
2. ImportController fetch SharedScheduleData depuis Supabase
3. Détection de conflits avec données locales Drift
4. Résolution conflits (keep/replace/merge)
5. Insert dans Drift (courses, supplies, calendar_courses)
6. Données immédiatement visibles dans l'app

## Architecture
- **Pattern Repository** avec `SharingRepository` et `SharingSupabaseRepository`
- **Gestion d'erreurs** via `Either<Failure, T>`
- **Models** :
  - `SharedSchedule` - Enregistrement Supabase complet
  - `SharedScheduleData` - Données JSON (cours + séances)
  - `ImportResult` - Résultat d'import avec conflits

## State Management
- **Riverpod** avec `@riverpod` annotations
- Controllers :
  - `ShareController` - Génération de code, sync vers Supabase
  - `ImportController` - Fetch par code, import des données

## Fichiers clés
- `models/shared_schedule.dart` - Modèle de partage Supabase
- `models/shared_schedule_data.dart` - Structure JSON des données partagées
- `repository/sharing_repository.dart` - Interface abstraite
- `repository/sharing_supabase_repository.dart` - Implémentation Supabase (upload/fetch)
- `services/schedule_serializer.dart` - Sérialisation Drift → JSON
- `services/code_generator.dart` - Génération code 6 caractères
- `services/deep_link_service.dart` - Gestion deep links
- `presentation/share/share_page.dart` - Modal de partage avec QR
- `presentation/share/controller/share_controller.dart` - Logique de partage (utilise ScheduleSerializer)
- `presentation/import/controller/import_controller.dart` - Logique d'import (fetch Supabase → insert Drift)
- `presentation/import/import_preview_page.dart` - Aperçu avant import
- `presentation/import/import_conflict_dialog.dart` - Résolution conflits

## Dépendances principales
- `flutter_riverpod` / `riverpod_annotation`
- `supabase_flutter`
- `dartz`
- `qr_flutter` - Génération QR code
- `share_plus` - Partage natif
- `common`, `course`, `schedule`

## Table Supabase
- `shared_schedules`
  - id (UUID), code (VARCHAR(6) UNIQUE), sharer_name, data (JSONB), created_at
  - **RLS** : Policies doivent permettre INSERT/UPDATE/SELECT

## Structure JSON `data`
```json
{
  "courses": [{"name": "Maths", "supplies": ["Calculatrice"]}],
  "calendar_courses": [{
    "course_name": "Maths",
    "room_name": "101",
    "start_time_hour": 8, "start_time_minute": 0,
    "end_time_hour": 9, "end_time_minute": 0,
    "week_type": "BOTH",
    "day_of_week": 1
  }]
}
```

## Scan QR Code — Points d'attention
- Le QR code encode un deep link : `dansmonsac://share/CODE`
- **Bug corrigé** : `_extractCodeFromBarcode` faisait `.toUpperCase()` sur la valeur brute AVANT le regex, ce qui transformait le scheme en `DANSMONSAC://SHARE/...` et cassait le match. Le regex doit être `caseSensitive: false` et s'appliquer sur la valeur brute originale. Seul le code extrait (groupe capturé) doit être passé en `.toUpperCase()`.
- **Duplication** : La logique de scan QR (`_openQrScanner`, `_extractCodeFromBarcode`) existe en deux endroits :
  1. `features/onboarding/lib/src/presentation/import/import_step_page.dart` (onboarding)
  2. `features/main/lib/presentation/home/settings_page.dart` (paramètres)
  - Toute correction doit être appliquée aux **deux** fichiers.
- Le widget `CodeInputWidget` (dans `presentation/widgets/code_input_widget.dart`) est partagé et utilisé par les deux pages.

## Notes importantes
- `@JsonSerializable(explicitToJson: true)` requis pour sérialiser les objets imbriqués
- Le partage est MANUEL : l'upload vers Supabase se fait uniquement quand l'utilisateur clique "Partager"
- Le state `syncFailed` permet d'afficher un avertissement et bouton de retry
- Les RLS policies Supabase doivent autoriser les UPDATE (bug rencontré)
- ImportController utilise les repositories Drift-only (CourseDriftRepository, CalendarCourseRepository)
