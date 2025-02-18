#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}Starting Flutter project cleanup...${NC}"

# Check if in Flutter project directory
if [ ! -f "pubspec.yaml" ]; then
    echo -e "${RED}Error: pubspec.yaml not found. Are you in a Flutter project directory?${NC}"
    exit 1
fi

# Clean Flutter
echo -e "${GREEN}Running flutter clean...${NC}"
flutter clean

# Remove pubspec.lock
echo -e "${GREEN}Removing pubspec.lock...${NC}"
rm -f pubspec.lock

# Clean iOS
if [ -d "ios" ]; then
    echo -e "${GREEN}Cleaning iOS dependencies...${NC}"
    cd ios
    rm -rf Pods
    rm -f Podfile.lock
    cd ..
fi

# Clean Android
if [ -d "android" ]; then
    echo -e "${GREEN}Cleaning Android dependencies...${NC}"
    cd android
    rm -rf .gradle
    rm -rf build
    cd ..
fi

# Get dependencies
echo -e "${GREEN}Getting fresh dependencies...${NC}"
flutter pub get

# Reinstall iOS pods
if [ -d "ios" ]; then
    echo -e "${GREEN}Reinstalling iOS pods...${NC}"
    cd ios
    pod install
    cd ..
fi

echo -e "${BLUE}Cleanup complete!${NC}"