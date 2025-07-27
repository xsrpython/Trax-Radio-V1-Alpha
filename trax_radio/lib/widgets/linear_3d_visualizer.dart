import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:async';
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
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;
  List<double> _barHeights = [];
  List<double> _beatIntensities = [];
  List<double> _barScales = [];
  
  Timer? _updateTimer;
  StreamSubscription? _playingSubscription;
  StreamSubscription? _processingStateSubscription;
  
  bool _isPlaying = false;
  bool _isProcessing = false;
  bool _isBeat = false;
  
  // Audio analysis variables
  List<double> _frequencyData = [];
  final List<double> _volumeHistory = [];
  double _currentVolume = 0.0;
  double _lastBeatTime = 0.0;
  double _averageVolume = 0.0;
  
  final List<Color> _colors = [
    Colors.redAccent, Colors.orangeAccent, Colors.yellowAccent,
    Colors.greenAccent, Colors.blueAccent, Colors.purpleAccent,
    Colors.pinkAccent, Colors.cyanAccent, Colors.lightGreenAccent,
    Colors.deepOrangeAccent, Colors.indigoAccent, Colors.tealAccent,
    Colors.amber, Colors.lime, Colors.deepPurple, Colors.blueGrey,
  ];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _setupAudioListeners();
  }

  void _initializeControllers() {
    _controllers = List.generate(
      widget.barCount,
      (i) => AnimationController(
        duration: const Duration(milliseconds: 150),
        vsync: this,
      ),
    );
    
    _animations = _controllers.map((controller) => 
      Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeOut)
      )
    ).toList();
    
    _barHeights = List.filled(widget.barCount, 0.0);
    _beatIntensities = List.filled(widget.barCount, 0.0);
    _barScales = List.filled(widget.barCount, 1.0);
    _frequencyData = List.filled(widget.barCount, 0.0);
  }

  void _setupAudioListeners() {
    // Listen to playing state
    _playingSubscription = widget.audioPlayer.playingStream.listen((playing) {
      if (mounted) {
        setState(() {
          _isPlaying = playing;
        });
        
        if (playing) {
          _startVisualization();
        } else {
          _stopVisualization();
          _resetBars();
        }
      }
    });

    // Listen to processing state for better audio detection
    _processingStateSubscription = widget.audioPlayer.processingStateStream.listen((state) {
      if (mounted) {
        setState(() {
          _isProcessing = state == ProcessingState.ready || 
                         state == ProcessingState.completed;
        });
      }
    });
  }

  void _startVisualization() {
    _updateTimer?.cancel();
    _updateTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) { // 60 FPS for smoother animation
      if (mounted && _isPlaying) {
        _updateBars();
        if (widget.enableBeatDetection) {
          _analyzeAudioForBeats();
        }
      }
    });
  }

  void _stopVisualization() {
    _updateTimer?.cancel();
  }

  void _updateBars() {
    if (!_isPlaying || !_isProcessing) {
      _resetBars();
      return;
    }

    final time = DateTime.now().millisecondsSinceEpoch / 1000.0;
    final random = math.Random();
    final position = widget.audioPlayer.position.inMilliseconds / 1000.0;
    final volume = widget.audioPlayer.volume;
    
    setState(() {
      for (int i = 0; i < widget.barCount; i++) {
        // Generate more responsive frequency data based on audio position and volume
        double frequency = 0.0;
        
        // Bass frequencies (left side) - More prominent for beats
        if (i < widget.barCount ~/ 4) {
          frequency = 0.4 + 0.5 * math.sin(position * 0.5 + i * 0.2);
          frequency += random.nextDouble() * 0.3 * volume;
        }
        // Mid frequencies (center) - Balanced response
        else if (i < (widget.barCount * 3) ~/ 4) {
          frequency = 0.3 + 0.6 * math.sin(position * 0.8 + i * 0.4);
          frequency += random.nextDouble() * 0.25 * volume;
        }
        // High frequencies (right side) - More dynamic
        else {
          frequency = 0.2 + 0.7 * math.sin(position * 1.2 + i * 0.6);
          frequency += random.nextDouble() * 0.2 * volume;
        }
        
        // Apply beat influence when beat is detected
        if (_isBeat) {
          // Bass frequencies get more beat influence
          if (i < widget.barCount ~/ 4) {
            frequency *= 3.0;
          } else if (i < (widget.barCount * 3) ~/ 4) {
            frequency *= 2.5;
          } else {
            frequency *= 2.0;
          }
        }
        
        // Add beat intensity influence
        frequency += _beatIntensities[i] * 0.8;
        
        // Clamp frequency to valid range
        frequency = frequency.clamp(0.0, 1.0);
        
        // More responsive bar height updates
        _barHeights[i] += (frequency - _barHeights[i]) * 0.6;
        
        // Update bar scale based on beat intensity
        _barScales[i] = 1.0 + (_beatIntensities[i] * 1.2);
        
        // Slower decay for more visible beat effects
        _beatIntensities[i] *= 0.95;
        
        // Animate the bar
        _controllers[i].animateTo(_barHeights[i]);
      }
    });
  }

  void _analyzeAudioForBeats() {
    // Calculate current average volume from bar heights
    final currentVolume = _barHeights.reduce((a, b) => a + b) / _barHeights.length;
    
    _volumeHistory.add(currentVolume);
    if (_volumeHistory.length > 30) { // Increased history for better detection
      _volumeHistory.removeAt(0);
    }
    
    // Calculate average volume
    if (_volumeHistory.length >= 15) {
      _averageVolume = _volumeHistory.reduce((a, b) => a + b) / _volumeHistory.length;
    }
    
    final time = DateTime.now().millisecondsSinceEpoch / 1000.0;
    final position = widget.audioPlayer.position.inMilliseconds / 1000.0;
    
    // Beat detection logic - more sensitive
    if (_volumeHistory.length >= 8) {
      final recentVolumes = _volumeHistory.skip(_volumeHistory.length - 8).toList();
      final volumeChange = currentVolume - recentVolumes.first;
      final volumeThreshold = _averageVolume * 0.2; // Lower threshold for more sensitivity
      
      // Detect sudden volume increases (beats)
      if (volumeChange > volumeThreshold && 
          currentVolume > _averageVolume * 1.1 && // Lower threshold
          time - _lastBeatTime > 0.15) { // Shorter minimum time between beats
        
        _triggerBeat();
        _lastBeatTime = time;
      }
      
      // Detect bass-heavy beats (stronger in low frequencies)
      final bassVolume = _barHeights.take(widget.barCount ~/ 4)
          .reduce((a, b) => a + b) / (widget.barCount ~/ 4);
      
      if (bassVolume > _averageVolume * 1.3 && // Lower threshold
          time - _lastBeatTime > 0.1) { // Even shorter for bass
        _triggerBeat();
        _lastBeatTime = time;
      }
      
      // Detect rhythmic patterns based on position
      final beatPattern = (position * 2) % 1.0; // 120 BPM pattern
      if (beatPattern < 0.1 && time - _lastBeatTime > 0.2) {
        _triggerBeat();
        _lastBeatTime = time;
      }
    }
  }

  void _triggerBeat() {
    setState(() {
      _isBeat = true;
      
      // Distribute beat intensity across bars
      for (int i = 0; i < widget.barCount; i++) {
        final distance = (i - widget.barCount / 2).abs() / (widget.barCount / 2);
        final intensity = (1.0 - distance) * 1.0;
        
        // Bass frequencies get more beat influence
        if (i < widget.barCount ~/ 4) {
          _beatIntensities[i] = math.max(_beatIntensities[i], intensity * 1.5);
        } else {
          _beatIntensities[i] = math.max(_beatIntensities[i], intensity);
        }
        
        // Add immediate height boost
        _barHeights[i] = math.min(1.0, _barHeights[i] + 0.3);
      }
    });
    
    // Reset beat flag
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        setState(() {
          _isBeat = false;
        });
      }
    });
  }

  void _resetBars() {
    setState(() {
      _barHeights = List.filled(widget.barCount, 0.0);
      _beatIntensities = List.filled(widget.barCount, 0.0);
      _barScales = List.filled(widget.barCount, 1.0);
      _frequencyData = List.filled(widget.barCount, 0.0);
      _volumeHistory.clear();
      _isBeat = false;
    });
    for (var controller in _controllers) {
      controller.animateTo(0.0);
    }
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    _playingSubscription?.cancel();
    _processingStateSubscription?.cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            Colors.black.withValues(alpha: 0.9),
            Colors.black.withValues(alpha: 0.7),
            Colors.black.withValues(alpha: 0.9),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Static background grid
            if (widget.enable3DEffects)
              CustomPaint(
                size: Size(widget.width, widget.height),
                painter: LinearGridPainter(rotationAngle: 0.0),
              ),
            
            // Animated Bars
            Center(
              child: SizedBox(
                width: widget.width * 0.9,
                height: widget.height * 0.9,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final availableWidth = constraints.maxWidth;
                    final maxBarWidth = 6.0; // Reduced from 8.0
                    final minBarWidth = 2.0; // Reduced from 4.0
                    final barSpacing = 2.0; // Reduced from 4.0
                    
                    // Calculate if we need to reduce bar count or spacing
                    final totalBarWidth = widget.barCount * maxBarWidth + (widget.barCount - 1) * barSpacing;
                    
                    if (totalBarWidth > availableWidth) {
                      // Calculate how many bars we can fit
                      final maxBars = ((availableWidth + barSpacing) / (maxBarWidth + barSpacing)).floor();
                      final actualBarCount = maxBars.clamp(10, widget.barCount); // Minimum 10 bars
                      
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(actualBarCount, (i) {
                          final isActive = _isPlaying && _barHeights[i] > 0.1;
                          final isBeatActive = _beatIntensities[i] > 0.1;
                          final color = _colors[i % _colors.length];
                          
                          return AnimatedBuilder(
                            animation: _animations[i],
                            builder: (context, child) {
                              final barHeight = 4.0 + (_barHeights[i] * (widget.height * 0.6));
                              final barWidth = (maxBarWidth * _barScales[i]).clamp(minBarWidth, maxBarWidth);
                              
                              return Padding(
                                padding: EdgeInsets.only(
                                  right: i < actualBarCount - 1 ? barSpacing : 0,
                                ),
                                child: Container(
                                  width: barWidth,
                                  height: barHeight,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        color.withValues(alpha: 0.6),
                                        color,
                                        color.withValues(alpha: 0.8),
                                      ],
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                    ),
                                    borderRadius: BorderRadius.circular(4),
                                    boxShadow: isActive ? [
                                      BoxShadow(
                                        color: color.withValues(
                                          alpha: isBeatActive ? 0.8 : 0.5,
                                        ),
                                        blurRadius: isBeatActive ? 12 : 6,
                                        spreadRadius: isBeatActive ? 2 : 1,
                                      ),
                                    ] : null,
                                  ),
                                ),
                              );
                            },
                          );
                        }),
                      );
                    } else {
                      // Use original bar count with calculated spacing
                      final actualSpacing = (availableWidth - widget.barCount * maxBarWidth) / (widget.barCount - 1).clamp(1.0, barSpacing);
                      
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(widget.barCount, (i) {
                          final isActive = _isPlaying && _barHeights[i] > 0.1;
                          final isBeatActive = _beatIntensities[i] > 0.1;
                          final color = _colors[i % _colors.length];
                          
                          return AnimatedBuilder(
                            animation: _animations[i],
                            builder: (context, child) {
                              final barHeight = 4.0 + (_barHeights[i] * (widget.height * 0.6));
                              final barWidth = (maxBarWidth * _barScales[i]).clamp(minBarWidth, maxBarWidth);
                              
                              return Padding(
                                padding: EdgeInsets.only(
                                  right: i < widget.barCount - 1 ? actualSpacing : 0,
                                ),
                                child: Container(
                                  width: barWidth,
                                  height: barHeight,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        color.withValues(alpha: 0.6),
                                        color,
                                        color.withValues(alpha: 0.8),
                                      ],
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                    ),
                                    borderRadius: BorderRadius.circular(4),
                                    boxShadow: isActive ? [
                                      BoxShadow(
                                        color: color.withValues(
                                          alpha: isBeatActive ? 0.8 : 0.5,
                                        ),
                                        blurRadius: isBeatActive ? 12 : 6,
                                        spreadRadius: isBeatActive ? 2 : 1,
                                      ),
                                    ] : null,
                                  ),
                                ),
                              );
                            },
                          );
                        }),
                      );
                    }
                  },
                ),
              ),
            ),
            
            // Beat indicator overlay
            if (_isBeat && widget.enableBeatDetection)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: RadialGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.1),
                        Colors.transparent,
                      ],
                      center: Alignment.center,
                      radius: 0.8,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class LinearGridPainter extends CustomPainter {
  final double rotationAngle;

  LinearGridPainter({required this.rotationAngle});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // Draw horizontal grid lines
    for (int i = 0; i <= 10; i++) {
      final y = (size.height / 10) * i;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Draw vertical grid lines
    for (int i = 0; i <= 20; i++) {
      final x = (size.width / 20) * i;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
} 