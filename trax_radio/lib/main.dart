import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'dj_service.dart';
import 'splash_screen.dart';
import 'monitoring_service.dart';
import 'widgets/current_dj_widget.dart';
import 'widgets/next_dj_widget.dart';
import 'widgets/linear_3d_visualizer.dart';
import 'widgets/current_track_widget.dart';
import 'widgets/monitoring_dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DJService.initialize();
  
  // Initialize and start monitoring service
  final monitoringService = MonitoringService();
  monitoringService.startMonitoring();
  
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
        } else {
          _controller.stop();
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
        print('Attempting to play stream: $streamUrl');
        await _player.setUrl(streamUrl);
        await _player.play();
        print('Stream started successfully');
      } catch (e) {
        print('Error playing stream: $e');
        if (!mounted) return; // Fix for "BuildContexts across async gaps"
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error playing stream: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _fadeController.dispose(); // Dispose fade controller
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
    // Check if beta has expired - DISABLED FOR NOW
    // if (_isBetaExpired()) {
    //   return _buildExpirationScreen();
    // }

    return Scaffold(
      backgroundColor: Colors.black,
      body: AnimatedBuilder(
        animation: _fadeController,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeController.value,
            child: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isLandscape = constraints.maxWidth > constraints.maxHeight;
                  
                  return Stack(
                    children: [
                      Column(
                        children: [
                          SizedBox(height: isLandscape ? 8 : 8), // Further reduced spacing
                          // Title - responsive sizing
                          Center(
                            child: Text(
                              'Trax Radio UK',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isLandscape ? 60 : 72, // Reduced font size in portrait
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                          SizedBox(height: isLandscape ? 2 : 2), // Minimal spacing
                          // Visualizer and BPM Display - responsive sizing
                          Padding(
                            padding: EdgeInsets.only(bottom: isLandscape ? 8.0 : 12.0), // Reduced padding in portrait
                            child: Column(
                              children: [
                                Linear3DVisualizer(
                                  audioPlayer: _player,
                                  height: isLandscape ? 40 : 60, // Much smaller height
                                  width: constraints.maxWidth,
                                  barCount: isLandscape ? 40 : 50, // Increased bar count for better visual coverage
                                  enableBeatDetection: true,
                                  enable3DEffects: true,
                                ),
                              ],
                            ),
                          ),
                          // Metadata Widget
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: isLandscape ? 1 : 2),
                            child: const CurrentTrackWidget(),
                          ),
                          // Extra space between metadata and DJ widget
                          SizedBox(height: isLandscape ? 8 : 12),
                          // Now Playing DJ Widget - Centered with more spacing to push down
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: isLandscape ? 4 : 8),
                            child: const CurrentDJWidget(),
                          ),
                          // Turntable section - responsive sizing
                          Expanded(
                            child: Center(
                              child: LayoutBuilder(
                                builder: (context, turntableConstraints) {
                                                                final size = isLandscape
                                ? turntableConstraints.maxHeight * 0.4 // Much smaller size
                                : turntableConstraints.maxWidth * 0.45; // Much smaller size
                                  const recordFactor = 0.7;
                                  
                                  return Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
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
                                                                SizedBox(height: isLandscape ? 2 : 1), // Very minimal spacing
                          // Next DJ Widget - responsive scaling
                          Transform.scale(
                                                          scale: isLandscape ? 0.8 : 0.75, // Even smaller scale
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
                            padding: const EdgeInsets.only(bottom: 6.0), // Final adjustment to eliminate 19px overflow
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
                                const SizedBox(height: 8), // Reduced spacing
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
                      ),
                      // Monitoring Dashboard
                      const MonitoringDashboard(),
                    ],
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}


