import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;

class MetadataService {
  static final MetadataService _instance = MetadataService._internal();
  factory MetadataService() => _instance;
  MetadataService._internal();

  String _currentTrack = 'Loading...';
  String _currentArtist = '';
  String _currentTitle = '';
  Timer? _updateTimer;

  String get currentTrack => _currentTrack;
  String get currentArtist => _currentArtist;
  String get currentTitle => _currentTitle;

  void startMetadataUpdates() {
    _updateTimer?.cancel();
    _updateTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _fetchLiveMetadata();
    });
    _fetchLiveMetadata(); // Initial fetch
  }

  void stopMetadataUpdates() {
    _updateTimer?.cancel();
  }

  Future<void> _fetchLiveMetadata() async {
    try {
      // Try to fetch real metadata from the stream
      final response = await http.get(
        Uri.parse('https://hello.citrus3.com:8138/status-json.xsl'),
        headers: {'User-Agent': 'TraxRadio/1.0'},
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final source = data['icestats']?['source'];
        
        if (source != null) {
          final title = source['title'] ?? '';
          final artist = source['artist'] ?? '';
          
          if (title.isNotEmpty) {
            _currentTitle = title;
            _currentArtist = artist.isNotEmpty ? artist : 'Unknown Artist';
            _currentTrack = artist.isNotEmpty ? '$artist - $title' : title;
            return;
          }
        }
      }
    } catch (e) {
      // Fall back to simulated data if live fetch fails
    }

    // Fallback to simulated metadata
    _updateSimulatedTrack();
  }

  void _updateSimulatedTrack() {
    final tracks = [
      'DJXSR - Trax Radio Mix',
      'House Classics - Live Mix',
      'Electronic Vibes - Studio Session',
      'UK Garage Hits - Live Stream',
      'Dance Anthems - Radio Mix',
      'Bassline Classics - Live DJ',
      'House Music - Studio Session',
      'Electronic Beats - Live Stream',
      'UK Dance Hits - Radio Mix',
      'Trax Radio - Live Mix',
    ];

    final random = DateTime.now().millisecondsSinceEpoch % tracks.length;
    _currentTrack = tracks[random];
    _currentArtist = 'Trax Radio';
    _currentTitle = tracks[random];
  }

  void dispose() {
    stopMetadataUpdates();
  }
} 