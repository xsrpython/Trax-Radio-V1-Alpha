import 'dart:developer' as developer;

class MonitoringService {
  static final MonitoringService _instance = MonitoringService._internal();
  factory MonitoringService() => _instance;
  MonitoringService._internal();

  void recordOverflow({
    required String widgetName,
    required String content,
    required String overflowType,
    required String resolution,
    Map<String, dynamic>? additionalData,
  }) {
    final logData = {
      'widget': widgetName,
      'content': content,
      'overflowType': overflowType,
      'resolution': resolution,
      'timestamp': DateTime.now().toIso8601String(),
      if (additionalData != null) ...additionalData,
    };

    developer.log(
      'UI Overflow Detected',
      name: 'MonitoringService',
      error: logData.toString(),
    );
  }

  void recordWidgetRender({
    required String widgetName,
    required Map<String, dynamic> data,
  }) {
    final logData = {
      'widget': widgetName,
      'data': data,
      'timestamp': DateTime.now().toIso8601String(),
    };

    developer.log(
      'Widget Rendered',
      name: 'MonitoringService',
      error: logData.toString(),
    );
  }

  void recordError({
    required String widgetName,
    required String error,
    required String context,
    Map<String, dynamic>? additionalData,
  }) {
    final logData = {
      'widget': widgetName,
      'error': error,
      'context': context,
      'timestamp': DateTime.now().toIso8601String(),
      if (additionalData != null) ...additionalData,
    };

    developer.log(
      'Widget Error',
      name: 'MonitoringService',
      error: logData.toString(),
    );
  }
} 