#!/usr/bin/env python3
"""
Generate placeholder assets for DockLambda
Creates simple app icons and sprite placeholders
"""

import os
from PIL import Image, ImageDraw, ImageFont
import sys

def create_app_icon(size, output_path):
    """Create a simple lambda-themed app icon"""
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Background circle
    margin = size // 8
    draw.ellipse([margin, margin, size-margin, size-margin], 
                fill=(147, 51, 234, 255), outline=(255, 255, 255, 200), width=2)
    
    # Lambda symbol
    try:
        # Try to use a system font
        font_size = size // 3
        font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", font_size)
    except:
        font = ImageFont.load_default()
    
    # Draw lambda symbol
    text = "λ"
    bbox = draw.textbbox((0, 0), text, font=font)
    text_width = bbox[2] - bbox[0]
    text_height = bbox[3] - bbox[1]
    x = (size - text_width) // 2
    y = (size - text_height) // 2 - font_size // 8
    
    draw.text((x, y), text, fill=(255, 255, 255, 255), font=font)
    
    img.save(output_path, 'PNG')
    print(f"✅ Created app icon: {output_path} ({size}x{size})")

def create_sprite_placeholder(state, frame_index, output_path):
    """Create a simple sprite placeholder"""
    size = 80
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # State colors
    colors = {
        'idle': (0, 122, 255, 200),     # Blue
        'walk': (52, 199, 89, 200),     # Green  
        'sleep': (175, 82, 222, 200),   # Purple
        'eat': (255, 149, 0, 200),      # Orange
        'dance': (255, 45, 85, 200)     # Pink
    }
    
    color = colors.get(state, (128, 128, 128, 200))
    
    # Draw circle
    margin = 8
    draw.ellipse([margin, margin, size-margin, size-margin], 
                fill=color, outline=(255, 255, 255, 180), width=2)
    
    # Simple face
    eye_size = 4
    # Eyes
    draw.ellipse([25, 35, 25+eye_size, 35+eye_size], fill=(255, 255, 255, 255))
    draw.ellipse([50, 35, 50+eye_size, 35+eye_size], fill=(255, 255, 255, 255))
    
    # Mouth (varies by state)
    if state == 'sleep':
        # Closed eyes
        draw.line([25, 37, 29, 37], fill=(255, 255, 255, 255), width=2)
        draw.line([50, 37, 54, 37], fill=(255, 255, 255, 255), width=2)
        # Zzz
        try:
            font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 8)
            draw.text((58, 25), "z", fill=(255, 255, 255, 180), font=font)
        except:
            pass
    elif state == 'eat':
        # Open mouth
        draw.ellipse([35, 48, 45, 55], fill=(255, 255, 255, 255))
    elif state == 'dance':
        # Happy expression
        draw.arc([30, 45, 50, 58], 0, 180, fill=(255, 255, 255, 255), width=2)
        # Add musical note
        try:
            font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 10)
            draw.text((58, 20), "♪", fill=(255, 255, 255, 200), font=font)
        except:
            pass
    else:
        # Normal smile
        draw.arc([30, 45, 50, 55], 0, 180, fill=(255, 255, 255, 255), width=2)
    
    # Frame indicator for animation
    if frame_index > 0:
        try:
            font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 6)
            draw.text((2, 2), str(frame_index), fill=(255, 255, 255, 150), font=font)
        except:
            pass
    
    img.save(output_path, 'PNG')
    print(f"✅ Created sprite: {output_path}")

def main():
    base_path = os.path.dirname(os.path.abspath(__file__))
    
    # Check if PIL is available
    try:
        from PIL import Image, ImageDraw, ImageFont
    except ImportError:
        print("❌ PIL (Pillow) not available. Install with: pip3 install Pillow")
        print("📝 Skipping asset generation - app will use built-in placeholders")
        return
    
    # Create app icons
    icon_path = os.path.join(base_path, "DockLambda/Assets.xcassets/AppIcon.appiconset")
    icon_sizes = [16, 32, 64, 128, 256, 512, 1024]
    
    for size in icon_sizes:
        icon_file = os.path.join(icon_path, f"{size}.png")
        create_app_icon(size, icon_file)
    
    # Create sprite placeholders
    sprites_path = os.path.join(base_path, "DockLambda/Sprites")
    states = ['idle', 'walk', 'sleep', 'eat', 'dance']
    
    for state in states:
        state_dir = os.path.join(sprites_path, state)
        os.makedirs(state_dir, exist_ok=True)
        
        # Create 2-3 frames per state for basic animation
        frame_count = 3 if state in ['walk', 'dance'] else 2
        for i in range(frame_count):
            sprite_file = os.path.join(state_dir, f"{state}_{i}.png")
            create_sprite_placeholder(state, i, sprite_file)
    
    print("\n🎉 Asset generation complete!")
    print("📁 App icons created in Assets.xcassets/AppIcon.appiconset/")
    print("🎨 Sprite placeholders created in Sprites/")
    print("\n▶️  You can now build and run the project in Xcode!")

if __name__ == "__main__":
    main()