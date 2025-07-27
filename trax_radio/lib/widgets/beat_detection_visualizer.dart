import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:async';
import 'dart:math' as math;

class BeatDetectionVisualizer extends StatefulWidget {
  final AudioPlayer audioPlayer;
  final double height;
  final double width;
  final int barCount;
  final bool enableBeatDetection;

  const BeatDetectionVisualizer({
    super.key,
    required this.audioPlayer,
    required this.height,
    required this.width,
    this.barCount = 32,
    this.enableBeatDetection = true,
  });

  @override
  State<BeatDetectionVisualizer> createState() => _BeatDetectionVisualizerState();
}

class _BeatDetectionVisualizerState extends State<BeatDetectionVisualizer> with TickerProviderStateMixin {
  List<double> _barHeights = [];
  List<AnimationController> _controllers = [];
  List<Animation<double>> _animations = [];
  List<Animation<double>> _beatAnimations = [];
  Timer? _updateTimer;
  Timer? _beatTimer;
  bool _isPlaying = false;
  double _currentVolume = 0.0;
  double _peakVolume = 0.0;
  List<double> _frequencyData = [];
  List<double> _beatIntensities = [];
  StreamSubscription? _volumeSubscription;
  StreamSubscription? _playingSubscription;
  
  // Beat detection variables
  double _bpm = 128.0; // Default BPM (typical for electronic music)
  double _beatInterval = 0.0;
  DateTime _lastBeat = DateTime.now();
  List<double> _volumeHistory = [];
  double _volumeThreshold = 0.3;
  int _beatCounter = 0;
  bool _isBeat = false;

  @override
  void initState() {
    super.initState();
    _initializeBars();
    _setupAudioListeners();
    _startUpdateTimer();
    _startBeatDetection();
  }

