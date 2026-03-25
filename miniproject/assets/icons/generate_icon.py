#!/usr/bin/env python3
"""
Generate neon-style app icon with glowing lightning bolt
Matches the modern Teal energy app theme
Install with: pip install pillow
"""

from PIL import Image, ImageDraw, ImageFilter
import os
from pathlib import Path

# Define sizes
ICON_SIZES = {
    'app_icon.png': 1024,
    'app_icon_android.png': 512,
}

# Colors for neon effect
BACKGROUND_COLOR = (15, 76, 98)      # Dark teal background #0F4C62
CIRCLE_COLOR = (100, 160, 180)       # Frosted glass circle
GLOW_COLOR = (100, 220, 255)         # Cyan glow #64DCFF
BOLT_COLOR = (150, 240, 255)         # Bright cyan bolt #96F0FF
DARKER_TEAL = (20, 100, 130)         # Darker teal for depth

def create_neon_icon(size):
    """Create a neon-style lightning bolt icon"""
    # Create a larger image for glow effect
    work_size = size + 200
    
    # Create transparent image for compositing
    img = Image.new('RGBA', (work_size, work_size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    center = work_size // 2
    radius = size // 2 - 50
    
    # Draw glow layers (multiple semi-transparent circles for glow effect)
    glow_layers = [
        (radius + 80, (100, 220, 255, 30)),  # Outer glow
        (radius + 60, (100, 220, 255, 60)),  # Mid glow
        (radius + 40, (100, 220, 255, 100)), # Inner glow
    ]
    
    for glow_radius, color in glow_layers:
        x0 = center - glow_radius
        y0 = center - glow_radius
        x1 = center + glow_radius
        y1 = center + glow_radius
        draw.ellipse([x0, y0, x1, y1], fill=color)
    
    # Draw glass-like circle background
    circle_radius = radius
    x0 = center - circle_radius
    y0 = center - circle_radius
    x1 = center + circle_radius
    y1 = center + circle_radius
    draw.ellipse([x0, y0, x1, y1], fill=(100, 160, 180, 200))
    
    # Draw circle border (frosted glass effect)
    border_width = max(2, size // 256)
    draw.ellipse([x0, y0, x1, y1], outline=(120, 180, 200, 255), width=border_width)
    
    # Draw inner circle border for depth
    inner_circle_radius = circle_radius - 30
    ix0 = center - inner_circle_radius
    iy0 = center - inner_circle_radius
    ix1 = center + inner_circle_radius
    iy1 = center + inner_circle_radius
    draw.ellipse([ix0, iy0, ix1, iy1], outline=(80, 140, 160, 180), width=border_width)
    
    # Draw lightning bolt with neon glow
    bolt_size = size // 4
    bolt_points = [
        (center, center - bolt_size),              # Top
        (center + bolt_size // 2, center - bolt_size // 3),
        (center + bolt_size // 3, center),
        (center + bolt_size // 2, center + bolt_size // 2),
        (center, center + bolt_size),              # Bottom
        (center - bolt_size // 3, center + bolt_size // 3),
        (center - bolt_size // 2, center),
        (center - bolt_size // 2, center - bolt_size // 3),
    ]
    
    # Draw bolt with bright cyan color
    draw.polygon(bolt_points, fill=(150, 240, 255, 255), outline=(150, 240, 255, 255))
    
    # Apply blur for glow effect
    img = img.filter(ImageFilter.GaussianBlur(radius=10))
    
    # Create final image with background
    final = Image.new('RGB', (size, size), BACKGROUND_COLOR)
    
    # Paste the glow image centered
    offset_x = (work_size - size) // 2
    offset_y = (work_size - size) // 2
    
    # Convert work image to RGB while preserving the effect
    temp = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    temp.paste(img, (-offset_x, -offset_y), img)
    temp_rgb = Image.new('RGB', (size, size), BACKGROUND_COLOR)
    temp_rgb.paste(temp, (0, 0), temp)
    
    return temp_rgb
    return temp_rgb

def main():
    base_dir = Path(__file__).parent
    
    print("Generating neon-style app icons with glow effect...")
    
    for filename, size in ICON_SIZES.items():
        try:
            output_path = base_dir / filename
            img = create_neon_icon(size)
            img.save(str(output_path), 'PNG')
            print(f"✓ Created {output_path} ({size}x{size})")
        except Exception as e:
            print(f"✗ Error creating {filename}: {e}")
            return False
    
    print("\n✓ Neon icons created successfully!")
    print("\nNext steps:")
    print("1. Run: flutter pub run flutter_launcher_icons")
    print("2. Run: flutter clean")
    print("3. Build your APK: flutter build apk")
    return True

if __name__ == '__main__':
    try:
        from PIL import Image, ImageDraw, ImageFilter
    except ImportError:
        print("ERROR: Pillow not installed")
        print("Install with: pip install pillow")
        exit(1)
    
    success = main()
    exit(0 if success else 1)
