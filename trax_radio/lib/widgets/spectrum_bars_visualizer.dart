import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:math' as math;
import 'dart:async';

class SpectrumBarsVisualizer extends StatefulWidget {
  final AudioPlayer audioPlayer;
  final double height;
  final double width;
  final bool enableBeatDetection;
  final bool enableGlow;

  const SpectrumBarsVisualizer({
    super.key,
    required this.audioPlayer,
    required this.height,
    required this.width,
    this.enableBeatDetection = true,
    this.enableGlow = true,
  });

  @override
  State<SpectrumBarsVisualizer> createState() => _SpectrumBarsVisualizerState();
}

class _SpectrumBarsVisualizerState extends State<SpectrumBarsVisualizer>
    with TickerProviderStateMixin {
  late List<double> _barHeights;
  Timer? _timer;
  bool _isPlaying = false;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _barHeights = List.filled(12, 0.1); // 12 bars for compact design
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    
    _startVisualization();
  }

  @override
  void didUpdateWidget(SpectrumBarsVisualizer oldWidget) {
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
      for (int i = 0; i < _barHeights.length; i++) {
        if (_barHeights[i] > 0.1) {
          _barHeights[i] = math.max(0.1, _barHeights[i] - 0.05);
        }
      }
    } else {
      // Generate realistic spectrum data
      for (int i = 0; i < _barHeights.length; i++) {
        // Create different patterns for different frequency ranges
        double baseHeight;
        if (i < 3) {
          // Bass frequencies (low)
          baseHeight = 0.2 + 0.4 * math.sin(DateTime.now().millisecondsSinceEpoch * 0.001 + i * 0.5);
        } else if (i < 8) {
          // Mid frequencies (medium)
          baseHeight = 0.3 + 0.5 * math.sin(DateTime.now().millisecondsSinceEpoch * 0.002 + i * 0.3);
        } else {
          // High frequencies (high)
          baseHeight = 0.1 + 0.3 * math.sin(DateTime.now().millisecondsSinceEpoch * 0.003 + i * 0.2);
        }

        // Add beat detection
        double beatFactor = widget.enableBeatDetection ? 
            (0.2 * math.sin(DateTime.now().millisecondsSinceEpoch * 0.008)) : 0.0;

        // Add some randomness
        double randomFactor = 0.1 * math.sin(DateTime.now().millisecondsSinceEpoch * 0.005 + i * 0.7);

        _barHeights[i] = math.max(0.1, math.min(1.0, baseHeight + beatFactor + randomFactor));
      }
    }

    setState(() {});
  }

  Color _getBarColor(int index, double height) {
    // Orange gradient based on frequency range and height
    if (index < 3) {
      // Bass - Orange to Red
      return Color.lerp(Colors.orange, Colors.red, height)!;
    } else if (index < 8) {
      // Mid - Orange to Yellow
      return Color.lerp(Colors.orange, Colors.yellow, height)!;
    } else {
      // High - Yellow to Green
      return Color.lerp(Colors.yellow, Colors.green, height)!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final barWidth = (widget.width / _barHeights.length) * 0.7; // 70% of available space per bar
    
    return SizedBox(
      height: widget.height,
      width: widget.width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(_barHeights.length, (index) {
          final barHeight = _barHeights[index];
          
          return SizedBox(
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
                    borderRadius: BorderRadius.circular(barWidth * 0.2),
                    boxShadow: widget.enableGlow ? [
                      BoxShadow(
                        color: _getBarColor(index, barHeight).withOpacity(0.4),
                        blurRadius: 3,
                        spreadRadius: 0.5,
                      ),
                    ] : null,
                  ),
                ),
                // Small gap at bottom
                SizedBox(height: 1),
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
    _animationController.dispose();
    super.dispose();
  }
} 