# Emma — Reviewer Senior (Projet local)

## Notes spécifiques à ce projet


## Patterns locaux


## Erreurs rencontrées ici

### KAP-32 Architecture notifications fragmentée détectée en review (2026-03-09)
- **Fix initial** : Notifications non reprogrammées après ajout cours calendrier
- **Issues systémiques trouvées** :
  - Synchronisation notifications dispersée dans plusieurs services sans coordination
  - Absence de tests intégration pour valider cohérence calendrier ↔ notifications
  - State management cours/planning fragmenté entre features
  - Patterns de désynchronisation similaires dans autres flows (supplies, schedules)
- **Actions requises** : Refactoring architecture notifications centralisée + tests robustes


