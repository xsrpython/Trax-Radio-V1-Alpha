# 🎵 Trax Radio BUTT App

**Status**: Initial Development Setup  
**Version**: 0.1.0  
**Last Updated**: August 2025  

---

## 🎯 **Project Overview**

**Trax Radio BUTT App** is a bespoke broadcasting software designed specifically for DJs to connect their equipment to the Trax Radio live stream with standardized metadata output.

### **What is BUTT?**
**BUTT** = **B**roadcast **U**sing **T**his **T**ool

A professional broadcasting application that allows DJs to:
- Connect any DJ equipment (USB Audio, MIDI, etc.)
- Stream to Trax Radio live stream
- Standardize metadata output
- Provide real-time stream monitoring

---

## 🎧 **Target Hardware**

### **Primary Test Equipment**
- **Pioneer DDJ-1000** (4-channel DJ controller)
- **USB Audio Interface** support
- **MIDI Mapping** capabilities

### **Universal Compatibility**
- **Windows**: ASIO/WASAPI audio drivers
- **macOS**: Core Audio support
- **Linux**: ALSA/PulseAudio support
- **Cross-platform**: USB Audio devices

---

## 🚀 **Core Features**

### **Audio Input Management**
- **Multi-device support** - Connect any audio interface
- **Real-time monitoring** - Visual feedback for audio levels
- **Device detection** - Automatic hardware recognition
- **Audio routing** - Flexible input/output configuration

### **Streaming Integration**
- **Trax Radio API** - Direct connection to live stream
- **Metadata injection** - Real-time track information
- **Stream health** - Connection monitoring and status
- **Auto-reconnect** - Robust connection handling

### **DJ Equipment Support**
- **USB Audio** - Direct device connection
- **MIDI Mapping** - Customizable controls
- **Hardware integration** - Pioneer DDJ-1000 support
- **Universal compatibility** - Any DJ equipment

### **Metadata Standardization**
- **Track information** - Artist, title, album
- **DJ information** - Current DJ, show details
- **Stream metadata** - Quality, bitrate, format
- **Real-time updates** - Live metadata injection

---

## 🏗️ **Technical Architecture**

### **Frontend (Flutter)**
- **Cross-platform UI** - Android, iOS, Web
- **Real-time updates** - Live stream monitoring
- **Responsive design** - All screen sizes
- **Native performance** - Optimized rendering

### **Backend Services**
- **Audio processing** - Real-time audio handling
- **Stream management** - Connection and routing
- **Metadata service** - Track information handling
- **API integration** - Trax Radio services

### **Audio Engine**
- **Just Audio** - Professional audio streaming
- **Audio Session** - Cross-platform audio management
- **Real-time processing** - Low-latency audio
- **Device abstraction** - Universal hardware support

---

## 📱 **Platform Support**

### **Mobile (Primary)**
- **Android** - Full feature support
- **iOS** - Core functionality
- **Responsive design** - All screen sizes

### **Web (Secondary)**
- **Browser-based** - No installation required
- **Audio API** - Modern web audio support
- **Cross-platform** - Any device with browser

### **Desktop (Future)**
- **Windows** - Native audio support
- **macOS** - Core Audio integration
- **Linux** - ALSA/PulseAudio support

---

## 🔧 **Development Setup**

### **Prerequisites**
- **Flutter SDK** 3.32.7 or higher
- **Dart SDK** 3.2.0 or higher
- **Android Studio** / VS Code
- **Git** for version control

### **Installation**
```bash
# Clone the repository
git clone [repository-url]
cd trax_radio_butt_app

# Install dependencies
flutter pub get

# Run the app
flutter run
```

### **Development Commands**
```bash
# Clean build
flutter clean

# Get dependencies
flutter pub get

# Run on device
flutter run

# Build APK
flutter build apk

# Build App Bundle
flutter build appbundle
```

---

## 📁 **Project Structure**

```
trax_radio_butt_app/
├── lib/
│   ├── main.dart                 # App entry point
│   ├── services/                 # Business logic
│   │   ├── audio_service.dart    # Audio management
│   │   ├── stream_service.dart   # Streaming logic
│   │   ├── metadata_service.dart # Metadata handling
│   │   └── device_service.dart   # Hardware detection
│   ├── models/                   # Data models
│   │   ├── audio_device.dart     # Device information
│   │   ├── stream_config.dart    # Stream settings
│   │   └── metadata_model.dart   # Metadata structure
│   ├── widgets/                  # UI components
│   │   ├── audio_monitor.dart    # Audio level display
│   │   ├── device_panel.dart     # Device management
│   │   ├── stream_status.dart    # Connection status
│   │   └── metadata_display.dart # Track information
│   └── utils/                    # Helper functions
│       ├── constants.dart         # App constants
│       ├── helpers.dart          # Utility functions
│       └── validators.dart       # Input validation
├── android/                      # Android-specific code
├── ios/                         # iOS-specific code
├── web/                         # Web-specific code
├── test/                        # Unit and widget tests
└── assets/                      # App resources
    ├── images/                  # App images
    ├── icons/                   # App icons
    └── audio/                   # Sample audio files
```

---

## 🎵 **Audio Integration**

