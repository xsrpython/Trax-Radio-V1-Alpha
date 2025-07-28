import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'dj_service.dart';
import 'bpm_service.dart';
import 'splash_screen.dart';
import 'widgets/current_dj_widget.dart';
import 'widgets/next_dj_widget.dart';
import 'widgets/linear_3d_visualizer.dart';
import 'widgets/bpm_display.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
        primarySwatch: Colors.orange,
        brightness: Brightness.dark,
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

class _RadioHomePageState extends State<RadioHomePage>
    with TickerProviderStateMixin {
  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;
  bool _isLoading = false;
  late AnimationController _controller;
  late AnimationController _fadeController; // Add fade controller

  // Beta expiration date - set to 2 weeks from now
  static final DateTime _betaExpirationDate = DateTime(2024, 2, 15); // Adjust this date as needed

  @override
  void initState() {
    super.initState();
    
    // Check if beta has expired
    if (_isBetaExpired()) {
      return; // Don't initialize audio if expired
    }
    
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
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

  bool _isBetaExpired() {
    final now = DateTime.now();
    return now.isAfter(_betaExpirationDate);
  }

  String _getDaysUntilExpiration() {
    final now = DateTime.now();
    final difference = _betaExpirationDate.difference(now);
    return difference.inDays.toString();
  }

  final String streamUrl = 'https://hello.citrus3.com:8138/stream';

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

  Widget _buildExpirationScreen() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.orange,
              size: 100,
            ),
            const SizedBox(height: 20),
            Text(
              'Beta Version Expired',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'This beta version of Trax Radio has expired. Please update to the latest version.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white54,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                // Optionally navigate back to splash screen or main app
                // For now, just show a message
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Beta expired. Please update the app.')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('OK'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Check if beta has expired
    if (_isBetaExpired()) {
      return _buildExpirationScreen();
    }

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
                  // Beta expiration warning
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.withOpacity(0.5)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.orange,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Beta expires in ${_getDaysUntilExpiration()} days',
                          style: const TextStyle(
                            color: Colors.orange,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
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


