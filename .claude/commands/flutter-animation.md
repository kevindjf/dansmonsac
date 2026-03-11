---
name: flutter-animation
description: Animations Flutter, transitions, micro-interactions, Rive. Utiliser quand on crée une animation, une transition entre écrans, ou un feedback tactile.
target: aurelien
stack: flutter
keywords: animation, transition, animé, hero, rive, opacity, scale, micro-interaction, curve, tween
---

Crée une animation Flutter en choisissant la bonne approche :

## Quand utiliser quoi
- **Transition simple** (opacity, size, color) → AnimatedContainer, AnimatedOpacity, AnimatedScale
- **Animation complexe/chaînée** → AnimationController + Tween + CurvedAnimation
- **Transition entre écrans** → Hero animation
- **Animation vectorielle riche** (onboarding, illustrations) → Rive
- **Micro-interaction** (feedback tactile, bouton press) → InkWell + AnimatedScale

## Règles
- TOUJOURS 60fps — pas de calcul lourd dans le build pendant l'animation
- RepaintBoundary autour des widgets animés indépendamment
- Dispose AnimationController dans dispose()
- vsync: this → ajouter TickerProviderStateMixin
- Durées : micro-interaction 150-200ms, transition 300ms, animation complexe 500-800ms
- Curves : easeInOut par défaut, bounceOut pour le fun, easeOut pour les entrées
