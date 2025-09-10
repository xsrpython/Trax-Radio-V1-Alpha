@echo off
REM Trax Radio UK - Release v1.0.1 with Auto-Update System
REM This script releases v1.0.1 with the new auto-update functionality

echo.
echo 🚀 Trax Radio UK - Release v1.0.1
echo ===================================
echo.
echo This release includes:
echo ✅ Auto-update system
echo ✅ Background downloads
echo ✅ One-tap installation
echo ✅ Release notes display
echo.

pause

echo.
echo 📦 Creating v1.0.1 release...
powershell -ExecutionPolicy Bypass -File "version-manager.ps1" -VersionType patch -Build -Release

echo.
echo 🎉 v1.0.1 Release Complete!
echo ============================
echo.
echo Next steps:
echo 1. Test the APK on a device
echo 2. Send DJ notification (see DJ_UPDATE_NOTIFICATION.md)
echo 3. Monitor for feedback
echo 4. Future updates will be automatic!
echo.

pause
