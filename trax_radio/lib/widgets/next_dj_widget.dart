import 'package:flutter/material.dart';
import 'dart:async';
import '../dj_service.dart';

class NextDJWidget extends StatefulWidget {
  const NextDJWidget({super.key});

  @override
  State<NextDJWidget> createState() => _NextDJWidgetState();
}

class _NextDJWidgetState extends State<NextDJWidget> {
  String _nextDJ = '';
  String _nextStartTime = '';
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _initializeDJService();
    _startTimer();
  }

  Future<void> _initializeDJService() async {
    await DJService.initialize();
    _updateNextDJ();
  }

  void _startTimer() {
    // Update every minute to check for DJ changes
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _updateNextDJ();
    });
  }

  void _updateNextDJ() {
    final nextDJInfo = DJService.getNextDJ();
    final newName = nextDJInfo['name'] ?? '';
    final newStartTime = nextDJInfo['startTime'] ?? '';
    
    if (mounted && (newName != _nextDJ || newStartTime != _nextStartTime)) {
      setState(() {
        _nextDJ = newName;
        _nextStartTime = newStartTime;
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Determine what text to show based on the DJ info
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

    return Transform.scale(
      scale: 1.0, // Reduced from 1.5 to 1.0 (no internal scaling)
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.orange.withValues(alpha: 0.5), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.schedule,
              color: Colors.orange,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Next: ',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            Text(
              displayText,
              style: const TextStyle(
                color: Colors.orange,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            if (timeText.isNotEmpty) ...[
              const SizedBox(width: 10),
              Text(
                timeText,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
} 