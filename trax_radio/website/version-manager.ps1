# Trax Radio UK - Automated Version Management Script
# This script handles versioning, building, and releasing APK files

param(
    [string]$VersionType = "patch",  # patch, minor, major
    [switch]$Build = $false,
    [switch]$Release = $false,
    [switch]$Help = $false
)

if ($Help) {
    Write-Host "🚀 Trax Radio UK - Version Manager" -ForegroundColor Cyan
    Write-Host "=================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Usage: .\version-manager.ps1 [options]" -ForegroundColor White
    Write-Host ""
    Write-Host "Options:" -ForegroundColor Yellow
    Write-Host "  -VersionType <type>  Version bump type: patch, minor, major (default: patch)" -ForegroundColor Gray
    Write-Host "  -Build               Build APK after versioning" -ForegroundColor Gray
    Write-Host "  -Release             Create GitHub release after building" -ForegroundColor Gray
    Write-Host "  -Help                Show this help message" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Examples:" -ForegroundColor Yellow
    Write-Host "  .\version-manager.ps1 -Build                    # Version patch + build" -ForegroundColor Gray
    Write-Host "  .\version-manager.ps1 -VersionType minor -Build # Version minor + build" -ForegroundColor Gray
    Write-Host "  .\version-manager.ps1 -Build -Release          # Full release process" -ForegroundColor Gray
    exit 0
}

Write-Host "🚀 Trax Radio UK - Version Manager" -ForegroundColor Cyan
Write-Host "=================================" -ForegroundColor Cyan

# Check if we're in the right directory
if (-not (Test-Path "../pubspec.yaml")) {
    Write-Host "❌ Error: Please run this script from the website folder" -ForegroundColor Red
    Write-Host "   Expected: trax_radio/website/" -ForegroundColor Yellow
    exit 1
}

# Read current version from pubspec.yaml
$pubspecPath = "../pubspec.yaml"
$pubspecContent = Get-Content $pubspecPath -Raw
$versionMatch = [regex]::Match($pubspecContent, 'version:\s*(\d+)\.(\d+)\.(\d+)')

if (-not $versionMatch.Success) {
    Write-Host "❌ Error: Could not find version in pubspec.yaml" -ForegroundColor Red
    exit 1
}

$currentMajor = [int]$versionMatch.Groups[1].Value
$currentMinor = [int]$versionMatch.Groups[2].Value
$currentPatch = [int]$versionMatch.Groups[3].Value

Write-Host "📋 Current Version: $currentMajor.$currentMinor.$currentPatch" -ForegroundColor White

# Calculate new version
$newMajor = $currentMajor
$newMinor = $currentMinor
$newPatch = $currentPatch

switch ($VersionType.ToLower()) {
    "major" {
        $newMajor++
        $newMinor = 0
        $newPatch = 0
    }
    "minor" {
        $newMinor++
        $newPatch = 0
    }
    "patch" {
        $newPatch++
    }
    default {
        Write-Host "❌ Error: Invalid version type. Use: patch, minor, or major" -ForegroundColor Red
        exit 1
    }
}

$newVersion = "$newMajor.$newMinor.$newPatch"
Write-Host "🆕 New Version: $newVersion" -ForegroundColor Green

# Update pubspec.yaml
$newVersionLine = "version: $newVersion+$newMajor$newMinor$newPatch"
$updatedContent = $pubspecContent -replace 'version:\s*\d+\.\d+\.\d+\+\d+', $newVersionLine
Set-Content $pubspecPath $updatedContent -NoNewline
Write-Host "✅ Updated pubspec.yaml to version $newVersion" -ForegroundColor Green

# Update website version references
$indexPath = "index.html"
if (Test-Path $indexPath) {
    $indexContent = Get-Content $indexPath -Raw
    $indexContent = $indexContent -replace 'v\d+\.\d+\.\d+', "v$newVersion"
    $indexContent = $indexContent -replace 'Version \d+\.\d+\.\d+', "Version $newVersion"
    Set-Content $indexPath $indexContent -NoNewline
    Write-Host "✅ Updated website version references" -ForegroundColor Green
}

# Create version info file
$versionInfo = @{
    version     = $newVersion
    major       = $newMajor
    minor       = $newMinor
    patch       = $newPatch
    buildDate   = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    buildNumber = "$newMajor$newMinor$newPatch"
} | ConvertTo-Json

Set-Content "version.json" $versionInfo
Write-Host "✅ Created version.json" -ForegroundColor Green

