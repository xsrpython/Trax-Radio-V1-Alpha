import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:async';
import 'dart:math' as math;

class AudioVisualizer extends StatefulWidget {
  final AudioPlayer audioPlayer;
  final double height;
  final double barWidth;
  final int barCount;
  
  const AudioVisualizer({
    Key? key,
    required this.audioPlayer,
    this.height = 40,
    this.barWidth = 6,
    this.barCount = 12,
  }) : super(key: key);

  @override
  State<AudioVisualizer> createState() => _AudioVisualizerState();
}

class _AudioVisualizerState extends State<AudioVisualizer> with TickerProviderStateMixin {
  List<double> _barHeights = [];
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
    _barHeights = List.filled(widget.barCount, 0.0);
    _controllers = List.generate(widget.barCount, (index) {
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
        _updateBarHeights();
      }
    });
  }

  void _updateBarHeights() {
    // Simulate audio frequency data based on current playback
    // In a real implementation, you'd get this from audio analysis
    final random = math.Random();
    final baseVolume = 0.3 + (random.nextDouble() * 0.7); // Simulate varying volume
    
    setState(() {
      for (int i = 0; i < widget.barCount; i++) {
        // Create a more realistic frequency response pattern
        double frequency = 0.0;
        
        // Bass frequencies (bars 0-2)
        if (i < 3) {
          frequency = baseVolume * (0.5 + random.nextDouble() * 0.5);
        }
        // Mid frequencies (bars 3-8)
        else if (i < 9) {
          frequency = baseVolume * (0.3 + random.nextDouble() * 0.7);
        }
        // High frequencies (bars 9-11)
        else {
          frequency = baseVolume * (0.1 + random.nextDouble() * 0.9);
        }
        
        // Add some variation based on bar position
        frequency *= (0.7 + (0.3 * math.sin(i * 0.5)));
        
        // Smooth transition to new height
        final targetHeight = frequency;
        _barHeights[i] += (targetHeight - _barHeights[i]) * 0.3;
        
        // Animate the bar
        _controllers[i].animateTo(_barHeights[i]);
      }
    });
  }

  void _resetBars() {
    setState(() {
      _barHeights = List.filled(widget.barCount, 0.0);
    });
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
        children: List.generate(widget.barCount, (i) {
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
                        colors[i % colors.length],
                        colors[(i + 1) % colors.length],
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: _isPlaying ? [
                      BoxShadow(
                        color: colors[i % colors.length].withOpacity(0.6),
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

// Fallback visualizer for when audio player is not available
class FallbackVisualizer extends StatefulWidget {
  final bool isActive;
  final double height;
  final double barWidth;
  
  const FallbackVisualizer({
    Key? key,
    required this.isActive,
    this.height = 40,
    this.barWidth = 6,
  }) : super(key: key);

  @override
  State<FallbackVisualizer> createState() => _FallbackVisualizerState();
}

class _FallbackVisualizerState extends State<FallbackVisualizer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.5, end: 1.0).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didUpdateWidget(covariant FallbackVisualizer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive) {
      _controller.repeat(reverse: true);
    } else {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
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
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(12, (i) {
              final barHeight = 24.0 + 40.0 * (_animation.value * (0.5 + (i % 3) / 3));
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3.0),
                child: Container(
                  width: widget.barWidth,
                  height: widget.isActive ? barHeight : 24.0,
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
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }
} 