@echo off
echo 🚀 Trax Radio UK - Auto Deploy to GitHub
echo ========================================

cd /d "%~dp0"

echo 📁 Preparing website files...
powershell -ExecutionPolicy Bypass -File "deploy-to-github.ps1"

echo.
echo 🎯 Ready to deploy! Choose your method:
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
echo 🔧 Setting up Git repository...
git init
git add .
git commit -m "Initial website upload"

echo.
echo 🔗 Connecting to GitHub...
git remote add origin https://github.com/xerpython/trax-radio-website.git
git branch -M main

echo.
echo 📤 Uploading to GitHub...
git push -u origin main

echo.
echo ✅ Upload complete!
echo 🌐 Your website: https://xerpython.github.io/trax-radio-website
echo.
echo 📋 Next step: Enable GitHub Pages
echo 1. Go to: https://github.com/xerpython/trax-radio-website/settings/pages
echo 2. Source: Deploy from a branch
echo 3. Branch: main
echo 4. Folder: / (root)
echo 5. Click Save
echo.
pause
goto end

:manual
echo.
echo 📋 Manual Upload Instructions:
echo.
echo 1. Go to: https://github.com/xerpython/trax-radio-website
echo 2. Click "uploading an existing file"
echo 3. Drag and drop ALL files from this folder
echo 4. Add commit message: "Initial website upload"
echo 5. Click "Commit changes"
echo 6. Go to Settings > Pages
echo 7. Enable GitHub Pages
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
