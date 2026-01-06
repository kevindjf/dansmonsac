#!/bin/bash

echo "🗑️  Suppression de tous les fichiers .g.dart..."
find . -name "*.g.dart" -type f -delete

echo ""
echo "🔧 Installation des dépendances..."
flutter pub get

echo ""
echo "🔧 Installation des dépendances dans features/common..."
cd features/common && flutter pub get && cd ../..

echo ""
echo "🔧 Installation des dépendances dans features/main..."
cd features/main && flutter pub get && cd ../..

echo ""
echo "🔧 Installation des dépendances dans features/schedule..."
cd features/schedule && flutter pub get && cd ../..

echo ""
echo "🔧 Installation des dépendances dans features/course..."
cd features/course && flutter pub get && cd ../..

echo ""
echo "🔧 Installation des dépendances dans features/supply..."
cd features/supply && flutter pub get && cd ../..

echo ""
echo "🔧 Installation des dépendances dans features/onboarding..."
cd features/onboarding && flutter pub get && cd ../..

echo ""
echo "🔧 Installation des dépendances dans features/splash..."
cd features/splash && flutter pub get && cd ../..

echo ""
echo "🚀 Régénération de tous les fichiers .g.dart..."
flutter pub run build_runner build --delete-conflicting-outputs

echo ""
echo "✅ Terminé ! Tous les fichiers ont été régénérés."
