import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:async';
import 'dart:math' as math;
import '../bpm_service.dart';

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

  // Global pulse animation for BPM sync
  late AnimationController _globalPulseController;
  late Animation<double> _globalPulseAnimation;
  StreamSubscription<int>? _bpmSubscription;
  int _currentBPM = 0;
  Timer? _bpmPulseTimer;

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
  double _averageVolume = 0.0;

  final List<Color> _colors = [
    Colors.red, // Bass (lower frequencies)
    Colors.red,
    Colors.red,
    Colors.red,
    Colors.red,
    Colors.red,
    Colors.orange, // Mid frequencies
    Colors.orange,
    Colors.orange,
    Colors.orange,
    Colors.orange,
    Colors.orange,
    Colors.yellow, // High frequencies
    Colors.yellow,
    Colors.yellow,
    Colors.yellow,
  ];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeGlobalPulse();
    _setupAudioListeners();
    _setupBPMSubscription();
    // Start BPM analysis
    BMPService().startAnalysis(widget.audioPlayer);
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

  void _initializeGlobalPulse() {
    _globalPulseController = AnimationController(
      duration: const Duration(milliseconds: 500), // Fixed 500ms duration
      vsync: this,
    );
    _globalPulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate( // Simple scale
      CurvedAnimation(parent: _globalPulseController, curve: Curves.easeInOut),
    );
    // Simple repeating pulse
    _globalPulseController.repeat(reverse: true);
  }

  void _setupAudioListeners() {
    // Real audio analysis for visualizer - increased frequency to match BPM service
    _updateTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) { // Increased from 100ms to 50ms
      if (mounted) {
        _analyzeAudio();
      }
    });

    // Listen to playing state
    _playingSubscription = widget.audioPlayer.playingStream.listen((playing) {
      setState(() {
        _isPlaying = playing;
        if (!playing) {
          // Reset bars when not playing
          for (int i = 0; i < widget.barCount; i++) {
            _barHeights[i] = 0.0;
            _beatIntensities[i] = 0.0;
            _barScales[i] = 1.0;
          }
          // Stop pulse animation when not playing
          _globalPulseController.stop();
          _isBeat = false;
        } else {
          // Start pulse animation when playing
          _globalPulseController.repeat(reverse: true);
        }
      });
    });

    // Listen to processing state
    _processingStateSubscription = widget.audioPlayer.processingStateStream.listen((state) {
      setState(() {
        _isProcessing = state == ProcessingState.loading || state == ProcessingState.buffering;
      });
    });

    // Listen to volume changes
    widget.audioPlayer.volumeStream.listen((volume) {
      _currentVolume = volume;
    });
  }

  void _analyzeAudio() {
    if (!mounted) return;

    setState(() {
      final now = DateTime.now().millisecondsSinceEpoch;
      
      if (_isPlaying) {
        // Enhanced audio analysis with BPM integration
        final bpm = _currentBPM > 0 ? _currentBPM : 120; // Fallback to 120 BPM
        final beatInterval = 60000 / bpm; // Beat interval in milliseconds
        final beatPhase = (now % beatInterval) / beatInterval; // Current position in beat cycle
        
        // Create dynamic patterns based on BPM and beat detection
        for (int i = 0; i < widget.barCount; i++) {
          // Time-based animation with BPM synchronization
          final time = now / 1000.0; // Convert to seconds
          final frequency = (i + 1) * 0.3; // Different frequency for each bar
          final phase = (time * frequency) % (math.pi * 2);
          
          // Create wave-like patterns with BPM influence
          final wave1 = math.sin(phase);
          final wave2 = math.sin(phase * 0.5);
          final wave3 = math.cos(phase * 0.3);
          
          // BPM-synchronized wave for beat emphasis
          final bpmWave = math.sin(beatPhase * math.pi * 2);
          
          // Combine waves with BPM influence
          final combinedWave = (wave1 + wave2 + wave3 + (bpmWave * 0.3)) / 3.3;
          
          // Enhanced randomness with beat influence
          final randomFactor = 0.7 + (math.Random().nextDouble() * 0.6);
          final beatInfluence = _isBeat ? 1.3 : 1.0; // Amplify during beat detection
          
          // Calculate bar height with beat influence - limit initial expansion
          final baseHeight = (combinedWave * 0.5 + 0.5) * randomFactor * beatInfluence;
          _barHeights[i] = baseHeight.clamp(0.1, 0.6); // Further reduced max height from 0.8 to 0.6
          
          // Enhanced beat detection with frequency-based sensitivity
          final beatThreshold = i < widget.barCount * 0.375 ? 0.6 : 0.7; // Increased thresholds (was 0.5 and 0.6)
          _beatIntensities[i] = _barHeights[i] > beatThreshold ? _barHeights[i] : 0.0;
          
          // Dynamic bar scaling based on frequency and beat - limit scaling
          final frequencyScale = i < widget.barCount * 0.375 ? 1.05 : 1.0; // Further reduced from 1.1
          _barScales[i] = (0.8 + (_barHeights[i] * 0.2)) * frequencyScale; // Further reduced multiplier from 0.3 to 0.2
          
          // Trigger animation with beat-synchronized timing
          if (_isBeat && beatPhase < 0.1) { // Trigger at start of beat
            _controllers[i].forward(from: 0.0);
          } else {
            _controllers[i].forward(from: 0.0);
          }
        }
        
        // Enhanced global beat detection with BPM consideration - more conservative
        final averageHeight = _barHeights.reduce((a, b) => a + b) / _barHeights.length;
        final beatIntensity = _beatIntensities.reduce((a, b) => a + b) / _beatIntensities.length;
        
        // More conservative beat detection to reduce excessive pulsing
        _isBeat = averageHeight > 0.6 && beatIntensity > 0.4; // Increased thresholds (was 0.5 and 0.3)
        
      } else {
        // When not playing, create very subtle idle animation or static bars
        for (int i = 0; i < widget.barCount; i++) {
          // Static bars with minimal height when not playing
          _barHeights[i] = 0.05; // Very low static height
          _beatIntensities[i] = 0.0;
          _barScales[i] = 1.0;
          
          // No animation when not playing
          // _controllers[i].forward(from: 0.0); // Commented out - no animation
        }
        _isBeat = false;
      }
    });
  }

  void _setupBPMSubscription() {
    // Simple BPM subscription - just for BPM display, not for pulse control
    _bpmSubscription = BMPService().bpmStream.listen((bpm) {
      if (mounted) {
        setState(() {
          _currentBPM = bpm > 0 ? bpm : 0;
        });
      }
    });
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    _playingSubscription?.cancel();
    _processingStateSubscription?.cancel();
    _bpmSubscription?.cancel();
    _bpmPulseTimer?.cancel();
    // Stop BPM analysis
    BMPService().stopAnalysis();
    _globalPulseController.dispose();
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _globalPulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _globalPulseAnimation.value,
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.9),
                  Colors.black.withOpacity(0.7),
                  Colors.black.withOpacity(0.9),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Stack(
                  children: [
                    // Animated Bars
                    Center(
                      child: SizedBox(
                        width: widget.width * 0.95,
                        height: widget.height * 0.9,
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final availableWidth = constraints.maxWidth;
                            final maxBarWidth = 8.0;
                            final minBarWidth = 4.0;
                            final barSpacing = 2.0;

                            final maxBars = ((availableWidth + barSpacing) / (maxBarWidth + barSpacing)).floor();
                            final actualBarCount = maxBars.clamp(12, widget.barCount);

                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: List.generate(actualBarCount, (i) {
                                final isActive = _isPlaying && _barHeights[i] > 0.1;
                                final isBeatActive = _beatIntensities[i] > 0.1;
                                final color = _colors[i % _colors.length];

                                return AnimatedBuilder(
                                  animation: _animations[i],
                                  builder: (context, child) {
                                    // Calculate base height based on frequency range
                                    double baseHeightMultiplier;
                                    if (i < actualBarCount * 0.375) {
                                      // Bass frequencies (red) - higher base height
                                      baseHeightMultiplier = 0.8;
                                    } else if (i < actualBarCount * 0.75) {
                                      // Mid frequencies (orange) - medium base height
                                      baseHeightMultiplier = 0.5;
                                    } else {
                                      // High frequencies (yellow) - lower base height
                                      baseHeightMultiplier = 0.3;
                                    }

                                    final barHeight = 4.0 + (_barHeights[i] * (widget.height * baseHeightMultiplier));
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
                                              color.withOpacity(0.6),
                                              color,
                                              color.withOpacity(0.8),
                                            ],
                                            begin: Alignment.bottomCenter,
                                            end: Alignment.topCenter,
                                          ),
                                          borderRadius: BorderRadius.circular(4),
                                          boxShadow: isActive
                                              ? [
                                                  BoxShadow(
                                                    color: color.withOpacity(isBeatActive ? 0.8 : 0.5),
                                                    blurRadius: isBeatActive ? 12 : 6,
                                                    spreadRadius: isBeatActive ? 2 : 1,
                                                  ),
                                                ]
                                              : null,
                                        ),
                                      ),
                                    );
                                  },
                                );
                              }),
                            );
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
                                Colors.white.withOpacity(0.1),
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
            ),
          ),
        );
      },
    );
  }
}

