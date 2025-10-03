# Trax Radio UK - GitHub Website Deployment Script
# This script prepares and uploads your website to GitHub

Write-Host "🚀 Trax Radio UK - GitHub Website Deployment" -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan

# Check if we're in the right directory
if (-not (Test-Path "index.html")) {
    Write-Host "❌ Error: Please run this script from the website folder" -ForegroundColor Red
    Write-Host "   Current directory: $(Get-Location)" -ForegroundColor Yellow
    Write-Host "   Expected files: index.html, styles.css, script.js" -ForegroundColor Yellow
    exit 1
}

Write-Host "✅ Found website files in current directory" -ForegroundColor Green

# Create assets folder if it doesn't exist
if (-not (Test-Path "assets")) {
    New-Item -ItemType Directory -Name "assets" | Out-Null
    Write-Host "📁 Created assets folder" -ForegroundColor Green
}

# Create releases folder if it doesn't exist
if (-not (Test-Path "releases")) {
    New-Item -ItemType Directory -Name "releases" | Out-Null
    Write-Host "📁 Created releases folder" -ForegroundColor Green
}

# Check for APK file
$apkSource = "../build/app/outputs/flutter-apk/app-release.apk"
$apkDestination = "releases/trax-radio-uk-v1.0.0.apk"

if (Test-Path $apkSource) {
    Copy-Item $apkSource $apkDestination -Force
    Write-Host "📱 Copied APK file to releases folder" -ForegroundColor Green
}
else {
    Write-Host "⚠️  APK file not found at: $apkSource" -ForegroundColor Yellow
    Write-Host "   Please build the APK first with: flutter build apk --release" -ForegroundColor Yellow
}

# Check for app icon
$iconSource = "../assets/traxicon.png"
$iconDestination = "assets/traxicon.png"

if (Test-Path $iconSource) {
    Copy-Item $iconSource $iconDestination -Force
    Write-Host "🎨 Copied app icon to assets folder" -ForegroundColor Green
}
else {
    Write-Host "⚠️  App icon not found at: $iconSource" -ForegroundColor Yellow
}

# Create placeholder images if they don't exist
$placeholderImages = @(
    "assets/phone-mockup.png",
    "assets/app-screenshot.png"
)

foreach ($image in $placeholderImages) {
    if (-not (Test-Path $image)) {
        # Create a simple placeholder image using PowerShell
        $width = 300
        $height = 600
        $bitmap = New-Object System.Drawing.Bitmap $width, $height
        $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
        $graphics.Clear([System.Drawing.Color]::LightGray)
        
        $font = New-Object System.Drawing.Font("Arial", 16)
        $brush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::Black)
        $text = "Placeholder Image`n$($image.Split('/')[-1])"
        $graphics.DrawString($text, $font, $brush, 50, 250)
        
        $bitmap.Save($image, [System.Drawing.Imaging.ImageFormat]::Png)
        $graphics.Dispose()
        $bitmap.Dispose()
        
        Write-Host "🖼️  Created placeholder: $image" -ForegroundColor Yellow
    }
}

# Create .gitignore file
$gitignoreContent = @"
# OS generated files
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db

# IDE files
.vscode/
.idea/
*.swp
*.swo

# Logs
*.log
npm-debug.log*

# Runtime data
pids
*.pid
*.seed
*.pid.lock

# Coverage directory used by tools like istanbul
coverage/

# nyc test coverage
.nyc_output

# Dependency directories
node_modules/

# Optional npm cache directory
.npm

# Optional REPL history
.node_repl_history

# Output of 'npm pack'
*.tgz

# Yarn Integrity file
.yarn-integrity

# dotenv environment variables file
.env

# Build outputs
build/
dist/
"@

Set-Content -Path ".gitignore" -Value $gitignoreContent
Write-Host "📝 Created .gitignore file" -ForegroundColor Green

# Create deployment instructions
$deploymentInstructions = @"
# 🚀 GitHub Website Deployment Instructions

## Quick Setup (5 minutes)

### 1. Initialize Git Repository
```bash
git init
git add .
git commit -m "Initial website upload"
```

### 2. Connect to GitHub
```bash
git remote add origin https://github.com/xsrpython/trax-radio-website.git
git branch -M main
git push -u origin main
```

### 3. Enable GitHub Pages
1. Go to: https://github.com/xsrpython/trax-radio-website/settings/pages
2. Source: "Deploy from a branch"
3. Branch: "main"
4. Folder: "/ (root)"
5. Click "Save"

### 4. Your Website URL
https://xsrpython.github.io/trax-radio-website

## Manual Upload Alternative
If you prefer to upload via GitHub web interface:
1. Go to: https://github.com/xsrpython/trax-radio-website
2. Click "uploading an existing file"
3. Drag and drop all files from this folder
4. Commit changes

## Files Ready for Upload
- ✅ index.html
- ✅ privacy-policy.html
- ✅ styles.css
- ✅ script.js
- ✅ README.md
- ✅ assets/traxicon.png
- ✅ releases/trax-radio-uk-v1.0.0.apk
- ✅ .gitignore

## Next Steps
1. Replace placeholder images with real ones
2. Test the website
3. Share your URL!
"@

Set-Content -Path "DEPLOYMENT_INSTRUCTIONS.md" -Value $deploymentInstructions
Write-Host "📋 Created deployment instructions" -ForegroundColor Green

# Summary
Write-Host "`n🎉 Website Preparation Complete!" -ForegroundColor Green
Write-Host "================================" -ForegroundColor Green
Write-Host "📁 Files ready for upload:" -ForegroundColor White
Write-Host "   • index.html" -ForegroundColor Gray
Write-Host "   • privacy-policy.html" -ForegroundColor Gray
Write-Host "   • styles.css" -ForegroundColor Gray
Write-Host "   • script.js" -ForegroundColor Gray
Write-Host "   • README.md" -ForegroundColor Gray
Write-Host "   • assets/traxicon.png" -ForegroundColor Gray
Write-Host "   • releases/trax-radio-uk-v1.0.0.apk" -ForegroundColor Gray
Write-Host "   • .gitignore" -ForegroundColor Gray

Write-Host "`n🚀 Next Steps:" -ForegroundColor Cyan
Write-Host "1. Run: git init" -ForegroundColor White
Write-Host "2. Run: git add ." -ForegroundColor White
Write-Host "3. Run: git commit -m 'Initial website upload'" -ForegroundColor White
Write-Host "4. Run: git remote add origin https://github.com/xsrpython/trax-radio-website.git" -ForegroundColor White
Write-Host "5. Run: git push -u origin main" -ForegroundColor White
Write-Host "6. Enable GitHub Pages in repository settings" -ForegroundColor White

Write-Host "`n📖 See DEPLOYMENT_INSTRUCTIONS.md for detailed steps" -ForegroundColor Yellow
Write-Host "🌐 Your website will be at: https://xsrpython.github.io/trax-radio-website" -ForegroundColor Cyan

Write-Host "`nPress any key to continue..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")



