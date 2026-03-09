# Erreurs connues - DansMonSac

## [flutter] [ui] [callback] Vacation mode callback bloque bottom sheet
**Date** : 2026-03-09 (KAP-31)
**Symptômes** : Bottom sheet vacation mode ne se ferme plus après interaction
**Cause** : Callback sans try-catch → exception non gérée bloque l'UI
**Fix** : Ajout try-catch défensif autour de la logique vacation mode
**Leçon** : Tous les callbacks UI async doivent avoir exception handling

## [flutter] [notifications] [sync] Notifications non reprogrammées après ajout cours
**Date** : 2026-03-09 (KAP-32)
**Symptômes** : Notifications obsolètes ou manquantes après modification du calendrier
**Cause** : Ajout cours au calendrier sans mise à jour des notifications associées
**Fix** : Hook automatique de resync notifications lors modification données planning
**Leçon** : Toute modification données avec notifications doit inclure resynchronisation