  void _initializeBars() {
    _barHeights = List.filled(widget.barCount, 0.0);
    _frequencyData = List.filled(widget.barCount, 0.0);
    _beatIntensities = List.filled(widget.barCount, 0.0);
    
    _controllers = List.generate(widget.barCount, (index) {
      return AnimationController(
        duration: Duration(milliseconds: 200 + (index * 30)),
        vsync: this,
      );
    });
    
    _animations = _controllers.map((controller) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeOutCubic),
      );
    }).toList();
    
    _beatAnimations = _controllers.map((controller) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: controller, curve: Curves.elasticOut),
      );
    }).toList();
  }

  void _setupAudioListeners() {
    // Listen to playing state
    _playingSubscription = widget.audioPlayer.playingStream.listen((playing) {
      setState(() {
        _isPlaying = playing;
      });
      if (!playing) {
        _resetBars();
      }
    });

    // Listen to volume changes
    _volumeSubscription = widget.audioPlayer.volumeStream.listen((volume) {
      setState(() {
        _currentVolume = volume;
        _peakVolume = math.max(_peakVolume, volume);
      });
    });

    // Get initial volume
    _currentVolume = widget.audioPlayer.volume;
  }

  void _startUpdateTimer() {
    _updateTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (_isPlaying && widget.enableBeatDetection) {
        _updateBarHeights();
        _detectBeats();
      }
    });
  }

  void _startBeatDetection() {
    _beatTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (_isPlaying) {
        _analyzeVolumeForBeats();
      }
    });
  }

  void _analyzeVolumeForBeats() {
    // Add current volume to history
    _volumeHistory.add(_currentVolume);
    if (_volumeHistory.length > 20) {
      _volumeHistory.removeAt(0);
    }

    // Calculate volume change rate
    if (_volumeHistory.length >= 3) {
      double recentAvg = _volumeHistory.skip(_volumeHistory.length - 3).reduce((a, b) => a + b) / 3;
      double previousAvg = _volumeHistory.take(_volumeHistory.length - 3).reduce((a, b) => a + b) / (_volumeHistory.length - 3);
      double volumeChange = recentAvg - previousAvg;

      // Detect sudden volume increases (potential beats)
      if (volumeChange > _volumeThreshold && !_isBeat) {
        _triggerBeat();
      }
    }

    // Auto-adjust BPM based on detected beats
    _adjustBPM();
  }

  void _triggerBeat() {
    setState(() {
      _isBeat = true;
      _beatCounter++;
      _lastBeat = DateTime.now();
    });

    // Trigger beat animations
    for (int i = 0; i < widget.barCount; i++) {
      _beatIntensities[i] = 1.0;
      _controllers[i].animateTo(1.0, duration: Duration(milliseconds: 150));
    }

    // Reset beat flag after animation
    Timer(const Duration(milliseconds: 200), () {
      if (mounted) {
        setState(() {
          _isBeat = false;
        });
      }
    });
  }

  void _adjustBPM() {
    // Simple BPM detection based on beat intervals
    if (_beatCounter > 4) {
      DateTime now = DateTime.now();
      double interval = now.difference(_lastBeat).inMilliseconds / 1000.0;
      
      if (interval > 0.5 && interval < 2.0) {
        double newBPM = 60.0 / interval;
        _bpm = (_bpm * 0.9) + (newBPM * 0.1); // Smooth BPM changes
        _beatInterval = 60.0 / _bpm;
      }
    }
  }

  void _detectBeats() {
    // Create frequency patterns that respond to beats
    final random = math.Random();
    final time = DateTime.now().millisecondsSinceEpoch / 1000.0;
    final beatPhase = (time * _bpm / 60.0) % 4.0; // 4-beat cycle
    
    setState(() {
      for (int i = 0; i < widget.barCount; i++) {
        // Base frequency calculation
        double frequency = 0.0;
        
        // Bass frequencies (bars 0-2) - strong on beats
        if (i < 3) {
          frequency = _currentVolume * (0.4 + 0.4 * math.sin(beatPhase * math.pi));
          if (_isBeat) frequency *= 1.5; // Amplify on beats
        }
        // Mid frequencies (bars 3-8) - moderate beat response
        else if (i < 9) {
          frequency = _currentVolume * (0.3 + 0.5 * math.sin(time * 1.2 + i * 0.7));
          if (_isBeat) frequency *= 1.3;
        }
        // High frequencies (bars 9-11) - subtle beat response
        else {
          frequency = _currentVolume * (0.2 + 0.6 * math.sin(time * 2.0 + i * 1.2));
          if (_isBeat) frequency *= 1.1;
        }
        
        // Add beat-driven variations
        double beatInfluence = _beatIntensities[i] * 0.3;
        frequency += beatInfluence;
        
        // Add some randomness for natural feel
        frequency += random.nextDouble() * 0.2;
        
        // Clamp frequency to reasonable range
        frequency = frequency.clamp(0.0, 1.0);
        
        // Smooth transition to new height
        final targetHeight = frequency;
        _frequencyData[i] = targetHeight;
        _barHeights[i] += (targetHeight - _barHeights[i]) * 0.4;
        
        // Decay beat intensity
        _beatIntensities[i] *= 0.95;
        
        // Animate the bar
        _controllers[i].animateTo(_barHeights[i]);
      }
    });
  }

  void _updateBarHeights() {
    // This method is now primarily handled by _detectBeats()
    // Keeping for compatibility
  }

  void _resetBars() {
    setState(() {
      _barHeights = List.filled(widget.barCount, 0.0);
      _frequencyData = List.filled(widget.barCount, 0.0);
      _beatIntensities = List.filled(widget.barCount, 0.0);
      _volumeHistory.clear();
      _beatCounter = 0;
      _isBeat = false;
    });
    for (var controller in _controllers) {
      controller.animateTo(0.0);
    }
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    _beatTimer?.cancel();
    _volumeSubscription?.cancel();
    _playingSubscription?.cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = [
      Colors.redAccent, Colors.orangeAccent, Colors.yellowAccent,
      Colors.greenAccent, Colors.blueAccent, Colors.purpleAccent,
      Colors.pinkAccent, Colors.cyanAccent, Colors.lightGreenAccent,
      Colors.deepOrangeAccent, Colors.indigoAccent, Colors.tealAccent,
    ];

    return Column(
      children: [
        // BPM Display (optional)
        if (widget.enableBeatDetection)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'BPM: ${_bpm.toStringAsFixed(0)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        
        // Main Visualizer
        SizedBox(
          height: widget.height,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.barCount, (i) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3.0),
                child: AnimatedBuilder(
                  animation: _animations[i],
                  builder: (context, child) {
                    final barHeight = 6.0 + (widget.height - 12.0) * _animations[i].value;
                    final isActive = _isPlaying && _barHeights[i] > 0.1;
                    final isBeatActive = _beatIntensities[i] > 0.1;
                    
                    return Container(
                      width: widget.width / widget.barCount,
                      height: barHeight,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            colors[i % colors.length].withOpacity(0.8),
                            colors[i % colors.length],
                            colors[(i + 1) % colors.length],
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: isActive ? [
                          BoxShadow(
                            color: colors[i % colors.length].withOpacity(
                              isBeatActive ? 1.0 : 0.8,
                            ),
                            blurRadius: isBeatActive ? 20 : 12,
                            spreadRadius: isBeatActive ? 4 : 2,
                          ),
                        ] : null,
                      ),
                    );
                  },
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

// Beat detection utilities
class BeatDetectionUtils {
  static double detectBPM(List<double> volumeHistory) {
    if (volumeHistory.length < 10) return 128.0;
    
    // Simple peak detection
    List<int> peaks = [];
    for (int i = 1; i < volumeHistory.length - 1; i++) {
      if (volumeHistory[i] > volumeHistory[i - 1] && 
          volumeHistory[i] > volumeHistory[i + 1] &&
          volumeHistory[i] > 0.5) {
        peaks.add(i);
      }
    }
    
    if (peaks.length < 2) return 128.0;
    
    // Calculate intervals between peaks
    List<double> intervals = [];
    for (int i = 1; i < peaks.length; i++) {
      intervals.add((peaks[i] - peaks[i - 1]) * 0.1); // 100ms intervals
    }
    
    // Calculate average interval and convert to BPM
    double avgInterval = intervals.reduce((a, b) => a + b) / intervals.length;
    return 60.0 / avgInterval;
  }
  
  static bool isBeat(double currentVolume, List<double> volumeHistory, double threshold) {
    if (volumeHistory.length < 3) return false;
    
    double recentAvg = volumeHistory.skip(volumeHistory.length - 3).reduce((a, b) => a + b) / 3;
    double previousAvg = volumeHistory.take(volumeHistory.length - 3).reduce((a, b) => a + b) / (volumeHistory.length - 3);
    
    return (recentAvg - previousAvg) > threshold;
  }
} 