import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/audio_device.dart';

/// Service for managing audio devices and audio input/output
class AudioService extends ChangeNotifier {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  // Audio devices
  List<AudioDevice> _availableDevices = [];
  AudioDevice? _selectedInputDevice;
  AudioDevice? _selectedOutputDevice;
  
  // Audio state
  bool _isInitialized = false;
  bool _isRecording = false;
  double _inputLevel = 0.0;
  double _outputLevel = 0.0;
  
  // Stream controllers
  final StreamController<double> _inputLevelController = StreamController<double>.broadcast();
  final StreamController<double> _outputLevelController = StreamController<double>.broadcast();
  final StreamController<AudioDevice> _deviceChangeController = StreamController<AudioDevice>.broadcast();

  // Getters
  List<AudioDevice> get availableDevices => _availableDevices;
  AudioDevice? get selectedInputDevice => _selectedInputDevice;
  AudioDevice? get selectedOutputDevice => _selectedOutputDevice;
  bool get isInitialized => _isInitialized;
  bool get isRecording => _isRecording;
  double get inputLevel => _inputLevel;
  double get outputLevel => _outputLevel;
  
  // Streams
  Stream<double> get inputLevelStream => _inputLevelController.stream;
  Stream<double> get outputLevelStream => _outputLevelController.stream;
  Stream<AudioDevice> get deviceChangeStream => _deviceChangeController.stream;

  /// Initialize the audio service
  Future<bool> initialize() async {
    try {
      if (kDebugMode) {
        print('AudioService: Initializing...');
      }
      
      // Detect available audio devices
      await _detectAudioDevices();
      
      // Set default devices
      if (_availableDevices.isNotEmpty) {
        _selectedInputDevice = _availableDevices.firstWhere(
          (device) => device.type == AudioDeviceType.input,
          orElse: () => _availableDevices.first,
        );
        
        _selectedOutputDevice = _availableDevices.firstWhere(
          (device) => device.type == AudioDeviceType.output,
          orElse: () => _availableDevices.first,
        );
      }
      
      _isInitialized = true;
      notifyListeners();
      
      if (kDebugMode) {
        print('AudioService: Initialized successfully');
        print('Available devices: ${_availableDevices.length}');
        print('Selected input: ${_selectedInputDevice?.name}');
        print('Selected output: ${_selectedOutputDevice?.name}');
      }
      
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('AudioService: Initialization failed: $e');
      }
      return false;
    }
  }

  /// Detect available audio devices
  Future<void> _detectAudioDevices() async {
    try {
      // For now, create mock devices
      // In a real implementation, this would use platform-specific audio APIs
      _availableDevices = [
        AudioDevice(
          id: 'system_mic',
          name: 'System Microphone',
          type: AudioDeviceType.input,
          isDefault: true,
          sampleRate: 44100,
          channels: 1,
        ),
        AudioDevice(
          id: 'system_speakers',
          name: 'System Speakers',
          type: AudioDeviceType.output,
          isDefault: true,
          sampleRate: 44100,
          channels: 2,
        ),
        AudioDevice(
          id: 'usb_audio',
          name: 'USB Audio Interface',
          type: AudioDeviceType.input,
          isDefault: false,
          sampleRate: 48000,
          channels: 2,
        ),
        AudioDevice(
          id: 'ddj_1000',
          name: 'Pioneer DDJ-1000',
          type: AudioDeviceType.input,
          isDefault: false,
          sampleRate: 44100,
          channels: 2,
        ),
      ];
      
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('AudioService: Device detection failed: $e');
      }
    }
  }

  /// Select input device
  Future<bool> selectInputDevice(AudioDevice device) async {
    try {
      if (device.type != AudioDeviceType.input) {
        throw ArgumentError('Device must be an input device');
      }
      
      _selectedInputDevice = device;
      notifyListeners();
      _deviceChangeController.add(device);
      
      if (kDebugMode) {
        print('AudioService: Selected input device: ${device.name}');
      }
      
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('AudioService: Failed to select input device: $e');
      }
      return false;
    }
  }

  /// Select output device
  Future<bool> selectOutputDevice(AudioDevice device) async {
    try {
      if (device.type != AudioDeviceType.output) {
        throw ArgumentError('Device must be an output device');
      }
      
      _selectedOutputDevice = device;
      notifyListeners();
      _deviceChangeController.add(device);
      
      if (kDebugMode) {
        print('AudioService: Selected output device: ${device.name}');
      }
      
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('AudioService: Failed to select output device: $e');
      }
      return false;
    }
  }

  /// Start audio recording/streaming
  Future<bool> startRecording() async {
    try {
      if (!_isInitialized) {
        throw StateError('Audio service not initialized');
      }
      
      if (_selectedInputDevice == null) {
        throw StateError('No input device selected');
      }
      
      _isRecording = true;
      notifyListeners();
      
      // Start monitoring audio levels
      _startAudioLevelMonitoring();
      
      if (kDebugMode) {
        print('AudioService: Started recording from ${_selectedInputDevice!.name}');
      }
      
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('AudioService: Failed to start recording: $e');
      }
      return false;
    }
  }

  /// Stop audio recording/streaming
  Future<bool> stopRecording() async {
    try {
      _isRecording = false;
      notifyListeners();
      
      // Stop monitoring audio levels
      _stopAudioLevelMonitoring();
      
      if (kDebugMode) {
        print('AudioService: Stopped recording');
      }
      
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('AudioService: Failed to stop recording: $e');
      }
      return false;
    }
  }

  /// Start monitoring audio levels
  void _startAudioLevelMonitoring() {
    // Simulate audio level monitoring
    Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!_isRecording) {
        timer.cancel();
        return;
      }
      
      // Simulate input level (0.0 to 1.0)
      _inputLevel = (DateTime.now().millisecondsSinceEpoch % 1000) / 1000.0;
      _inputLevelController.add(_inputLevel);
      
      // Simulate output level
      _outputLevel = (_inputLevel * 0.8) + 0.1; // Slightly lower than input
      _outputLevelController.add(_outputLevel);
      
      notifyListeners();
    });
  }

  /// Stop monitoring audio levels
  void _stopAudioLevelMonitoring() {
    _inputLevel = 0.0;
    _outputLevel = 0.0;
    _inputLevelController.add(_inputLevel);
    _outputLevelController.add(_outputLevel);
    notifyListeners();
  }

  /// Get device by ID
  AudioDevice? getDeviceById(String id) {
    try {
      return _availableDevices.firstWhere((device) => device.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Refresh available devices
  Future<void> refreshDevices() async {
    await _detectAudioDevices();
  }

  /// Dispose resources
  @override
  void dispose() {
    _inputLevelController.close();
    _outputLevelController.close();
    _deviceChangeController.close();
    super.dispose();
  }
}
