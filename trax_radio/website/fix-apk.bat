@echo off
echo 🔧 Trax Radio UK - Fix APK Upload
echo ==================================

cd /d "%~dp0"

echo 📁 Running APK fix script...
powershell -ExecutionPolicy Bypass -File "fix-apk-upload.ps1"

echo.
echo 🎯 Ready to upload! Choose your method:
echo.
echo 1. Command Line (Recommended)
echo 2. Manual Upload via GitHub Web
echo 3. Exit
echo.
set /p choice="Enter your choice (1-3): "

if "%choice%"=="1" goto commandline
if "%choice%"=="2" goto manual
if "%choice%"=="3" goto exit
goto invalid

:commandline
echo.
echo 🔧 Uploading fixed files...
git add .
git commit -m "Fix APK download link and upload correct APK file"
git push origin main

echo.
echo ✅ Upload complete!
echo 🌐 Your website: https://xsrpython.github.io/trax-radio-website
echo 📱 Test download: https://xsrpython.github.io/trax-radio-website
echo.
pause
goto end

:manual
echo.
echo 📋 Manual Upload Instructions:
echo.
echo 1. Go to: https://github.com/xsrpython/trax-radio-website
echo 2. Click "uploading an existing file"
echo 3. Upload the files from this folder:
echo    - index.html (updated with correct download link)
echo    - releases/trax-radio-uk-v1.0.0.apk (correct APK file)
echo    - assets/traxicon.png (app icon)
echo 4. Commit changes
echo.
echo 📁 Files to upload:
dir /b
echo.
pause
goto end

:invalid
echo ❌ Invalid choice. Please try again.
goto end

:exit
echo 👋 Goodbye!
goto end

:end
