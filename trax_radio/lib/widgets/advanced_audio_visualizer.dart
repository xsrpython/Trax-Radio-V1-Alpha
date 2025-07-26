import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:async';
import 'dart:math' as math;

class AdvancedAudioVisualizer extends StatefulWidget {
  final AudioPlayer audioPlayer;
  final double height;
  final double barWidth;
  final int barCount;
  final bool enableRealTimeAnalysis;
  
  const AdvancedAudioVisualizer({
    Key? key,
    required this.audioPlayer,
    this.height = 40,
    this.barWidth = 6,
    this.barCount = 12,
    this.enableRealTimeAnalysis = true,
  }) : super(key: key);

  @override
  State<AdvancedAudioVisualizer> createState() => _AdvancedAudioVisualizerState();
}

class _AdvancedAudioVisualizerState extends State<AdvancedAudioVisualizer> with TickerProviderStateMixin {
  List<double> _barHeights = [];
  List<AnimationController> _controllers = [];
  List<Animation<double>> _animations = [];
  Timer? _updateTimer;
  bool _isPlaying = false;
  double _currentVolume = 0.0;
  double _peakVolume = 0.0;
  List<double> _frequencyData = [];
  StreamSubscription? _volumeSubscription;
  StreamSubscription? _playingSubscription;

  @override
  void initState() {
    super.initState();
    _initializeBars();
    _setupAudioListeners();
    _startUpdateTimer();
  }

  void _initializeBars() {
    _barHeights = List.filled(widget.barCount, 0.0);
    _frequencyData = List.filled(widget.barCount, 0.0);
    _controllers = List.generate(widget.barCount, (index) {
      return AnimationController(
        duration: Duration(milliseconds: 150 + (index * 30)),
        vsync: this,
      );
    });
    _animations = _controllers.map((controller) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeOutCubic),
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

    // Listen to volume changes (if available)
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
      if (_isPlaying && widget.enableRealTimeAnalysis) {
        _updateBarHeights();
      }
    });
  }

  void _updateBarHeights() {
    // Create realistic frequency response based on audio characteristics
    final random = math.Random();
    final baseVolume = _currentVolume;
    final time = DateTime.now().millisecondsSinceEpoch / 1000.0;
    
    setState(() {
      for (int i = 0; i < widget.barCount; i++) {
        // Create frequency-specific patterns
        double frequency = 0.0;
        
        // Bass frequencies (bars 0-2) - lower, more stable
        if (i < 3) {
          frequency = baseVolume * (0.4 + 0.3 * math.sin(time * 0.5 + i));
          frequency += random.nextDouble() * 0.2;
        }
        // Mid frequencies (bars 3-8) - more dynamic
        else if (i < 9) {
          frequency = baseVolume * (0.3 + 0.5 * math.sin(time * 1.2 + i * 0.7));
          frequency += random.nextDouble() * 0.4;
        }
        // High frequencies (bars 9-11) - most dynamic
        else {
          frequency = baseVolume * (0.2 + 0.6 * math.sin(time * 2.0 + i * 1.2));
          frequency += random.nextDouble() * 0.6;
        }
        
        // Add some musical patterns
        frequency *= (0.6 + 0.4 * math.sin(time * 0.3 + i * 0.2));
        
        // Clamp frequency to reasonable range
        frequency = frequency.clamp(0.0, 1.0);
        
        // Smooth transition to new height
        final targetHeight = frequency;
        _frequencyData[i] = targetHeight;
        _barHeights[i] += (targetHeight - _barHeights[i]) * 0.4;
        
        // Animate the bar with some delay for wave effect
        _controllers[i].animateTo(_barHeights[i]);
      }
    });
  }

  void _resetBars() {
    setState(() {
      _barHeights = List.filled(widget.barCount, 0.0);
      _frequencyData = List.filled(widget.barCount, 0.0);
    });
    for (var controller in _controllers) {
      controller.animateTo(0.0);
    }
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
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

    return SizedBox(
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
                
                return Container(
                  width: widget.barWidth,
                  height: isActive ? barHeight : 6.0,
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
                        color: colors[i % colors.length].withOpacity(0.8),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ] : null,
                  ),
                );
              },
            ),
          );
        }),
      ),
    );
  }
}

// Simple visualizer for when advanced features aren't needed
class SimpleAudioVisualizer extends StatefulWidget {
  final AudioPlayer audioPlayer;
  final double height;
  final double barWidth;
  
  const SimpleAudioVisualizer({
    Key? key,
    required this.audioPlayer,
    this.height = 40,
    this.barWidth = 6,
  }) : super(key: key);

  @override
  State<SimpleAudioVisualizer> createState() => _SimpleAudioVisualizerState();
}

class _SimpleAudioVisualizerState extends State<SimpleAudioVisualizer> with TickerProviderStateMixin {
  List<AnimationController> _controllers = [];
  List<Animation<double>> _animations = [];
  Timer? _updateTimer;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _initializeBars();
    _setupAudioListener();
    _startUpdateTimer();
  }

  void _initializeBars() {
    _controllers = List.generate(12, (index) {
      return AnimationController(
        duration: Duration(milliseconds: 200 + (index * 50)),
        vsync: this,
      );
    });
    _animations = _controllers.map((controller) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeOutCubic),
      );
    }).toList();
  }

  void _setupAudioListener() {
    widget.audioPlayer.playingStream.listen((playing) {
      setState(() {
        _isPlaying = playing;
      });
      if (!playing) {
        _resetBars();
      }
    });
  }

  void _startUpdateTimer() {
    _updateTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (_isPlaying) {
        _updateBars();
      }
    });
  }

  void _updateBars() {
    final random = math.Random();
    for (int i = 0; i < 12; i++) {
      final targetValue = random.nextDouble();
      _controllers[i].animateTo(targetValue);
    }
  }

  void _resetBars() {
    for (var controller in _controllers) {
      controller.animateTo(0.0);
    }
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
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

    return SizedBox(
      height: widget.height,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(12, (i) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3.0),
            child: AnimatedBuilder(
              animation: _animations[i],
              builder: (context, child) {
                final barHeight = 8.0 + (widget.height - 16.0) * _animations[i].value;
                return Container(
                  width: widget.barWidth,
                  height: _isPlaying ? barHeight : 8.0,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colors[i],
                        colors[(i + 1) % colors.length],
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: _isPlaying ? [
                      BoxShadow(
                        color: colors[i].withOpacity(0.6),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ] : null,
                  ),
                );
              },
            ),
          );
        }),
      ),
    );
  }
} 