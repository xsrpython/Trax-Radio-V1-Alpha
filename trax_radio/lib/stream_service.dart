import 'dart:convert';
import 'package:http/http.dart' as http;
import 'performance_optimizer.dart';

class StreamConfig {
  final String streamUrl;
  final String fallbackStreamUrl;
  final String metadataUrl;
  final String streamFormat;
  final int bitrate;
  final String status;
  final String lastUpdated;
  final String version;

  StreamConfig({
    required this.streamUrl,
    required this.fallbackStreamUrl,
    required this.metadataUrl,
    required this.streamFormat,
    required this.bitrate,
    required this.status,
    required this.lastUpdated,
    required this.version,
  });

  factory StreamConfig.fromJson(Map<String, dynamic> json) {
    return StreamConfig(
      streamUrl: json['stream_url'] ?? '',
      fallbackStreamUrl: json['fallback_stream_url'] ?? '',
      metadataUrl: json['metadata_url'] ?? '',
      streamFormat: json['stream_format'] ?? 'mp3',
      bitrate: json['bitrate'] ?? 128,
      status: json['status'] ?? 'unknown',
      lastUpdated: json['last_updated'] ?? '',
      version: json['version'] ?? '1.0.0',
    );
  }
}

class StreamService {
  static final StreamService _instance = StreamService._internal();
  factory StreamService() => _instance;
  StreamService._internal();

  static const String _configApiUrl = 'https://xsrpython.github.io/trax-radio-website/stream-config.json';
  static const Duration _cacheTimeout = Duration(hours: 1);
  
  StreamConfig? _cachedConfig;
  DateTime? _lastFetch;
  
  // Fallback configuration if API fails
  static StreamConfig get _fallbackConfig => StreamConfig(
    streamUrl: 'https://cast3.asurahosting.com/proxy/traxradi/stream',
    fallbackStreamUrl: 'http://cast3.asurahosting.com/proxy/traxradi/stream',
    metadataUrl: 'https://cast3.asurahosting.com/proxy/traxradi/status-json.xsl',
    streamFormat: 'mp3',
    bitrate: 128,
    status: 'active',
    lastUpdated: '2025-10-14T15:30:00Z',
    version: '1.0.3',
  );

  /// Get the current stream configuration
  /// Returns cached config if available and not expired
  /// Otherwise fetches from API or returns fallback
  Future<StreamConfig> getStreamConfig() async {
    // Check if we have cached config that's still valid
    if (_cachedConfig != null && _lastFetch != null) {
      final timeSinceFetch = DateTime.now().difference(_lastFetch!);
      if (timeSinceFetch < _cacheTimeout) {
        return _cachedConfig!;
      }
    }

    try {
      // Fetch fresh config from API
      final response = await http.get(
        Uri.parse(_configApiUrl),
        headers: {
          'Accept': 'application/json',
          'User-Agent': 'TraxRadio/1.0',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _cachedConfig = StreamConfig.fromJson(data);
        _lastFetch = DateTime.now();
        return _cachedConfig!;
      }
    } catch (e) {
      // API fetch failed, use cached config if available
      if (_cachedConfig != null) {
        return _cachedConfig!;
      }
    }

    // Return fallback config if everything fails
    return _fallbackConfig;
  }

  /// Force refresh the stream configuration from API
  Future<StreamConfig> refreshStreamConfig() async {
    _cachedConfig = null;
    _lastFetch = null;
    return await getStreamConfig();
  }

  /// Get primary stream URL
  Future<String> getPrimaryStreamUrl() async {
    final config = await getStreamConfig();
    return config.streamUrl;
  }

  /// Get fallback stream URL
  Future<String> getFallbackStreamUrl() async {
    final config = await getStreamConfig();
    return config.fallbackStreamUrl;
  }

  /// Get metadata URL
  Future<String> getMetadataUrl() async {
    final config = await getStreamConfig();
    return config.metadataUrl;
  }

  /// Get all stream URLs as a list for fallback handling
  Future<List<String>> getStreamUrls() async {
    final config = await getStreamConfig();
    return [config.streamUrl, config.fallbackStreamUrl];
  }
}
