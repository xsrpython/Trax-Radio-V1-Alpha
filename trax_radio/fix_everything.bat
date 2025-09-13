@echo off
echo 🔧 Trax Radio UK - Complete Fix Script
echo =====================================

cd /d "%~dp0"

echo.
echo Step 1: Accepting Android Licenses...
echo y | flutter doctor --android-licenses

echo.
echo Step 2: Cleaning Flutter project...
flutter clean

echo.
echo Step 3: Getting dependencies...
flutter pub get

echo.
echo Step 4: Building release APK...
flutter build apk --release

echo.
echo Step 5: Installing app...
flutter install

echo.
echo ✅ All fixes complete!
echo.
echo If installation still fails:
echo 1. Open Android Studio
echo 2. Tools → AVD Manager
echo 3. Edit emulator → Advanced Settings
echo 4. WebView Implementation → Google WebView
echo 5. Restart emulator and run: flutter install
echo.
pause
