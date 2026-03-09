# Emma — Reviewer Senior (Projet local)

## Notes spécifiques à ce projet


## Patterns locaux


## Erreurs rencontrées ici

### KAP-31 Exception handling issues détectées en review (2026-03-09)
- **Fix initial** : Callback vacation mode sans try-catch bloquait bottom sheet
- **Issues supplémentaires trouvées** :
  - Patterns similaires dans d'autres UI interactions
  - Tests manquants pour cas d'erreur UI critiques
  - Inconsistance dans gestion d'erreurs entre features
- **Actions requises** : Audit complet exception handling + tests défensifs uniformes


