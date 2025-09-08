# Fix APK Upload Script for Trax Radio UK
# This script will help you upload the APK correctly to GitHub

Write-Host "🔧 Trax Radio UK - Fix APK Upload" -ForegroundColor Cyan
Write-Host "====================================" -ForegroundColor Cyan

# Check if we're in the right directory
if (-not (Test-Path "index.html")) {
    Write-Host "❌ Error: Please run this script from the website folder" -ForegroundColor Red
    Write-Host "   Current directory: $(Get-Location)" -ForegroundColor Yellow
    Write-Host "   Expected files: index.html, styles.css, script.js" -ForegroundColor Yellow
    exit 1
}

Write-Host "✅ Found website files in current directory" -ForegroundColor Green

# Check for APK file
$apkSource = "../build/app/outputs/flutter-apk/app-release.apk"
$apkDestination = "releases/trax-radio-uk-v1.0.0.apk"

if (Test-Path $apkSource) {
    $apkSize = (Get-Item $apkSource).Length
    Write-Host "📱 Found APK file: $apkSource" -ForegroundColor Green
    Write-Host "   Size: $([math]::Round($apkSize/1MB, 2)) MB" -ForegroundColor Green
    
    # Copy APK to releases folder
    if (-not (Test-Path "releases")) {
        New-Item -ItemType Directory -Name "releases" | Out-Null
        Write-Host "📁 Created releases folder" -ForegroundColor Green
    }
    
    Copy-Item $apkSource $apkDestination -Force
    Write-Host "📱 Copied APK to releases folder" -ForegroundColor Green
} else {
    Write-Host "❌ APK file not found at: $apkSource" -ForegroundColor Red
    Write-Host "   Please build the APK first with: flutter build apk --release" -ForegroundColor Yellow
    exit 1
}

# Check for app icon
$iconSource = "../assets/traxicon.png"
$iconDestination = "assets/traxicon.png"

if (Test-Path $iconSource) {
    Copy-Item $iconSource $iconDestination -Force
    Write-Host "🎨 Copied app icon to assets folder" -ForegroundColor Green
} else {
    Write-Host "⚠️  App icon not found at: $iconSource" -ForegroundColor Yellow
}

# Create updated index.html with correct download link
Write-Host "🔧 Updating download link..." -ForegroundColor Yellow

$indexContent = @"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Trax Radio UK - Download</title>
    <meta name="description" content="Download Trax Radio UK - Live streaming radio with real-time DJ information and audio visualization">
    <link rel="stylesheet" href="styles.css">
    <link rel="icon" type="image/png" href="assets/traxicon.png">
