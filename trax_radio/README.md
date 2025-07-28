# Trax Radio UK - Mobile App

## 🎵 **Professional Electronic Music Radio Streaming App**

**Version**: 1.0.0 Beta  
**Status**: Ready for Beta Testing  
**Platform**: Android (Flutter)  

---

## ✨ **Features**

### **🎧 Live Radio Streaming**
- **High-quality audio** streaming from Trax Radio UK
- **Play/Pause controls** with smooth audio transitions
- **Real-time metadata** display (artist, title, listeners, bitrate)
- **Auto-reconnect** on network interruptions

### **🎛️ DJ Scheduling System**
- **Real-time DJ transitions** with accurate timezone handling
- **Current DJ display** with "Now Playing" status
- **Next DJ preview** with day indicators (Today, Tomorrow, Mon, Tue, etc.)
- **Auto DJ fallback** when no scheduled DJs

### **🎨 Advanced Audio Visualization**
- **3D Linear Visualizer** with responsive beat detection
- **Dynamic bar animations** synchronized with music
- **Beat detection system** with realistic BPM display
- **Landscape and portrait** responsive design

### **📱 Professional UI/UX**
- **Dark theme** with orange accent colors
- **Responsive design** for all screen sizes
- **Smooth animations** and transitions
- **Professional branding** with custom icons

---

## 🚀 **Getting Started**

### **Prerequisites**
- Flutter 3.8.1 or higher
- Android Studio / VS Code
- Android device or emulator

### **Installation**
```bash
# Clone the repository
git clone https://github.com/xsrpython/traxradionew.git

# Navigate to project directory
cd trax_radio

# Install dependencies
flutter pub get

# Run the app
flutter run
```

### **Building for Release**
```bash
# Build APK
flutter build apk --release

# Build App Bundle (recommended for Play Store)
flutter build appbundle --release
```

---

## 🛠 **Technical Architecture**

### **Core Components**
- **`main.dart`**: Main application entry point
- **`dj_service.dart`**: DJ scheduling and timezone management
- **`metadata_service.dart`**: Live track metadata fetching
- **`bpm_service.dart`**: Beat detection and BPM analysis

### **Widgets**
- **`current_dj_widget.dart`**: Current DJ display
- **`next_dj_widget.dart`**: Next DJ preview
- **`current_track_widget.dart`**: Live track metadata
- **`linear_3d_visualizer.dart`**: Audio visualization
- **`bpm_display.dart`**: BPM counter display

### **Dependencies**
```yaml
dependencies:
  flutter: ^3.8.1
  just_audio: ^0.10.4
  timezone: ^0.10.1
  http: ^1.1.0
  flutter_launcher_icons: ^0.14.4
```

---

## 📊 **Current Status**

### **✅ Completed Features**
- **Audio Streaming**: Fully functional with Trax Radio UK
- **DJ Scheduling**: Real-time updates with proper timezone handling
- **Audio Visualization**: 3D visualizer with beat detection
- **Metadata Integration**: Live track information
- **Responsive UI**: Optimized for all screen sizes
- **Error Handling**: Robust error management
- **Performance**: Optimized memory and CPU usage

### **🟡 In Progress**
- **Beta Testing**: Preparing for beta launch
- **Documentation**: User guides and technical docs
- **Marketing**: App store assets and descriptions

### **🔮 Future Features**
- **Multi-station support**: Additional radio stations
- **Offline mode**: Cached content for offline listening
- **Social features**: Share functionality and user profiles
- **Premium features**: Ad-free experience and exclusive content

---

## 🎯 **Beta Testing**

### **Current Phase**: Beta Launch Preparation
- **Target Testers**: 20 Android users
- **Testing Focus**: Audio quality, DJ scheduling, UI/UX, performance
- **Distribution**: Firebase App Distribution (planned)
- **Timeline**: This week

### **Testing Areas**
- **Audio Quality**: Streaming performance and stability
- **DJ Scheduling**: Accuracy across different timezones
- **Metadata**: Real-time track information updates
- **Visualizer**: Responsiveness to music and beat detection
- **UI/UX**: User experience across different devices
- **Performance**: Memory usage and battery consumption

---

## 📱 **Screenshots**

*Screenshots will be added after beta testing*

### **Main Features**
- **Home Screen**: Live radio with visualizer
- **DJ Information**: Current and next DJ display
- **Track Metadata**: Artist, title, listeners, bitrate
- **Audio Controls**: Play/pause functionality

---

## 🐛 **Known Issues**

### **Minor Issues**
- **BPM Accuracy**: Occasionally shows double values (80 BPM = 160 actual)
- **Visualizer Sensitivity**: Could be more responsive to music
- **Metadata Refresh**: Occasional delays in track info updates

### **Technical Notes**
- **Timezone Handling**: Properly converts UK time to user's local time
- **Error Recovery**: Graceful handling of network interruptions
- **Memory Management**: Optimized for long listening sessions

---

## 📈 **Performance Metrics**

### **Current Performance**
- **App Launch Time**: <3 seconds
- **Audio Start Time**: <2 seconds
- **Memory Usage**: Optimized for mobile devices
- **Battery Impact**: Minimal during streaming
- **Network Usage**: Efficient data consumption

### **Target Metrics**
- **Crash Rate**: <1%
- **User Retention**: 70%+ 7-day retention
- **App Rating**: 4.0+ stars
- **Daily Active Users**: 500+ (post-launch)

---

## 🤝 **Contributing**

### **Development Setup**
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

### **Code Standards**
- Follow Flutter/Dart conventions
- Add comments for complex logic
- Test on multiple devices
- Ensure responsive design

---

## 📄 **License**

This project is proprietary software developed for Trax Radio UK.

### **Usage Rights**
- **Personal Use**: Allowed for beta testing
- **Commercial Use**: Requires permission
- **Distribution**: Restricted to authorized users

---

## 📞 **Support & Contact**

### **Development Team**
- **Lead Developer**: DJXSR
- **Repository**: https://github.com/xsrpython/traxradionew
- **Branch**: Trax-Radio-V1-Beta

### **Support Channels**
- **Beta Testing**: Email-based feedback system
- **Bug Reports**: GitHub Issues
- **Feature Requests**: GitHub Discussions
- **General Support**: Email support

---

## 🎵 **About Trax Radio UK**

Trax Radio UK is a premier electronic music radio station featuring:
- **Live DJ shows** with scheduled programming
- **Electronic music** across all sub-genres
- **Professional audio quality** streaming
- **Global audience** with 24/7 broadcasting

### **Station Information**
- **Stream URL**: https://hello.citrus3.com:8138/stream
- **Metadata API**: https://hello.citrus3.com:8138/status-json.xsl
- **Website**: [Trax Radio UK Website]
- **Social Media**: [Social Media Links]

---

## 🚀 **Roadmap**

### **Version 1.0** (Current)
- ✅ Core radio streaming functionality
- ✅ DJ scheduling system
- ✅ Audio visualization
- ✅ Live metadata integration

### **Version 2.0** (Future)
- **Multi-station support**
- **Enhanced audio features**
- **User accounts and profiles**
- **Social sharing functionality**

### **Version 3.0** (Long-term)
- **AI-powered recommendations**
- **Voice commands**
- **Car mode optimization**
- **Premium subscription features**

---

**Last Updated**: December 2024  
**Status**: Ready for Beta Launch 🎵
