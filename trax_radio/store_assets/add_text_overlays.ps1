# Add professional text overlays to Trax Radio UK screenshots
# For Google Play Store submission

Add-Type -AssemblyName System.Drawing

function Add-TextOverlay {
    param(
        [string]$InputFile,
        [string]$OutputFile,
        [string]$Text,
        [string]$SubText = ""
    )
    
    # Load the original image
    $originalImage = [System.Drawing.Image]::FromFile($InputFile)
    $bitmap = New-Object System.Drawing.Bitmap($originalImage.Width, $originalImage.Height)
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    
    # Set high quality rendering
    $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $graphics.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAlias
    
    # Draw the original image
    $graphics.DrawImage($originalImage, 0, 0)
    
    # Define fonts
    $titleFont = New-Object System.Drawing.Font("Arial", 36, [System.Drawing.FontStyle]::Bold)
    $subtitleFont = New-Object System.Drawing.Font("Arial", 24, [System.Drawing.FontStyle]::Regular)
    
    # Define colors
    $whiteBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)
    $blackBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::Black)
    $blueBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(25, 118, 210))
    
    # Create semi-transparent background for text
    $overlayBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(150, 0, 0, 0))
    
    # Calculate text area (bottom third of image)
    $textAreaHeight = $originalImage.Height / 3
    $textAreaY = $originalImage.Height - $textAreaHeight
    
    # Draw background overlay
    $graphics.FillRectangle($overlayBrush, 0, $textAreaY, $originalImage.Width, $textAreaHeight)
    
    # Measure text for centering
    $textSize = $graphics.MeasureString($Text, $titleFont)
    $textX = ($originalImage.Width - $textSize.Width) / 2
    $textY = $textAreaY + 30
    
    # Draw text with outline (black outline, white fill)
    $graphics.DrawString($Text, $titleFont, $blackBrush, $textX - 2, $textY - 2)
    $graphics.DrawString($Text, $titleFont, $blackBrush, $textX + 2, $textY + 2)
    $graphics.DrawString($Text, $titleFont, $blackBrush, $textX - 2, $textY + 2)
    $graphics.DrawString($Text, $titleFont, $blackBrush, $textX + 2, $textY - 2)
    $graphics.DrawString($Text, $titleFont, $whiteBrush, $textX, $textY)
    
    # Draw subtitle if provided
    if ($SubText -ne "") {
        $subTextSize = $graphics.MeasureString($SubText, $subtitleFont)
        $subTextX = ($originalImage.Width - $subTextSize.Width) / 2
        $subTextY = $textY + $textSize.Height + 10
        
        $graphics.DrawString($SubText, $subtitleFont, $blackBrush, $subTextX - 1, $subTextY - 1)
        $graphics.DrawString($SubText, $subtitleFont, $blackBrush, $subTextX + 1, $subTextY + 1)
        $graphics.DrawString($SubText, $subtitleFont, $blackBrush, $subTextX - 1, $subTextY + 1)
        $graphics.DrawString($SubText, $subtitleFont, $blackBrush, $subTextX + 1, $subTextY - 1)
        $graphics.DrawString($SubText, $subtitleFont, $blueBrush, $subTextX, $subTextY)
    }
    
    # Save the modified image
    $bitmap.Save($OutputFile, [System.Drawing.Imaging.ImageFormat]::Png)
    
    # Clean up
    $graphics.Dispose()
    $bitmap.Dispose()
    $originalImage.Dispose()
    $titleFont.Dispose()
    $subtitleFont.Dispose()
    $whiteBrush.Dispose()
    $blackBrush.Dispose()
    $blueBrush.Dispose()
    $overlayBrush.Dispose()
    
    Write-Host "Created: $OutputFile" -ForegroundColor Green
}

# Process screenshots with text overlays
Write-Host "Adding professional text overlays to screenshots..." -ForegroundColor Cyan

# Screenshot 1 - Main screen
if (Test-Path "screenshot1.png") {
    Add-TextOverlay -InputFile "screenshot1.png" -OutputFile "screenshot1_with_text.png" -Text "Live Radio Streaming" -SubText "Real-time DJ information and schedule"
}

# Screenshot 2 - Different state
if (Test-Path "screenshot2.png") {
    Add-TextOverlay -InputFile "screenshot2.png" -OutputFile "screenshot2_with_text.png" -Text "Audio Visualization" -SubText "Beautiful 3D audio visualizer with beat detection"
}

# Screenshot 3 - Another state
if (Test-Path "screenshot3.png") {
    Add-TextOverlay -InputFile "screenshot3.png" -OutputFile "screenshot3_with_text.png" -Text "Background Playback" -SubText "Listen while using other apps"
}

Write-Host "All screenshots processed with professional text overlays!" -ForegroundColor Green
