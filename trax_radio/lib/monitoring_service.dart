import 'dart:async';
import 'dart:developer' as developer;
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dj_service.dart';
import 'metadata_service.dart';

class MonitoringService {
  static final MonitoringService _instance = MonitoringService._internal();
  factory MonitoringService() => _instance;
  MonitoringService._internal();

  // Monitoring state
  bool _isMonitoring = false;
  Timer? _monitoringTimer;
  Timer? _saveTimer;
  String _lastCurrentDJ = '';
  String _lastNextDJ = '';
  Map<String, dynamic>? _lastTrackInfo;
  DateTime _lastDJChange = DateTime.now();
  
  // Overflow tracking
  List<OverflowEvent> _overflowEvents = [];
  
  // DJ change tracking
  List<DJChangeEvent> _djChangeEvents = [];
  
  // Metadata tracking
  List<MetadataEvent> _metadataEvents = [];

  // Stream controllers for real-time updates
  final StreamController<OverflowEvent> _overflowController = 
      StreamController<OverflowEvent>.broadcast();
  final StreamController<DJChangeEvent> _djChangeController = 
      StreamController<DJChangeEvent>.broadcast();
  final StreamController<MetadataEvent> _metadataController = 
      StreamController<MetadataEvent>.broadcast();

  // Getters for streams
  Stream<OverflowEvent> get overflowStream => _overflowController.stream;
  Stream<DJChangeEvent> get djChangeStream => _djChangeController.stream;
  Stream<MetadataEvent> get metadataStream => _metadataController.stream;

  // Getters for event lists
  List<OverflowEvent> get overflowEvents => List.unmodifiable(_overflowEvents);
  List<DJChangeEvent> get djChangeEvents => List.unmodifiable(_djChangeEvents);
  List<MetadataEvent> get metadataEvents => List.unmodifiable(_metadataEvents);

  bool get isMonitoring => _isMonitoring;

