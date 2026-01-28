# Module Main

## Description
Module principal de l'application. Contient la page d'accueil avec la navigation par onglets et les différentes vues principales (fournitures du jour, calendrier, cours, paramètres).

## Responsabilités
- Navigation principale avec BottomNavigationBar
- Page "Mon sac" (fournitures à préparer pour demain)
- Page "Calendrier" (emploi du temps hebdomadaire)
- Page "Paramètres"
- Page "Aide"

## Architecture
- **Single Page Architecture** avec changement de contenu via état
- **Enum** `HomeViewPage` pour représenter les différentes vues
- **Aucun repository** - Ce module orchestre les autres modules

## State Management
- **Riverpod** avec `@riverpod` annotations
- Controller principal :
  - `HomeController` - Gestion de la navigation entre onglets
  - State: `HomeStateUi(index, page)`

## Fichiers clés
- `presentation/home/home_page.dart` - Page principale avec navigation
- `presentation/home/list_supply_page.dart` - Vue "Mon sac" (fournitures du jour)
- `presentation/home/calendar_page.dart` - Vue emploi du temps + bouton partage
- `presentation/home/settings_page.dart` - Paramètres (heure de notification, partage, import)
- `presentation/home/help_page.dart` - Page d'aide
- `presentation/home/controller/home_controller.dart` - Logique de navigation

## Dépendances principales
- `flutter_riverpod` / `riverpod_annotation`
- `common` (navigation, services)
- `course` (affichage des cours)
- `schedule` (emploi du temps, fournitures du jour)
- `sharing` (modal de partage)

## Notes
- La vue "Mon sac" affiche les fournitures à préparer en fonction des cours du lendemain
- Le bouton de partage est intégré dans `calendar_page.dart`
- Les paramètres incluent l'option d'import d'emploi du temps

## Import & Scan QR (settings_page.dart)
- `settings_page.dart` contient sa propre copie de `_openQrScanner` et `_extractCodeFromBarcode` (dupliquée depuis l'onboarding).
- **Toute modification du scan QR doit aussi être appliquée ici** — voir aussi `features/onboarding/lib/src/presentation/import/import_step_page.dart`.
- Le bottom sheet du scanner doit inclure `viewPadding.bottom` pour le edge-to-edge.
