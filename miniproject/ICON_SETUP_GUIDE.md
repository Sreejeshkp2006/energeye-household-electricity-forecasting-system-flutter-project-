# App Icon Change Guide

## Overview
Your app icon has been updated to a minimalistic, clean Teal-themed design that represents energy/electricity. This matches your app theme perfectly.

## What Was Changed

### 1. **pubspec.yaml** Updated
- Added `flutter_launcher_icons: ^0.13.1` to dev dependencies
- Added flutter_launcher_icons configuration section

### 2. **Icon Files Created**
- `assets/icons/app_icon.svg` - SVG source design
- `assets/icons/generate_icon.py` - Python script to generate PNG icons

## Steps to Apply the New App Icon

### Step 1: Generate PNG Icons
Open PowerShell in the assets/icons directory and run:

```powershell
python generate_icon.py
```

**Prerequisites:**
- Python 3 installed on your system
- Pillow package: `pip install pillow`

This creates:
- `app_icon.png` (1024x1024 for iOS and Web)
- `app_icon_android.png` (512x512 for Android)

### Step 2: Get Dependencies
Run in your project root:

```powershell
flutter pub get
```

### Step 3: Generate Platform Icons
This command generates icons for all platforms (Android, iOS, Web):

```powershell
flutter pub run flutter_launcher_icons
```

This generates:
- **Android**: Icons in all mipmap densities (hdpi, mdpi, xhdpi, xxhdpi, xxxhdpi)
- **iOS**: App icon and notification icons
- **Web**: Favicon and icons

### Step 4: Clean Build Files
```powershell
flutter clean
```

### Step 5: Build Your APK
```powershell
flutter build apk --release
```

Or for debug:
```powershell
flutter build apk
```

## Icon Design Details

**Colors:**
- Primary Teal: #009688 (matches your app theme)
- Light Teal Accent: #00BCD4
- Light Background: #FBFDFF

**Design:**
- Minimalistic lightning bolt (represents energy/electricity)
- Clean circular border
- International standard design
- Works well on light and dark backgrounds

## Customizing the Icon

If you want to modify the icon design, edit either:

1. **SVG Version** - `app_icon.svg`
   - Edit in any SVG editor or text editor
   - Then regenerate PNG from SVG using `convert_svg_to_png.py`

2. **PNG Generation Script** - `generate_icon.py`
   - Directly modify the Python code to change colors, shapes, etc.
   - Re-run to generate new PNGs

## Troubleshooting

### Icon still shows Flutter logo
- Make sure to run `flutter clean` before rebuilding
- Delete build directory if needed
- Rebuild the APK

### Icon size issues
- Run `flutter clean` first
- The flutter_launcher_icons package handles all sizes automatically

### PNG not created
- Ensure Python is in your PATH
- Install Pillow: `pip install pillow`
- Check file permissions in assets/icons directory

## Next Steps

After building the APK with the new icon:
1. Transfer and install the APK on your phone
2. Check that the new minimalistic Teal icon appears instead of the Flutter logo
3. The icon will appear in your app launcher and system menus

---
**Note:** The icon generation is a one-time setup. Future builds will automatically use these icons.
