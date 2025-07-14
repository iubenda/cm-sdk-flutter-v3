#!/bin/bash

# Stop on error
set -e

echo "Cleaning iOS build..."

# Navigate to iOS directory and clean pods
cd ios
rm -rf Pods Podfile.lock
pod deintegrate
pod cache clean --all

# Return to project root and clean Flutter
cd ..
flutter clean
flutter pub get

# Reinstall pods
cd ios
pod install

cd ..
echo "Clean completed. Running Flutter..."
