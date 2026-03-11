---
name: architecture
description: Règles clean architecture Flutter 4 couches. Utiliser quand on planifie l'architecture d'une feature, crée la structure de fichiers, ou vérifie les dépendances entre couches.
target: laurent, aurelien, clement
stack: flutter, supabase
keywords: architecture, clean archi, domain, entity, use case, repository, couche, layer, dependency inversion
---

Analyse et planifie l'architecture en respectant ces règles NON-NÉGOCIABLES :

## Avant de planifier
1. Explorer la structure du projet (ls les dossiers principaux)
2. Lire .claude/ARCHITECTURE.md, CONVENTIONS.md, PATTERNS.md si existants
3. Vérifier les schémas Supabase existants via MCP (list_tables) si pertinent
4. Chercher si un composant/widget/service similaire existe déjà (grep, glob)

## Clean Architecture — 4 couches strictes

```
lib/features/feature_name/
  domain/
    entities/        ← objets métier PURS (Dart uniquement, zéro import Flutter)
    repositories/    ← interfaces abstraites (contrats, pas d'implémentation)
    usecases/        ← 1 classe = 1 action métier (GetProfile, PlaceBet)
  data/
    models/          ← fromJson/toJson, mapping entity ↔ API/DB
    datasources/     ← accès Supabase/API/Hive brut
    repositories/    ← implémentation concrète des interfaces domain
  application/
    providers/       ← Riverpod notifiers, appellent les use cases
  presentation/
    pages/           ← écrans complets (Scaffold)
    widgets/         ← composants UI spécifiques à la feature

lib/core/
  constants/         ← AppDimensions, spacing, durées
  extensions/        ← extensions Dart/BuildContext
  theme/             ← AppTheme, ThemeExtension custom, AppColors
  router/            ← GoRouter configuration
  services/          ← services partagés (init Hive, etc.)
  utils/             ← Result<T>, formatters
  widgets/           ← widgets réutilisables cross-features
```

## Règles NON-NÉGOCIABLES

### Domain (la loi)
- ZÉRO import Flutter dans domain/ — Dart pur uniquement
- Entities avec @freezed (immutables, sealed classes pour les unions)
- Use cases : 1 classe = 1 action. Le provider appelle le use case, JAMAIS le repo directement
- Repository interfaces dans domain/, implémentations dans data/
- Le domain ne dépend de RIEN (pas de data, pas de presentation)

### Data
- Models séparés des entities : Model = sérialisation (fromJson/toJson), Entity = métier
- Datasources abstraits dans domain, concrets dans data
- Repository impl mappe Model → Entity avant de retourner

### Application (State)
- Riverpod Generator obligatoire : @riverpod, PAS de providers manuels
- Provider appelle use case, JAMAIS Supabase/API directement
- Notifier pour l'état mutable, Provider pour les dépendances simples
- `dart run build_runner build --delete-conflicting-outputs` après chaque ajout

### Presentation (UI)
- 1 widget = 1 fichier. Pas de _PrivateWidget en bas du fichier
- build() max 50 lignes. Au-delà → extraire en widget séparé (pas en méthode _build)
- ZÉRO logique métier dans les widgets — le widget AFFICHE, le provider DÉCIDE
- ZÉRO couleur en dur → Theme.of(context).colorScheme ou ThemeExtension custom
- ZÉRO string en dur → context.l10n.keyName (ARB + gen-l10n)
- ZÉRO spacing en dur → AppDimensions.spacingM (multiples de 4)

## Dependency Inversion (sens des dépendances)
```
presentation → application → domain ← data
```
- presentation dépend de application (providers)
- application dépend de domain (use cases, entities)
- data IMPLÉMENTE domain (repositories, datasources)
- domain ne dépend de RIEN

## Plan d'implémentation
- Ordonner : entities → repositories (interface) → datasources → repositories (impl) → use cases → providers → widgets → pages
- Lister TOUS les fichiers avec chemin exact
- Préciser les commands pour le dev (/flutter-design, /flutter-widget, etc.)
- Si un composant similaire existe : réutiliser, pas recréer

## Anti-patterns INTERDITS
- Logique métier dans un widget → use case
- Provider qui appelle Supabase directement → use case + repository
- Entity avec fromJson/toJson → séparer en Model (data/) + Entity (domain/)
- build() > 50 lignes → extraire en widgets
- Widget _buildSection() méthode → extraire en fichier widget séparé
- Color(0xFF...) ou "texte" en dur → theme + l10n
- Provider manuel `final xProvider = ...` → @riverpod generator
- God provider (plusieurs responsabilités) → split
- Import Flutter dans domain/ → INTERDIT

## Erreurs courantes

### Import Flutter dans domain/
- Symptôme : `import 'package:flutter/...';` dans un fichier sous `domain/`
- Fix : Extraire en Dart pur, utiliser @freezed pour les entities, pas de Widget/Color/BuildContext

### Provider appelle le repository directement
- Symptôme : `ref.read(profileRepositoryProvider)` dans un provider
- Fix : Créer un use case dans `application/usecases/`, le provider appelle le use case

### Entity avec fromJson/toJson
- Symptôme : `factory Entity.fromJson(Map<String, dynamic> json)` dans `domain/entities/`
- Fix : Séparer en Model (data/models/) avec sérialisation + Entity (domain/entities/) pure @freezed

### build() trop long (> 50 lignes)
- Symptôme : Widget avec build() de 80+ lignes, méthodes _buildSection()
- Fix : Extraire chaque section en widget séparé dans son propre fichier

### God provider (plusieurs responsabilités)
- Symptôme : Un provider qui gère auth + profil + settings
- Fix : Split en 3 providers distincts, chacun avec son use case
