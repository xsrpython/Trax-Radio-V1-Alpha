import 'dj_service.dart';

void debugDJDetection() async {
  await DJService.initialize();
  
  print('=== DJ Detection Debug ===');
  print('Current UK Time: ${DateTime.now()}');
  
  // Test current DJ detection
  final currentDJ = DJService.getCurrentDJ();
  print('Current DJ: $currentDJ');
  
  // Test time range logic
  print('\n=== Time Range Tests ===');
  print('18:52 in range 18:00-19:00: ${_testTimeRange("18:52", "18:00", "19:00")}');
  print('18:52 in range 19:00-20:00: ${_testTimeRange("18:52", "19:00", "20:00")}');
  print('18:52 in range 20:00-21:00: ${_testTimeRange("18:52", "20:00", "21:00")}');
  
  // Test day name
  print('\n=== Day Name Test ===');
  print('Current weekday: ${DateTime.now().weekday}');
  print('Day name: ${_getDayName(DateTime.now().weekday)}');
}

bool _testTimeRange(String currentTime, String startTime, String endTime) {
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