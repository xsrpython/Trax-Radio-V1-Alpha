# TraxRadio Beta Distribution Information

## 📱 **App Overview**
- **App Name**: Trax Radio UK
- **Version**: V1.0.0 Beta
- **Developer**: DJXSR
- **Platform**: Android (Primary), iOS (Future)
- **Category**: Music & Audio / Radio Streaming

## 📦 **App Size Information**

### **Download Size**
- **Small devices (arm)**: ~25-30MB
- **Modern devices (arm64)**: ~30-35MB
- **Universal APK**: ~35-40MB

### **Installed Size**
- **After installation**: ~40-50MB
- **With cache/data**: ~50-60MB

### **Size Benefits**
- ✅ **Lightweight** - Similar to other radio apps
- ✅ **Fast download** - Under 40MB download size
- ✅ **Efficient storage** - Minimal space usage
- ✅ **Optimized assets** - Images are appropriately sized
- ✅ **Tree-shaking** - Icon font reduced by 99.9%

## 🎵 **Bluetooth Audio Support**

### **Compatible Devices**
- ✅ **Car Audio Systems** - Any car with Bluetooth connectivity
- ✅ **Bluetooth Speakers** - Portable speakers, home speakers
- ✅ **Bluetooth Headphones** - Wireless earbuds, over-ear headphones
- ✅ **Bluetooth Earbuds** - AirPods, Galaxy Buds, etc.
- ✅ **Smart Home Speakers** - Google Home, Amazon Echo, etc.
- ✅ **Bluetooth Receivers** - Adapters for older car systems

### **Car Integration Features**
- **Steering Wheel Controls**: Play/pause, volume, track skip (if supported)
- **Car Display**: Shows track info (artist/title) if car supports metadata
- **Auto-resume**: App continues playing when car Bluetooth reconnects
- **Background Play**: Continues playing when app is minimized

### **Audio Quality**
- **Stream Quality**: Depends on the radio station's bitrate (typically 128-320kbps)
- **Bluetooth Codec**: Uses device's default Bluetooth codec (AAC, SBC, aptX, etc.)
- **Latency**: Standard Bluetooth audio latency (~100-200ms)

## 🚀 **Key Features for Beta Testing**

### **Core Functionality**
- **Live Radio Streaming** - High-quality audio from Trax Radio UK
- **DJ Scheduling System** - Real-time DJ information with day indicators
- **3D Audio Visualizer** - Responsive visualization with beat detection
- **BPM Display** - Real-time beats per minute with realistic values
- **Responsive Design** - Optimized for all screen sizes and orientations

### **UI/UX Features**
- **Professional Dark Theme** - Black background with accent colors
- **Animated Elements** - Rotating record, scrolling DJ names
- **Smart Text Handling** - Long DJ names with tooltips
- **Touch Optimization** - Large touch targets for easy use

## 📋 **Beta Testing Requirements**

### **Device Requirements**
- **Android Version**: 6.0 (API 23) or higher
- **RAM**: 2GB minimum, 4GB recommended
- **Storage**: 100MB free space
- **Internet**: Stable connection for streaming

### **Recommended Devices**
- **Samsung Galaxy S21/S22/S23/S24**
- **Google Pixel 6/7/8/9**
- **OnePlus 8/9/10/11**
- **Any modern Android device with Bluetooth**

### **Testing Scenarios**
1. **Basic Functionality**
   - App launch and loading
   - Play/pause controls
   - DJ information display
   - Visualizer animation

2. **Bluetooth Testing**
   - Connect to car audio system
   - Test with Bluetooth speakers
   - Verify steering wheel controls
   - Check metadata display

3. **UI/UX Testing**
   - Portrait and landscape orientations
   - Different screen sizes
   - Text overflow handling
   - Touch responsiveness

4. **Performance Testing**
   - Battery usage during streaming
   - Memory usage over time
   - App stability during long sessions
   - Background playback

## 🔧 **Technical Specifications**

### **Dependencies**
```yaml
dependencies:
  flutter: sdk: flutter
  just_audio: ^0.10.4
  timezone: ^0.10.1
  cupertino_icons: ^1.0.8
```

### **Permissions Required**
- **Internet Access** - For radio streaming
- **Audio Focus** - For background playback
- **Wake Lock** - To prevent sleep during playback

### **Supported Android Versions**
- **Minimum**: Android 6.0 (API 23)
- **Target**: Android 14 (API 34)
- **Recommended**: Android 10+ for best experience

## 📊 **Beta Testing Metrics**

### **Performance Metrics**
- App launch time (target: <3 seconds)
- Memory usage (target: <100MB)
- Battery consumption (target: <5% per hour)
- Crash rate (target: <1%)

### **User Experience Metrics**
- Audio streaming stability
- DJ schedule accuracy
- Visualizer responsiveness
- Bluetooth connectivity reliability

### **Feedback Categories**
- **Critical Issues** - App crashes, audio not working
- **Major Issues** - UI problems, performance issues
- **Minor Issues** - Visual glitches, text formatting
- **Feature Requests** - New functionality suggestions

## 📞 **Support Information**

### **Beta Tester Support**
- **Developer**: DJXSR
- **Repository**: https://github.com/xsrpython/traxradionew
- **Branch**: Trax-Radio-V1-Beta
- **Feedback Channel**: Email or GitHub Issues

### **Known Issues**
- Landscape mode may need optimization on some devices
- BPM display shows fallback values when no beats detected
- Some older Android devices may have performance issues

### **Troubleshooting**
1. **Audio not playing**: Check internet connection
2. **DJ not showing**: Verify app has internet access
3. **Bluetooth issues**: Restart Bluetooth on device
4. **App crashes**: Clear app data and restart

## 🎯 **Beta Testing Goals**

### **Primary Objectives**
- ✅ **Functionality Verification** - All features work as expected
- ✅ **Performance Validation** - App runs smoothly on various devices
- ✅ **Bluetooth Testing** - Audio works with car systems and speakers
- ✅ **UI/UX Feedback** - Interface is intuitive and responsive

### **Success Criteria**
- **Stability**: <1% crash rate
- **Performance**: <3 second launch time
- **User Satisfaction**: >80% positive feedback
- **Bluetooth Compatibility**: Works with 95% of tested devices

---

**Trax Radio UK - V1.0.0 Beta** 🎵✨
*Professional Radio Streaming with Advanced Visualization* 