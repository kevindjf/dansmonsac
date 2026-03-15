# Mémo — Memory Manager (Projet local)

## Notes spécifiques à ce projet

### Analyse mémoire globale - 2025-03-15
✅ **PROMU EN GLOBAL** : Patterns et conventions du projet dansmonsac
- Architecture Local-First avec Drift + remoteId nullable
- Git workflow 3-branches (main/staging/feature) avec fast-forward
- Repository pattern avec handleErrors() wrapper
- Service logging centralisé avec niveaux par build
- Validation + messages d'erreur centralisés
- Architecture feature-based avec DI locale
- Convention UI edge-to-edge avec safe areas
- Workflow git pour stories BMAD avec isolation complète
- Erreur Android 16Ko plugin alignment requirement
- Erreur versioning Flutter pour store uploads

### Patterns locaux spécifiques à dansmonsac
- **DefaultSupplies** : Données métier pour matières scolaires françaises avec aliases
- **Migration one-shot** : Supabase → Drift au démarrage (idempotente)
- **ScheduleSerializer** : Export/import manuel pour partage via QR codes
- **Theme sombre** : Couleurs spécifiques `0xFFB9A0FF`, `0xFF212121`, `0xFF424242`

## Erreurs rencontrées ici

*Aucune erreur spécifique documentée pour ce projet à ce jour.*


