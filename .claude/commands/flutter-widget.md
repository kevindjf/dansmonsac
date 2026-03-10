Crée un widget Flutter en respectant ces règles :

## Structure
- 1 widget = 1 fichier. Pas de _PrivateWidget en bas du fichier
- Max 50 lignes de build(). Au-delà → extraire en widget SÉPARÉ (fichier), pas en méthode _build()
- const constructors partout où possible
- Préférer ConsumerWidget (Riverpod) ou StatelessWidget
- StatefulWidget UNIQUEMENT pour du state UI local (AnimationController, TextEditingController)

## Séparation stricte
- Le widget AFFICHE, le provider DÉCIDE — ZÉRO logique métier dans un widget
- ZÉRO couleur en dur → Theme.of(context).colorScheme ou ThemeExtension
- ZÉRO string en dur → context.l10n.keyName
- ZÉRO spacing en dur → AppDimensions constants (multiples de 4)

## Listes
- TOUJOURS ListView.builder ou SliverList pour du contenu dynamique
- Jamais Column + map() pour des listes

## État (Riverpod)
- ref.watch dans build(), ref.read dans les callbacks
- AsyncValue.when(data:, loading:, error:) → TOUJOURS gérer les 3
- Dispose obligatoire sur TextEditingController, ScrollController, AnimationController
- @riverpod generator, PAS de providers manuels

## Performance
- RepaintBoundary sur les widgets qui s'animent indépendamment
- const sur tous les sous-widgets statiques
- Éviter les rebuilds inutiles : extraire en widgets séparés, pas de fonctions inline

## Placement
- Widget spécifique à une feature → lib/features/{feature}/presentation/widgets/
- Widget réutilisable cross-features → lib/core/widgets/
