---
name: flutter-design
description: Design system Material 3, layout responsive, composants riches. Utiliser quand on crée un écran, une page, un composant visuel, ou du UI.
target: aurelien
stack: flutter
keywords: design, UI, écran, page, layout, theme, couleur, responsive, material, ombre, gradient, composant visuel
---

Crée une UI Flutter belle et professionnelle en respectant ces règles :

## Design System (Material 3)
- TOUJOURS utiliser `Theme.of(context)` : `colorScheme`, `textTheme`, `extensions`
- Couleurs : `primary`, `secondary`, `surface`, `surfaceContainerHighest` — jamais de Color(0xFF...) en dur
- Typo : `titleLarge`, `bodyMedium`, etc. via `textTheme`. Jamais de TextStyle en dur
- Spacing cohérent : multiples de 4 (4, 8, 12, 16, 24, 32). Définir des constantes si récurrent
- Border radius cohérent : petit=8, moyen=12, grand=16, pill=999. Un seul style par app

## Esthétique & Finitions
- Ombres : `BoxShadow` subtiles (blurRadius: 8-16, color: black12). Pas d'ombre sur fond sombre
- Gradients : max 2-3 couleurs, `LinearGradient` avec stops naturels
- Cards : `surfaceContainerLow` + border radius 12-16 + padding 16. Pas de `elevation > 4`
- Glassmorphism : `BackdropFilter` + `ImageFilter.blur` + container semi-transparent
- Neumorphism : double BoxShadow (light en haut-gauche, dark en bas-droite) sur fond `surface`
- Icônes : taille cohérente (20-24), couleur `onSurface` ou `primary`. Outlined par défaut
- Images : TOUJOURS `ClipRRect` pour border radius, `BoxFit.cover`, placeholder/error widget

## Layout & Responsive
- `SafeArea` en haut de chaque écran principal
- `MediaQuery.sizeOf(context)` pour responsive, PAS `MediaQuery.of(context).size`
- Padding écran : 16 horizontal minimum, 24 si contenu large
- `Expanded` / `Flexible` dans Row/Column, jamais de largeurs fixes pour du contenu adaptatif
- `ConstrainedBox(maxWidth: 600)` pour centrer le contenu sur tablette/web
- `SliverAppBar` + `CustomScrollView` pour les écrans avec scroll complexe

## Composants Riches
- Bottom sheets : `showModalBottomSheet` + `DraggableScrollableSheet` pour le contenu long
- AppBar custom : `SliverAppBar.large` ou `flexibleSpace` avec image/gradient
- Boutons : `FilledButton` (action primaire), `OutlinedButton` (secondaire), `TextButton` (tertiaire)
- Inputs : `InputDecoration` avec `filled: true`, `border: OutlineInputBorder(borderRadius:)`
- Listes : séparateurs `Divider(height: 1)`, leading/trailing alignés, onTap avec `InkWell`
- Empty states : illustration + texte + CTA, centré verticalement
- Loading : `Shimmer` pour les placeholders, pas juste un `CircularProgressIndicator` centré

## Patterns Clean
- Widgets "dumb" (affichage pur) vs "smart" (connectés au state) — séparer les deux
- Composition : construire des petits widgets réutilisables, pas un mega build()
- `_buildSection()` privé OK pour découper, mais extraire en widget si > 30 lignes
- Thème custom via `ThemeExtension<T>` pour les tokens spécifiques à l'app (AppColors, AppSpacing)