### **Input Sources**
- **USB Audio Interface** - Direct hardware connection
- **System Audio** - Capture system audio output
- **Microphone** - Voice input support
- **File Input** - Pre-recorded audio files

### **Output Destinations**
- **Trax Radio Stream** - Primary live stream
- **Local Recording** - Save stream locally
- **Audio Monitoring** - Real-time playback
- **Multiple Outputs** - Stream to multiple destinations

### **Audio Processing**
- **Real-time mixing** - Multiple input sources
- **Audio effects** - Basic audio processing
- **Level control** - Input/output gain
- **Noise reduction** - Audio cleanup

---

## 🔌 **Hardware Integration**

### **Pioneer DDJ-1000**
- **4-channel mixing** - Professional DJ setup
- **USB connection** - Direct computer interface
- **MIDI mapping** - Customizable controls
- **Audio routing** - Flexible input/output

### **Universal Support**
- **USB Audio Class** - Standard audio devices
- **ASIO/WASAPI** - Windows audio drivers
- **Core Audio** - macOS audio system
- **ALSA/PulseAudio** - Linux audio

### **Device Detection**
- **Automatic recognition** - Plug-and-play setup
- **Driver management** - Audio driver handling
- **Configuration storage** - Device settings
- **Hot-swapping** - Dynamic device changes

---

## 📊 **Metadata System**

### **Track Information**
```json
{
  "track": {
    "title": "Song Title",
    "artist": "Artist Name",
    "album": "Album Name",
    "duration": "3:45",
    "bpm": 128,
    "key": "C Major"
  },
  "dj": {
    "name": "DJ Name",
    "show": "Show Title",
    "time": "2025-08-14T21:00:00Z"
  },
  "stream": {
    "quality": "320kbps",
    "format": "MP3",
    "bitrate": 320000
  }
}
```

### **Real-time Updates**
- **Live metadata** - Current track information
- **DJ schedule** - Upcoming shows
- **Stream status** - Connection health
- **Audio levels** - Input/output monitoring

---

## 🚀 **Development Roadmap**

### **Phase 1: Foundation (Current)**
- [ ] **Project setup** - Basic Flutter structure
- [ ] **Audio service** - Basic audio handling
- [ ] **Device detection** - Hardware recognition
- [ ] **Basic UI** - Main app interface

### **Phase 2: Core Features**
- [ ] **Audio input** - Device connection
- [ ] **Streaming** - Trax Radio integration
- [ ] **Metadata** - Track information handling
- [ ] **Real-time monitoring** - Live status updates

### **Phase 3: Advanced Features**
- [ ] **MIDI mapping** - Customizable controls
- [ ] **Audio effects** - Basic processing
- [ ] **Recording** - Local stream capture
- [ ] **Multi-output** - Multiple destinations

### **Phase 4: Polish & Testing**
- [ ] **UI/UX refinement** - User experience
- [ ] **Performance optimization** - Speed and efficiency
- [ ] **Testing** - Device compatibility
- [ ] **Documentation** - User guides

---

## 🧪 **Testing Strategy**

### **Hardware Testing**
- **Pioneer DDJ-1000** - Primary test device
- **USB Audio interfaces** - Various manufacturers
- **Different computers** - Windows, macOS, Linux
- **Audio devices** - Speakers, headphones, monitors

### **Software Testing**
- **Unit tests** - Individual component testing
- **Integration tests** - Service interaction testing
- **UI tests** - User interface testing
- **Performance tests** - Speed and memory testing

### **User Testing**
- **DJ feedback** - Professional user input
- **Usability testing** - Interface evaluation
- **Performance testing** - Real-world usage
- **Compatibility testing** - Various setups

---

## 📚 **Documentation**

### **User Guides**
- **Installation guide** - Setup instructions
- **User manual** - Feature explanations
- **Troubleshooting** - Common issues and solutions
- **FAQ** - Frequently asked questions

### **Developer Docs**
- **API documentation** - Service interfaces
- **Code examples** - Usage patterns
- **Architecture guide** - System design
- **Contributing guide** - Development setup

---

## 🤝 **Contributing**

### **Development Setup**
1. **Fork the repository**
2. **Create feature branch**
3. **Make changes**
4. **Test thoroughly**
5. **Submit pull request**

### **Code Standards**
- **Dart/Flutter** - Official style guide
- **Clean code** - Readable and maintainable
- **Documentation** - Clear code comments
- **Testing** - Comprehensive test coverage

---

## 📞 **Support & Contact**

### **Development Team**
- **Project Lead** - [Your Name]
- **Audio Engineer** - [Audio Specialist]
- **UI/UX Designer** - [Designer]
- **QA Tester** - [Tester]

### **Contact Information**
- **Email** - [your-email@domain.com]
- **GitHub** - [github-username]
- **Discord** - [discord-username]

---

## 📄 **License**

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.

---

## 🙏 **Acknowledgments**

- **Trax Radio UK** - For the streaming platform
- **Flutter Team** - For the amazing framework
- **Audio Community** - For technical guidance
- **DJ Community** - For feature requests and feedback

---

**Ready to revolutionize DJ broadcasting! 🎵🚀**
