import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class DJ {
  final String name;
  final List<Schedule> schedule;
  final String bio;
  final String image;

  DJ({
    required this.name,
    required this.schedule,
    required this.bio,
    required this.image,
  });

  factory DJ.fromJson(Map<String, dynamic> json) {
    return DJ(
      name: json['name'] ?? '',
      schedule: (json['schedule'] as List?)
          ?.map((s) => Schedule.fromJson(s))
          .toList() ?? [],
      bio: json['bio'] ?? '',
      image: json['image'] ?? '',
    );
  }
}

class Schedule {
  final String day;
  final String start;
  final String end;

  Schedule({
    required this.day,
    required this.start,
    required this.end,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      day: json['day'] ?? '',
      start: json['start'] ?? '',
      end: json['end'] ?? '',
    );
  }
}

class DJService {
  static List<DJ> _djs = [];
  static bool _isInitialized = false;
  static tz.Location? _userLocation;
  static tz.Location _ukLocation = tz.getLocation('Europe/London');

  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize timezone data
      tz.initializeTimeZones();
      
      // Detect user's timezone
      _userLocation = tz.local;
      
      print('DJ Service Debug: User timezone: ${_userLocation?.name}');
      print('DJ Service Debug: UK timezone: ${_ukLocation.name}');

      final String response = await rootBundle.loadString('assets/dj_schedule.json');
      final List<dynamic> jsonList = json.decode(response);
      _djs = jsonList.map((json) => DJ.fromJson(json)).toList();
      _isInitialized = true;
      print('DJ Service Debug: Initialized with ${_djs.length} DJs');
      
