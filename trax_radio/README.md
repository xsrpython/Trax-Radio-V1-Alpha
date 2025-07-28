# Trax Radio UK - V1.0.0 Beta

---

## 🚦 Workflow Summary (as of V1.0.0 Beta)

### ✅ **Completed**
- Integrated advanced UI features (3D visualizer, DJ widgets, BPM display)
- Fixed DJ schedule logic and timezone handling with proper day indicators
- Improved visualizer responsiveness and beat detection
- Enhanced BPM service with realistic beat patterns and fallback generation
- Added custom splash screen and app icons
- Cleaned up all debug code and optimized codebase
- Updated app version display to "V1.0.0 Beta"
- Updated packages (timezone to 0.10.1, flutter_launcher_icons to 0.14.4)
- Fixed text overflow issues in Next DJ widget
- Created marketing blurbs and workflow documentation
- Started beta tester list (6 testers identified)
- Implemented beta expiration system (currently disabled)
- Committed and pushed all changes to `Trax-Radio-V1-Beta` branch

### 🕒 **Pending/Next Steps**
- Complete beta tester list (target: 20 testers, need 14 more)
- Set up Firebase App Distribution for Android beta
- Prepare onboarding guide for Android beta testers
- Re-enable beta expiration when ready for launch
- Continue real-time DJ schedule monitoring for further bug fixes

---

A professional Flutter-based radio streaming application featuring real-time DJ scheduling, advanced audio visualization, and beat detection.

## 🎵 Features

### **Live Radio Streaming**
- High-quality audio streaming from Trax Radio UK
- Seamless play/pause controls
- Real-time audio processing

### **DJ Scheduling System**
- **Current DJ Display**: Shows the currently playing DJ with animated scrolling text
- **Next DJ Widget**: Displays upcoming DJ information with proper day indicators (Today, Tomorrow, Mon, etc.)
- **Automatic Updates**: Real-time DJ schedule updates every 10 seconds
- **Fallback System**: Graceful handling when no DJs are scheduled
- **Timezone Support**: Proper UK to local timezone conversion

### **Advanced Audio Visualization**
- **3D Linear Visualizer**: Multi-layered 3D audio bars with depth effects
- **Real-time Beat Detection**: Analyzes audio stream for beat synchronization
- **BPM Display**: Shows detected beats per minute with realistic values (100-140 BPM range)
- **Frequency Response**: Different visual responses for bass, mid, and high frequencies
- **Dynamic Effects**: Glow effects, shadows, and beat amplification

### **Professional UI/UX**
- **Responsive Design**: Optimized for both portrait and landscape orientations
- **Dark Theme**: Professional black background with accent colors
- **Animated Elements**: Rotating record, scrolling DJ names, dynamic visualizers
- **Material Design**: Modern Flutter Material 3 components
- **Text Overflow Handling**: Smart text truncation with tooltips for long DJ names

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.8.1 or higher
- Dart SDK
- Android Studio / VS Code
- Android device or emulator

### Installation
1. Clone the repository:
   ```bash
   git clone https://github.com/xsrpython/traxradionew.git
   cd traxradionew/trax_radio
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the application:
   ```bash
   flutter run
   ```

## 📱 Supported Platforms

- **Android**: Full support with optimized performance
- **iOS**: Compatible (requires testing)
- **Web**: Compatible (limited audio features)
- **Windows**: Compatible
- **macOS**: Compatible
- **Linux**: Compatible

## 🎛️ Technical Architecture

### **Core Components**
- **AudioPlayer**: Just Audio package for streaming
- **DJ Service**: JSON-based DJ schedule management with timezone support
- **Visualizer Engine**: Custom 3D audio visualization
- **Beat Detection**: Real-time audio analysis with fallback BPM generation

### **Key Dependencies**
```yaml
dependencies:
  flutter: sdk: flutter
  just_audio: ^0.10.4
  timezone: ^0.10.1
  cupertino_icons: ^1.0.8

dev_dependencies:
  flutter_launcher_icons: ^0.14.4
  flutter_lints: ^6.0.0
