# Trax Radio UK - Flutter App

A professional internet radio streaming application for Trax Radio UK, built with Flutter. **Ready for Firebase rollout and beta testing.**

## 🎵 Features

### Core Functionality
- **Live Radio Streaming** - Stream Trax Radio UK live
- **Audio Visualization** - Real-time beat detection and visualizer
- **DJ Information** - Current and next DJ displays
- **Metadata Display** - Song information and track details
- **Professional UI** - Modern, responsive design
- **Portrait Mode Lock** - Optimized for portrait orientation

### Technical Features
- **Multi-platform Support** - Android, iOS, Web, Desktop
- **Firebase Integration** - Analytics and crash reporting
- **Audio Processing** - Just Audio plugin for streaming
- **Responsive Design** - Adapts to different screen sizes
- **Performance Optimized** - Efficient animations and state management
- **S25 Optimized** - Special optimizations for Samsung Galaxy S25

## 📱 Current Status

### ✅ Completed Features
- **Core Audio Streaming** - Play/pause functionality working perfectly
- **Visualizer System** - Beat detection and animations optimized
- **DJ Service** - Real-time DJ information
- **UI Components** - Professional styling and layout
- **Error Handling** - Robust error management
- **Performance Optimization** - Smooth animations on S25
- **Device Compatibility** - Tested on Samsung S21 and S25

### 🚀 Ready for Deployment
- **Firebase Configuration** - All services configured
- **Build System** - Successfully building and installing
- **Performance** - Frame skipping resolved, smooth operation
- **Audio Player** - Fixed play button and streaming issues
- **Visualizer** - Optimized for better performance

## 🛠️ Setup Instructions

### Prerequisites
- Flutter SDK (latest stable)
- Android Studio / VS Code
- Android device or emulator
- Internet connection

### Installation
1. **Clone the repository**
   ```bash
   git clone [repository-url]
   cd trax_radio
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Android Configuration
- **Application ID**: `com.alphatest.trax_radio`
- **Package**: `com.alphatest.trax_radio`
- **Min SDK**: Android API 21+
- **Target SDK**: Android API 35

## 📁 Project Structure

```
trax_radio/
├── lib/
│   ├── main.dart                 # Main app entry point
│   ├── splash_screen.dart        # Splash screen
│   ├── dj_service.dart           # DJ information service
│   ├── bpm_service.dart          # Beat detection service
│   └── widgets/
│       ├── current_dj_widget.dart    # Current DJ display
│       ├── next_dj_widget.dart       # Next DJ display
│       ├── metadata_display.dart     # Song metadata
│       ├── linear_3d_visualizer.dart # Audio visualizer (optimized)
│       └── equalizer_visualizer.dart # Alternative visualizer
├── android/                      # Android-specific configuration
├── ios/                         # iOS-specific configuration
├── assets/                      # App assets and resources
└── pubspec.yaml                 # Dependencies and configuration
```

## 🔧 Technical Details

### Dependencies
- **just_audio** - Audio streaming
- **firebase_core** - Firebase initialization
- **firebase_analytics** - Usage analytics
- **firebase_crashlytics** - Crash reporting
- **flutter** - Core framework

### Key Components
- **AudioPlayer** - Handles streaming audio (optimized)
- **Linear3DVisualizer** - Real-time audio visualization (simplified)
- **DJService** - Manages DJ schedule and information
- **BMPService** - Beat detection and analysis

## 🎯 Development Priorities

### Current Focus
1. **Firebase Rollout** - Deploy to Firebase App Distribution
2. **Beta Testing** - Gather user feedback
3. **Performance Monitoring** - Track app performance
4. **Bug Fixes** - Address any issues found

### Future Enhancements
- **Multi-station Support** - Additional radio stations
- **Offline Mode** - Cached content
- **Social Features** - Share functionality
- **Premium Features** - Ad-free experience

## 🐛 Recent Fixes

### Critical Issues Resolved
- **MainActivity ClassNotFoundException** - Fixed package mismatch
- **Android Build Issues** - Resolved Gradle configuration
- **S25 Performance Issues** - Fixed frame skipping, visualizer, and play button
- **Import Errors** - Added missing imports
- **Audio Player** - Improved compatibility and reliability

### Performance Improvements
- **Frame Rate** - Eliminated frame skipping on S25
- **Visualizer** - Simplified for better performance
- **Memory Usage** - Optimized widget lifecycle
- **Error Recovery** - Robust error handling

## 📊 Performance Metrics

- **Core Features**: 100% Complete
- **UI/UX**: 95% Complete
- **Testing**: Complete and verified
- **Documentation**: 90% Complete

## 🚀 Deployment

### Firebase App Distribution
- **Ready for rollout** - All configurations complete
- **Beta testing** - Ready for user feedback
- **Performance monitoring** - Firebase Analytics configured
- **Crash reporting** - Firebase Crashlytics active

### Android
- **Debug Build**: `flutter build apk --debug`
- **Release Build**: `flutter build apk --release`
- **App Bundle**: `flutter build appbundle`

### iOS
- **Debug Build**: `flutter build ios --debug`
- **Release Build**: `flutter build ios --release`

## 📞 Support

For issues or questions:
- Check the TODO.md file for current development status
- Review the code comments for implementation details
- Test on different devices for compatibility

## 📄 License

This project is proprietary software for Trax Radio UK.

---

**Last Updated**: December 2024  
**Version**: Alpha V1  
**Status**: Ready for Firebase Rollout 🚀
