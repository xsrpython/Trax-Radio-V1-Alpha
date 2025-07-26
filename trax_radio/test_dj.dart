import 'dart:convert';
import 'package:flutter/services.dart';

void main() async {
  await testDJDetection();
}

Future<void> testDJDetection() async {
  print('=== DJ Detection Test ===');
  
  try {
    // Load DJ schedule
    final String jsonString = await rootBundle.loadString('assets/dj_schedule.json');
    final List<dynamic> jsonList = json.decode(jsonString);
    print('Loaded ${jsonList.length} DJs from schedule');
    
    // Find DJ SIDWAYNE
    final djSidwayne = jsonList.firstWhere(
      (dj) => dj['name'] == 'DJ SIDWAYNE',
      orElse: () => null,
    );
    
    if (djSidwayne != null) {
      print('Found DJ SIDWAYNE: ${djSidwayne['schedule']}');
      
      // Test current time
      final now = DateTime.now();
      final currentDay = _getDayName(now.weekday);
      final currentTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
      
      print('Current time: $currentTime, Day: $currentDay');
      
      // Check if DJ SIDWAYNE should be playing
      for (final schedule in djSidwayne['schedule']) {
        final day = schedule['day'];
        final start = schedule['start'];
        final end = schedule['end'];
        
        print('Checking schedule: $day $start-$end');
        
        if (day == currentDay) {
          final inRange = _isTimeInRange(currentTime, start, end);
          print('Time in range: $inRange');
          
          if (inRange) {
            print('✅ DJ SIDWAYNE should be playing!');
            return;
          }
        }
      }
      
      print('❌ DJ SIDWAYNE should NOT be playing');
    } else {
      print('❌ DJ SIDWAYNE not found in schedule');
    }
    
  } catch (e) {
    print('Error: $e');
  }
}

String _getDayName(int weekday) {
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

bool _isTimeInRange(String currentTime, String startTime, String endTime) {
  int currentMinutes = _timeStringToMinutes(currentTime);
  int startMinutes = _timeStringToMinutes(startTime);
  int endMinutes = _timeStringToMinutes(endTime);
  
  if (endMinutes < startMinutes) {
    endMinutes += 24 * 60;
  }
  
  return currentMinutes >= startMinutes && currentMinutes < endMinutes;
}

int _timeStringToMinutes(String timeString) {
  final parts = timeString.split(':');
  if (parts.length != 2) return 0;
  
  final hours = int.tryParse(parts[0]) ?? 0;
  final minutes = int.tryParse(parts[1]) ?? 0;
  
  return hours * 60 + minutes;
} 