  /// Start real-time monitoring
  void startMonitoring() {
    if (_isMonitoring) return;
    
    _isMonitoring = true;
    _logMonitoringEvent('🔴 MONITORING STARTED', 'Real-time monitoring enabled');
    
    // Load any previously saved data
    _loadSavedData();
    
    // Start monitoring timer (every 5 seconds for detailed tracking)
    _monitoringTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _checkDJChanges();
      _checkMetadataChanges();
    });
    
    // Start auto-save timer (every 15 minutes)
    _saveTimer = Timer.periodic(const Duration(minutes: 15), (timer) {
      _saveMonitoringData();
    });
    
    // Initial check
    _checkDJChanges();
    _checkMetadataChanges();
  }

  /// Stop real-time monitoring
  void stopMonitoring() {
    if (!_isMonitoring) return;
    
    _isMonitoring = false;
    _monitoringTimer?.cancel();
    _saveTimer?.cancel();
    
    // Save data before stopping
    _saveMonitoringData();
    
    _logMonitoringEvent('🟢 MONITORING STOPPED', 'Real-time monitoring disabled');
  }

  /// Save monitoring data to local storage
  Future<void> _saveMonitoringData() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final monitoringDir = Directory('${directory.path}/monitoring');
      
      if (!await monitoringDir.exists()) {
        await monitoringDir.create(recursive: true);
      }
      
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final data = {
        'timestamp': timestamp,
        'overflowEvents': _overflowEvents.map((e) => e.toJson()).toList(),
        'djChangeEvents': _djChangeEvents.map((e) => e.toJson()).toList(),
        'metadataEvents': _metadataEvents.map((e) => e.toJson()).toList(),
        'summary': getMonitoringSummary(),
      };
      
      final file = File('${monitoringDir.path}/monitoring_data_$timestamp.json');
      await file.writeAsString(jsonEncode(data));
      
      // Keep only the last 10 save files to prevent storage bloat
      await _cleanupOldSaveFiles(monitoringDir);
      
      _logMonitoringEvent('💾 DATA SAVED', 'Monitoring data saved to local storage');
    } catch (e) {
      _logMonitoringEvent('❌ SAVE ERROR', 'Failed to save monitoring data: $e');
    }
  }

  /// Load previously saved monitoring data
  Future<void> _loadSavedData() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final monitoringDir = Directory('${directory.path}/monitoring');
      
      if (!await monitoringDir.exists()) return;
      
      final files = monitoringDir.listSync()
          .whereType<File>()
          .where((file) => file.path.contains('monitoring_data_'))
          .toList();
      
      if (files.isEmpty) return;
      
      // Load the most recent save file
      files.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));
      final latestFile = files.first;
      
      final data = jsonDecode(await latestFile.readAsString());
      
      // Restore events
      _overflowEvents.clear();
      _overflowEvents.addAll(
        (data['overflowEvents'] as List).map((e) => OverflowEvent.fromJson(e))
      );
      
      _djChangeEvents.clear();
      _djChangeEvents.addAll(
        (data['djChangeEvents'] as List).map((e) => DJChangeEvent.fromJson(e))
      );
      
      _metadataEvents.clear();
      _metadataEvents.addAll(
        (data['metadataEvents'] as List).map((e) => MetadataEvent.fromJson(e))
      );
      
      _logMonitoringEvent('📂 DATA LOADED', 'Loaded ${_overflowEvents.length} overflow, ${_djChangeEvents.length} DJ, ${_metadataEvents.length} metadata events');
    } catch (e) {
      _logMonitoringEvent('❌ LOAD ERROR', 'Failed to load saved data: $e');
    }
  }

  /// Clean up old save files to prevent storage bloat
  Future<void> _cleanupOldSaveFiles(Directory monitoringDir) async {
    try {
      final files = monitoringDir.listSync()
          .whereType<File>()
          .where((file) => file.path.contains('monitoring_data_'))
          .toList();
      
      if (files.length > 10) {
        files.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));
        
        for (int i = 10; i < files.length; i++) {
          await files[i].delete();
        }
        
        _logMonitoringEvent('🧹 CLEANUP', 'Removed ${files.length - 10} old save files');
      }
    } catch (e) {
      _logMonitoringEvent('❌ CLEANUP ERROR', 'Failed to cleanup old files: $e');
    }
  }

  /// Record an overflow event
  void recordOverflow({
    required String widgetName,
    required String content,
    required String overflowType,
    required String resolution,
    Map<String, dynamic>? additionalData,
  }) {
    final event = OverflowEvent(
      timestamp: DateTime.now(),
      widgetName: widgetName,
      content: content,
      overflowType: overflowType,
      resolution: resolution,
      additionalData: additionalData ?? {},
    );
    
    _overflowEvents.add(event);
    _overflowController.add(event);
    
    _logMonitoringEvent('⚠️ OVERFLOW DETECTED', 
      'Widget: $widgetName | Type: $overflowType | Content: ${content.length} chars | Resolution: $resolution');
  }

  /// Check for DJ changes
  void _checkDJChanges() async {
    try {
      // Check current DJ
      final currentDJ = DJService.getCurrentDJ();
      final currentDJName = currentDJ?.name ?? 'Auto DJ';
      
      // Check next DJ
      final nextDJInfo = DJService.getNextDJ();
      final nextDJName = nextDJInfo['name'] ?? 'Auto DJ';
      final nextDJTime = nextDJInfo['startTime'] ?? '';
      
      // Detect changes
      bool currentDJChanged = currentDJName != _lastCurrentDJ;
      bool nextDJChanged = nextDJName != _lastNextDJ;
      
      if (currentDJChanged || nextDJChanged) {
        final event = DJChangeEvent(
          timestamp: DateTime.now(),
          previousCurrentDJ: _lastCurrentDJ,
          newCurrentDJ: currentDJName,
          previousNextDJ: _lastNextDJ,
          newNextDJ: nextDJName,
          nextDJTime: nextDJTime,
          isCrossover: _isCrossoverTime(),
          timeSinceLastChange: DateTime.now().difference(_lastDJChange),
        );
        
        _djChangeEvents.add(event);
        _djChangeController.add(event);
        
        _logMonitoringEvent('🎧 DJ CHANGE DETECTED', 
          'Current: $_lastCurrentDJ → $currentDJName | Next: $_lastNextDJ → $nextDJName | Crossover: ${event.isCrossover}');
        
        // Update last values
        _lastCurrentDJ = currentDJName;
        _lastNextDJ = nextDJName;
        _lastDJChange = DateTime.now();
      }
    } catch (e) {
      _logMonitoringEvent('❌ DJ CHECK ERROR', 'Error checking DJ changes: $e');
    }
  }

  /// Check for metadata changes
  void _checkMetadataChanges() async {
    try {
      final metadataService = MetadataService();
      final trackInfo = await metadataService.getTrackInfoWithCache();
      
      if (trackInfo != null) {
        final event = MetadataEvent(
          timestamp: DateTime.now(),
          artist: trackInfo.artist,
          title: trackInfo.title,
          listeners: trackInfo.listeners,
          bitrate: trackInfo.bitrate,
          lastUpdated: trackInfo.lastUpdated,
          isNewTrack: _isNewTrack(trackInfo),
        );
        
        _metadataEvents.add(event);
        _metadataController.add(event);
        
        if (event.isNewTrack) {
          _logMonitoringEvent('🎵 NEW TRACK DETECTED', 
            'Artist: ${trackInfo.artist} | Title: ${trackInfo.title} | Listeners: ${trackInfo.listeners}');
        }
        
        _lastTrackInfo = {
          'artist': trackInfo.artist,
          'title': trackInfo.title,
          'listeners': trackInfo.listeners,
          'bitrate': trackInfo.bitrate,
        };
      }
    } catch (e) {
      _logMonitoringEvent('❌ METADATA CHECK ERROR', 'Error checking metadata: $e');
    }
  }

  /// Check if this is a crossover time (within 5 minutes of DJ change)
  bool _isCrossoverTime() {
    final now = DateTime.now();
    final currentDJ = DJService.getCurrentDJ();
    
    if (currentDJ == null) return false;
    
    // Check if we're near the end of current DJ's slot
    for (final schedule in currentDJ.schedule) {
      final endTime = _parseTime(schedule.end);
      final currentTime = now.hour * 60 + now.minute;
      final timeUntilEnd = endTime - currentTime;
      
      // Consider it crossover if within 5 minutes of end
      if (timeUntilEnd >= 0 && timeUntilEnd <= 5) {
        return true;
      }
    }
    
    return false;
  }

  /// Check if this is a new track
  bool _isNewTrack(TrackInfo trackInfo) {
    if (_lastTrackInfo == null) return true;
    
    return _lastTrackInfo!['artist'] != trackInfo.artist || 
           _lastTrackInfo!['title'] != trackInfo.title;
  }

  /// Parse time string to minutes
  int _parseTime(String time) {
    final parts = time.split(':');
    if (parts.length == 2) {
      final hours = int.tryParse(parts[0]) ?? 0;
      final minutes = int.tryParse(parts[1]) ?? 0;
      return hours * 60 + minutes;
    }
    return 0;
  }

  /// Log monitoring event
  void _logMonitoringEvent(String type, String message) {
    final timestamp = DateTime.now().toIso8601String();
    final logMessage = '[$timestamp] $type: $message';
    
    // Log to console
    print(logMessage);
    
    // Log to developer console
    developer.log(logMessage, name: 'TraxRadio_Monitoring');
  }

  /// Get monitoring summary
  Map<String, dynamic> getMonitoringSummary() {
    return {
      'isMonitoring': _isMonitoring,
      'overflowEvents': _overflowEvents.length,
      'djChangeEvents': _djChangeEvents.length,
      'metadataEvents': _metadataEvents.length,
      'lastDJChange': _lastDJChange.toIso8601String(),
      'currentDJ': _lastCurrentDJ,
      'nextDJ': _lastNextDJ,
    };
  }

  /// Clear all monitoring data
  void clearMonitoringData() {
    _overflowEvents.clear();
    _djChangeEvents.clear();
    _metadataEvents.clear();
    _logMonitoringEvent('🧹 MONITORING DATA CLEARED', 'All monitoring data has been cleared');
  }

  /// Dispose resources
  void dispose() {
    stopMonitoring();
    _overflowController.close();
    _djChangeController.close();
    _metadataController.close();
  }
}

