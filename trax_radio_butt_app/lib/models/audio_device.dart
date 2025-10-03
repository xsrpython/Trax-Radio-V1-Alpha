/// Represents an audio device (input or output)
class AudioDevice {
  final String id;
  final String name;
  final AudioDeviceType type;
  final bool isDefault;
  final int sampleRate;
  final int channels;
  final String? manufacturer;
  final String? model;
  final bool isConnected;

  const AudioDevice({
    required this.id,
    required this.name,
    required this.type,
    required this.isDefault,
    required this.sampleRate,
    required this.channels,
    this.manufacturer,
    this.model,
    this.isConnected = true,
  });

  /// Create AudioDevice from JSON
  factory AudioDevice.fromJson(Map<String, dynamic> json) {
    return AudioDevice(
      id: json['id'] as String,
      name: json['name'] as String,
      type: AudioDeviceType.values.firstWhere(
        (e) => e.toString() == 'AudioDeviceType.${json['type']}',
        orElse: () => AudioDeviceType.input,
      ),
      isDefault: json['isDefault'] as bool? ?? false,
      sampleRate: json['sampleRate'] as int? ?? 44100,
      channels: json['channels'] as int? ?? 2,
      manufacturer: json['manufacturer'] as String?,
      model: json['model'] as String?,
      isConnected: json['isConnected'] as bool? ?? true,
    );
  }

  /// Convert AudioDevice to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.toString().split('.').last,
      'isDefault': isDefault,
      'sampleRate': sampleRate,
      'channels': channels,
      'manufacturer': manufacturer,
      'model': model,
      'isConnected': isConnected,
    };
  }

  /// Create a copy with updated values
  AudioDevice copyWith({
    String? id,
    String? name,
    AudioDeviceType? type,
    bool? isDefault,
    int? sampleRate,
    int? channels,
    String? manufacturer,
    String? model,
    bool? isConnected,
  }) {
    return AudioDevice(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      isDefault: isDefault ?? this.isDefault,
      sampleRate: sampleRate ?? this.sampleRate,
      channels: channels ?? this.channels,
      manufacturer: manufacturer ?? this.manufacturer,
      model: model ?? this.model,
      isConnected: isConnected ?? this.isConnected,
    );
  }

  /// Get display name for UI
  String get displayName {
    if (manufacturer != null && model != null) {
      return '$manufacturer $model';
    }
    return name;
  }

  /// Get device capabilities summary
  String get capabilities {
    return '${channels}ch @ ${sampleRate}Hz';
  }

  /// Check if device is a DJ controller
  bool get isDJController {
    return name.toLowerCase().contains('ddj') ||
           name.toLowerCase().contains('cdj') ||
           name.toLowerCase().contains('dj') ||
           name.toLowerCase().contains('controller');
  }

  /// Check if device is a USB audio interface
  bool get isUSBAudio {
    return name.toLowerCase().contains('usb') ||
           name.toLowerCase().contains('interface') ||
           name.toLowerCase().contains('soundcard');
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AudioDevice && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'AudioDevice(id: $id, name: $name, type: $type, isDefault: $isDefault)';
  }
}

/// Audio device types
enum AudioDeviceType {
  input,
  output,
  both,
}

/// Extension for AudioDeviceType
extension AudioDeviceTypeExtension on AudioDeviceType {
  /// Get display name
  String get displayName {
    switch (this) {
      case AudioDeviceType.input:
        return 'Input';
      case AudioDeviceType.output:
        return 'Output';
      case AudioDeviceType.both:
        return 'Input/Output';
    }
  }

  /// Get icon name
  String get iconName {
    switch (this) {
      case AudioDeviceType.input:
        return 'mic';
      case AudioDeviceType.output:
        return 'speaker';
      case AudioDeviceType.both:
        return 'settings_input_component';
    }
  }
}





