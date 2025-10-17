# Create Trax Radio UK Feature Graphic using PowerShell
# This creates a simple 1024x500 PNG image

Add-Type -AssemblyName System.Drawing

# Create a 1024x500 bitmap
$bitmap = New-Object System.Drawing.Bitmap(1024, 500)
$graphics = [System.Drawing.Graphics]::FromImage($bitmap)

# Set high quality rendering
$graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$graphics.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAlias

# Create gradient background (simplified - solid blue)
$backgroundBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(25, 118, 210))
$graphics.FillRectangle($backgroundBrush, 0, 0, 1024, 500)

# Define fonts
$titleFont = New-Object System.Drawing.Font("Arial", 48, [System.Drawing.FontStyle]::Bold)
$subtitleFont = New-Object System.Drawing.Font("Arial", 24, [System.Drawing.FontStyle]::Regular)
$featureFont = New-Object System.Drawing.Font("Arial", 16, [System.Drawing.FontStyle]::Regular)

# Define colors
$whiteBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)
$lightBlueBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 255, 255, 230))

# Draw main title
$titleText = "Trax Radio UK"
$titleSize = $graphics.MeasureString($titleText, $titleFont)
$titleX = (1024 - $titleSize.Width) / 2
$titleY = 150
$graphics.DrawString($titleText, $titleFont, $whiteBrush, $titleX, $titleY)

# Draw subtitle
$subtitleText = "Live Streaming Radio Experience"
$subtitleSize = $graphics.MeasureString($subtitleText, $subtitleFont)
$subtitleX = (1024 - $subtitleSize.Width) / 2
$subtitleY = 220
$graphics.DrawString($subtitleText, $subtitleFont, $lightBlueBrush, $subtitleX, $subtitleY)

# Draw features
$features = @(
    "Live Streaming",
    "Real-time DJ Info", 
    "Audio Visualization"
)

$featureY = 300
$featureSpacing = 280

for ($i = 0; $i -lt $features.Count; $i++) {
    $featureX = 150 + ($i * $featureSpacing)
    $graphics.DrawString($features[$i], $featureFont, $whiteBrush, $featureX, $featureY)
}

# Draw radio waves (simple circles)
$wavePen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(100, 255, 255, 255), 3)
$centerX = 512
$centerY = 250

# Draw concentric circles for radio waves
for ($i = 1; $i -le 4; $i++) {
    $radius = 40 + ($i * 30)
    $graphics.DrawEllipse($wavePen, $centerX - $radius, $centerY - $radius, $radius * 2, $radius * 2)
}

# Draw app icon placeholder
$iconBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(230, 255, 255, 255))
$graphics.FillRectangle($iconBrush, $centerX - 40, $centerY - 40, 80, 80)

# Draw music note symbols
$musicNotes = @("*", "*", "*", "*")
$notePositions = @(
    @(100, 100),
    @(924, 120),
    @(150, 380),
    @(874, 400)
)

for ($i = 0; $i -lt $musicNotes.Count; $i++) {
    $graphics.DrawString($musicNotes[$i], $featureFont, $lightBlueBrush, $notePositions[$i][0], $notePositions[$i][1])
}

# Save the image
$bitmap.Save("feature_graphic.png", [System.Drawing.Imaging.ImageFormat]::Png)

# Clean up
$graphics.Dispose()
$bitmap.Dispose()
$titleFont.Dispose()
$subtitleFont.Dispose()
$featureFont.Dispose()
$whiteBrush.Dispose()
$lightBlueBrush.Dispose()
$backgroundBrush.Dispose()
$wavePen.Dispose()
$iconBrush.Dispose()

Write-Host "Feature graphic created: feature_graphic.png" -ForegroundColor Green
Write-Host "Dimensions: 1024x500 pixels" -ForegroundColor Cyan
