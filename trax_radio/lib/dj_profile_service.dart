import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'performance_optimizer.dart';
import 'dj_service.dart';

/// DJ Profile data model
class DJProfile {
  final String name;
  final String bio;
  final String picture;
  final String status; // 'live', 'auto', 'offline'
  final List<String> socialMedia;
  final DateTime lastUpdated;

  DJProfile({
    required this.name,
    required this.bio,
    required this.picture,
    required this.status,
    required this.socialMedia,
    required this.lastUpdated,
  });

  factory DJProfile.fromJson(Map<String, dynamic> json) {
    return DJProfile(
      name: json['name'] ?? 'Unknown DJ',
      bio: json['bio'] ?? 'Professional DJ at Trax Radio UK',
      picture: json['picture'] ?? '',
      status: json['status'] ?? 'auto',
      socialMedia: (json['social_media'] as List?)?.cast<String>() ?? [],
      lastUpdated: DateTime.tryParse(json['last_updated'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'bio': bio,
      'picture': picture,
      'status': status,
      'social_media': socialMedia,
      'last_updated': lastUpdated.toIso8601String(),
    };
  }
}

/// Service for managing DJ profiles with smart Auto DJ vs Live DJ detection
class DJProfileService {
  static final DJProfileService _instance = DJProfileService._internal();
  factory DJProfileService() => _instance;
  DJProfileService._internal();

  // API endpoints
  static const String _wordpressApiUrl = 'https://trax-radio-uk.com/wp-json/wp/v2/dj_profiles';
  static const String _fallbackApiUrl = 'https://xsrpython.github.io/trax-radio-website/api/dj-profiles.json';
  
  // Cache management
  static const String _cacheKey = 'dj_profiles_cache';
  static const Duration _cacheTimeout = Duration(minutes: 15);
  
  DJProfile? _currentDJProfile;
  DateTime? _lastFetch;
  Timer? _updateTimer;

  /// Initialize the DJ profile service
  Future<void> initialize() async {
    // Start periodic updates
    _updateTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => _updateCurrentDJProfile(),
    );
    
    // Initial fetch
    await _updateCurrentDJProfile();
  }

  /// Get current DJ profile with smart detection
  Future<DJProfile> getCurrentDJProfile() async {
    // Return cached profile if available and not expired
    if (_currentDJProfile != null && _lastFetch != null &&
        DateTime.now().difference(_lastFetch!) < _cacheTimeout) {
      return _currentDJProfile!;
    }

    // Fetch fresh data
    await _updateCurrentDJProfile();
    return _currentDJProfile ?? _getDefaultAutoDJProfile();
  }

  /// Update current DJ profile with smart detection
  Future<void> _updateCurrentDJProfile() async {
    try {
      // Try to detect if there's a live DJ based on current time and schedule
      final currentTime = DateTime.now();
      final isLiveDJTime = _isLiveDJTime(currentTime);
      
      if (isLiveDJTime) {
        // Try to fetch live DJ profile
        final liveDJ = await _fetchLiveDJProfile();
        if (liveDJ != null) {
          _currentDJProfile = liveDJ;
          _lastFetch = DateTime.now();
          await _cacheProfile(liveDJ);
          return;
        }
      }
      
      // Fall back to Auto DJ profile
      _currentDJProfile = await _fetchAutoDJProfile();
      _lastFetch = DateTime.now();
      await _cacheProfile(_currentDJProfile!);
      
    } catch (e) {
      // Use cached profile if available, otherwise default Auto DJ
      _currentDJProfile = await _getCachedProfile() ?? _getDefaultAutoDJProfile();
    }
  }

  /// Check if current time falls within live DJ schedule
  bool _isLiveDJTime(DateTime currentTime) {
    // Integrate with the existing DJ service to check if there's a live DJ
    try {
      // Get current DJ from the existing DJ service
      final currentDJ = DJService.getCurrentDJ();
      
      // If there's a current DJ (not Auto DJ), it means there's a live DJ scheduled
      if (currentDJ != null && currentDJ.name.toLowerCase() != 'auto dj') {
        return true;
      }
      
      // Check if there's a DJ scheduled for the current time
      final currentTimeStr = '${currentTime.hour.toString().padLeft(2, '0')}:${currentTime.minute.toString().padLeft(2, '0')}';
      final dayName = _getDayName(currentTime.weekday);
      
      // Check if any DJ has a schedule for current day and time
      final djs = DJService.getAllDJs();
      for (final dj in djs) {
        for (final schedule in dj.schedule) {
          if (schedule.day.toLowerCase() == dayName.toLowerCase()) {
            // Check if current time falls within DJ's schedule
            if (_isTimeInRange(currentTimeStr, schedule.start, schedule.end)) {
              return true;
            }
          }
        }
      }
      
    } catch (e) {
      // Fallback to simple time-based detection if DJ service fails
      return _fallbackLiveDJDetection(currentTime);
    }
    
    return false;
  }

  /// Fallback live DJ detection based on typical schedule
  bool _fallbackLiveDJDetection(DateTime currentTime) {
    final hour = currentTime.hour;
    final dayOfWeek = currentTime.weekday;
    
    // Example: Live DJs typically on weekdays 18:00-23:00
    if (dayOfWeek >= 1 && dayOfWeek <= 5) { // Monday to Friday
      return hour >= 18 && hour <= 23;
    }
    
    // Weekend: Live DJs 14:00-22:00
    if (dayOfWeek >= 6 && dayOfWeek <= 7) { // Saturday and Sunday
      return hour >= 14 && hour <= 22;
    }
    
    return false;
  }

  /// Get day name from weekday number
  String _getDayName(int weekday) {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[weekday - 1];
  }

  /// Check if current time is within a DJ's schedule range
  bool _isTimeInRange(String currentTime, String startTime, String endTime) {
    try {
      final current = _parseTime(currentTime);
      final start = _parseTime(startTime);
      final end = _parseTime(endTime);
      
      if (start <= end) {
        // Same day schedule
        return current >= start && current <= end;
      } else {
        // Overnight schedule (e.g., 23:00-01:00)
        return current >= start || current <= end;
      }
    } catch (e) {
      return false;
    }
  }

  /// Parse time string (HH:MM) to minutes since midnight
  int _parseTime(String timeStr) {
    final parts = timeStr.split(':');
    final hours = int.parse(parts[0]);
    final minutes = int.parse(parts[1]);
    return hours * 60 + minutes;
  }

  /// Fetch live DJ profile from WordPress API
  Future<DJProfile?> _fetchLiveDJProfile() async {
    try {
      final response = await NetworkOptimizer.optimizedRequest(
        _wordpressApiUrl,
        () => http.get(
          Uri.parse(_wordpressApiUrl),
          headers: {'User-Agent': 'TraxRadio/1.0'},
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List && data.isNotEmpty) {
          // Find the DJ who should be live right now
          for (var djData in data) {
            final profile = DJProfile.fromJson(djData);
            if (profile.status == 'live') {
              return profile;
            }
          }
        }
      }
    } catch (e) {
      // Fall back to alternative method
    }
    
    return null;
  }

  /// Fetch Auto DJ profile from fallback API
  Future<DJProfile> _fetchAutoDJProfile() async {
    try {
      final response = await NetworkOptimizer.optimizedRequest(
        _fallbackApiUrl,
        () => http.get(
          Uri.parse(_fallbackApiUrl),
          headers: {'User-Agent': 'TraxRadio/1.0'},
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return DJProfile.fromJson(data['auto_dj'] ?? data);
      }
    } catch (e) {
      // Use cached or default
    }
    
    return await _getCachedProfile() ?? _getDefaultAutoDJProfile();
  }

  /// Get default Auto DJ profile (only image stored internally)
  DJProfile _getDefaultAutoDJProfile() {
    return DJProfile(
      name: 'Auto DJ',
      bio: 'Trax Radio UK\'s automated music system, playing the best electronic and dance music 24/7. Curated playlists ensure continuous high-quality entertainment.',
      picture: 'assets/images/auto_dj_logo.png', // Your new Auto DJ logo
      status: 'auto',
      socialMedia: [],
      lastUpdated: DateTime.now(),
    );
  }

  /// Cache DJ profile locally
  Future<void> _cacheProfile(DJProfile profile) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cacheKey, json.encode(profile.toJson()));
    } catch (e) {
      // Cache failed, continue without caching
    }
  }

  /// Get cached DJ profile
  Future<DJProfile?> _getCachedProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedJson = prefs.getString(_cacheKey);
      if (cachedJson != null) {
        final data = json.decode(cachedJson);
        return DJProfile.fromJson(data);
      }
    } catch (e) {
      // Cache read failed
    }
    return null;
  }

  /// Force refresh DJ profile
  Future<void> refreshProfile() async {
    _currentDJProfile = null;
    _lastFetch = null;
    await _updateCurrentDJProfile();
  }

  /// Check if current DJ is live
  bool get isLiveDJ => _currentDJProfile?.status == 'live';
  
  /// Check if current DJ is Auto DJ
  bool get isAutoDJ => _currentDJProfile?.status == 'auto';

  /// Get current DJ name
  String get currentDJName => _currentDJProfile?.name ?? 'Auto DJ';

  /// Dispose resources
  void dispose() {
    _updateTimer?.cancel();
  }
}

