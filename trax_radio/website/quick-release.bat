@echo off
REM Trax Radio UK - Quick Release Script
REM This script provides easy commands for common release tasks

echo.
echo 🚀 Trax Radio UK - Quick Release
echo ================================
echo.

if "%1"=="" goto :help
if "%1"=="help" goto :help
if "%1"=="patch" goto :patch
if "%1"=="minor" goto :minor
if "%1"=="major" goto :major
if "%1"=="build" goto :build
if "%1"=="release" goto :release
if "%1"=="full" goto :full
goto :help

:help
echo Usage: quick-release.bat [command]
echo.
echo Commands:
echo   patch     - Version patch + build + release
echo   minor     - Version minor + build + release  
echo   major     - Version major + build + release
echo   build     - Just build APK (no version change)
echo   release   - Create release from current version
echo   full      - Full release process (patch + build + release)
echo.
echo Examples:
echo   quick-release.bat patch
echo   quick-release.bat minor
echo   quick-release.bat build
echo.
goto :end

:patch
echo 📦 Creating patch release...
powershell -ExecutionPolicy Bypass -File "version-manager.ps1" -VersionType patch -Build -Release
goto :end

:minor
echo 📦 Creating minor release...
powershell -ExecutionPolicy Bypass -File "version-manager.ps1" -VersionType minor -Build -Release
goto :end

:major
echo 📦 Creating major release...
powershell -ExecutionPolicy Bypass -File "version-manager.ps1" -VersionType major -Build -Release
goto :end

:build
echo 🔨 Building APK only...
powershell -ExecutionPolicy Bypass -File "version-manager.ps1" -Build
goto :end

:release
echo 📦 Creating release...
powershell -ExecutionPolicy Bypass -File "version-manager.ps1" -Release
goto :end

:full
echo 🚀 Full release process...
powershell -ExecutionPolicy Bypass -File "version-manager.ps1" -VersionType patch -Build -Release
goto :end

:end
echo.
echo ✅ Done!
pause
