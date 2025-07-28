import 'dart:async';
import 'dart:math';
import 'package:just_audio/just_audio.dart';

class BMPService {
  static final BMPService _instance = BMPService._internal();
  factory BMPService() => _instance;
  BMPService._internal();

  static const int _bufferSize = 1024;
  static const double _minBPM = 60.0;
  static const double _maxBPM = 200.0;
  static const double _bpmDoublingThreshold = 80.0; // BPM values at or below this will be doubled
  
  final List<double> _audioBuffer = [];
  final List<double> _beatTimes = [];
  final StreamController<int> _bpmController = StreamController<int>.broadcast();
  
  Timer? _analysisTimer;
  int _currentBPM = 0;
  DateTime? _lastBeatTime;
  double _averageInterval = 0.0;
  
  Stream<int> get bpmStream => _bpmController.stream;
  int get currentBPM => _currentBPM;

  void startAnalysis(AudioPlayer audioPlayer) {
    _analysisTimer?.cancel();
    _audioBuffer.clear();
    _beatTimes.clear();
    _currentBPM = 0;
    _lastBeatTime = null;
    _averageInterval = 0.0;

    _analysisTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (audioPlayer.playing) {
        _analyzeAudio(audioPlayer);
      }
    });
  }

  void stopAnalysis() {
    _analysisTimer?.cancel();
    _audioBuffer.clear();
    _beatTimes.clear();
    _currentBPM = 0;
    _lastBeatTime = null;
    _averageInterval = 0.0;
  }

  void _analyzeAudio(AudioPlayer audioPlayer) {
    try {
      // Simulate audio analysis since we can't directly access audio data
      // In a real implementation, you'd use audio plugins or native code
      final volume = audioPlayer.volume;
      final position = audioPlayer.position;
      
      // Generate simulated audio data based on volume and position
      final simulatedAudio = _generateSimulatedAudioData(volume, position);
      _audioBuffer.addAll(simulatedAudio);
      
      // Keep buffer size manageable
      if (_audioBuffer.length > _bufferSize * 2) {
        _audioBuffer.removeRange(0, _bufferSize);
      }
      
      // Detect beats
      if (_detectBeat(_audioBuffer)) {
        _onBeatDetected();
      }
      
      // Update BPM calculation
      _updateBPM();
      
    } catch (e) {
      // Handle errors silently
    }
  }

  List<double> _generateSimulatedAudioData(double volume, Duration position) {
    final random = Random();
    final samples = <double>[];
    final time = position.inMilliseconds / 1000.0;
    
    for (int i = 0; i < 50; i++) {
      // Create rhythmic patterns based on time and volume
      final baseFrequency = 1.0 + (time * 0.1) % 2.0;
      final amplitude = volume * (0.5 + 0.5 * sin(time * baseFrequency * 2 * pi));
      final noise = (random.nextDouble() - 0.5) * 0.1;
      
      samples.add(amplitude + noise);
    }
    
    return samples;
  }

  bool _detectBeat(List<double> buffer) {
    if (buffer.length < 100) return false;
    
    // Calculate energy in recent samples
    final recentSamples = buffer.take(100).toList();
    final energy = recentSamples.map((s) => s * s).reduce((a, b) => a + b) / recentSamples.length;
    
    // Calculate average energy over longer period
    final longTermSamples = buffer.take(500).toList();
    final averageEnergy = longTermSamples.map((s) => s * s).reduce((a, b) => a + b) / longTermSamples.length;
    
    // Beat detection threshold
    final threshold = averageEnergy * 1.5;
    
    return energy > threshold;
  }

  void _onBeatDetected() {
    final now = DateTime.now();
    
    if (_lastBeatTime != null) {
      final interval = now.difference(_lastBeatTime!).inMilliseconds;
      
      // Filter out unrealistic intervals
      if (interval > 200 && interval < 2000) {
        _beatTimes.add(interval.toDouble());
        
        // Keep only recent beat times
        if (_beatTimes.length > 10) {
          _beatTimes.removeAt(0);
        }
      }
    }
    
    _lastBeatTime = now;
  }

  void _updateBPM() {
    if (_beatTimes.length < 3) return;
    
    // Calculate average interval
    _averageInterval = _beatTimes.reduce((a, b) => a + b) / _beatTimes.length;
    
    // Convert to BPM
    final calculatedBPM = (60000 / _averageInterval).round();
    
    // Apply BPM doubling rule for low BPM values
    var adjustedBPM = calculatedBPM;
    if (calculatedBPM <= _bpmDoublingThreshold) {
      adjustedBPM = calculatedBPM * 2;
    }
    
    // Apply BPM range constraints
    final constrainedBPM = adjustedBPM.clamp(_minBPM.round(), _maxBPM.round());
    
    // Smooth BPM changes
    if (_currentBPM == 0) {
      _currentBPM = constrainedBPM;
    } else {
      _currentBPM = ((_currentBPM * 0.7) + (constrainedBPM * 0.3)).round();
    }
    
    // Emit BPM update
    _bpmController.add(_currentBPM);
  }

  void dispose() {
    _analysisTimer?.cancel();
    _bpmController.close();
  }
} 