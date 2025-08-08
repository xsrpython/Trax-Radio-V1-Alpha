# Firebase App Distribution Installation Troubleshooting

## 🚨 Installation Failed - Quick Fix Guide

### Step 1: Check Your Device Settings

#### Enable Unknown Sources
1. Go to **Settings** → **Security** (or **Privacy**)
2. Find **"Install unknown apps"** or **"Unknown sources"**
3. Enable it for your browser or file manager
4. **Alternative**: Go to **Settings** → **Apps** → **Special app access** → **Install unknown apps**

#### Enable Developer Options (if needed)
1. Go to **Settings** → **About phone**
2. Tap **Build number** 7 times
3. Go back to **Settings** → **Developer options**
4. Enable **"USB debugging"** and **"Install via USB"**

### Step 2: Check APK File

#### Verify Download
- Make sure the APK download completed fully
- Check file size (should be ~20-50MB)
- Try downloading again if file seems corrupted

#### Clear Browser Cache
- Clear your browser cache and cookies
- Try downloading in incognito/private mode
- Try a different browser

### Step 3: Device Compatibility Issues

#### Check Android Version
- **Minimum Required**: Android 5.0 (API 21)
- **Recommended**: Android 8.0+ (API 26+)
- **Your Device**: Check in **Settings** → **About phone** → **Android version**

#### Check Architecture
- **Supported**: ARM64, ARMv7
- **Not Supported**: x86 (older tablets)

### Step 4: Common Error Messages & Solutions

#### "App not installed"
- **Cause**: Package name conflict with existing app
- **Solution**: Uninstall any existing Trax Radio app first

#### "Parse error"
- **Cause**: Corrupted APK or incompatible Android version
- **Solution**: Re-download APK, check Android version

#### "Installation blocked"
- **Cause**: Security settings blocking installation
- **Solution**: Enable "Install unknown apps" for your browser

#### "Insufficient storage"
- **Cause**: Not enough storage space
- **Solution**: Free up at least 100MB of storage

### Step 5: Alternative Installation Methods

#### Method 1: ADB Installation (Advanced)
```bash
# Connect phone via USB with USB debugging enabled
adb install trax_radio.apk
```

#### Method 2: File Manager Installation
1. Download APK to your phone's Downloads folder
2. Use a file manager app (like Files by Google)
3. Navigate to Downloads folder
4. Tap the APK file to install

#### Method 3: Email Installation
1. Email the APK to yourself
2. Open email on your phone
3. Download and install from email

### Step 6: Firebase Console Verification

#### Check Firebase Configuration
1. Go to **Firebase Console** → **App Distribution**
2. Verify your device is registered
3. Check if you're in the correct test group
4. Ensure the app is properly uploaded

#### Re-register Device
1. Go to **Firebase Console** → **App Distribution** → **Testers**
2. Remove your device
3. Re-add your device with the correct email

### Step 7: Build a Fresh APK

If all else fails, let's build a fresh APK with proper configuration:

```bash
# Clean the project
flutter clean

# Get dependencies
flutter pub get

# Build release APK
flutter build apk --release

# The APK will be at:
# build/app/outputs/flutter-apk/app-release.apk
```

### Step 8: Manual APK Installation

1. **Transfer APK to Phone**:
   - Use USB cable
   - Use cloud storage (Google Drive, Dropbox)
   - Use email

2. **Install APK**:
   - Use file manager to navigate to APK
   - Tap APK file
   - Follow installation prompts

### Step 9: Post-Installation Verification

#### Check App Permissions
After installation, go to:
- **Settings** → **Apps** → **Trax Radio**
- Grant necessary permissions:
  - **Internet**
  - **Audio Focus**
  - **Wake Lock**

#### Test App Functionality
1. Launch Trax Radio app
2. Test play button
3. Check visualizer
4. Verify DJ information display

### Step 10: If Still Failing

#### Collect Debug Information
1. **Device Info**:
   - Model: Samsung Galaxy S21/S25
   - Android Version: [Check in Settings]
   - Available Storage: [Check in Settings]

2. **Error Details**:
   - Exact error message
   - When error occurs (during download/installation)
   - Screenshot of error

3. **Firebase Info**:
   - Test group name
   - App version
   - Distribution date

#### Contact Support
Provide the debug information above for further assistance.

---

## 🔧 Technical Details

### APK Specifications
- **Package Name**: `com.alphatest.trax_radio`
- **Version**: 1.0.0
- **Min SDK**: 21 (Android 5.0)
- **Target SDK**: 34 (Android 14)
- **Architecture**: ARM64, ARMv7

### Firebase Requirements
- **Test Device Registration**: Required
- **Test Group Membership**: Required
- **Valid Email**: Required for distribution

### Common Device Issues
- **Samsung**: Sometimes requires additional security settings
- **Older Android**: May need different installation method
- **Custom ROMs**: May have different security policies

---

## 📞 Quick Support

If you're still having issues:

1. **Check this guide first** - Most issues are covered above
2. **Try alternative installation methods** - Different approaches work for different devices
3. **Collect debug info** - Device details and error messages
4. **Contact support** - With complete information for faster resolution

**Remember**: The app is designed to work on Android 5.0+ devices. If your device meets this requirement and you're still having issues, it's likely a configuration or installation method problem that can be resolved.
