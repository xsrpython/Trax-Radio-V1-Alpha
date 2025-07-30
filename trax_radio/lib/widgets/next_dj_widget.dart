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
  String _nextDay = '';
  bool _isLoading = true;
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
    final newDay = nextDJInfo['day'] ?? '';

    if (mounted && (newName != _nextDJ || newStartTime != _nextStartTime || newDay != _nextDay || _isLoading)) {
      setState(() {
        _nextDJ = newName;
        _nextStartTime = newStartTime;
        _nextDay = newDay;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox.shrink();
    }

    String displayText = _nextDJ;
    String timeText = '';

    if (_nextDJ.isEmpty || _nextDJ == 'No upcoming DJs') {
      displayText = 'Auto DJ';
      timeText = 'Now';
    } else if (_nextStartTime.isNotEmpty) {
      if (_nextDay.isNotEmpty) {
        // Use shorter day names to save space
        String shortDay = _nextDay;
        if (_nextDay == 'Today') {
          // Don't show "Today", just show the time
          timeText = 'at $_nextStartTime';
        } else if (_nextDay == 'Tomorrow') {
          // Get the actual short day name for tomorrow
          final now = DateTime.now();
          final tomorrow = now.add(const Duration(days: 1));
          final tomorrowWeekday = tomorrow.weekday;
          
          switch (tomorrowWeekday) {
            case DateTime.monday:
              shortDay = 'Mon';
              break;
            case DateTime.tuesday:
              shortDay = 'Tue';
              break;
            case DateTime.wednesday:
              shortDay = 'Wed';
              break;
            case DateTime.thursday:
              shortDay = 'Thu';
              break;
            case DateTime.friday:
              shortDay = 'Fri';
              break;
            case DateTime.saturday:
              shortDay = 'Sat';
              break;
            case DateTime.sunday:
              shortDay = 'Sun';
              break;
            default:
              shortDay = 'Mon';
          }
          timeText = '$shortDay at $_nextStartTime';
        } else if (_nextDay == 'Monday') {
          shortDay = 'Mon';
          timeText = '$shortDay at $_nextStartTime';
        } else if (_nextDay == 'Tuesday') {
          shortDay = 'Tue';
          timeText = '$shortDay at $_nextStartTime';
        } else if (_nextDay == 'Wednesday') {
          shortDay = 'Wed';
          timeText = '$shortDay at $_nextStartTime';
        } else if (_nextDay == 'Thursday') {
          shortDay = 'Thu';
          timeText = '$shortDay at $_nextStartTime';
        } else if (_nextDay == 'Friday') {
          shortDay = 'Fri';
          timeText = '$shortDay at $_nextStartTime';
        } else if (_nextDay == 'Saturday') {
          shortDay = 'Sat';
          timeText = '$shortDay at $_nextStartTime';
        } else if (_nextDay == 'Sunday') {
          shortDay = 'Sun';
          timeText = '$shortDay at $_nextStartTime';
        } else {
          timeText = '$shortDay at $_nextStartTime';
        }
      } else {
        timeText = 'at $_nextStartTime';
      }
    } else {
      timeText = 'Coming Soon';
    }

    return Transform.scale(
      scale: 1.0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.orange.withOpacity(0.5),
            width: 2,
          ),
        ),
        child: Row(
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
            Expanded(
              child: Tooltip(
                message: '$displayText (UK Time)',
                child: Text(
                  displayText,
                  style: const TextStyle(
                    color: Colors.orange,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ),
            const SizedBox(width: 4), // Reduced spacing from 8 to 4
            Expanded(
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
        ),
      ),
    );
  }
} 