      // Print all DJs and their schedules for debugging
      for (final dj in _djs) {
        print('DJ Service Debug: ${dj.name} - ${dj.schedule.length} schedule(s)');
        for (final schedule in dj.schedule) {
          print('DJ Service Debug:   ${schedule.day} ${schedule.start}-${schedule.end} (UK time)');
        }
      }
    } catch (e) {
      _djs = [];
      print('DJ Service Debug: Error initializing: $e');
    }
  }

  static DJ? getCurrentDJ() {
    if (!_isInitialized || _djs.isEmpty || _userLocation == null) return null;

    final now = tz.TZDateTime.now(_userLocation!);
    final ukNow = tz.TZDateTime.now(_ukLocation);
    
    final currentDay = _getDayName(now.weekday);
    final currentTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    final currentMinutes = _timeStringToMinutes(currentTime);

    print('DJ Service Debug: User timezone: ${_userLocation!.name}');
    print('DJ Service Debug: User time: $currentDay $currentTime (${currentMinutes} minutes)');
    print('DJ Service Debug: UK time: ${_getDayName(ukNow.weekday)} ${ukNow.hour.toString().padLeft(2, '0')}:${ukNow.minute.toString().padLeft(2, '0')}');

    // Find the current DJ slot
    DJ? currentDJ;
    int? currentEndMinutes;

    for (final dj in _djs) {
      for (final schedule in dj.schedule) {
        if (schedule.day == currentDay) {
          final startMinutes = _timeStringToMinutes(schedule.start);
          final endMinutes = _timeStringToMinutes(schedule.end);

          print('DJ Service Debug: Checking ${dj.name} - ${schedule.start} to ${schedule.end} (${startMinutes} to ${endMinutes})');

          if (currentMinutes >= startMinutes && currentMinutes < endMinutes) {
            currentDJ = dj;
            currentEndMinutes = endMinutes;
            print('DJ Service Debug: Found current DJ: ${dj.name}');
            break;
          }
        }
      }
      if (currentDJ != null) break;
    }

    if (currentDJ == null) {
      print('DJ Service Debug: No current DJ found for $currentDay at $currentTime');
    }

    return currentDJ;
  }

  static Map<String, String> getNextDJ() {
    if (!_isInitialized || _djs.isEmpty || _userLocation == null) {
      return {'name': 'Auto DJ', 'startTime': 'Now'};
    }

    final now = tz.TZDateTime.now(_userLocation!);
    final currentDay = _getDayName(now.weekday);
    final currentTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    final currentMinutes = _timeStringToMinutes(currentTime);

    // Get all slots for today
    List<Map<String, dynamic>> todaySlots = [];
    for (final dj in _djs) {
      for (final schedule in dj.schedule) {
        if (schedule.day == currentDay) {
          todaySlots.add({
            'dj': dj.name,
            'start': schedule.start,
            'end': schedule.end,
            'startMinutes': _timeStringToMinutes(schedule.start),
            'endMinutes': _timeStringToMinutes(schedule.end),
          });
        }
      }
    }

    // Sort by start time
    todaySlots.sort((a, b) => a['startMinutes'].compareTo(b['startMinutes']));

    // Find the next slot that starts after current time
    for (final slot in todaySlots) {
      final startMinutes = slot['startMinutes'];
      final endMinutes = slot['endMinutes'];

      // If this slot starts in the future, it's the next one
      if (startMinutes > currentMinutes) {
        return {'name': slot['dj'], 'startTime': slot['start']};
      }

      // If we're currently in this slot, find the next one
      if (currentMinutes >= startMinutes && currentMinutes < endMinutes) {
        // Look for the next slot after this one
        for (final nextSlot in todaySlots) {
          if (nextSlot['startMinutes'] > endMinutes) {
            return {'name': nextSlot['dj'], 'startTime': nextSlot['start']};
          }
        }
        // If no more slots today, look for tomorrow
        break;
      }
    }

    // Check tomorrow
    final tomorrow = now.add(const Duration(days: 1));
    final tomorrowDay = _getDayName(tomorrow.weekday);

    for (final dj in _djs) {
      for (final schedule in dj.schedule) {
        if (schedule.day == tomorrowDay) {
          return {'name': dj.name, 'startTime': schedule.start};
        }
      }
    }

    // Check next 7 days
    for (int dayOffset = 2; dayOffset <= 7; dayOffset++) {
      final futureDate = now.add(Duration(days: dayOffset));
      final futureDayName = _getDayName(futureDate.weekday);

      for (final dj in _djs) {
        for (final schedule in dj.schedule) {
          if (schedule.day == futureDayName) {
            return {'name': dj.name, 'startTime': schedule.start};
          }
        }
      }
    }

    // Fallback to first available DJ
    if (_djs.isNotEmpty) {
      final firstDJ = _djs.first;
      if (firstDJ.schedule.isNotEmpty) {
        final firstSchedule = firstDJ.schedule.first;
        return {'name': firstDJ.name, 'startTime': firstSchedule.start};
      }
    }

    return {'name': 'Auto DJ', 'startTime': 'Now'};
  }

  // Helper method to convert UK time to user's local time
  static String convertUKTimeToLocal(String ukTime, String day) {
    if (_userLocation == null) return ukTime;
    
    try {
      // Parse the UK time
      final parts = ukTime.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      
      // Create a UK time for the given day
      final ukDateTime = tz.TZDateTime(_ukLocation, DateTime.now().year, 
          _getMonthFromDay(day), _getDayOfMonth(day), hour, minute);
      
      // Convert to user's timezone
      final localDateTime = ukDateTime.toLocation(_userLocation!);
      
      return '${localDateTime.hour.toString().padLeft(2, '0')}:${localDateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      print('DJ Service Debug: Error converting time: $e');
      return ukTime;
    }
  }

  // Helper method to get month from day name (simplified)
  static int _getMonthFromDay(String day) {
    // This is a simplified approach - in production you'd want more sophisticated logic
    final now = DateTime.now();
    return now.month;
  }

  // Helper method to get day of month from day name (simplified)
  static int _getDayOfMonth(String day) {
    // This is a simplified approach - in production you'd want more sophisticated logic
    final now = DateTime.now();
    return now.day;
  }

  static String _getDayName(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Monday';
      case DateTime.tuesday:
        return 'Tuesday';
      case DateTime.wednesday:
        return 'Wednesday';
      case DateTime.thursday:
        return 'Thursday';
      case DateTime.friday:
        return 'Friday';
      case DateTime.saturday:
        return 'Saturday';
      case DateTime.sunday:
        return 'Sunday';
      default:
        return 'Monday';
    }
  }

  static int _timeStringToMinutes(String time) {
    final parts = time.split(':');
    if (parts.length == 2) {
      final hours = int.tryParse(parts[0]) ?? 0;
      final minutes = int.tryParse(parts[1]) ?? 0;
      return hours * 60 + minutes;
    }
    return 0;
  }
} 