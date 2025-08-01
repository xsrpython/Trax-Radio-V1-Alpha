import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:math' as math;
import 'dart:async';

class EqualizerVisualizer extends StatefulWidget {
  final AudioPlayer audioPlayer;
  final double height;
  final double width;
  final int barCount;
  final bool enableBeatDetection;
  final bool enable3DEffects;

  const EqualizerVisualizer({
    super.key,
    required this.audioPlayer,
    required this.height,
    required this.width,
    this.barCount = 20,
    this.enableBeatDetection = true,
    this.enable3DEffects = true,
  });

  @override
  State<EqualizerVisualizer> createState() => _EqualizerVisualizerState();
}

class _EqualizerVisualizerState extends State<EqualizerVisualizer>
    with TickerProviderStateMixin {
  late List<double> _barHeights;
  late List<AnimationController> _animationControllers;
  late List<Animation<double>> _animations;
  Timer? _timer;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _barHeights = List.filled(widget.barCount, 0.1);
    _animationControllers = List.generate(
      widget.barCount,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 200),
        vsync: this,
      ),
    );
    _animations = _animationControllers
        .map((controller) => Tween<double>(begin: 0.1, end: 1.0).animate(
              CurvedAnimation(parent: controller, curve: Curves.easeOut),
            ))
        .toList();

    _startVisualization();
  }

  @override
  void didUpdateWidget(EqualizerVisualizer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.audioPlayer != widget.audioPlayer) {
      _startVisualization();
    }
  }

  void _startVisualization() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (mounted) {
        _updateBars();
      }
    });
  }

  void _updateBars() {
    final playing = widget.audioPlayer.playing;
    if (playing != _isPlaying) {
      setState(() {
        _isPlaying = playing;
      });
    }

    if (!_isPlaying) {
      // Gradually reduce bar heights when not playing
      for (int i = 0; i < widget.barCount; i++) {
        if (_barHeights[i] > 0.1) {
          _barHeights[i] = math.max(0.1, _barHeights[i] - 0.05);
        }
      }
    } else {
      // Generate realistic equalizer data
      for (int i = 0; i < widget.barCount; i++) {
        // Simulate different frequency ranges
        double baseHeight;
        if (i < 3) {
          // Bass frequencies (low)
          baseHeight = 0.3 + 0.4 * math.sin(DateTime.now().millisecondsSinceEpoch * 0.001 + i * 0.5);
        } else if (i < 8) {
          // Mid frequencies (medium)
          baseHeight = 0.4 + 0.5 * math.sin(DateTime.now().millisecondsSinceEpoch * 0.002 + i * 0.3);
        } else if (i < 15) {
          // High frequencies (high)
          baseHeight = 0.2 + 0.6 * math.sin(DateTime.now().millisecondsSinceEpoch * 0.003 + i * 0.2);
        } else {
          // Very high frequencies (variable)
          baseHeight = 0.1 + 0.3 * math.sin(DateTime.now().millisecondsSinceEpoch * 0.004 + i * 0.1);
        }

        // Add some randomness and beat detection
        double randomFactor = 0.1 * math.sin(DateTime.now().millisecondsSinceEpoch * 0.005 + i * 0.7);
        double beatFactor = widget.enableBeatDetection ? 
            (0.2 * math.sin(DateTime.now().millisecondsSinceEpoch * 0.008)) : 0.0;

        _barHeights[i] = math.max(0.1, math.min(1.0, baseHeight + randomFactor + beatFactor));
      }
    }

    setState(() {});
  }

  Color _getBarColor(int index, double height) {
    // Color gradient based on frequency range and height
    if (index < 3) {
      // Bass - Red to Orange
      return Color.lerp(Colors.red, Colors.orange, height)!;
    } else if (index < 8) {
      // Mid - Orange to Yellow
      return Color.lerp(Colors.orange, Colors.yellow, height)!;
    } else if (index < 15) {
      // High - Yellow to Green
      return Color.lerp(Colors.yellow, Colors.green, height)!;
    } else {
      // Very High - Green to Blue
      return Color.lerp(Colors.green, Colors.blue, height)!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      width: widget.width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(widget.barCount, (index) {
          final barHeight = _barHeights[index];
          final barWidth = (widget.width / widget.barCount) * 0.8;
          
          return Container(
            width: barWidth,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Main bar
                Container(
                  height: widget.height * barHeight,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        _getBarColor(index, barHeight),
                        _getBarColor(index, barHeight).withOpacity(0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(barWidth * 0.3),
                    boxShadow: widget.enable3DEffects ? [
                      BoxShadow(
                        color: _getBarColor(index, barHeight).withOpacity(0.5),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ] : null,
                  ),
                ),
                // Small gap at bottom
                SizedBox(height: 2),
              ],
            ),
          );
        }),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _animationControllers) {
      controller.dispose();
    }
    super.dispose();
  }
} 