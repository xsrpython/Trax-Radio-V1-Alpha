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

  // Beta expiration date - DISABLED FOR NOW
  // static final DateTime _betaExpirationDate = DateTime(2024, 2, 15); // Adjust this date as needed

  @override
  void initState() {
    super.initState();
    
    // Check if beta has expired - DISABLED FOR NOW
    // if (_isBetaExpired()) {
    //   return; // Don't initialize audio if expired
    // }
    
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

  // Beta expiration methods - DISABLED FOR NOW
  // bool _isBetaExpired() {
  //   final now = DateTime.now();
  //   return now.isAfter(_betaExpirationDate);
  // }

  // String _getDaysUntilExpiration() {
  //   final now = DateTime.now();
  //   final difference = _betaExpirationDate.difference(now);
  //   return difference.inDays.toString();
  // }

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

  // Beta expiration screen - DISABLED FOR NOW
  // Widget _buildExpirationScreen() {
  //   return Scaffold(
  //     backgroundColor: Colors.black,
  //     body: Center(
  //       child: Column(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: [
  //           Icon(
  //             Icons.warning_amber_rounded,
  //             color: Colors.orange,
  //             size: 100,
  //           ),
  //           const SizedBox(height: 20),
  //           Text(
  //             'Beta Version Expired',
  //             style: TextStyle(
  //               color: Colors.white,
  //               fontSize: 24,
  //               fontWeight: FontWeight.bold,
  //             ),
  //           ),
  //           const SizedBox(height: 10),
  //           Text(
  //             'This beta version of Trax Radio has expired. Please update to the latest version.',
  //             textAlign: TextAlign.center,
  //             style: TextStyle(
  //               color: Colors.white54,
  //               fontSize: 16,
  //             ),
  //           ),
  //           const SizedBox(height: 30),
  //           ElevatedButton(
  //             onPressed: () {
  //               // Optionally navigate back to splash screen or main app
  //               // For now, just show a message
  //               ScaffoldMessenger.of(context).showSnackBar(
  //                 const SnackBar(content: Text('Beta expired. Please update the app.')),
  //               );
  //             },
  //             style: ElevatedButton.styleFrom(
  //               backgroundColor: Colors.orange,
  //               foregroundColor: Colors.white,
  //               padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
  //               shape: RoundedRectangleBorder(
  //                 borderRadius: BorderRadius.circular(10),
  //               ),
  //             ),
  //             child: const Text('OK'),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    // Check if beta has expired
    // if (_isBetaExpired()) {
    //   return _buildExpirationScreen();
    // }

    return Scaffold(
      backgroundColor: Colors.black,
      body: FadeTransition( // Add fade transition wrapper
        opacity: _fadeController,
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isLandscape = constraints.maxWidth > constraints.maxHeight;
              final screenHeight = MediaQuery.of(context).size.height;
              final screenWidth = MediaQuery.of(context).size.width;
              final isSmallScreen = screenHeight < 700;
              final isMediumScreen = screenHeight >= 700 && screenHeight <= 900;
              final isLargeScreen = screenHeight > 900;
              final isExtraSmallScreen = screenHeight < 600;
              
              return Column(
                children: [
                  SizedBox(height: isExtraSmallScreen ? 2 : (isSmallScreen ? 4 : (isLandscape ? 8 : 12))),
                  // Title - responsive sizing
                  Center(
                    child: Text(
                      'Trax Radio UK',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isExtraSmallScreen ? 18 : (isSmallScreen ? 22 : (isLandscape ? 28 : 36)),
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  SizedBox(height: isExtraSmallScreen ? 1 : (isSmallScreen ? 3 : (isLandscape ? 6 : 8))),
                  // Beta expiration warning
                  // Container(
                  //   margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  //   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  //   decoration: BoxDecoration(
                  //     color: Colors.orange.withOpacity(0.2),
                  //     borderRadius: BorderRadius.circular(12),
                  //     border: Border.all(color: Colors.orange.withOpacity(0.5)),
                  //   ),
                  //   child: Row(
                  //     mainAxisSize: MainAxisSize.min,
                  //     children: [
                  //       const Icon(
                  //         Icons.warning_amber_rounded,
                  //         color: Colors.orange,
                  //         size: 20,
                  //       ),
                  //       const SizedBox(width: 8),
                  //       Text(
                  //         'Beta expires in ${_getDaysUntilExpiration()} days',
                  //         style: const TextStyle(
                  //           color: Colors.orange,
                  //           fontSize: 14,
                  //           fontWeight: FontWeight.w600,
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  // Visualizer and BPM Display - responsive sizing
                  Padding(
                    padding: EdgeInsets.only(bottom: isLandscape ? 8.0 : 12.0), // Reduced padding in portrait
                    child: Column(
                      children: [
                        Linear3DVisualizer(
                          audioPlayer: _player,
                          height: isExtraSmallScreen ? 40 : (isSmallScreen ? 55 : (isLandscape ? 70 : 90)),
                          width: constraints.maxWidth,
                          barCount: isLandscape ? 30 : 40, // Reduced bar count
                          enableBeatDetection: true,
                          enable3DEffects: true,
                        ),
                        SizedBox(height: isLandscape ? 8 : 16),
                        Padding(
                          padding: EdgeInsets.only(bottom: isLandscape ? 4 : 12),
                          child: const BPMDisplay(),
                        ),
                      ],
                    ),
                  ),
                  // Turntable section - responsive sizing
                  Expanded(
                    child: Center(
                      child: LayoutBuilder(
                        builder: (context, turntableConstraints) {
                          // Calculate consistent width for all widgets
                          final widgetWidth = isLandscape 
                            ? turntableConstraints.maxWidth * 0.8
                            : turntableConstraints.maxWidth * 0.9;
                          
                          final size = isLandscape 
                            ? turntableConstraints.maxHeight * (isExtraSmallScreen ? 0.3 : (isSmallScreen ? 0.35 : 0.45))
                            : widgetWidth * 0.8; // Make turntable 80% of widget width
                          const recordFactor = 0.7;
                          
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Current DJ Widget - responsive scaling with consistent width
                              SizedBox(
                                width: widgetWidth,
                                child: Transform.scale(
                                  scale: isExtraSmallScreen ? 0.6 : (isSmallScreen ? 0.7 : (isLandscape ? 0.8 : 0.85)),
                                  child: const CurrentDJWidget(),
                                ),
                              ),
                              SizedBox(height: isExtraSmallScreen ? 1 : (isSmallScreen ? 3 : (isLandscape ? 6 : 8))),
                              SizedBox(
                                width: widgetWidth,
                                child: Center(
                                  child: SizedBox(
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
                            ),
                          ),
                              SizedBox(height: isExtraSmallScreen ? 1 : (isSmallScreen ? 2 : (isLandscape ? 4 : 6))),
                              // Next DJ Widget - responsive scaling with consistent width
                              SizedBox(
                                width: widgetWidth,
                                child: Transform.scale(
                                  scale: isExtraSmallScreen ? 0.6 : (isSmallScreen ? 0.7 : (isLandscape ? 0.8 : 0.85)),
                                  child: const NextDJWidget(),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                  // Play/Pause button and version info
                  Padding(
                    padding: EdgeInsets.only(bottom: isExtraSmallScreen ? 3.0 : (isSmallScreen ? 8.0 : 15.0)),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Center(
                          child: IconButton(
                            iconSize: isExtraSmallScreen ? 45 : (isSmallScreen ? 55 : 70),
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
                        SizedBox(height: isExtraSmallScreen ? 1 : (isSmallScreen ? 3 : 6)),
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


