import 'dart:async';
import 'package:flutter/material.dart';
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
    _updateNextDJ();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) {
        _updateNextDJ();
      }
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
  Widget build(BuildContext context) {
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
      scale: 1.0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.orange.withOpacity(0.5),
            width: 1,
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