</head>
<body>
    <header>
        <div class="container">
            <div class="logo">
                <img src="assets/traxicon.png" alt="Trax Radio UK" class="logo-img">
                <h1>Trax Radio UK</h1>
            </div>
            <nav>
                <a href="#download">Download</a>
                <a href="#features">Features</a>
                <a href="#about">About</a>
            </nav>
        </div>
    </header>

    <main>
        <section class="hero">
            <div class="container">
                <div class="hero-content">
                    <h2>Live Streaming Radio</h2>
                    <p>Experience the best of UK radio with real-time DJ information, stunning audio visualization, and seamless background playback.</p>
                    <div class="download-buttons">
                        <a href="#download" class="btn btn-primary">Download APK</a>
                        <a href="#features" class="btn btn-secondary">Learn More</a>
                    </div>
                </div>
                <div class="hero-image">
                    <img src="assets/phone-mockup.png" alt="Trax Radio UK App" class="phone-mockup">
                </div>
            </div>
        </section>

        <section id="download" class="download-section">
            <div class="container">
                <h2>Download Trax Radio UK</h2>
                <div class="download-card">
                    <div class="app-info">
                        <img src="assets/traxicon.png" alt="App Icon" class="app-icon">
                        <div class="app-details">
                            <h3>Trax Radio UK</h3>
                            <p class="version">Version 1.0.0</p>
                            <p class="size">Size: ~15 MB</p>
                            <div class="rating">
                                <span class="stars">★★★★★</span>
                                <span class="rating-text">Free • No Ads</span>
                            </div>
                        </div>
                    </div>
                    <div class="download-actions">
                        <a href="https://github.com/xsrpython/trax-radio-website/raw/main/releases/trax-radio-uk-v1.0.0.apk" class="btn btn-download" download>
                            <span class="download-icon">📱</span>
                            Download APK
                        </a>
                        <p class="download-note">Android 5.0+ required</p>
                    </div>
                </div>
                
                <div class="install-instructions">
                    <h3>Installation Instructions</h3>
                    <ol>
                        <li>Download the APK file above</li>
                        <li>On your Android device, go to Settings > Security</li>
                        <li>Enable "Install from Unknown Sources" or "Unknown Apps"</li>
                        <li>Open the downloaded APK file</li>
                        <li>Follow the installation prompts</li>
                        <li>Enjoy live radio streaming!</li>
                    </ol>
                </div>
            </div>
        </section>

        <section id="features" class="features-section">
            <div class="container">
                <h2>Features</h2>
                <div class="features-grid">
                    <div class="feature-card">
                        <div class="feature-icon">🎵</div>
                        <h3>Live Radio Streaming</h3>
                        <p>High-quality live radio streaming from Trax Radio UK with professional audio quality.</p>
                    </div>
                    <div class="feature-card">
                        <div class="feature-icon">🎧</div>
                        <h3>Audio Visualization</h3>
                        <p>Beautiful 3D audio visualizer with beat detection for an immersive experience.</p>
                    </div>
                    <div class="feature-card">
                        <div class="feature-icon">📱</div>
                        <h3>Background Playback</h3>
                        <p>Continue listening while using other apps with seamless background audio support.</p>
                    </div>
                    <div class="feature-card">
                        <div class="feature-icon">👨‍💼</div>
                        <h3>Real-time DJ Info</h3>
                        <p>Live DJ schedule and information with current and upcoming DJ displays.</p>
                    </div>
                    <div class="feature-card">
                        <div class="feature-icon">🔒</div>
                        <h3>Privacy Focused</h3>
                        <p>No personal data collection, no ads, and minimal permissions required.</p>
                    </div>
                    <div class="feature-card">
                        <div class="feature-icon">⚡</div>
                        <h3>Performance Optimized</h3>
                        <p>Smooth 60fps performance optimized for all modern Android devices.</p>
                    </div>
                </div>
            </div>
        </section>

        <section id="about" class="about-section">
            <div class="container">
                <h2>About Trax Radio UK</h2>
                <div class="about-content">
                    <div class="about-text">
                        <p>Trax Radio UK is a professional streaming application that brings you live radio content with real-time DJ information, stunning audio visualization, and seamless background playback.</p>
                        
                        <h3>Stream Information</h3>
                        <ul>
                            <li><strong>Stream URL:</strong> https://hello.citrus3.com:8138/stream</li>
                            <li><strong>Format:</strong> Electronic, House, Dance Music</li>
                            <li><strong>Live DJs:</strong> 42 hours per week</li>
                            <li><strong>Auto DJ:</strong> 126 hours per week</li>
                        </ul>

                        <h3>Technical Requirements</h3>
                        <ul>
                            <li>Android 5.0 (API 21) or higher</li>
                            <li>Internet connection required</li>
                            <li>Audio output device recommended</li>
                            <li>50MB storage space</li>
                        </ul>
                    </div>
                    <div class="about-image">
                        <img src="assets/app-screenshot.png" alt="App Screenshot" class="app-screenshot">
                    </div>
                </div>
            </div>
        </section>
    </main>

    <footer>
        <div class="container">
            <div class="footer-content">
                <div class="footer-section">
                    <h4>Trax Radio UK</h4>
                    <p>Professional radio streaming with real-time DJ information and audio visualization.</p>
                </div>
                <div class="footer-section">
                    <h4>Download</h4>
                    <a href="https://github.com/xsrpython/trax-radio-website/raw/main/releases/trax-radio-uk-v1.0.0.apk" download>Latest APK</a>
                    <a href="privacy-policy.html">Privacy Policy</a>
                </div>
                <div class="footer-section">
                    <h4>Contact</h4>
                    <p>Email: [Your Email]</p>
                    <p>Website: [Your Website]</p>
                </div>
            </div>
            <div class="footer-bottom">
                <p>&copy; 2025 Trax Radio UK. All rights reserved.</p>
            </div>
        </div>
    </footer>

    <script src="script.js"></script>
</body>
</html>
"@

Set-Content -Path "index.html" -Value $indexContent
Write-Host "✅ Updated index.html with correct download link" -ForegroundColor Green

# Create Git commands for easy upload
$gitCommands = @"
# Git Commands to Upload Fixed Files
git add .
git commit -m "Fix APK download link and upload correct APK file"
git push origin main
"@

Set-Content -Path "upload-commands.txt" -Value $gitCommands
Write-Host "📝 Created upload-commands.txt with Git commands" -ForegroundColor Green

# Summary
Write-Host "`n🎉 APK Upload Fix Complete!" -ForegroundColor Green
Write-Host "=============================" -ForegroundColor Green
Write-Host "✅ APK file copied to releases folder" -ForegroundColor White
Write-Host "✅ App icon copied to assets folder" -ForegroundColor White
Write-Host "✅ Updated download link to use GitHub raw URL" -ForegroundColor White
Write-Host "✅ Created Git upload commands" -ForegroundColor White

Write-Host "`n🚀 Next Steps:" -ForegroundColor Cyan
Write-Host "1. Run: git add ." -ForegroundColor White
Write-Host "2. Run: git commit -m 'Fix APK download link and upload correct APK file'" -ForegroundColor White
Write-Host "3. Run: git push origin main" -ForegroundColor White
Write-Host "4. Test download from: https://xsrpython.github.io/trax-radio-website" -ForegroundColor White

Write-Host "`n📖 Or run the commands from upload-commands.txt" -ForegroundColor Yellow
Write-Host "🌐 Your website: https://xsrpython.github.io/trax-radio-website" -ForegroundColor Cyan

Write-Host "`nPress any key to continue..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
