# Trax Radio UK - V1.0.0 Beta

---

## 🚦 Workflow Summary (as of V1.0.0 Beta)

### ✅ **Completed**
- Integrated advanced UI features (3D visualizer, DJ widgets, BPM display)
- Fixed DJ schedule logic and timezone handling
- Improved visualizer responsiveness and beat detection
- Added custom splash screen and app icons
- Cleaned up all debug code and optimized codebase
- Updated app version display to "V1.0.0 Beta"
- Created marketing blurbs and workflow documentation
- Started beta tester list
- Committed and pushed all changes to `Trax-Radio-V1-Beta` branch

### 🕒 **Pending/Next Steps**
- Finalize Next DJ widget logic for end-of-day/week (e.g., "Tomorrow" prefix, scrolling text)
- Complete beta tester list (target: 20 testers)
- Integrate Firebase App Distribution for Android beta
- Prepare onboarding guide for Android beta testers
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
- **Next DJ Widget**: Displays upcoming DJ information with schedule times
- **Automatic Updates**: Real-time DJ schedule updates every 30 seconds
- **Fallback System**: Graceful handling when no DJs are scheduled

### **Advanced Audio Visualization**
- **3D Linear Visualizer**: Multi-layered 3D audio bars with depth effects
- **Real-time Beat Detection**: Analyzes audio stream for beat synchronization
- **BPM Display**: Shows detected beats per minute
- **Frequency Response**: Different visual responses for bass, mid, and high frequencies
- **Dynamic Effects**: Glow effects, shadows, and beat amplification

### **Professional UI/UX**
- **Responsive Design**: Optimized for both portrait and landscape orientations
- **Dark Theme**: Professional black background with accent colors
- **Animated Elements**: Rotating record, scrolling DJ names, dynamic visualizers
- **Material Design**: Modern Flutter Material 3 components

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
- **DJ Service**: JSON-based DJ schedule management
- **Visualizer Engine**: Custom 3D audio visualization
- **Beat Detection**: Real-time audio analysis

### **Key Dependencies**
```yaml
dependencies:
  flutter: sdk: flutter
  just_audio: ^0.10.4
  cupertino_icons: ^1.0.8
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
- **Turntable**: Animated record and turntable graphics
- **DJ Widgets**: Current and next DJ information
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

## 🎵 Audio Features

### **Beat Detection**
- **Volume Analysis**: Monitors audio volume changes
- **Peak Detection**: Identifies sudden volume spikes
- **BPM Calculation**: Real-time tempo detection
- **Beat Synchronization**: Visual effects sync to music

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
- Automatic refresh every 30 seconds
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

### **Debug Mode**
Enable debug logging by setting `debugShowCheckedModeBanner: true` in main.dart

## 📄 License

This project is proprietary software developed by DJXSR for Trax Radio UK.

## 👨‍💻 Development

### **Code Structure**
```
lib/
├── main.dart              # Main application entry
├── dj_service.dart        # DJ scheduling logic
├── splash_screen.dart     # Custom splash screen
└── widgets/
    ├── current_dj_widget.dart
    ├── next_dj_widget.dart
    └── linear_3d_visualizer.dart
```

### **Contributing**
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 🎉 Version History

### **V1.0.0 Beta** (Current)
- ✅ Complete DJ scheduling system
- ✅ Advanced 3D audio visualization
- ✅ Real-time beat detection
- ✅ Responsive UI design
- ✅ Professional audio streaming
- ✅ Cross-platform compatibility

## 📞 Support

For support and questions:
- **Developer**: DJXSR
- **Repository**: https://github.com/xsrpython/traxradionew
- **Branch**: Trax-Radio-V1-Beta

---

**Trax Radio UK - V1.0.0 Beta** 🎵✨
*Professional Radio Streaming with Advanced Visualization*