# Build APK if requested
if ($Build) {
    Write-Host "`n🔨 Building APK..." -ForegroundColor Yellow
    Set-Location ..
    
    try {
        # Clean previous build
        Write-Host "🧹 Cleaning previous build..." -ForegroundColor Gray
        flutter clean | Out-Null
        
        # Get dependencies
        Write-Host "📦 Getting dependencies..." -ForegroundColor Gray
        flutter pub get | Out-Null
        
        # Build APK
        Write-Host "🔨 Building release APK..." -ForegroundColor Gray
        flutter build apk --release
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ APK build successful!" -ForegroundColor Green
            
            # Copy APK to website releases folder
            $apkSource = "build/app/outputs/flutter-apk/app-release.apk"
            $apkDestination = "website/releases/trax-radio-uk-v$newVersion.apk"
            
            if (Test-Path $apkSource) {
                Copy-Item $apkSource $apkDestination -Force
                Write-Host "📱 Copied APK to releases folder: $apkDestination" -ForegroundColor Green
                
                # Update download links in website
                $indexPath = "website/index.html"
                if (Test-Path $indexPath) {
                    $indexContent = Get-Content $indexPath -Raw
                    $indexContent = $indexContent -replace 'trax-radio-uk-v\d+\.\d+\.\d+\.apk', "trax-radio-uk-v$newVersion.apk"
                    Set-Content $indexPath $indexContent -NoNewline
                    Write-Host "🔗 Updated download links in website" -ForegroundColor Green
                }
            }
            else {
                Write-Host "❌ APK file not found at: $apkSource" -ForegroundColor Red
            }
        }
        else {
            Write-Host "❌ APK build failed!" -ForegroundColor Red
            Set-Location "website"
            exit 1
        }
    }
    catch {
        Write-Host "❌ Build error: $($_.Exception.Message)" -ForegroundColor Red
        Set-Location "website"
        exit 1
    }
    finally {
        Set-Location "website"
    }
}

# Create release if requested
if ($Release) {
    Write-Host "`n📦 Preparing GitHub release..." -ForegroundColor Yellow
    
    # Create release notes
    $releaseNotes = @"
## Trax Radio UK v$newVersion

### What's New
- Version $newVersion release
- Built on $((Get-Date).ToString('yyyy-MM-dd HH:mm:ss'))

### Download
- **APK File**: trax-radio-uk-v$newVersion.apk
- **Size**: $((Get-Item "releases/trax-radio-uk-v$newVersion.apk" -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Length) / 1MB | ForEach-Object {[math]::Round($_, 2)}) MB

### Installation
1. Download the APK file
2. Enable "Install from unknown sources" in Android settings
3. Install the APK file
4. Enjoy Trax Radio UK!

### Previous Versions
Check the releases page for previous versions and changelog.
"@

    Set-Content "RELEASE_NOTES_v$newVersion.md" $releaseNotes
    Write-Host "✅ Created release notes: RELEASE_NOTES_v$newVersion.md" -ForegroundColor Green
    
    # Create git commit
    Write-Host "📝 Creating git commit..." -ForegroundColor Gray
    git add .
    git commit -m "Release v$newVersion

- Updated version to $newVersion
- Built new APK
- Updated website references
- Generated release notes

Build: $((Get-Date).ToString('yyyy-MM-dd HH:mm:ss'))"
    
    # Create git tag
    Write-Host "🏷️ Creating git tag..." -ForegroundColor Gray
    git tag -a "v$newVersion" -m "Release v$newVersion"
    
    Write-Host "✅ Git commit and tag created" -ForegroundColor Green
    Write-Host "`n📤 Next steps:" -ForegroundColor Cyan
    Write-Host "1. Push to GitHub: git push origin main --tags" -ForegroundColor White
    Write-Host "2. Create GitHub release using tag v$newVersion" -ForegroundColor White
    Write-Host "3. Upload APK file to the release" -ForegroundColor White
}

Write-Host "`n🎉 Version management complete!" -ForegroundColor Green
Write-Host "================================" -ForegroundColor Green
Write-Host "📋 Summary:" -ForegroundColor White
Write-Host "   • Version: $newVersion" -ForegroundColor Gray
Write-Host "   • Build: $(if($Build){'Yes'}else{'No'})" -ForegroundColor Gray
Write-Host "   • Release: $(if($Release){'Yes'}else{'No'})" -ForegroundColor Gray
Write-Host "   • Files updated: pubspec.yaml, website" -ForegroundColor Gray

if ($Build) {
    Write-Host "   • APK: releases/trax-radio-uk-v$newVersion.apk" -ForegroundColor Gray
}

if ($Release) {
    Write-Host "   • Release notes: RELEASE_NOTES_v$newVersion.md" -ForegroundColor Gray
    Write-Host "   • Git tag: v$newVersion" -ForegroundColor Gray
}
