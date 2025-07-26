import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:async';
import 'dart:math' as math;

class ThreeDAudioVisualizer extends StatefulWidget {
  final AudioPlayer audioPlayer;
  final double height;
  final double width;
  final int barCount;
  final bool enableBeatDetection;
  final bool enable3DEffects;

  const ThreeDAudioVisualizer({
    super.key,
    required this.audioPlayer,
    required this.height,
    required this.width,
    this.barCount = 32,
    this.enableBeatDetection = true,
    this.enable3DEffects = true,
  });

  @override
  State<ThreeDAudioVisualizer> createState() => _ThreeDAudioVisualizerState();
}

class _ThreeDAudioVisualizerState extends State<ThreeDAudioVisualizer> with TickerProviderStateMixin {
  List<double> _barHeights = [];
  List<double> _barDepths = [];
  List<AnimationController> _controllers = [];
  List<Animation<double>> _animations = [];
  List<Animation<double>> _rotationAnimations = [];
  Timer? _updateTimer;
  Timer? _beatTimer;
  bool _isPlaying = false;
  double _currentVolume = 0.0;
  double _peakVolume = 0.0;
  List<double> _frequencyData = [];
  List<double> _beatIntensities = [];
  StreamSubscription? _volumeSubscription;
  StreamSubscription? _playingSubscription;
  
  // 3D effect variables
  double _rotationAngle = 0.0;
  double _perspectiveDepth = 0.0;
  List<double> _barRotations = [];
  List<double> _barScales = [];
  
  // Beat detection variables
  double _bpm = 128.0;
  DateTime _lastBeat = DateTime.now();
  List<double> _volumeHistory = [];
  double _volumeThreshold = 0.3;
  int _beatCounter = 0;
  bool _isBeat = false;

  @override
  void initState() {
    super.initState();
    _initialize3DBars();
    _setupAudioListeners();
    _startUpdateTimer();
    _startBeatDetection();
  }

