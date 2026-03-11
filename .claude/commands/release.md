---
name: release
description: Procédure complète de release Flutter - bump version, build appbundle/IPA, changelog, critères Go/No-Go calibrés. Utiliser quand on prépare une release, monte la version, ou build pour le store.
target: hugo
stack: flutter, android, ios
keywords: release, version, build, appbundle, ipa, store, deploy, changelog, bump, numéro de version, play store, testflight
---

Procédure de release Flutter — suis ces étapes dans l'ordre :

## Step 1 : Vérifier la branche

- Doit être sur `main` ou `staging`
- Si feature branch → STOP, ne pas release depuis une feature branch

## Step 2 : Bump version dans pubspec.yaml

1. Lire la version actuelle : `grep '^version:' pubspec.yaml`
2. Lire le dernier tag : `git describe --tags --abbrev=0 2>/dev/null`
3. Déterminer le type de bump selon les commits depuis le dernier tag :
   - `feat:` → MINOR (1.0.0 → 1.1.0)
   - `fix:` / `security:` → PATCH (1.0.0 → 1.0.1)
   - `BREAKING:` ou refonte → MAJOR (1.0.0 → 2.0.0)
4. TOUJOURS incrémenter le build number (+N → +N+1)
5. Modifier `pubspec.yaml` : `version: X.Y.Z+BUILD`
6. VÉRIFIER que la nouvelle version est strictement supérieure à l'ancienne

## Step 3 : Tests

1. Lancer `flutter test`
2. Critère GO : **100% des tests passent**
3. Critère NO-GO : **≥1 test en échec**
4. Si NO-GO → STOP, lister les tests qui échouent

## Step 4 : Analyze

1. Lancer `flutter analyze`
2. Compter UNIQUEMENT les lignes contenant `error` (niveau error)
3. IGNORER COMPLÈTEMENT :
   - Tous les `warning` — ne comptent pas
   - Tous les `info` — ne comptent pas
   - `implementation_imports` — architecture modulaire, normal
   - `invalid_dependency` (path) — monorepo Flutter, normal
   - `deprecated_member_use` (withOpacity) — cosmétique
4. Critère GO : **0 error**
5. Critère NO-GO : **≥1 error**
6. Reporter le nombre de warnings pour info, mais ils NE BLOQUENT PAS

## Step 5 : Git clean

1. Lancer `git status --porcelain`
2. IGNORER ces fichiers/dossiers modifiés :
   - `.claude/**` — config Claude
   - `.idea/**` — config IDE
   - `*.iml` — config IntelliJ
   - Tout fichier listé dans `.gitignore`
3. Critère GO : **aucun fichier source modifié** (lib/, test/, pubspec.*, android/, ios/)
4. Critère NO-GO : **fichiers source modifiés non commités**

## Step 6 : Changelog

1. `git log $(git describe --tags --abbrev=0 2>/dev/null || echo HEAD~20)..HEAD --oneline`
2. Grouper : Features, Fixes, Security, Other
3. Écrire en tête de `CHANGELOG.md` (créer si inexistant) :
```
## vX.Y.Z (YYYY-MM-DD)

### Features
- Description (KAP-XX)

### Fixes
- Description (KAP-XX)
```

## Step 7 : Build Android

1. `flutter build appbundle --release`
2. Artifact : `build/app/outputs/bundle/release/app-release.aab`
3. Vérifier que le fichier existe
4. Si erreur signing/keystore → reporter mais NE PAS bloquer toute la release

## Step 8 : Build iOS (si Mac)

1. `flutter build ipa --release`
2. Si erreur signing/provisioning → reporter, NE PAS bloquer la release Android
3. Kevin gère les certificats iOS manuellement

## Step 9 : Commit et tag

1. `git add pubspec.yaml CHANGELOG.md`
2. `git commit -m "release: vX.Y.Z"`
3. `git tag vX.Y.Z`
4. **NE PAS push** — Kevin confirme avant

## Verdict final

- **GO** si : tests pass + 0 analyze error + git clean (hors whitelist) + version incrémentée + build réussi
- **NO-GO** si : un des critères ci-dessus échoue → lister les blockers

## Erreurs courantes

### "131 issues found" sur analyze → faux positif
- Cause : On a compté warnings + info comme des erreurs
- Fix : Ne compter QUE les `error`. Filtrer avec `flutter analyze 2>&1 | grep -c ' error '`

### .claude/settings.local.json modifié → faux positif
- Cause : On a considéré un fichier IDE comme du code source
- Fix : Ignorer tout sous .claude/, .idea/, *.iml

### Build number identique au précédent
- Cause : Le store rejette si build number pas strictement supérieur
- Fix : Toujours +1 sur le build number, même pour un rebuild
