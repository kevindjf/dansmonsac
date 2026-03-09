# Erreurs connues - DansMonSac

## [flutter] [ui] [callback] Vacation mode callback bloque bottom sheet
**Date** : 2026-03-09 (KAP-31)
**Symptômes** : Bottom sheet vacation mode ne se ferme plus après interaction
**Cause** : Callback sans try-catch → exception non gérée bloque l'UI
**Fix** : Ajout try-catch défensif autour de la logique vacation mode
**Leçon** : Tous les callbacks UI async doivent avoir exception handling