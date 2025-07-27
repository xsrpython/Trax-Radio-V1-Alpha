import 'dart:convert';
import 'package:flutter/services.dart';

class DJ {
  final String name;
  final List<DJSchedule> schedule;
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
          ?.map((s) => DJSchedule.fromJson(s))
          .toList() ?? [],
      bio: json['bio'] ?? '',
      image: json['image'] ?? '',
    );
  }
}

class DJSchedule {
  final String day;
  final String start;
  final String end;

  DJSchedule({
    required this.day,
    required this.start,
    required this.end,
  });

  factory DJSchedule.fromJson(Map<String, dynamic> json) {
    return DJSchedule(
      day: json['day'] ?? '',
      start: json['start'] ?? '',
      end: json['end'] ?? '',
    );
  }
}

class DJService {
  static List<DJ> _djs = [];
  static bool _isInitialized = false;

  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final String jsonString = await rootBundle.loadString('assets/dj_schedule.json');
      final List<dynamic> jsonList = json.decode(jsonString);
      _djs = jsonList.map((json) => DJ.fromJson(json)).toList();
      _isInitialized = true;
      print('DJ Service Debug: Initialized with ${_djs.length} DJs');
      for (final dj in _djs) {
        print('  - ${dj.name}: ${dj.schedule.length} schedule(s)');
        for (final schedule in dj.schedule) {
          print('    * ${schedule.day} ${schedule.start}-${schedule.end}');
        }
      }
    } catch (e) {
      print('DJ Service Debug: Error initializing: $e');
      _djs = [];
    }
  }

  static String getCurrentDJ() {
    if (!_isInitialized || _djs.isEmpty) {
      return 'Trax Auto DJ';
    }

    // Use UK time (GMT/BST) with automatic detection
    final ukTime = _getUKTime();
    
    final currentDay = _getDayName(ukTime.weekday);
    final currentTime = '${ukTime.hour.toString().padLeft(2, '0')}:${ukTime.minute.toString().padLeft(2, '0')}';

    for (final dj in _djs) {
      for (final schedule in dj.schedule) {
        if (schedule.day == currentDay && _isTimeInRange(currentTime, schedule.start, schedule.end)) {
          return dj.name;
        }
      }
    }
    return 'Trax Auto DJ';
  }

  static DateTime _getUKTime() {
    // For now, let's use local time and assume we're in UK timezone
    // This is simpler and should work for testing
    final now = DateTime.now();
    
    // If you're in a different timezone, you might need to adjust this
    // For now, we'll use local time and assume it's UK time
    return now;
  }

  static DJ? getCurrentDJObject() {
    if (!_isInitialized || _djs.isEmpty) {
      return null;
    }

    final now = DateTime.now();
    final currentDay = _getDayName(now.weekday);
    final currentTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    for (final dj in _djs) {
      for (final schedule in dj.schedule) {
        if (schedule.day == currentDay && _isTimeInRange(currentTime, schedule.start, schedule.end)) {
          return dj;
        }
      }
    }

    return null;
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

  static bool _isTimeInRange(String currentTime, String startTime, String endTime) {
    // Convert time strings to minutes for comparison
    int currentMinutes = _timeStringToMinutes(currentTime);
    int startMinutes = _timeStringToMinutes(startTime);
    int endMinutes = _timeStringToMinutes(endTime);
    
    // Handle midnight case (e.g., "23:00" to "00:00")
    if (endMinutes < startMinutes) {
      endMinutes += 24 * 60; // Add 24 hours
    }
    
    final result = currentMinutes >= startMinutes && currentMinutes < endMinutes;
    
    return result;
  }

  static int _timeStringToMinutes(String timeString) {
    final parts = timeString.split(':');
    if (parts.length != 2) return 0;
    
    final hours = int.tryParse(parts[0]) ?? 0;
    final minutes = int.tryParse(parts[1]) ?? 0;
    
    return hours * 60 + minutes;
  }

  static List<DJ> getAllDJs() {
    return List.from(_djs);
  }

  static Map<String, String> getNextDJ() {
    if (!_isInitialized || _djs.isEmpty) {
      print('DJ Service Debug: Not initialized or no DJs available');
      return {'name': 'Auto DJ', 'startTime': 'Now'};
    }

    final ukTime = _getUKTime();
    final currentDay = _getDayName(ukTime.weekday);
    final currentTime = '${ukTime.hour.toString().padLeft(2, '0')}:${ukTime.minute.toString().padLeft(2, '0')}';
    final currentMinutes = _timeStringToMinutes(currentTime);

    // Debug: Print current time info
    print('DJ Service Debug: Current day: $currentDay, Current time: $currentTime');

    // Collect all today's slots and sort them by start time
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
    
    // Debug: Print today's slots
    print('DJ Service Debug: Found ${todaySlots.length} slots for today');
    for (final slot in todaySlots) {
      print('  - ${slot['dj']}: ${slot['start']} to ${slot['end']}');
    }
    
    // Sort by start time
    todaySlots.sort((a, b) => a['startMinutes'].compareTo(b['startMinutes']));
    
    // Find the next slot after current time
    for (final slot in todaySlots) {
      final startMinutes = slot['startMinutes'];
      final endMinutes = slot['endMinutes'];
      
      // If this slot starts after current time, it's the next one
      if (startMinutes > currentMinutes) {
        print('DJ Service Debug: Found next DJ today: ${slot['dj']} at ${slot['start']}');
        return {'name': slot['dj'], 'startTime': slot['start']};
      }
      
      // If we're currently in this slot, the next one is after it ends
      if (currentMinutes >= startMinutes && currentMinutes < endMinutes) {
        print('DJ Service Debug: Currently in slot: ${slot['dj']}');
        // Continue to find the next slot
        continue;
      }
    }

    // If no more slots today, find the first slot tomorrow
    final tomorrow = ukTime.add(const Duration(days: 1));
    final tomorrowDay = _getDayName(tomorrow.weekday);
    print('DJ Service Debug: Looking for tomorrow ($tomorrowDay)');

    for (final dj in _djs) {
      for (final schedule in dj.schedule) {
        if (schedule.day == tomorrowDay) {
          print('DJ Service Debug: Found next DJ tomorrow: ${dj.name} at ${schedule.start}');
          return {'name': dj.name, 'startTime': schedule.start};
        }
      }
    }

    // If no DJs found for tomorrow, look for the next available slot in the week
    for (int dayOffset = 2; dayOffset <= 7; dayOffset++) {
      final futureDay = ukTime.add(Duration(days: dayOffset));
      final futureDayName = _getDayName(futureDay.weekday);
      
      for (final dj in _djs) {
        for (final schedule in dj.schedule) {
          if (schedule.day == futureDayName) {
            print('DJ Service Debug: Found next DJ in ${dayOffset} days: ${dj.name} at ${schedule.start}');
            return {'name': dj.name, 'startTime': schedule.start};
          }
        }
      }
    }

    // If still no DJs found, return the first available DJ in the schedule
    if (_djs.isNotEmpty) {
      final firstDJ = _djs.first;
      if (firstDJ.schedule.isNotEmpty) {
        final firstSchedule = firstDJ.schedule.first;
        print('DJ Service Debug: Using fallback DJ: ${firstDJ.name} at ${firstSchedule.start}');
        return {'name': firstDJ.name, 'startTime': firstSchedule.start};
      }
    }

    print('DJ Service Debug: No DJs found, using Auto DJ');
    return {'name': 'Auto DJ', 'startTime': 'Now'};
  }
} 