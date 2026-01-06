#!/bin/bash

echo "🧹 Nettoyage complet du projet..."

# Nettoyer Flutter
echo "Nettoyage du cache Flutter..."
flutter clean

# Supprimer tous les fichiers générés
echo "Suppression de tous les fichiers .g.dart..."
find . -name "*.g.dart" -type f -delete

# Supprimer les dossiers de build
echo "Suppression des dossiers build..."
find . -type d -name "build" -exec rm -rf {} + 2>/dev/null || true

# Supprimer les fichiers de lock
echo "Suppression des pubspec.lock..."
find . -name "pubspec.lock" -type f -delete

echo ""
echo "🔧 Installation des dépendances..."

# Main project
echo "Installation dans le projet principal..."
flutter pub get

# Modules
for module in features/common features/onboarding features/splash features/main features/schedule features/course features/supply; do
  if [ -d "$module" ]; then
    echo "Installation dans $module..."
    cd $module
    flutter pub get
    cd ../..
  fi
done

echo ""
echo "🚀 Régénération de tous les fichiers .g.dart..."
flutter pub run build_runner build --delete-conflicting-outputs

echo ""
echo "✅ Terminé ! Essayez de redémarrer votre IDE maintenant."
