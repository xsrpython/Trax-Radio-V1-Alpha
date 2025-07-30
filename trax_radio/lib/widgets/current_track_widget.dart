import 'package:flutter/material.dart';
import 'dart:async';
import '../metadata_service.dart';
import '../dj_service.dart';
import '../monitoring_service.dart';

class CurrentTrackWidget extends StatefulWidget {
  const CurrentTrackWidget({Key? key}) : super(key: key);

  @override
  State<CurrentTrackWidget> createState() => _CurrentTrackWidgetState();
}

class _CurrentTrackWidgetState extends State<CurrentTrackWidget> {
  final MetadataService _metadataService = MetadataService();
  final MonitoringService _monitoringService = MonitoringService();
  TrackInfo? _currentTrack;
  String _currentDJ = 'Loading...';
  bool _isLoading = false;
  Timer? _updateTimer;

  @override
  void initState() {
    super.initState();
    _loadTrackInfo();
    _startPeriodicUpdates();
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }

  void _startPeriodicUpdates() {
    _updateTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
              if (mounted) {
          _loadTrackInfo();
        }
    });
  }

  Future<void> _loadTrackInfo() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final trackInfo = await _metadataService.getTrackInfoWithCache();
      if (mounted) {
        setState(() {
          _currentTrack = trackInfo;
          _isLoading = false;
        });
        
        // Check for overflow and record it
        if (trackInfo != null) {
          _checkAndRecordOverflow(trackInfo);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      print('Error loading track info: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.orange.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (_isLoading)
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                  ),
                ),
              if (_isLoading) const SizedBox(width: 8),
            ],
          ),
          const SizedBox(height: 8),
          if (_currentTrack != null) ...[
            _buildTrackInfo(),
          ] else if (_isLoading) ...[
            _buildLoadingPlaceholder(),
          ] else ...[
            _buildErrorState(),
          ],
        ],
      ),
    );
  }

  Widget _buildTrackInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Single line: NOW PLAYING Artist - Title
        Row(
          children: [
            Text(
              'NOW PLAYING ',
              style: TextStyle(
                color: Colors.orange,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            Expanded(
              child: Text(
                '${_currentTrack!.artist} - ${_currentTrack!.title}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        // Single line: Listeners and Bitrate
        Row(
          children: [
            Icon(
              Icons.headphones,
              color: Colors.orange.withOpacity(0.7),
              size: 14,
            ),
            const SizedBox(width: 4),
            Text(
              '${_currentTrack!.listeners} listeners',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
            const SizedBox(width: 16),
            Icon(
              Icons.speed,
              color: Colors.orange.withOpacity(0.7),
              size: 14,
            ),
            const SizedBox(width: 4),
            Text(
              '${_currentTrack!.bitrate} kbps',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
            const Spacer(),
            if (_currentTrack!.lastUpdated != null)
              Text(
                'Updated: ${_formatTime(_currentTrack!.lastUpdated)}',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 10,
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildStreamInfo() {
    // This method is no longer needed as stream info is now in _buildTrackInfo
    return const SizedBox.shrink();
  }

  Widget _buildLoadingPlaceholder() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 18,
          width: 150,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 16,
          width: 200,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Unable to load track info',
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: _loadTrackInfo,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          child: const Text('Retry'),
        ),
      ],
    );
  }

  void _checkAndRecordOverflow(TrackInfo trackInfo) {
    final artistTitleText = '${trackInfo.artist} - ${trackInfo.title}';
    const maxRecommendedLength = 50; // Approximate max chars that fit well
    
    if (artistTitleText.length > maxRecommendedLength) {
      _monitoringService.recordOverflow(
        widgetName: 'CurrentTrackWidget',
        content: artistTitleText,
        overflowType: 'artist_title_length',
        resolution: 'ellipsis',
        additionalData: {
          'artistLength': trackInfo.artist.length,
          'titleLength': trackInfo.title.length,
          'totalLength': artistTitleText.length,
          'maxRecommendedLength': maxRecommendedLength,
          'listeners': trackInfo.listeners,
          'bitrate': trackInfo.bitrate,
        },
      );
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else {
      return '${difference.inHours}h ago';
    }
  }
} 