/// Widget for displaying DJ profile information
class DJProfileWidget extends StatefulWidget {
  final bool showPicture;
  final bool showBio;
  final bool showSocialMedia;

  const DJProfileWidget({
    super.key,
    this.showPicture = true,
    this.showBio = true,
    this.showSocialMedia = false,
  });

  @override
  State<DJProfileWidget> createState() => _DJProfileWidgetState();
}

class _DJProfileWidgetState extends State<DJProfileWidget> {
  final DJProfileService _djProfileService = DJProfileService();
  DJProfile? _currentProfile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await _djProfileService.getCurrentDJProfile();
      if (mounted) {
        setState(() {
          _currentProfile = profile;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.orange, strokeWidth: 2),
      );
    }

    if (_currentProfile == null) {
      return const SizedBox.shrink(); // Hide if no profile data
    }

    // If only showing picture, make it expanded and centered
    if (widget.showPicture && !widget.showBio) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              children: [
                ClipOval(
                  child: Container(
                    width: 120,
                    height: 120,
                    color: _currentProfile!.status == 'auto' 
                        ? Colors.blue 
                        : Colors.orange,
                    child: _currentProfile!.picture.isNotEmpty
                        ? _currentProfile!.picture.startsWith('assets/')
                            ? Image.asset(
                                _currentProfile!.picture,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  print('Failed to load Auto DJ image: $error');
                                  return Icon(
                                    _currentProfile!.status == 'auto' 
                                        ? Icons.music_note 
                                        : Icons.person,
                                    size: 48,
                                    color: Colors.white,
                                  );
                                },
                              )
                            : _currentProfile!.picture.startsWith('data:')
                                ? Image.memory(
                                    base64Decode(_currentProfile!.picture.split(',')[1]),
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      print('Failed to load Auto DJ image from data URI: $error');
                                      return Icon(
                                        _currentProfile!.status == 'auto' 
                                            ? Icons.music_note 
                                            : Icons.person,
                                        size: 48,
                                        color: Colors.white,
                                      );
                                    },
                                  )
                                : Image.network(
                                    _currentProfile!.picture,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      print('Failed to load Auto DJ image from network: $error');
                                      return Icon(
                                        _currentProfile!.status == 'auto' 
                                            ? Icons.music_note 
                                            : Icons.person,
                                        size: 48,
                                        color: Colors.white,
                                      );
                                    },
                                  )
                        : Icon(
                            _currentProfile!.status == 'auto' 
                                ? Icons.music_note 
                                : Icons.person,
                            size: 48,
                            color: Colors.white,
                          ),
                  ),
                ),
                // Live/Auto indicator
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: _currentProfile!.status == 'live' 
                          ? Colors.green 
                          : Colors.orange,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black, width: 2),
                    ),
                    child: Center(
                      child: Text(
                        _currentProfile!.status == 'live' ? 'LIVE' : 'AUTO',
                        style: const TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              _currentProfile!.name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _currentProfile!.status == 'auto' 
                  ? 'Automated Music System'
                  : 'Live DJ Session',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    // Full profile view (if bio is enabled)
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          if (widget.showPicture) ...[
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.orange,
              backgroundImage: _currentProfile!.picture.isNotEmpty
                  ? _currentProfile!.picture.startsWith('data:')
                      ? MemoryImage(base64Decode(_currentProfile!.picture.split(',')[1])) as ImageProvider
                      : NetworkImage(_currentProfile!.picture)
                  : null,
              child: _currentProfile!.picture.isEmpty
                  ? Text(
                      _currentProfile!.name.substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 16),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      _currentProfile!.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _currentProfile!.status == 'live' 
                            ? Colors.green 
                            : Colors.orange,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        _currentProfile!.status == 'live' ? 'LIVE' : 'AUTO',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                if (widget.showBio) ...[
                  const SizedBox(height: 4),
                  Text(
                    _currentProfile!.bio,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _djProfileService.dispose();
    super.dispose();
  }
}
