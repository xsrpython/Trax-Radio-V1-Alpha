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
  static final tz.Location _ukLocation = tz.getLocation('Europe/London');

  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize timezone data
      tz.initializeTimeZones();
      
      // Detect user's timezone
      _userLocation = tz.local;
      


      final String response = await rootBundle.loadString('assets/dj_schedule.json');
      final List<dynamic> jsonList = json.decode(response);
      _djs = jsonList.map((json) => DJ.fromJson(json)).toList();
      _isInitialized = true;
    } catch (e) {
      _djs = [];
    }
  }

  static DJ? getCurrentDJ() {
    if (!_isInitialized || _djs.isEmpty || _userLocation == null) return null;

    final ukNow = tz.TZDateTime.now(_ukLocation);
    
    final currentDay = _getDayName(ukNow.weekday);
    final currentTime = '${ukNow.hour.toString().padLeft(2, '0')}:${ukNow.minute.toString().padLeft(2, '0')}';
    final currentMinutes = _timeStringToMinutes(currentTime);

    // Find the current DJ slot
    DJ? currentDJ;

    for (final dj in _djs) {
      for (final schedule in dj.schedule) {
        if (schedule.day == currentDay) {
          // Convert UK schedule times to user's local timezone
          final localStartTime = _convertUKTimeToLocalMinutes(schedule.start, currentDay);
          final localEndTime = _convertUKTimeToLocalMinutes(schedule.end, currentDay);

          if (currentMinutes >= localStartTime && currentMinutes < localEndTime) {
            currentDJ = dj;
            break;
          }
        }
      }
      if (currentDJ != null) break;
    }

    if (currentDJ == null) {
      // Auto DJ active - return a default DJ object
      return DJ(
        name: 'Auto DJ',
        schedule: [],
        bio: 'Automated music selection',
        image: '',
      );
    }

    return currentDJ;
  }

  static Map<String, String> getNextDJ() {
    if (!_isInitialized || _djs.isEmpty || _userLocation == null) {
      return {'name': 'Auto DJ', 'startTime': 'Now'};
    }

    final ukNow = tz.TZDateTime.now(_ukLocation);
    final currentDay = _getDayName(ukNow.weekday);
    final currentTime = '${ukNow.hour.toString().padLeft(2, '0')}:${ukNow.minute.toString().padLeft(2, '0')}';
    final currentMinutes = _timeStringToMinutes(currentTime);
    


    // Get all slots for today
    List<Map<String, dynamic>> todaySlots = [];
    for (final dj in _djs) {
      for (final schedule in dj.schedule) {
        if (schedule.day == currentDay) {
          // Convert UK schedule times to user's local timezone
          final localStartTime = _convertUKTimeToLocalMinutes(schedule.start, currentDay);
          final localEndTime = _convertUKTimeToLocalMinutes(schedule.end, currentDay);
          
          todaySlots.add({
            'dj': dj.name,
            'start': _minutesToTimeString(localStartTime), // Use converted local time
            'end': _minutesToTimeString(localEndTime),
            'startMinutes': localStartTime,
            'endMinutes': localEndTime,
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
        // Look for the next slot after this one ends
        for (final nextSlot in todaySlots) {
          if (nextSlot['startMinutes'] >= endMinutes) {
            return {'name': nextSlot['dj'], 'startTime': nextSlot['start']};
          }
        }
        // If no more slots today, look for tomorrow
        break;
      }
    }

    // Check tomorrow with proper date calculation
    final tomorrow = ukNow.add(const Duration(days: 1));
    final tomorrowDay = _getDayName(tomorrow.weekday);

    // Get all tomorrow's DJ slots and find the earliest one
    List<Map<String, dynamic>> tomorrowSlots = [];
    for (final dj in _djs) {
      for (final schedule in dj.schedule) {
        if (schedule.day == tomorrowDay) {
          final localStartTime = _convertUKTimeToLocalMinutes(schedule.start, tomorrowDay);
          tomorrowSlots.add({
            'dj': dj.name,
            'startTime': _minutesToTimeString(localStartTime),
            'startMinutes': localStartTime,
          });
        }
      }
    }

    // Sort by start time and return the earliest
    if (tomorrowSlots.isNotEmpty) {
      tomorrowSlots.sort((a, b) => a['startMinutes'].compareTo(b['startMinutes']));
      final earliestSlot = tomorrowSlots.first;
      return {
        'name': '${earliestSlot['dj']} (Tomorrow)', 
        'startTime': earliestSlot['startTime']
      };
    }

    // Check next 7 days with proper date calculation
    for (int dayOffset = 2; dayOffset <= 7; dayOffset++) {
      final futureDate = ukNow.add(Duration(days: dayOffset));
      final futureDayName = _getDayName(futureDate.weekday);

      for (final dj in _djs) {
        for (final schedule in dj.schedule) {
          if (schedule.day == futureDayName) {
            final localStartTime = _convertUKTimeToLocalMinutes(schedule.start, futureDayName);
            final dayName = _getShortDayName(futureDate.weekday);
            return {
              'name': '${dj.name} ($dayName)', 
              'startTime': _minutesToTimeString(localStartTime)
            };
          }
        }
      }
    }

    // Fallback to first available DJ
    if (_djs.isNotEmpty) {
      final firstDJ = _djs.first;
      if (firstDJ.schedule.isNotEmpty) {
        final firstSchedule = firstDJ.schedule.first;
        final localStartTime = _convertUKTimeToLocalMinutes(firstSchedule.start, firstSchedule.day);
        return {'name': firstDJ.name, 'startTime': _minutesToTimeString(localStartTime)};
      }
    }

    return {'name': 'Auto DJ', 'startTime': 'Now'};
  }

  // Helper method to get short day name
  static String _getShortDayName(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Mon';
      case DateTime.tuesday:
        return 'Tue';
      case DateTime.wednesday:
        return 'Wed';
      case DateTime.thursday:
        return 'Thu';
      case DateTime.friday:
        return 'Fri';
      case DateTime.saturday:
        return 'Sat';
      case DateTime.sunday:
        return 'Sun';
      default:
        return 'Mon';
    }
  }

  // Helper method to convert UK time to user's local time
  static String convertUKTimeToLocal(String ukTime, String day) {
    if (_userLocation == null) return ukTime;
    
    try {
      // Parse the UK time
      final parts = ukTime.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      
      // Create a UK time for the given day using proper date calculation
      final ukDateTime = _createUKDateTime(day, hour, minute);
      
      // Convert to user's timezone using the correct method
      final localDateTime = tz.TZDateTime.from(ukDateTime, _userLocation!);
      
      return '${localDateTime.hour.toString().padLeft(2, '0')}:${localDateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return ukTime;
    }
  }

  // Helper method to create proper UK DateTime for a given day
  static tz.TZDateTime _createUKDateTime(String day, int hour, int minute) {
    final now = tz.TZDateTime.now(_userLocation!);
    final targetWeekday = _getWeekdayFromDayName(day);
    
    // Calculate days to add to get to the target weekday
    int daysToAdd = targetWeekday - now.weekday;
    if (daysToAdd < 0) {
      daysToAdd += 7; // Move to next week
    }
    
    final targetDate = now.add(Duration(days: daysToAdd));
    
    return tz.TZDateTime(_ukLocation, targetDate.year, targetDate.month, targetDate.day, hour, minute);
  }

  // Helper method to get weekday number from day name
  static int _getWeekdayFromDayName(String day) {
    switch (day.toLowerCase()) {
      case 'monday':
        return DateTime.monday;
      case 'tuesday':
        return DateTime.tuesday;
      case 'wednesday':
        return DateTime.wednesday;
      case 'thursday':
        return DateTime.thursday;
      case 'friday':
        return DateTime.friday;
      case 'saturday':
        return DateTime.saturday;
      case 'sunday':
        return DateTime.sunday;
      default:
        return DateTime.monday;
    }
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
      // Handle 00:00 as 24:00 (1440 minutes) for end times
      if (hours == 0 && minutes == 0) {
        return 1440; // 24 hours in minutes
      }
      return hours * 60 + minutes;
    }
    return 0;
  }

  static int _convertUKTimeToLocalMinutes(String ukTime, String day) {
    // Use UK time directly for consistent comparison
    return _timeStringToMinutes(ukTime);
  }

  static String _minutesToTimeString(int minutes) {
    // Handle 1440 minutes (24:00) as 00:00 for display
    if (minutes == 1440) {
      return '00:00';
    }
    final hours = (minutes / 60).floor();
    final remainingMinutes = minutes % 60;
    return '${hours.toString().padLeft(2, '0')}:${remainingMinutes.toString().padLeft(2, '0')}';
  }
} 