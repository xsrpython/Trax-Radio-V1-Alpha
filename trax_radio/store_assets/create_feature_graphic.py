#!/usr/bin/env python3
"""
Create Trax Radio UK Feature Graphic for Google Play Store
Converts HTML to 1024x500 PNG image
"""

import os
import sys
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.common.by import By
import time

def create_feature_graphic():
    """Create the feature graphic PNG from HTML"""
    
    # Set up Chrome options for headless mode
    chrome_options = Options()
    chrome_options.add_argument("--headless")
    chrome_options.add_argument("--no-sandbox")
    chrome_options.add_argument("--disable-dev-shm-usage")
    chrome_options.add_argument("--window-size=1024,500")
    chrome_options.add_argument("--disable-gpu")
    
    try:
        # Initialize Chrome driver
        driver = webdriver.Chrome(options=chrome_options)
        
        # Get the HTML file path
        html_file = os.path.abspath("feature_graphic.html")
        file_url = f"file://{html_file}"
        
        # Load the HTML file
        driver.get(file_url)
        
        # Wait for animations to load
        time.sleep(2)
        
        # Take screenshot
        screenshot_path = os.path.abspath("feature_graphic.png")
        driver.save_screenshot(screenshot_path)
        
        print(f"✅ Feature graphic created: {screenshot_path}")
        print(f"📏 Dimensions: 1024x500 pixels")
        
        driver.quit()
        return True
        
    except Exception as e:
        print(f"❌ Error creating feature graphic: {e}")
        print("💡 Make sure Chrome/Chromium is installed and accessible")
        return False

def create_simple_feature_graphic():
    """Create a simple feature graphic using PIL if Selenium fails"""
    try:
        from PIL import Image, ImageDraw, ImageFont
        
        # Create 1024x500 image with gradient background
        img = Image.new('RGB', (1024, 500), color='#1976D2')
        draw = ImageDraw.Draw(img)
        
        # Create gradient effect (simplified)
        for y in range(500):
            ratio = y / 500
            r = int(25 + (66 - 25) * ratio)
            g = int(118 + (165 - 118) * ratio)
            b = int(210 + (245 - 210) * ratio)
            draw.line([(0, y), (1024, y)], fill=(r, g, b))
        
        # Try to load a font, fallback to default
        try:
            font_large = ImageFont.truetype("arial.ttf", 48)
            font_medium = ImageFont.truetype("arial.ttf", 24)
            font_small = ImageFont.truetype("arial.ttf", 16)
        except:
            font_large = ImageFont.load_default()
            font_medium = ImageFont.load_default()
            font_small = ImageFont.load_default()
        
        # Draw text
        title = "Trax Radio UK"
        subtitle = "Live Streaming Radio Experience"
        
        # Get text dimensions for centering
        title_bbox = draw.textbbox((0, 0), title, font=font_large)
        subtitle_bbox = draw.textbbox((0, 0), subtitle, font=font_medium)
        
        title_width = title_bbox[2] - title_bbox[0]
        subtitle_width = subtitle_bbox[2] - subtitle_bbox[0]
        
        # Draw main title
        draw.text(((1024 - title_width) // 2, 150), title, fill='white', font=font_large)
        
        # Draw subtitle
        draw.text(((1024 - subtitle_width) // 2, 220), subtitle, fill='rgba(255,255,255,0.9)', font=font_medium)
        
        # Draw features
        features = ["📻 Live Streaming", "🎧 Real-time DJ Info", "🎨 Audio Visualization"]
        y_start = 300
        
        for i, feature in enumerate(features):
            x_pos = 200 + i * 250
            draw.text((x_pos, y_start), feature, fill='white', font=font_small)
        
        # Save the image
        img.save("feature_graphic.png")
        print(f"✅ Feature graphic created using PIL: feature_graphic.png")
        print(f"📏 Dimensions: 1024x500 pixels")
        return True
        
    except ImportError:
        print("❌ PIL not available. Install with: pip install Pillow")
        return False
    except Exception as e:
        print(f"❌ Error creating simple feature graphic: {e}")
        return False

if __name__ == "__main__":
    print("🎨 Creating Trax Radio UK Feature Graphic...")
    
    # Try Selenium first, fallback to PIL
    if not create_feature_graphic():
        print("🔄 Falling back to PIL method...")
        create_simple_feature_graphic()
