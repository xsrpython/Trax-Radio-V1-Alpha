# Trax Radio - Professional Internet Radio App

A Flutter-based internet radio application for Trax Radio UK, featuring real-time DJ scheduling, live metadata, and advanced audio visualization.

## 🎵 Features

### Professional UI/UX
- **Multi-color accent system** with blue, green, and orange themes
- **4px thick borders** on all widgets for professional appearance
- **Responsive design** that adapts to different screen sizes
- **Scrolling text animations** for long content display
- **Overflow handling** with tooltips and ellipsis for clean layout

### Live Audio Streaming
- **High-quality streaming** from Trax Radio UK
- **Real-time play/pause controls** with smooth transitions
- **Volume control** with persistent settings
- **Background playback** support for continuous listening
- **Animated turntable** with perfectly aligned spinning record

### Advanced Audio Visualization
- **Real-time visualizer bars** that react to streaming audio
- **Simplified pulse system** with reliable 500ms timing
- **Frequency-based colors**: Red (bass), Orange (mid), Yellow (high)
- **Controlled animations** with 50ms update frequency
- **State-aware behavior** - stops when paused, starts when playing

### Enhanced Beat Detection
- **Multi-frequency analysis** with bass, snare, and hi-hat patterns
- **Advanced BPM calculation** with outlier filtering and weighted averaging
- **Real-time beat detection** with 50ms analysis frequency
- **Adaptive smoothing** for accurate tempo tracking

### DJ Scheduling System
- **Real-time DJ schedule** with UK timezone handling
- **Current DJ display** with live status updates
- **Next DJ preview** with countdown information
- **Accurate scheduling** across different time zones

### Live Metadata Integration
- **Real-time track information** from Trax Radio UK
- **Scrolling text display** for long artist/title combinations
- **Auto-refresh system** every 15 seconds
- **Overflow protection** with proper layout constraints

## 🛠️ Technical Implementation

### Widgets
- **MetadataDisplay**: Live track info with scrolling text
- **CurrentDJWidget**: Real-time DJ information
- **NextDJWidget**: Upcoming DJ preview
- **TurntableWidget**: Animated turntable and record
- **Linear3DVisualizer**: Advanced audio visualization
- **BPMDisplay**: Real-time beat detection display

### Services
- **DJService**: DJ scheduling and timezone management
- **MetadataService**: Live track data fetching
- **BMPService**: Enhanced beat detection and BPM calculation
- **MonitoringService**: UI performance tracking

### Audio Analysis
- **Multi-window energy calculation** (25ms, 50ms, 200ms windows)
- **Outlier filtering** for accurate beat detection
- **Weighted averaging** with recent beats having higher weight
- **Frequency-based patterns** for realistic audio simulation

## 📱 Platform Support

### Primary Platform
- **Android**: Full feature support with optimized performance

### Future Platforms
- **iOS**: Planned for future development
- **Web**: Responsive web interface under consideration

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (latest stable version)
- Android Studio / VS Code
- Android device or emulator

### Installation
1. Clone the repository
2. Run `flutter pub get`
3. Connect Android device or start emulator
4. Run `flutter run`

### Configuration
- No API keys required
- Automatic DJ schedule loading
- Real-time metadata from Trax Radio UK

## 🎯 Current Status

### Completed Features ✅
- Professional UI styling with 4px borders
- Real-time audio streaming and visualization
- Enhanced beat detection with multi-frequency analysis
- Simplified pulse system for reliable operation
- DJ scheduling with accurate timezone handling
- Live metadata integration with scrolling text
- Responsive layout with overflow protection

### Performance Optimizations ✅
- 50ms update frequency for smooth animations
- Controlled bar expansion (max 60% height)
- Efficient state management
- Memory-optimized audio analysis
- Clean code with removed complexity

### Development Status 🟡
- Core features implemented and in testing
- Professional UI/UX with consistent styling
- Audio visualization system functional
- Error handling implemented
- Performance optimization ongoing

## 📊 Project Metrics

### Code Quality
- **Files**: 15+ core files
- **Widgets**: 6 main UI components
- **Services**: 4 core services
- **Performance**: Optimized for smooth operation

### User Experience
- **UI Responsiveness**: Optimized
- **Audio Performance**: Stable
- **Visualization**: Smooth and responsive
- **Error Handling**: Robust

## 🤝 Contributing

This project is currently in active development. For development opportunities, please contact the development team.

## 📄 License

This project is proprietary software developed for Trax Radio UK.

---

**Last Updated**: December 2024  
**Version**: 1.0.0-Alpha  
**Status**: Alpha Development 🎵