  void _initialize3DBars() {
    _barHeights = List.filled(widget.barCount, 0.0);
    _barDepths = List.filled(widget.barCount, 0.0);
    _frequencyData = List.filled(widget.barCount, 0.0);
    _beatIntensities = List.filled(widget.barCount, 0.0);
    _barRotations = List.filled(widget.barCount, 0.0);
    _barScales = List.filled(widget.barCount, 1.0);
    
    _controllers = List.generate(widget.barCount, (index) {
      return AnimationController(
        duration: Duration(milliseconds: 300 + (index * 50)),
        vsync: this,
      );
    });
    
    _animations = _controllers.map((controller) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeOutCubic),
      );
    }).toList();
    
    _rotationAnimations = _controllers.map((controller) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: controller, curve: Curves.elasticOut),
      );
    }).toList();
  }

  void _setupAudioListeners() {
    _playingSubscription = widget.audioPlayer.playingStream.listen((playing) {
      setState(() {
        _isPlaying = playing;
      });
      if (!playing) {
        _resetBars();
      }
    });

    _volumeSubscription = widget.audioPlayer.volumeStream.listen((volume) {
      setState(() {
        _currentVolume = volume;
        _peakVolume = math.max(_peakVolume, volume);
      });
    });

    _currentVolume = widget.audioPlayer.volume;
  }

  void _startUpdateTimer() {
    _updateTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (_isPlaying) {
        _update3DBars();
        _update3DEffects();
      }
    });
  }

  void _startBeatDetection() {
    _beatTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (_isPlaying && widget.enableBeatDetection) {
        _analyzeVolumeForBeats();
      }
    });
  }

  void _analyzeVolumeForBeats() {
    _volumeHistory.add(_currentVolume);
    if (_volumeHistory.length > 20) {
      _volumeHistory.removeAt(0);
    }

    if (_volumeHistory.length >= 3) {
      double recentAvg = _volumeHistory.skip(_volumeHistory.length - 3).reduce((a, b) => a + b) / 3;
      double previousAvg = _volumeHistory.take(_volumeHistory.length - 3).reduce((a, b) => a + b) / (_volumeHistory.length - 3);
      double volumeChange = recentAvg - previousAvg;

      if (volumeChange > _volumeThreshold && !_isBeat) {
        _triggerBeat();
      }
    }

    _adjustBPM();
  }

  void _triggerBeat() {
    setState(() {
      _isBeat = true;
      _beatCounter++;
      _lastBeat = DateTime.now();
    });

    for (int i = 0; i < widget.barCount; i++) {
      _beatIntensities[i] = 1.0;
      _barScales[i] = 1.2 + (math.Random().nextDouble() * 0.3);
      _controllers[i].animateTo(1.0, duration: Duration(milliseconds: 200));
    }

    Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _isBeat = false;
        });
      }
    });
  }

  void _adjustBPM() {
    if (_beatCounter > 4) {
      DateTime now = DateTime.now();
      double interval = now.difference(_lastBeat).inMilliseconds / 1000.0;
      
      if (interval > 0.5 && interval < 2.0) {
        double newBPM = 60.0 / interval;
        _bpm = (_bpm * 0.9) + (newBPM * 0.1);
      }
    }
  }

  void _update3DBars() {
    final random = math.Random();
    final time = DateTime.now().millisecondsSinceEpoch / 1000.0;
    final beatPhase = (time * _bpm / 60.0) % 4.0;
    
    setState(() {
      for (int i = 0; i < widget.barCount; i++) {
        // Calculate 3D position
        double angle = (i / widget.barCount) * 2 * math.pi;
        double radius = 80.0 + (_currentVolume * 40.0);
        
        // Base frequency calculation with 3D variation
        double frequency = 0.0;
        
        // Create spiral effect
        double spiralOffset = (time * 0.5 + i * 0.3) % (2 * math.pi);
        double spiralRadius = radius * (0.8 + 0.2 * math.sin(spiralOffset));
        
        // Bass frequencies (inner bars)
        if (i < widget.barCount ~/ 3) {
          frequency = _currentVolume * (0.4 + 0.4 * math.sin(beatPhase * math.pi + i * 0.5));
          if (_isBeat) frequency *= 1.8;
        }
        // Mid frequencies (middle bars)
        else if (i < (widget.barCount * 2) ~/ 3) {
          frequency = _currentVolume * (0.3 + 0.5 * math.sin(time * 1.2 + i * 0.7));
          if (_isBeat) frequency *= 1.4;
        }
        // High frequencies (outer bars)
        else {
          frequency = _currentVolume * (0.2 + 0.6 * math.sin(time * 2.0 + i * 1.2));
          if (_isBeat) frequency *= 1.2;
        }
        
        // Simple depth for clean effect
        _barDepths[i] = 0.5 + (_beatIntensities[i] * 0.3);
        
        // Add beat influence
        double beatInfluence = _beatIntensities[i] * 0.4;
        frequency += beatInfluence;
        
        // Add randomness for natural feel
        frequency += random.nextDouble() * 0.2;
        frequency = frequency.clamp(0.0, 1.0);
        
        // Update bar properties
        _frequencyData[i] = frequency;
        _barHeights[i] += (frequency - _barHeights[i]) * 0.3;
        
        // 3D rotation effects
        _barRotations[i] = (time * 30 + i * 15) % 360;
        
        // Decay beat intensity
        _beatIntensities[i] *= 0.92;
        _barScales[i] += (1.0 - _barScales[i]) * 0.1;
        
        // Animate the bar
        _controllers[i].animateTo(_barHeights[i]);
      }
    });
  }

  void _update3DEffects() {
    if (widget.enable3DEffects) {
      setState(() {
        _rotationAngle += 0.8; // Slightly faster rotation for better visual effect
      });
    }
  }

  void _resetBars() {
    setState(() {
      _barHeights = List.filled(widget.barCount, 0.0);
      _barDepths = List.filled(widget.barCount, 0.0);
      _frequencyData = List.filled(widget.barCount, 0.0);
      _beatIntensities = List.filled(widget.barCount, 0.0);
      _barRotations = List.filled(widget.barCount, 0.0);
      _barScales = List.filled(widget.barCount, 1.0);
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
      Colors.amber, Colors.lime, Colors.deepPurple, Colors.blueGrey,
    ];

    return Column(
      children: [
        // BPM Display
        if (widget.enableBeatDetection)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.8),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white24, width: 1),
            ),
            child: Text(
              'BPM: ${_bpm.toStringAsFixed(0)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
        
        // 3D Visualizer Container
        Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: RadialGradient(
              colors: [
                Colors.black.withOpacity(0.9),
                Colors.black.withOpacity(0.7),
                Colors.black.withOpacity(0.5),
              ],
              center: Alignment.center,
              radius: 1.0,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                // Background grid effect
                if (widget.enable3DEffects)
                  CustomPaint(
                    size: Size(widget.width, widget.height),
                    painter: GridPainter(
                      rotationAngle: _rotationAngle,
                      perspectiveDepth: _perspectiveDepth,
                    ),
                  ),
                
                // Spinning Color Bars
                Center(
                  child: Transform.rotate(
                    angle: _rotationAngle * math.pi / 180,
                    child: SizedBox(
                      width: widget.width * 0.6, // Smaller container to prevent cropping
                      height: widget.height * 0.6,
                      child: Stack(
                        children: List.generate(widget.barCount, (i) {
                          final angle = (i / widget.barCount) * 2 * math.pi;
                          final radius = 40.0 + (_currentVolume * 20.0); // Smaller radius
                          final x = math.cos(angle) * radius;
                          final y = math.sin(angle) * radius;
                          final isActive = _isPlaying && _barHeights[i] > 0.1;
                          final isBeatActive = _beatIntensities[i] > 0.1;
                          
                          return Positioned(
                            left: (widget.width * 0.3) + x - 6, // Adjusted positioning
                            top: (widget.height * 0.3) + y - 6,
                            child: AnimatedBuilder(
                              animation: _animations[i],
                              builder: (context, child) {
                                final barHeight = 6.0 + (_barHeights[i] * 40.0); // Smaller bars
                                final barWidth = 12.0 * _barScales[i];
                                
                                return Transform(
                                  transform: Matrix4.identity()
                                    ..rotateZ(_barRotations[i] * math.pi / 180), // Simple rotation only
                                  alignment: Alignment.center,
                                  child: Container(
                                    width: barWidth,
                                    height: barHeight,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          colors[i % colors.length].withOpacity(0.8),
                                          colors[i % colors.length],
                                          colors[(i + 1) % colors.length].withOpacity(0.8),
                                        ],
                                        begin: Alignment.bottomCenter,
                                        end: Alignment.topCenter,
                                      ),
                                      borderRadius: BorderRadius.circular(3),
                                      boxShadow: isActive ? [
                                        BoxShadow(
                                          color: colors[i % colors.length].withOpacity(
                                            isBeatActive ? 0.9 : 0.6,
                                          ),
                                          blurRadius: isBeatActive ? 15 : 8,
                                          spreadRadius: isBeatActive ? 3 : 1,
                                        ),
                                      ] : null,
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// Custom painter for 3D grid effect
class GridPainter extends CustomPainter {
  final double rotationAngle;
  final double perspectiveDepth;
  
  GridPainter({
    required this.rotationAngle,
    required this.perspectiveDepth,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    
    final center = Offset(size.width / 2, size.height / 2);
    
    // Draw perspective grid
    for (int i = 0; i < 10; i++) {
      final offset = i * 20.0;
      
      // Horizontal lines
      canvas.drawLine(
        Offset(0, center.dy - 100 + offset),
        Offset(size.width, center.dy - 100 + offset),
        paint,
      );
      
      // Vertical lines
      canvas.drawLine(
        Offset(center.dx - 100 + offset, 0),
        Offset(center.dx - 100 + offset, size.height),
        paint,
      );
    }
    
    // Draw rotating center point
    final centerPaint = Paint()
      ..color = Colors.cyanAccent.withOpacity(0.6)
      ..style = PaintingStyle.fill;
    
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotationAngle * math.pi / 180);
    canvas.drawCircle(Offset.zero, 3, centerPaint);
    canvas.restore();
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Simplified 3D visualizer for performance
class Simple3DVisualizer extends StatefulWidget {
  final AudioPlayer audioPlayer;
  final double height;
  final double width;
  
  const Simple3DVisualizer({
    super.key,
    required this.audioPlayer,
    this.height = 150,
    this.width = 250,
  });

  @override
  State<Simple3DVisualizer> createState() => _Simple3DVisualizerState();
}

class _Simple3DVisualizerState extends State<Simple3DVisualizer> with TickerProviderStateMixin {
  List<AnimationController> _controllers = [];
  List<Animation<double>> _animations = [];
  Timer? _updateTimer;
  bool _isPlaying = false;
  double _rotationAngle = 0.0;

  @override
  void initState() {
    super.initState();
    _initializeBars();
    _setupAudioListener();
    _startUpdateTimer();
  }

  void _initializeBars() {
    _controllers = List.generate(8, (index) {
      return AnimationController(
        duration: Duration(milliseconds: 400 + (index * 100)),
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
    for (int i = 0; i < 8; i++) {
      final targetValue = random.nextDouble();
      _controllers[i].animateTo(targetValue);
    }
    
    setState(() {
      _rotationAngle += 2.0;
    });
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
      Colors.pinkAccent, Colors.cyanAccent,
    ];

    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: RadialGradient(
          colors: [
            Colors.black.withOpacity(0.8),
            Colors.black.withOpacity(0.6),
          ],
        ),
      ),
      child: Center(
        child: Transform.rotate(
          angle: _rotationAngle * math.pi / 180,
          child: SizedBox(
            width: widget.width * 0.6,
            height: widget.height * 0.6,
            child: Stack(
              children: List.generate(8, (i) {
                final angle = (i / 8) * 2 * math.pi;
                final radius = 40.0;
                final x = math.cos(angle) * radius;
                final y = math.sin(angle) * radius;
                
                return Positioned(
                  left: (widget.width * 0.3) + x - 10,
                  top: (widget.height * 0.3) + y - 10,
                  child: AnimatedBuilder(
                    animation: _animations[i],
                    builder: (context, child) {
                      final barHeight = 20.0 + (_animations[i].value * 40.0);
                      
                      return Container(
                        width: 20,
                        height: _isPlaying ? barHeight : 20,
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
          ),
        ),
      ),
    );
  }
} 