```

### **Asset Management**
- **Audio Stream**: HTTPS streaming from Trax Radio UK
- **DJ Schedule**: JSON file with DJ information and schedules
- **Images**: Turntable and record graphics
- **Icons**: Material Design icons

## 🎨 UI Components

### **Main Interface**
- **Title**: "Trax Radio UK" with responsive sizing
- **Visualizer**: 3D audio bars with beat detection
- **BPM Display**: Real-time BPM values with pulse animation
- **Turntable**: Animated record and turntable graphics
- **DJ Widgets**: Current and next DJ information with day indicators
- **Controls**: Play/pause button with loading states

### **Responsive Design**
- **Portrait Mode**: Optimized for mobile devices
- **Landscape Mode**: Enhanced layout for tablets
- **Dynamic Scaling**: Automatic component sizing
- **Touch Optimization**: Large touch targets

## 🔧 Configuration

### **DJ Schedule**
Edit `assets/dj_schedule.json` to update DJ information:
```json
[
  {
    "name": "DJ Name",
    "schedule": [
      {
        "day": "Wednesday",
        "start": "18:00",
        "end": "19:00"
      }
    ],
    "bio": "DJ description",
    "image": "image_url"
  }
]
```

### **Audio Stream**
Update the stream URL in `lib/main.dart`:
```dart
final String streamUrl = 'https://hello.citrus3.com:8138/stream';
```

### **Beta Expiration (Currently Disabled)**
To re-enable beta expiration, uncomment the code in `lib/main.dart`:
```dart
// static final DateTime _betaExpirationDate = DateTime(2024, 2, 15);
```

## 🎵 Audio Features

### **Beat Detection**
- **Volume Analysis**: Monitors audio volume changes
- **Peak Detection**: Identifies sudden volume spikes
- **BPM Calculation**: Real-time tempo detection with fallback generation
- **Beat Synchronization**: Visual effects sync to music
- **Realistic Patterns**: Simulated beat patterns for consistent BPM display

### **Visualization**
- **Frequency Bands**: 12-64 audio frequency bars
- **3D Effects**: Depth, shadows, and perspective
- **Color Gradients**: Dynamic color changes
- **Animation**: Smooth transitions and effects

## 🚀 Performance Optimization

### **Memory Management**
- Efficient audio processing
- Optimized widget rebuilds
- Proper resource disposal
- Background processing

### **Battery Optimization**
- Intelligent update intervals
- Efficient calculations
- Minimal CPU usage
- Smart timer management

## 🔄 Update System

### **DJ Schedule Updates**
- Automatic refresh every 10 seconds
- JSON-based configuration
- No app restart required
- Fallback mechanisms

### **Version Management**
- Semantic versioning (1.0.0)
- Beta release channel
- Git-based deployment
- Automated builds

## 🐛 Troubleshooting

### **Common Issues**
1. **Audio not playing**: Check internet connection and stream URL
2. **DJ not showing**: Verify `dj_schedule.json` format and assets
3. **Visualizer not working**: Ensure audio permissions are granted
4. **Performance issues**: Check device compatibility and memory
5. **BPM not showing**: App will show fallback BPM values when no beats detected

### **Debug Mode**
Enable debug logging by setting `debugShowCheckedModeBanner: true` in main.dart

## 📄 License

This project is proprietary software developed by DJXSR for Trax Radio UK.

## 👨‍💻 Development

### **Code Structure**
```
lib/
├── main.dart              # Main application entry
├── dj_service.dart        # DJ scheduling logic with timezone support
├── bpm_service.dart       # Beat detection and BPM calculation
├── splash_screen.dart     # Custom splash screen
└── widgets/
    ├── current_dj_widget.dart
    ├── next_dj_widget.dart
    ├── linear_3d_visualizer.dart
    └── bpm_display.dart
```

### **Contributing**
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 🎉 Version History

### **V1.0.0 Beta** (Current)
- ✅ Complete DJ scheduling system with day indicators
- ✅ Advanced 3D audio visualization
- ✅ Real-time beat detection with fallback BPM
- ✅ Responsive UI design with text overflow handling
- ✅ Professional audio streaming
- ✅ Cross-platform compatibility
- ✅ Updated packages and optimized codebase
- ✅ Beta expiration system (disabled)
- ✅ Marketing materials and workflow documentation

## 📞 Support

For support and questions:
- **Developer**: DJXSR
- **Repository**: https://github.com/xsrpython/traxradionew
- **Branch**: Trax-Radio-V1-Beta

---

**Trax Radio UK - V1.0.0 Beta** 🎵✨
*Professional Radio Streaming with Advanced Visualization*
