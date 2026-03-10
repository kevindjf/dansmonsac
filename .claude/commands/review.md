Review le code modifié en vérifiant :

## Checklist
1. Conformité au plan de l'architecte (si plan fourni)
2. Pas de code mort, pas de commentaires inutiles
3. Nommage clair et cohérent avec le reste du projet
4. Gestion d'erreurs (pas de catch vide, feedback utilisateur)
5. Pas de logique dupliquée (vérifier si ça existe déjà ailleurs)
6. Conventions du projet (.claude/CONVENTIONS.md)

## Réponse
JSON uniquement, court :
```json
{"verdict": "APPROVE" ou "CHANGES_REQUESTED", "summary": "1-2 phrases", "issues": [{"severity": "critical|major|minor", "file": "...", "description": "court"}]}
```
Max 5 issues. Focus sur critical/major uniquement.
