---
name: review
description: Checklist review Flutter/Supabase avec 18 règles par sévérité. Utiliser pour reviewer du code, vérifier la conformité clean architecture, valider une PR.
target: emma
stack: flutter, supabase
keywords: review, reviewer, vérifier, valider, PR, pull request, code review, quality
---

Review le code modifié en vérifiant ces règles NON-NÉGOCIABLES :

## Clean Architecture (CRITICAL — bloquer si violé)
1. **Domain pur** : ZÉRO `import 'package:flutter'` dans `domain/`. Dart uniquement
2. **Use cases** : Le provider appelle un use case, JAMAIS un repository directement
3. **Entities vs Models** : Entity dans domain/ (pure, @freezed), Model dans data/ (fromJson/toJson)
4. **Dependency inversion** : domain/ ne dépend de RIEN (ni data/, ni presentation/)
5. **Repository interfaces** dans domain/, implémentations dans data/

## Presentation (MAJOR — bloquer si violé)
6. **1 widget = 1 fichier** : Pas de _PrivateWidget en bas du fichier
7. **build() ≤ 50 lignes** : Au-delà → extraire en widget séparé, PAS en méthode _build()
8. **ZÉRO logique métier** dans les widgets : le widget AFFICHE, le provider DÉCIDE
9. **ZÉRO en dur** : couleurs → ThemeExtension, strings → context.l10n, spacing → AppDimensions
10. **ConsumerWidget** préféré. StatefulWidget UNIQUEMENT pour state UI local (AnimationController)

## State Management (MAJOR)
11. **@riverpod generator** obligatoire : PAS de providers manuels `final xProvider = ...`
12. **AsyncValue.when** : TOUJOURS gérer data, loading, error (les 3)
13. **Un provider = une responsabilité** : split si fait 2 choses

## Code Quality (MAJOR/MINOR)
14. Conformité au plan de l'architecte (si fourni)
15. Pas de code mort, pas de commentaires inutiles
16. Gestion d'erreurs (pas de catch vide, pas de `catch (e) {}`)
17. Pas de logique dupliquée (vérifier si ça existe déjà)
18. Conventions du projet (.claude/CONVENTIONS.md)

## Réponse
JSON uniquement, court :
```json
{"verdict": "APPROVE" ou "CHANGES_REQUESTED", "summary": "1-2 phrases", "issues": [{"severity": "critical|major|minor", "file": "...", "line": 0, "description": "court"}]}
```
Max 5 issues. Les règles 1-5 sont CRITICAL, 6-13 sont MAJOR, 14-18 sont MINOR.
CHANGES_REQUESTED si au moins 1 critical ou 2 major.