/// Overflow event data class
class OverflowEvent {
  final DateTime timestamp;
  final String widgetName;
  final String content;
  final String overflowType;
  final String resolution;
  final Map<String, dynamic> additionalData;

  OverflowEvent({
    required this.timestamp,
    required this.widgetName,
    required this.content,
    required this.overflowType,
    required this.resolution,
    required this.additionalData,
  });

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'widgetName': widgetName,
      'content': content,
      'overflowType': overflowType,
      'resolution': resolution,
      'additionalData': additionalData,
    };
  }

  factory OverflowEvent.fromJson(Map<String, dynamic> json) {
    return OverflowEvent(
      timestamp: DateTime.parse(json['timestamp']),
      widgetName: json['widgetName'],
      content: json['content'],
      overflowType: json['overflowType'],
      resolution: json['resolution'],
      additionalData: json['additionalData'] ?? {},
    );
  }
}

/// DJ change event data class
class DJChangeEvent {
  final DateTime timestamp;
  final String previousCurrentDJ;
  final String newCurrentDJ;
  final String previousNextDJ;
  final String newNextDJ;
  final String nextDJTime;
  final bool isCrossover;
  final Duration timeSinceLastChange;

  DJChangeEvent({
    required this.timestamp,
    required this.previousCurrentDJ,
    required this.newCurrentDJ,
    required this.previousNextDJ,
    required this.newNextDJ,
    required this.nextDJTime,
    required this.isCrossover,
    required this.timeSinceLastChange,
  });

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'previousCurrentDJ': previousCurrentDJ,
      'newCurrentDJ': newCurrentDJ,
      'previousNextDJ': previousNextDJ,
      'newNextDJ': newNextDJ,
      'nextDJTime': nextDJTime,
      'isCrossover': isCrossover,
      'timeSinceLastChangeSeconds': timeSinceLastChange.inSeconds,
    };
  }

  factory DJChangeEvent.fromJson(Map<String, dynamic> json) {
    return DJChangeEvent(
      timestamp: DateTime.parse(json['timestamp']),
      previousCurrentDJ: json['previousCurrentDJ'],
      newCurrentDJ: json['newCurrentDJ'],
      previousNextDJ: json['previousNextDJ'],
      newNextDJ: json['newNextDJ'],
      nextDJTime: json['nextDJTime'],
      isCrossover: json['isCrossover'],
      timeSinceLastChange: Duration(seconds: json['timeSinceLastChangeSeconds']),
    );
  }
}

/// Metadata event data class
class MetadataEvent {
  final DateTime timestamp;
  final String artist;
  final String title;
  final int listeners;
  final int bitrate;
  final DateTime? lastUpdated;
  final bool isNewTrack;

  MetadataEvent({
    required this.timestamp,
    required this.artist,
    required this.title,
    required this.listeners,
    required this.bitrate,
    this.lastUpdated,
    required this.isNewTrack,
  });

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'artist': artist,
      'title': title,
      'listeners': listeners,
      'bitrate': bitrate,
      'lastUpdated': lastUpdated?.toIso8601String(),
      'isNewTrack': isNewTrack,
    };
  }

  factory MetadataEvent.fromJson(Map<String, dynamic> json) {
    return MetadataEvent(
      timestamp: DateTime.parse(json['timestamp']),
      artist: json['artist'],
      title: json['title'],
      listeners: json['listeners'],
      bitrate: json['bitrate'],
      lastUpdated: json['lastUpdated'] != null ? DateTime.parse(json['lastUpdated']) : null,
      isNewTrack: json['isNewTrack'],
    );
  }
} 