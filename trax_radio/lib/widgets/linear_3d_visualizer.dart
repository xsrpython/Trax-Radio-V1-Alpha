import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:async';
import 'dart:math';
import 'dart:math' as math;

class Linear3DVisualizer extends StatefulWidget {
  final AudioPlayer audioPlayer;
  final double height;
  final double width;
  final int barCount;
  final bool enableBeatDetection;
  final bool enable3DEffects;

  const Linear3DVisualizer({
    super.key,
    required this.audioPlayer,
    required this.height,
    required this.width,
    this.barCount = 32,
    this.enableBeatDetection = true,
    this.enable3DEffects = true,
  });

  @override
  State<Linear3DVisualizer> createState() => _Linear3DVisualizerState();
}

class _Linear3DVisualizerState extends State<Linear3DVisualizer>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  
  Timer? _updateTimer;
  StreamSubscription? _playingSubscription;
  bool _isPlaying = false;
  
  // Simplified bar heights for better performance
  List<double> _barHeights = [];
  final Random _random = Random();

  final List<Color> _colors = [
    Colors.red,    // Bass
    Colors.red,
    Colors.red,
    Colors.red,
    Colors.orange, // Mid
    Colors.orange,
    Colors.orange,
    Colors.orange,
    Colors.yellow, // High
    Colors.yellow,
    Colors.yellow,
    Colors.yellow,
  ];

  @override
  void initState() {
    super.initState();
    _initializeVisualizer();
    _setupAudioListeners();
  }

  void _initializeVisualizer() {
    // Initialize bar heights
    _barHeights = List.generate(widget.barCount, (i) => 0.1);
    
    // Simple pulse animation
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  void _setupAudioListeners() {
    _playingSubscription = widget.audioPlayer.playingStream.listen((playing) {
      setState(() {
        _isPlaying = playing;
      });
      
      if (playing) {
        _startVisualization();
      } else {
        _stopVisualization();
      }
    });
  }

  void _startVisualization() {
    _updateTimer?.cancel();
    _updateTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (mounted && _isPlaying) {
        _updateBars();
      }
    });
  }

  void _stopVisualization() {
    _updateTimer?.cancel();
    setState(() {
      _barHeights = List.generate(widget.barCount, (i) => 0.1);
    });
  }

  void _updateBars() {
    if (!mounted) return;
    
    setState(() {
      for (int i = 0; i < widget.barCount; i++) {
        // Generate realistic bar heights based on frequency ranges
        double baseHeight;
        if (i < widget.barCount * 0.4) {
          // Bass frequencies - more variation
          baseHeight = 0.3 + (_random.nextDouble() * 0.7);
        } else if (i < widget.barCount * 0.8) {
          // Mid frequencies - medium variation
          baseHeight = 0.2 + (_random.nextDouble() * 0.6);
        } else {
          // High frequencies - less variation
          baseHeight = 0.1 + (_random.nextDouble() * 0.4);
        }
        
        _barHeights[i] = baseHeight;
      }
    });
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    _playingSubscription?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(widget.barCount, (i) {
            final color = _colors[i % _colors.length];
            final height = _barHeights[i] * widget.height * 0.8;
            
            return AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              width: 4,
              height: height.clamp(4, widget.height * 0.8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color.withOpacity(0.6),
                    color,
                    color.withOpacity(0.8),
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
                borderRadius: BorderRadius.circular(2),
                boxShadow: _isPlaying && height > 10
                    ? [
                        BoxShadow(
                          color: color.withOpacity(0.5),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
            );
          }),
        ),
      ),
    );
  }
}

