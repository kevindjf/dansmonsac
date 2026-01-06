#!/bin/bash

echo "🧹 Nettoyage et régénération complète de tous les modules..."
echo ""

# Function to clean and rebuild a module
rebuild_module() {
  local module_path=$1
  local module_name=$2

  if [ -d "$module_path" ]; then
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📦 Module: $module_name"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    cd "$module_path"

    # Clean
    echo "  🗑️  Nettoyage..."
    flutter clean > /dev/null 2>&1
    rm -rf build
    find . -name "*.g.dart" -type f -delete
    rm -f pubspec.lock

    # Get dependencies
    echo "  📥 Installation des dépendances..."
    flutter pub get

    # Generate code if build_runner is present
    if grep -q "build_runner" pubspec.yaml; then
      echo "  🔧 Génération du code..."
      flutter pub run build_runner build --delete-conflicting-outputs
    fi

    cd - > /dev/null
    echo "  ✅ $module_name terminé"
    echo ""
  fi
}

# Clean main project first
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📦 Projet principal"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
flutter clean
find . -name "*.g.dart" -type f -delete
rm -f pubspec.lock
echo "  📥 Installation des dépendances..."
flutter pub get
echo "  ✅ Projet principal nettoyé"
echo ""

# Rebuild all feature modules
rebuild_module "features/common" "Common"
rebuild_module "features/onboarding" "Onboarding"
rebuild_module "features/splash" "Splash"
rebuild_module "features/course" "Course"
rebuild_module "features/supply" "Supply"
rebuild_module "features/schedule" "Schedule"
rebuild_module "features/main" "Main"

# Final build runner at root level
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🚀 Génération finale au niveau du projet principal"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
flutter pub run build_runner build --delete-conflicting-outputs
echo ""
echo "✅✅✅ TERMINÉ ! ✅✅✅"
echo ""
echo "⚠️  IMPORTANT : Redémarrez maintenant votre IDE (VS Code/Android Studio)"
echo ""
