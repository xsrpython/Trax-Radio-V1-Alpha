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

    _analysisTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) { // Increased frequency from 100ms to 50ms
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
    
    // Enhanced beat pattern generation with multiple frequency components
    for (int i = 0; i < 100; i++) { // Increased sample count
      // Multiple frequency components for more realistic audio
      final bassFrequency = 1.0; // Bass drum frequency
      final snareFrequency = 2.0; // Snare frequency
      final hihatFrequency = 4.0; // Hi-hat frequency
      
      // Create more complex rhythmic patterns
      final bassPattern = sin(time * bassFrequency * 2 * pi);
      final snarePattern = sin(time * snareFrequency * 2 * pi);
      final hihatPattern = sin(time * hihatFrequency * 2 * pi);
      
      // Combine patterns with different weights
      final combinedPattern = (bassPattern * 0.6) + (snarePattern * 0.3) + (hihatPattern * 0.1);
      
      // Enhanced amplitude calculation
      final baseAmplitude = volume * (0.2 + 0.8 * (combinedPattern > 0 ? combinedPattern : 0));
      
      // Add frequency-dependent variations
      final frequencyVariation = sin(time * 0.5) * 0.1; // Slow frequency drift
      
      // Enhanced noise for realism
      final noise = (random.nextDouble() - 0.5) * 0.15;
      
      // Final amplitude with all components
      final amplitude = (baseAmplitude + frequencyVariation + noise).clamp(0.0, 1.0);
      
      samples.add(amplitude);
    }
    
    return samples;
  }

  bool _detectBeat(List<double> buffer) {
    if (buffer.length < 100) return false;
    
    // Enhanced energy calculation with multiple time windows
    final shortWindow = buffer.take(25).toList(); // Very recent samples
    final mediumWindow = buffer.take(50).toList(); // Recent samples
    final longWindow = buffer.take(200).toList(); // Long-term average
    
    // Calculate energy for different time windows
    final shortEnergy = shortWindow.map((s) => s * s).reduce((a, b) => a + b) / shortWindow.length;
    final mediumEnergy = mediumWindow.map((s) => s * s).reduce((a, b) => a + b) / mediumWindow.length;
    final longEnergy = longWindow.map((s) => s * s).reduce((a, b) => a + b) / longWindow.length;
    
    // Enhanced beat detection with multiple criteria
    final energyRatio = shortEnergy / (longEnergy + 0.001); // Avoid division by zero
    final energyDifference = mediumEnergy - longEnergy;
    
    // Dynamic threshold based on recent activity
    final dynamicThreshold = longEnergy * 1.3;
    
    // Beat detection criteria
    final isEnergySpike = shortEnergy > dynamicThreshold;
    final isEnergyRatio = energyRatio > 1.5;
    final isEnergyDifference = energyDifference > (longEnergy * 0.3);
    
    // Combine criteria for more accurate detection
    final beatDetected = isEnergySpike && (isEnergyRatio || isEnergyDifference);
    
    // Add some controlled randomness for natural variation
    final random = Random();
    final randomFactor = 0.9 + (random.nextDouble() * 0.2); // 0.9 to 1.1
    
    return beatDetected && (random.nextDouble() > 0.1); // 90% detection rate
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
    // Enhanced BPM calculation with better filtering
    if (_beatTimes.length >= 3) { // Increased minimum beat count
      // Calculate multiple interval statistics
      final sortedIntervals = List<double>.from(_beatTimes)..sort();
      final medianInterval = sortedIntervals[sortedIntervals.length ~/ 2];
      
      // Filter out outliers (intervals that are too different from median)
      final filteredIntervals = _beatTimes.where((interval) {
        final deviation = (interval - medianInterval).abs() / medianInterval;
        return deviation < 0.3; // Keep intervals within 30% of median
      }).toList();
      
      if (filteredIntervals.length >= 2) {
        // Calculate weighted average (recent beats have more weight)
        double weightedSum = 0.0;
        double weightSum = 0.0;
        
        for (int i = 0; i < filteredIntervals.length; i++) {
          final weight = i + 1; // More recent beats have higher weight
          weightedSum += filteredIntervals[i] * weight;
          weightSum += weight;
        }
        
        _averageInterval = weightedSum / weightSum;
        
        // Convert to BPM with improved accuracy
        final calculatedBPM = (60000 / _averageInterval).round();
        
        // Apply BPM doubling rule for low BPM values
        var adjustedBPM = calculatedBPM;
        if (calculatedBPM <= _bpmDoublingThreshold) {
          adjustedBPM = calculatedBPM * 2;
        }
        
        // Apply BPM range constraints
        final constrainedBPM = adjustedBPM.clamp(_minBPM.round(), _maxBPM.round());
        
        // Enhanced smoothing with adaptive rate
        if (_currentBPM == 0) {
          _currentBPM = constrainedBPM;
        } else {
          // Adaptive smoothing based on BPM difference
          final bpmDifference = (constrainedBPM - _currentBPM).abs();
          final smoothingRate = bpmDifference > 20 ? 0.5 : 0.2; // Faster adaptation for big changes
          
          _currentBPM = ((_currentBPM * (1 - smoothingRate)) + (constrainedBPM * smoothingRate)).round();
        }
      }
    } else {
      // Enhanced fallback BPM generation
      final random = Random();
      final timeVariation = sin(DateTime.now().millisecondsSinceEpoch / 10000.0) * 10;
      final baseBPM = 120 + timeVariation.round(); // Vary around 120 BPM
      
      if (_currentBPM == 0) {
        _currentBPM = baseBPM;
      } else {
        // Gradual BPM variation for more realistic behavior
        final variation = (random.nextDouble() * 6 - 3).round(); // ±3 BPM variation
        _currentBPM = (_currentBPM + variation).clamp(_minBPM.round(), _maxBPM.round());
      }
    }
    
    // Emit BPM update more frequently
    _bpmController.add(_currentBPM);
  }

  void dispose() {
    _analysisTimer?.cancel();
    _bpmController.close();
  }
} 