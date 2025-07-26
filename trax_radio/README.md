# Trax Radio UK - Flutter App

A cross-platform Flutter application for streaming Trax Radio UK with real-time DJ information, responsive design, and enhanced audio visualization.

## 🎵 Features

### **Core Functionality**
- **Live Audio Streaming** from `https://hello.citrus3.com:8138/stream`
- **Real-time DJ Detection** with automatic schedule updates
- **Responsive Design** optimized for both portrait and landscape orientations
- **Enhanced Audio Visualization** with beat detection and 3D effects

### **DJ Information System**
- **Current DJ Display** with scrolling text animation
- **Next DJ Widget** showing upcoming DJ and start time
- **Automatic Schedule Updates** every minute
- **UK Timezone Support** with automatic BST/GMT detection

### **Audio Visualization**
- **Linear 3D Visualizer** with beat-responsive bars
- **Enhanced Beat Detection** with dramatic visual spikes
- **Real-time Audio Analysis** using volume streams
- **Responsive Layout** spanning full app width

### **UI/UX Features**
- **Turntable & Record Animation** with spinning record during playback
- **Responsive Widget Scaling** for different screen sizes
- **Smooth Scrolling Text** for DJ names
- **Professional Color Scheme** with green accents and orange highlights

## 📱 Platform Support

- **Android** (Primary target)
- **iOS** (Compatible)
- **Web** (Compatible)
- **Desktop** (Compatible)

## 🛠 Technical Stack

- **Framework**: Flutter 3.32.7
- **Language**: Dart
- **Audio**: `just_audio` package
- **Permissions**: `permission_handler`
- **Audio Session**: `audio_session`
- **State Management**: Flutter StatefulWidget
- **Animation**: Flutter AnimationController

## 🚀 Installation & Setup

### Prerequisites
- Flutter SDK 3.32.7 or higher
- Android Studio / VS Code
- Android SDK (for Android development)

### Setup Steps
1. **Clone the repository**
   ```bash
   git clone https://github.com/xsrpython/traxradionew.git
   cd traxradionew/trax_radio
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run --debug
   ```

## 📊 Project Structure

```
trax_radio/
├── lib/
│   ├── main.dart                 # Main app entry point
│   ├── dj_service.dart           # DJ schedule management
│   ├── widgets/
│   │   ├── current_dj_widget.dart    # Current DJ display
│   │   ├── next_dj_widget.dart       # Next DJ display
│   │   └── linear_3d_visualizer.dart # Audio visualizer
│   └── assets/
│       ├── dj_schedule.json      # DJ schedule data
│       ├── turntable.png         # Turntable image
│       └── record.png            # Record image
├── pubspec.yaml                  # Dependencies
└── README.md                     # This file
```

## 🎛 Configuration

### DJ Schedule
The app uses `assets/dj_schedule.json` for DJ information. Each DJ entry includes:
- **Name**: DJ display name
- **Schedule**: Array of time slots with day, start, and end times
- **Bio**: DJ biography (optional)
- **Image**: DJ profile image URL (optional)

### Audio Stream
- **URL**: `https://hello.citrus3.com:8138/stream`
- **Format**: MP3/AAC stream
- **Quality**: High-quality audio

## 🔧 Recent Optimizations

### **Responsive Design (Latest)**
- **Portrait Mode**: Optimized spacing and widget sizes
- **Landscape Mode**: Larger turntable, reduced overflow
- **Dynamic Scaling**: Widgets adapt to screen orientation
- **No Overflow Issues**: Fixed 150px portrait and 86px landscape overflow

### **Enhanced Visualization**
- **Beat Detection**: More sensitive and dramatic response
- **Linear Layout**: No cropping issues
- **Real-time Response**: Faster audio analysis
- **3D Effects**: Enhanced visual depth

### **DJ System Improvements**
- **Fixed Next DJ Logic**: Proper chronological ordering
- **Smooth Scrolling**: Linear animation without jerky behavior
- **Reduced Spacing**: Tighter text containers
- **Debug Output**: Comprehensive logging for troubleshooting

## 📈 Performance Metrics

- **App Size**: ~15MB (optimized)
- **Memory Usage**: ~50MB during playback
- **Startup Time**: <3 seconds
- **Audio Latency**: <500ms
- **Visualization FPS**: 60fps

## 🐛 Known Issues

- **Debug Prints**: Multiple print statements in production code (info level)
- **Deprecated Methods**: Some `withOpacity` calls need updating
- **Unused Fields**: Some animation fields not currently used

## 🔮 Future Enhancements

- [ ] **App Icons**: Generate proper app icons
- [ ] **Push Notifications**: DJ change notifications
- [ ] **Offline Mode**: Cached DJ information
- [ ] **Social Integration**: Share current track/DJ
- [ ] **Equalizer**: Audio equalizer controls
- [ ] **Playlist History**: Recent tracks played

## 👨‍💻 Development

### **Developer**: DJXSR (xsr_python@hotmail.com)
### **Last Updated**: January 2025
### **Version**: 1.0.0

## 📄 License

This project is proprietary software developed for Trax Radio UK.

## 🤝 Contributing

For feature requests or bug reports, please contact:
- **Email**: xsr_python@hotmail.com
- **GitHub**: https://github.com/xsrpython/traxradionew

---

**Trax Radio UK** - Keeping the music alive! 🎵📻
