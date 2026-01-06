#!/bin/bash

# Script to rebuild all generated code in the Flutter project

echo "🔧 Running flutter pub get in main project..."
flutter pub get

echo ""
echo "🔧 Running flutter pub get in features/common..."
cd features/common
flutter pub get
cd ../..

echo ""
echo "🔧 Running flutter pub get in features/main..."
cd features/main
flutter pub get
cd ../..

echo ""
echo "🔧 Running flutter pub get in features/schedule..."
cd features/schedule
flutter pub get
cd ../..

echo ""
echo "🔧 Running flutter pub get in features/course..."
cd features/course
flutter pub get
cd ../..

echo ""
echo "🔧 Running flutter pub get in features/supply..."
cd features/supply
flutter pub get
cd ../..

echo ""
echo "🔧 Running flutter pub get in features/onboarding..."
cd features/onboarding
flutter pub get
cd ../..

echo ""
echo "🔧 Running flutter pub get in features/splash..."
cd features/splash
flutter pub get
cd ../..

echo ""
echo "🚀 Running build_runner to regenerate all .g.dart files..."
flutter pub run build_runner build --delete-conflicting-outputs

echo ""
echo "✅ Done! All dependencies installed and code generated."
