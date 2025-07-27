import 'dart:convert';
import 'package:flutter/services.dart';

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

  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final String response = await rootBundle.loadString('assets/dj_schedule.json');
      final List<dynamic> jsonList = json.decode(response);
      _djs = jsonList.map((json) => DJ.fromJson(json)).toList();
      _isInitialized = true;
    } catch (e) {
      _djs = [];
    }
  }

  static DJ? getCurrentDJ() {
    if (!_isInitialized || _djs.isEmpty) return null;

    final now = DateTime.now();
    final ukTime = now.toUtc().add(const Duration(hours: 0)); // Simplified timezone handling
    final currentDay = _getDayName(ukTime.weekday);
    final currentTime = '${ukTime.hour.toString().padLeft(2, '0')}:${ukTime.minute.toString().padLeft(2, '0')}';
    final currentMinutes = _timeStringToMinutes(currentTime);

    // Find the current DJ slot
    DJ? currentDJ;
    int? currentEndMinutes;

    for (final dj in _djs) {
      for (final schedule in dj.schedule) {
        if (schedule.day == currentDay) {
          final startMinutes = _timeStringToMinutes(schedule.start);
          final endMinutes = _timeStringToMinutes(schedule.end);

          if (currentMinutes >= startMinutes && currentMinutes < endMinutes) {
            currentDJ = dj;
            currentEndMinutes = endMinutes;
            break;
          }
        }
      }
      if (currentDJ != null) break;
    }

    return currentDJ;
  }

  static Map<String, String> getNextDJ() {
    if (!_isInitialized || _djs.isEmpty) {
      return {'name': 'Auto DJ', 'startTime': 'Now'};
    }

    final now = DateTime.now();
    final ukTime = now.toUtc().add(const Duration(hours: 0));
    final currentDay = _getDayName(ukTime.weekday);
    final currentTime = '${ukTime.hour.toString().padLeft(2, '0')}:${ukTime.minute.toString().padLeft(2, '0')}';
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
    final tomorrow = ukTime.add(const Duration(days: 1));
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
      final futureDate = ukTime.add(Duration(days: dayOffset));
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