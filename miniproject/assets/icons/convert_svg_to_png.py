#!/usr/bin/env python3
"""
Convert SVG icon to PNG for Flutter app icons
Requires: cairosvg and pillow
Install with: pip install cairosvg pillow
"""

import os
from pathlib import Path
try:
    import cairosvg
except ImportError:
    print("ERROR: cairosvg not installed")
    print("Install with: pip install cairosvg")
    exit(1)

# Icon sizes needed for different platforms
ICON_SIZES = {
    'app_icon.png': 1024,  # iOS and Web
    'app_icon_android.png': 512,  # Android base
}

# Base directory
base_dir = Path(__file__).parent
svg_file = base_dir / 'app_icon.svg'

if not svg_file.exists():
    print(f"ERROR: {svg_file} not found")
    exit(1)

print("Converting SVG to PNG icons...")

for filename, size in ICON_SIZES.items():
    output_file = base_dir / filename
    try:
        cairosvg.svg2png(
            url=str(svg_file),
            write_to=str(output_file),
            output_width=size,
            output_height=size
        )
        print(f"✓ Created {output_file} ({size}x{size})")
    except Exception as e:
        print(f"✗ Error creating {filename}: {e}")

print("\nDone! PNG icons have been created.")
print("Next steps:")
print("1. Run: flutter pub get")
print("2. Run: flutter pub run flutter_launcher_icons")
print("3. Run: flutter clean")
print("4. Build your APK: flutter build apk")
