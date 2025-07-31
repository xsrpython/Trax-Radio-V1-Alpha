import 'dart:async';
import 'package:flutter/material.dart';
import '../dj_service.dart';
import '../monitoring_service.dart';

class NextDJWidget extends StatefulWidget {
  const NextDJWidget({super.key});

  @override
  State<NextDJWidget> createState() => _NextDJWidgetState();
}

class _NextDJWidgetState extends State<NextDJWidget> {
  String _nextDJ = '';
  String _nextStartTime = '';
  bool _isLoading = true;
  Timer? _timer;
  final MonitoringService _monitoringService = MonitoringService();

  @override
  void initState() {
    super.initState();
    _updateNextDJ();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (mounted) {
        _updateNextDJ();
      }
    });
  }

  void _updateNextDJ() {
    final nextDJInfo = DJService.getNextDJ();
    final newName = nextDJInfo['name'] ?? '';
    final newStartTime = nextDJInfo['startTime'] ?? '';

    if (mounted && (newName != _nextDJ || newStartTime != _nextStartTime || _isLoading)) {
      setState(() {
        _nextDJ = newName;
        _nextStartTime = newStartTime;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Transform.scale(
        scale: 1.0,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.7),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.orange.withOpacity(0.5),
              width: 4,
            ),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                ),
              ),
              SizedBox(width: 8),
              Text(
                'Loading DJ Schedule...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    String displayText = _nextDJ;
    String timeText = '';

    if (_nextDJ.isEmpty || _nextDJ == 'No upcoming DJs') {
      displayText = 'Auto DJ';
      timeText = 'Now';
    } else if (_nextStartTime.isNotEmpty) {
      timeText = 'at $_nextStartTime';
    } else {
      timeText = 'Coming Soon';
    }

    // Check for overflow and record it
    _checkAndRecordOverflow(displayText, timeText);

    return Transform.scale(
      scale: 1.0,
      child: Container(
        width: double.infinity, // Fill available width
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.orange.withOpacity(0.5),
            width: 4,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.schedule,
              color: Colors.orange,
              size: 16,
            ),
            const SizedBox(width: 8),
            const Text(
              'Next: ',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
              ),
            ),
            Flexible(
              child: Tooltip(
                message: displayText,
                child: Text(
                  displayText,
                  style: const TextStyle(
                    color: Colors.orange,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ),
            if (timeText.isNotEmpty) ...[
              const SizedBox(width: 10),
              Flexible(
                child: Tooltip(
                  message: '$timeText (UK Time)',
                  child: Text(
                    '$timeText (UK)',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _checkAndRecordOverflow(String displayText, String timeText) {
    // Check if text might overflow (rough estimation)
    final totalTextLength = displayText.length + timeText.length;
    const maxRecommendedLength = 40; // Increased for longer DJ names
    
    if (totalTextLength > maxRecommendedLength) {
      _monitoringService.recordOverflow(
        widgetName: 'NextDJWidget',
        content: '$displayText $timeText',
        overflowType: 'text_length',
        resolution: 'tooltip_and_ellipsis',
        additionalData: {
          'displayTextLength': displayText.length,
          'timeTextLength': timeText.length,
          'totalLength': totalTextLength,
          'maxRecommendedLength': maxRecommendedLength,
        },
      );
    }
  }
} 