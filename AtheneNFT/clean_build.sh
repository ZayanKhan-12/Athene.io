#!/bin/bash

echo "=== Cleaning AtheneNFT project ==="

# Remove derived data
echo "Removing derived data..."
rm -rf ~/Library/Developer/Xcode/DerivedData/AtheneNFT-*

# Remove build folder
echo "Removing build folders..."
rm -rf build/
rm -rf .build/
rm -rf Build/

# Clean Swift package
echo "Cleaning Swift packages..."
swift package clean

# Reset package resolution
echo "Resetting package resolution..."
rm -rf .swiftpm
rm -f Package.resolved

# Clean Xcode project
echo "Cleaning Xcode project..."
xcodebuild clean -project AtheneNFT.xcodeproj -scheme AtheneNFT || echo "Xcode clean failed, continuing..."

echo "=== Clean completed ==="
echo "To rebuild the project:"
echo "1. Run: swift package resolve"
echo "2. Open AtheneNFT.xcodeproj in Xcode"
echo "3. Build the project (Cmd+B)"