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
    Key? key,
    required this.audioPlayer,
    required this.height,
    required this.width,
    this.barCount = 32,
    this.enableBeatDetection = true,
    this.enable3DEffects = true,
  }) : super(key: key);

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
  Timer? _beatTimer;
  StreamSubscription? _volumeSubscription;
  StreamSubscription? _playingSubscription;
  
  double _currentVolume = 0.0;
  bool _isPlaying = false;
  bool _isBeat = false;
  List<double> _volumeHistory = [];
  
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
    _startVisualization();
    _setupAudioListener();
  }

  void _initializeControllers() {
    _controllers = List.generate(
      widget.barCount,
      (i) => AnimationController(
        duration: const Duration(milliseconds: 200),
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
  }

  void _startVisualization() {
    _updateTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (mounted) {
        _updateBars();
      }
    });

    if (widget.enableBeatDetection) {
      _beatTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
        if (mounted) {
          _analyzeVolumeForBeats();
        }
      });
    }
  }

  void _setupAudioListener() {
    _volumeSubscription = widget.audioPlayer.volumeStream.listen((volume) {
      if (mounted) {
        setState(() {
          _currentVolume = volume;
        });
      }
    });

    _playingSubscription = widget.audioPlayer.playingStream.listen((playing) {
      if (mounted) {
        setState(() {
          _isPlaying = playing;
        });
        if (!playing) {
          _resetBars();
        }
      }
    });
  }

  void _updateBars() {
    final random = math.Random();
    final time = DateTime.now().millisecondsSinceEpoch / 1000.0;
    
    setState(() {
      for (int i = 0; i < widget.barCount; i++) {
        // Calculate frequency based on position and audio
        double frequency = 0.0;
        
        // Bass frequencies (left side) - More prominent
        if (i < widget.barCount ~/ 4) {
          frequency = _currentVolume * (0.5 + 0.6 * math.sin(time * 1.2 + i * 0.4));
        }
        // Mid frequencies (center) - Enhanced
        else if (i < (widget.barCount * 3) ~/ 4) {
          frequency = _currentVolume * (0.4 + 0.7 * math.sin(time * 1.6 + i * 0.6));
        }
        // High frequencies (right side) - More responsive
        else {
          frequency = _currentVolume * (0.3 + 0.8 * math.sin(time * 2.0 + i * 0.8));
        }
        
        // Enhanced beat influence - Much more prominent
        if (_isBeat) {
          frequency *= 2.5; // Increased from 1.5 to 2.5
        }
        
        // Enhanced beat intensity - More dramatic
        frequency += _beatIntensities[i] * 0.8; // Increased from 0.3 to 0.8
        
        // Add randomness for natural feel
        frequency += random.nextDouble() * 0.2; // Increased randomness
        frequency = frequency.clamp(0.0, 1.0);
        
        // Update bar properties with faster response
        _barHeights[i] += (frequency - _barHeights[i]) * 0.6; // Increased from 0.3 to 0.6
        _barScales[i] = 1.0 + (_beatIntensities[i] * 1.2); // Increased from 0.5 to 1.2
        
        // Slower decay for more sustained beat effect
        _beatIntensities[i] *= 0.98; // Increased from 0.95 to 0.98
        
        // Animate the bar
        _controllers[i].animateTo(_barHeights[i]);
      }
    });
  }

  void _analyzeVolumeForBeats() {
    _volumeHistory.add(_currentVolume);
    if (_volumeHistory.length > 15) { // Reduced history for faster response
      _volumeHistory.removeAt(0);
    }
    
    if (_volumeHistory.length >= 8) { // Reduced threshold for faster detection
      final recentVolumes = _volumeHistory.skip(_volumeHistory.length - 8).toList();
      final averageVolume = recentVolumes.reduce((a, b) => a + b) / recentVolumes.length;
      final currentVolume = _currentVolume;
      
      // Enhanced beat detection logic - More sensitive
      if (currentVolume > averageVolume * 1.3 && currentVolume > 0.05) { // Reduced thresholds
        _triggerBeat();
      }
      
      // Additional beat detection for sudden volume spikes
      if (_volumeHistory.length >= 3) {
        final lastVolume = _volumeHistory[_volumeHistory.length - 2];
        if (currentVolume > lastVolume * 1.4 && currentVolume > 0.08) {
          _triggerBeat();
        }
      }
    }
  }

  void _triggerBeat() {
    setState(() {
      _isBeat = true;
      
      // Enhanced beat distribution - More dramatic effect
      for (int i = 0; i < widget.barCount; i++) {
        final distance = (i - widget.barCount / 2).abs() / (widget.barCount / 2);
        // Increased intensity and added wave pattern
        final intensity = (1.0 - distance) * 1.2 + 0.3 * math.sin(i * 0.5);
        _beatIntensities[i] = math.max(_beatIntensities[i], intensity);
        
        // Add immediate height boost for dramatic effect
        _barHeights[i] = math.min(1.0, _barHeights[i] + 0.4);
      }
    });
    
    // Reset beat flag after a longer delay for more sustained effect
    Future.delayed(const Duration(milliseconds: 300), () {
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
            
            // Static Horizontal Bars
            Center(
              child: SizedBox(
                width: widget.width * 0.9,
                height: widget.height * 0.9,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(widget.barCount, (i) {
                    final isActive = _isPlaying && _barHeights[i] > 0.1;
                    final isBeatActive = _beatIntensities[i] > 0.1;
                    final color = _colors[i % _colors.length];
                    
                    return AnimatedBuilder(
                      animation: _animations[i],
                      builder: (context, child) {
                        final barHeight = 4.0 + (_barHeights[i] * (widget.height * 0.6));
                        final barWidth = 8.0 * _barScales[i];
                        
                        return Container(
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
                        );
                      },
                    );
                  }),
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
    
    final center = Offset(size.width / 2, size.height / 2);
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotationAngle * math.pi / 180);
    canvas.translate(-center.dx, -center.dy);
    
    // Draw horizontal lines
    for (int i = 0; i <= 10; i++) {
      final y = (size.height / 10) * i;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    
    // Draw vertical lines
    for (int i = 0; i <= 10; i++) {
      final x = (size.width / 10) * i;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    
    canvas.restore();
  }
  
  @override
  bool shouldRepaint(LinearGridPainter oldDelegate) {
    return oldDelegate.rotationAngle != rotationAngle;
  }
} 