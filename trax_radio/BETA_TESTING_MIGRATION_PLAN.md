# BETA TESTING MIGRATION PLAN
**Created:** July 30, 2025  
**Status:** READY FOR MIGRATION  
**Target:** Beta Testing Branch

## 🎯 **MIGRATION OVERVIEW**
This document captures all current development work that needs to be migrated to the beta testing branch, including UI fixes, metadata improvements, and monitoring enhancements.

---

## 📱 **CURRENT WORKFLOW STATUS**

### **✅ COMPLETED FIXES (Pixel Pro Emulator)**
1. **Overflow Resolution**: Fixed 74px overflow in portrait mode
2. **Layout Optimization**: Aggressive space reduction for all widgets
3. **Metadata Service**: Enhanced error handling and debugging
4. **Stream Player**: Improved error handling and logging
5. **Network Permissions**: Added required Android permissions

### **🔧 SPECIFIC CHANGES MADE**

#### **1. Main Layout Adjustments (`lib/main.dart`)**
```dart
// SPACING REDUCTIONS
SizedBox(height: isLandscape ? 2 : 2), // Minimal spacing (was 6px)
SizedBox(height: isLandscape ? 8 : 12), // Reduced metadata-DJ spacing (was 24px)
padding: EdgeInsets.symmetric(horizontal: 16, vertical: isLandscape ? 4 : 8), // Reduced DJ padding (was 16px)
SizedBox(height: isLandscape ? 2 : 1), // Very minimal spacing (was 2px)

// WIDGET SCALING
scale: isLandscape ? 0.8 : 0.75, // Smaller Next DJ widget (was 0.85)
height: isLandscape ? 40 : 60, // Smaller visualizer (was 80px)
final size = isLandscape ? turntableConstraints.maxHeight * 0.4 : turntableConstraints.maxWidth * 0.45; // Smaller turntable (was 0.55)

// STREAM PLAYER ENHANCEMENTS
print('Attempting to play stream: $streamUrl');
print('Stream started successfully');
SnackBar(backgroundColor: Colors.red, duration: const Duration(seconds: 5));
```

#### **2. Monitoring Dashboard Adjustments (`lib/widgets/monitoring_dashboard.dart`)**
```dart
// POSITIONING & SIZE
top: 40, // Reduced from 60
right: 5, // Reduced from 10
width: _isExpanded ? 250 : 40, // Reduced from 300:50
maxHeight: MediaQuery.of(context).size.height * 0.4, // Reduced from 0.5
```

#### **3. Metadata Service Enhancements (`lib/metadata_service.dart`)**
```dart
// ENHANCED LOGGING
print('Listeners: ${_currentTrack!.listeners}, Bitrate: ${_currentTrack!.bitrate}');
print('Response body: ${response.body}');

// BETTER ERROR HANDLING
// Added detailed error logging for debugging
```

#### **4. Android Permissions (`android/app/src/main/AndroidManifest.xml`)**
```xml
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
android:usesCleartextTraffic="true"
```

---

## 🎵 **METADATA IMPROVEMENTS TO MIGRATE**

### **Current Status:**
- **Working DJs**: 8/28 slots confirmed (28.6% coverage)
- **Confirmed Working**: Tim Bee, Simon Bradbury, DJ N-SANE
- **Enhanced Error Handling**: Better timeout and network error management
- **Debug Logging**: Detailed console output for troubleshooting

### **Key Enhancements:**
1. **Timeout Handling**: 10-second timeout with fallback to cached data
2. **Network Debugging**: Response body logging for failed requests
3. **User-Agent Headers**: Proper identification for API requests
4. **Caching Logic**: Returns last known track on errors

---

## 📊 **MONITORING SYSTEM TO MIGRATE**

### **Real-Time Monitoring Features:**
1. **Overflow Detection**: Tracks UI text overflow events
2. **DJ Change Tracking**: Records DJ transitions and crossovers
3. **Metadata Monitoring**: Logs metadata availability and changes
4. **Auto-Save**: 15-minute intervals to prevent data loss
5. **Visual Dashboard**: Expandable monitoring interface

### **Monitoring Data Classes:**
```dart
class OverflowEvent {
  final String widgetName;
  final String content;
  final int contentLength;
  final DateTime timestamp;
}

class DJChangeEvent {
  final String fromDJ;
  final String toDJ;
  final DateTime timestamp;
  final String type; // 'crossover', 'scheduled', 'auto'
}

class MetadataEvent {
  final String artist;
  final String title;
  final int listeners;
  final DateTime timestamp;
  final bool success;
}
```

---

## 🔄 **MIGRATION STEPS FOR BETA BRANCH**

### **Phase 1: Core Fixes**
1. **Apply all layout adjustments** from `lib/main.dart`
2. **Update monitoring dashboard** positioning and sizing
3. **Enhance metadata service** with improved error handling
4. **Add Android permissions** for network access

### **Phase 2: Monitoring Integration**
1. **Copy monitoring service** (`lib/monitoring_service.dart`)
2. **Copy monitoring dashboard** (`lib/widgets/monitoring_dashboard.dart`)
3. **Integrate monitoring** into main app
4. **Add path_provider dependency** to `pubspec.yaml`

### **Phase 3: Testing & Validation**
1. **Test on Pixel Pro emulator** (API 34)
2. **Verify no overflow errors**
3. **Confirm stream playback works**
4. **Validate metadata display**
5. **Test monitoring data capture**

---

## 📋 **DEPENDENCIES TO ADD**
```yaml
dependencies:
  path_provider: ^2.1.1  # For monitoring data storage
```

---

## 🎯 **BETA TESTING OBJECTIVES**

### **Primary Goals:**
1. **Eliminate UI overflow** on all device sizes
2. **Ensure stable stream playback** across devices
3. **Validate metadata reliability** for working DJs
4. **Test monitoring system** functionality
5. **Verify cross-platform compatibility**

### **Success Criteria:**
- ✅ **Zero overflow errors** in console
- ✅ **Stream plays consistently** on all test devices
- ✅ **Metadata displays** for confirmed working DJs
- ✅ **Monitoring data saves** every 15 minutes
- ✅ **All widgets fit** on screen properly

---

## 📝 **FILES TO MIGRATE**

### **Core App Files:**
- `lib/main.dart` (layout fixes + monitoring integration)
- `lib/metadata_service.dart` (enhanced error handling)
- `lib/monitoring_service.dart` (new file)
- `lib/widgets/monitoring_dashboard.dart` (new file)

### **Configuration Files:**
- `android/app/src/main/AndroidManifest.xml` (permissions)
- `pubspec.yaml` (dependencies)

### **Documentation:**
- `MONITORING_WORKFLOW.md` (current workflow)
- `TIME_TRACKING_SYSTEM.md` (session tracking)
- `DJ_METADATA_STATUS_REPORT.md` (DJ status)

---

## 🚀 **NEXT STEPS**

1. **Create beta branch** from current development
2. **Apply all fixes** documented above
3. **Test thoroughly** on multiple devices
4. **Validate monitoring** system functionality
5. **Prepare for beta release**

---

**Note:** This migration preserves all current development work while preparing for stable beta testing. All UI fixes, metadata improvements, and monitoring features are documented for seamless transfer to the beta branch. 