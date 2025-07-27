import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'widgets/current_dj_widget.dart';
import 'widgets/next_dj_widget.dart';
import 'widgets/linear_3d_visualizer.dart';
import 'widgets/bpm_display.dart';
import 'dj_service.dart';
import 'bpm_service.dart';
import 'splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Prefetch DJ data on app startup
  await DJService.initialize();
  
  runApp(const TraxRadioApp());
}

class TraxRadioApp extends StatelessWidget {
  const TraxRadioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trax Radio V1.0.0 Beta',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class RadioHomePage extends StatefulWidget {
  const RadioHomePage({super.key});

  @override
  State<RadioHomePage> createState() => _RadioHomePageState();
}

class _RadioHomePageState extends State<RadioHomePage> with TickerProviderStateMixin {
  final _player = AudioPlayer();
  bool _isPlaying = false;
  bool _isLoading = false;

  final String streamUrl = 'https://hello.citrus3.com:8138/stream';
  late final AnimationController _controller;
  late final AnimationController _fadeController; // Add fade controller

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _fadeController = AnimationController( // Initialize fade controller
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    // Start fade-in after a brief delay
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _fadeController.forward();
      }
    });
    
    _player.playerStateStream.listen((state) {
      setState(() {
        _isPlaying = state.playing;
        _isLoading = state.processingState == ProcessingState.loading ||
            state.processingState == ProcessingState.buffering;
        if (_isPlaying) {
          _controller.repeat();
          BMPService().startAnalysis(_player);
        } else {
          _controller.stop();
          BMPService().stopAnalysis();
        }
      });
    });
  }

  Future<void> _togglePlayPause() async {
    if (_isPlaying) {
      await _player.pause();
    } else {
      try {
        await _player.setUrl(streamUrl);
        await _player.play();
      } catch (e) {
        if (!mounted) return; // Fix for "BuildContexts across async gaps"
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error playing stream: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _fadeController.dispose(); // Dispose fade controller
    BMPService().stopAnalysis();
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FadeTransition( // Add fade transition wrapper
        opacity: _fadeController,
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isLandscape = constraints.maxWidth > constraints.maxHeight;
              
              return Column(
                children: [
                  SizedBox(height: isLandscape ? 10 : 12), // Reduced from 20 to 12 in portrait
                  // Title - responsive sizing
                  Center(
                    child: Text(
                      'Trax Radio UK',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isLandscape ? 60 : 88,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  SizedBox(height: isLandscape ? 8 : 16),
                  // Visualizer and BPM Display - responsive sizing
                  Padding(
                    padding: EdgeInsets.only(bottom: isLandscape ? 8.0 : 12.0), // Reduced padding in portrait
                    child: Column(
                      children: [
                        Linear3DVisualizer(
                          audioPlayer: _player,
                          height: isLandscape ? 120 : 150, // Reduced from 200 to 150 in portrait
                          width: constraints.maxWidth,
                          barCount: isLandscape ? 40 : 50, // Increased bar count for better visual coverage
                          enableBeatDetection: true,
                          enable3DEffects: true,
                        ),
                        const SizedBox(height: 8),
                        const BPMDisplay(),
                      ],
                    ),
                  ),
                  // Turntable section - responsive sizing
                  Expanded(
                    child: Center(
                      child: LayoutBuilder(
                        builder: (context, turntableConstraints) {
                          final size = isLandscape 
                            ? turntableConstraints.maxHeight * 0.6 // Larger in landscape
                            : turntableConstraints.maxWidth * 0.65; // Smaller in portrait to prevent overflow
                          const recordFactor = 0.7;
                          
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Current DJ Widget - responsive scaling
                              Transform.scale(
                                scale: isLandscape ? 1.4 : 1.8, // Now Playing: Larger scale
                                child: const CurrentDJWidget(),
                              ),
                              SizedBox(height: isLandscape ? 12 : 8), // Reduced spacing in portrait
                              SizedBox(
                                width: size,
                                height: size,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Transform.translate(
                                      offset: Offset(-0.13 * size, -0.014 * size),
                                      child: FractionallySizedBox(
                                        widthFactor: recordFactor,
                                        heightFactor: recordFactor,
                                        child: RotationTransition(
                                          turns: _controller,
                                          child: Image.asset(
                                            'assets/record.png',
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Image.asset(
                                      'assets/turntable.png',
                                      fit: BoxFit.contain,
                                      width: size,
                                      height: size,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: isLandscape ? 8 : 6), // Reduced spacing in portrait
                              // Next DJ Widget - responsive scaling
                              Transform.scale(
                                scale: isLandscape ? 1.0 : 1.0, // Up Next: Smaller scale (no internal scaling now)
                                child: const NextDJWidget(),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                  // Play/Pause button and version info
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Center(
                          child: IconButton(
                            iconSize: 100,
                            color: Colors.white,
                            icon: _isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 6,
                                  )
                                : Icon(_isPlaying ? Icons.pause_circle : Icons.play_circle),
                            onPressed: _isLoading ? null : _togglePlayPause,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: 16.0),
                              child: Text(
                                'V1.0.0 Beta',
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(right: 16.0),
                              child: Text(
                                'Developed by DJXSR',
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}


