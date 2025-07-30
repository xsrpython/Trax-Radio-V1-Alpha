import 'package:http/http.dart' as http;
import 'dart:convert';

class TrackInfo {
  final String artist;
  final String title;
  final String genre;
  final int listeners;
  final int peakListeners;
  final int bitrate;
  final String currentlyPlaying;
  final DateTime lastUpdated;

  TrackInfo({
    required this.artist,
    required this.title,
    required this.genre,
    required this.listeners,
    required this.peakListeners,
    required this.bitrate,
    required this.currentlyPlaying,
    required this.lastUpdated,
  });

  factory TrackInfo.fromJson(Map<String, dynamic> json) {
    final source = json['icestats']['source'];
    return TrackInfo(
      artist: source['artist'] ?? 'Unknown Artist',
      title: source['title'] ?? 'Unknown Title',
      genre: source['genre'] ?? 'Unknown Genre',
      listeners: source['listeners'] ?? 0,
      peakListeners: source['listener_peak'] ?? 0,
      bitrate: source['bitrate'] ?? 0,
      currentlyPlaying: source['yp_currently_playing'] ?? 'Unknown Track',
      lastUpdated: DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'TrackInfo(artist: $artist, title: $title, listeners: $listeners)';
  }
}

class MetadataService {
  static const String _metadataUrl = 'https://hello.citrus3.com:8138/status-json.xsl';
  static const Duration _updateInterval = Duration(seconds: 30);
  
  static final MetadataService _instance = MetadataService._internal();
  factory MetadataService() => _instance;
  MetadataService._internal();

  TrackInfo? _currentTrack;
  DateTime? _lastFetch;
  bool _isFetching = false;

  TrackInfo? get currentTrack => _currentTrack;
  DateTime? get lastFetch => _lastFetch;
  bool get isFetching => _isFetching;

  /// Fetch current track information from Trax Radio UK
  Future<TrackInfo?> getCurrentTrack() async {
    if (_isFetching) {
      return _currentTrack;
    }

    _isFetching = true;
    
    try {
      final response = await http.get(
        Uri.parse(_metadataUrl),
        headers: {
          'User-Agent': 'TraxRadio/1.0.0',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _currentTrack = TrackInfo.fromJson(data);
        _lastFetch = DateTime.now();
        
              print('Metadata fetched: ${_currentTrack!.artist} - ${_currentTrack!.title}');
      print('Listeners: ${_currentTrack!.listeners}, Bitrate: ${_currentTrack!.bitrate}');
      return _currentTrack;
      } else {
              print('Failed to fetch metadata: HTTP ${response.statusCode}');
      print('Response body: ${response.body}');
      return _currentTrack; // Return last known track
      }
    } catch (e) {
      print('Error fetching metadata: $e');
      return _currentTrack; // Return last known track
    } finally {
      _isFetching = false;
    }
  }

  /// Get track info with caching (returns cached data if recent)
  Future<TrackInfo?> getTrackInfoWithCache() async {
    if (_currentTrack != null && _lastFetch != null) {
      final timeSinceLastFetch = DateTime.now().difference(_lastFetch!);
      if (timeSinceLastFetch < _updateInterval) {
        return _currentTrack;
      }
    }
    
    return await getCurrentTrack();
  }

  /// Check if metadata is stale (older than update interval)
  bool get isMetadataStale {
    if (_lastFetch == null) return true;
    return DateTime.now().difference(_lastFetch!) > _updateInterval;
  }

  /// Get formatted current track string
  String get formattedCurrentTrack {
    if (_currentTrack == null) return 'Loading track info...';
    return '${_currentTrack!.artist} - ${_currentTrack!.title}';
  }

  /// Get formatted listener count
  String get formattedListenerCount {
    if (_currentTrack == null) return '0';
    return '${_currentTrack!.listeners}';
  }

  /// Get formatted bitrate
  String get formattedBitrate {
    if (_currentTrack == null) return '0';
    return '${_currentTrack!.bitrate} kbps';
  }

  /// Clear cached data
  void clearCache() {
    _currentTrack = null;
    _lastFetch = null;
  }

  /// Test connection to metadata endpoint
  Future<bool> testConnection() async {
    try {
      final response = await http.get(
        Uri.parse(_metadataUrl),
        headers: {
          'User-Agent': 'TraxRadio/1.0.0',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      print('Connection test failed: $e');
      return false;
    }
  }
} 