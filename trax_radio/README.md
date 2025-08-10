# Trax Radio UK

A professional internet radio streaming application for Trax Radio UK, built with Flutter. **Ready for Play Store submission.**

## 🎵 Features

### Core Functionality
- **Live Streaming** - High-quality internet radio streaming
- **Audio Visualization** - Real-time beat detection and visualizer
- **DJ Information** - Current and upcoming DJ schedules
- **Metadata Display** - Song information and artist details
- **Professional UI** - Modern, responsive design
- **Portrait Mode Lock** - Optimized for mobile use

### Technical Features
- **Multi-Platform Support** - Android, iOS, Web, Desktop
- **Just Audio Plugin** - Robust audio streaming with background support
- **Background Audio** - Continuous playback when switching apps
- **Audio Focus Management** - Professional audio handling
- **Real-time Updates** - Live DJ and schedule information
- **Performance Optimized** - Smooth 60fps on Samsung Galaxy S25
- **Responsive Design** - Adapts to different screen sizes

## 📱 Current Status

### ✅ Completed Features
- **Audio Streaming** - Live radio with Just Audio plugin
- **Visualizer** - Real-time audio visualization and BPM detection
- **DJ Service** - Current and next DJ information display
- **UI Components** - Professional, modern interface
- **Performance** - Optimized for smooth operation
- **App Icon** - Professional turntable/radio themed icon

### 🎯 Ready for
- **Play Store Submission** - App configured and ready
- **Beta Testing** - APK ready for distribution
- **Production Release** - All core features complete

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (latest stable)
- Android Studio / VS Code
- Android device or emulator

### Installation
1. **Clone the repository**
   ```bash
   git clone <repository-url>
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

## 🏗️ Project Structure

```
trax_radio/
├── lib/
│   ├── main.dart              # App entry point
│   ├── bpm_service.dart       # Beat detection service
│   ├── dj_service.dart        # DJ information service
│   └── widgets/               # UI components
│       ├── bpm_display.dart   # BPM visualization
│       ├── current_dj_widget.dart
│       ├── equalizer_visualizer.dart
│       └── ...
├── android/                   # Android-specific code
├── ios/                      # iOS-specific code
├── assets/                   # Images and data files
└── pubspec.yaml             # Dependencies and configuration
```

## 🔧 Technical Details

### Dependencies
- **just_audio** - Audio streaming and playback
- **audio_session** - Background audio and audio focus management
- **timezone** - Time zone handling
- **http** - API communication
- **path_provider** - File system access

### Key Components
- **BPM Service** - Real-time beat detection
- **DJ Service** - Schedule and information management
- **Audio Visualizer** - Real-time audio visualization
- **Main Player** - Central audio control interface

## 📊 Development Priorities

### Current Focus
1. **Play Store Submission** - Final preparation and testing
2. **Performance Optimization** - Ensure smooth operation
3. **User Experience** - Polish UI and interactions

### Future Enhancements
- **iOS Optimization** - Enhanced iOS support
- **Web Features** - Advanced web functionality
- **Analytics** - User behavior tracking
- **Push Notifications** - DJ schedule updates

## 🐛 Recent Fixes

### Performance Optimizations
- **Frame Rate**: Optimized for 60fps on Samsung Galaxy S25
- **Visualizer**: Improved performance and smoothness
- **Memory Usage**: Reduced memory footprint
- **Battery Life**: Optimized audio processing

### UI Improvements
- **Responsive Design**: Better adaptation to screen sizes
- **Icon System**: Professional app icon implementation
- **Color Scheme**: Consistent visual identity
- **Layout**: Improved component positioning

## 🚀 Deployment

### Play Store Ready
- **App Icon**: Professional design implemented
- **Build Configuration**: Optimized for release
- **Metadata**: Complete app information
- **Signing**: Ready for release keystore

### Build Commands
```bash
# Development build
flutter build apk --debug

# Release build
flutter build apk --release

# Play Store build (after keystore setup)
flutter build appbundle --release
```

## 📱 Device Compatibility

### Tested Devices
- **Samsung Galaxy S25** - Primary development device
- **Android 5.0+** - Minimum API level 21
- **High Performance** - Optimized for modern devices

### Performance Metrics
- **Frame Rate**: 60fps target achieved
- **Audio Latency**: Minimal streaming delay
- **Memory Usage**: Optimized for mobile devices
- **Battery Impact**: Minimal background processing

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

This project is proprietary software for Trax Radio UK.

---

**Status**: Ready for Play Store Submission 🚀
**Version**: 1.0.0
**Last Updated**: August 2025
