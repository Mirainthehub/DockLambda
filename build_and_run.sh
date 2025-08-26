#!/bin/bash

# Build and run script for DockLambda
# macOS Dock Pet Application

set -e  # Exit on any error

echo "🚀 DockLambda Build & Run Script"
echo "================================"

# Check if we're in the right directory
if [ ! -f "DockLambda.xcodeproj/project.pbxproj" ]; then
    echo "❌ Error: DockLambda.xcodeproj not found!"
    echo "Please run this script from the MacLambda directory"
    exit 1
fi

# Check if Xcode is available
if ! command -v xcodebuild &> /dev/null; then
    echo "❌ Error: xcodebuild not found!"
    echo "Please install Xcode or Xcode Command Line Tools"
    exit 1
fi

# Generate placeholder assets if Python is available
echo "🎨 Generating placeholder assets..."
if command -v python3 &> /dev/null; then
    python3 generate_placeholder_assets.py || echo "⚠️  Asset generation failed, continuing with built-in placeholders"
else
    echo "⚠️  Python3 not available, using built-in placeholders"
fi

echo ""
echo "🔨 Building DockLambda..."

# Build the project
xcodebuild -project DockLambda.xcodeproj \
           -scheme DockLambda \
           -configuration Debug \
           -derivedDataPath ./build \
           build

if [ $? -eq 0 ]; then
    echo "✅ Build successful!"
    
    # Find the built app
    APP_PATH="./build/Build/Products/Debug/DockLambda.app"
    
    if [ -d "$APP_PATH" ]; then
        echo ""
        echo "🎯 Running DockLambda..."
        echo "👀 Look for:"
        echo "   • Pet window near your Dock"
        echo "   • λ icon in menu bar"
        echo "   • Try clicking/dragging the pet!"
        echo ""
        
        # Run the app
        open "$APP_PATH"
        
        echo "✅ DockLambda launched!"
        echo ""
        echo "📝 Usage Tips:"
        echo "   • Single click pet: Feed (eat animation)"
        echo "   • Double click pet: Dance animation"
        echo "   • Option+drag: Move pet position"
        echo "   • Menu bar λ: Settings & controls"
        echo "   • Drag files to pet: Wiggle animation"
        echo ""
        echo "🛑 To quit: Use menu bar → Quit DockLambda"
        
    else
        echo "❌ Built app not found at expected location: $APP_PATH"
        exit 1
    fi
else
    echo "❌ Build failed!"
    exit 1
fi