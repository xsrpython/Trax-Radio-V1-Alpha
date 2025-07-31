import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'dj_service.dart';
import 'splash_screen.dart';
import 'widgets/current_dj_widget.dart';
import 'widgets/next_dj_widget.dart';
import 'widgets/linear_3d_visualizer.dart';
import 'widgets/metadata_display.dart';
import 'widgets/turntable_widget.dart';

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
                  
                  // Use separate layouts for portrait and landscape
                  if (isLandscape) {
                    return _buildLandscapeLayout(constraints);
                  } else {
                    return _buildPortraitLayout(constraints);
                  }
                },
              ),
            ),
          );
        },
      ),
    );
  }

  // Dedicated portrait layout - optimized and locked down
  Widget _buildPortraitLayout(BoxConstraints constraints) {
    return Column(
      children: [
        // Top spacing - reduced
        const SizedBox(height: 4),
        
        // Title - optimized for portrait
        const Center(
          child: Text(
            'Trax Radio UK',
            style: TextStyle(
              color: Colors.white,
              fontSize: 40,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ),
        
        const SizedBox(height: 11), // Reduced from 21 to 11 (10px less)
        
        // Visualizer - optimized for portrait with balanced height
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Linear3DVisualizer(
            audioPlayer: _player,
            height: 150, // Reduced from 180 to 150 for better compatibility
            width: constraints.maxWidth,
            barCount: 50,
            enableBeatDetection: true,
            enable3DEffects: true,
          ),
        ),
        
        // Minimal spacer to fix overflow
        const SizedBox(height: 20),
        
        // Metadata Widget - positioned above turntable
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          child: MetadataDisplay(),
        ),
        
        // 1px spacing
        const SizedBox(height: 1),
        
        // Current DJ Widget - positioned above turntable
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          child: CurrentDJWidget(),
        ),
        
        // 1px spacing
        const SizedBox(height: 1),
        
        // Next DJ Widget - positioned above turntable
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          child: NextDJWidget(),
        ),
        
        // Turntable section - positioned above play button
        Center(
          child: SizedBox(
            width: constraints.maxWidth * 0.52,
            height: constraints.maxWidth * 0.52,
            child: TurntableWidget(
              size: constraints.maxWidth * 0.52,
              isPlaying: _isPlaying,
              isLandscape: false,
            ),
          ),
        ),
        
        // Small spacing above play button
        const SizedBox(height: 1),
        
        // Play/Pause button
        Center(
          child: IconButton(
            iconSize: 65,
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
      ],
    );
  }

  // Dedicated landscape layout - optimized for horizontal space
  Widget _buildLandscapeLayout(BoxConstraints constraints) {
    return Row(
      children: [
        // Left side - Visualizer and controls
        Expanded(
          flex: 3,
          child: Column(
            children: [
              // Top spacing
              const SizedBox(height: 4),
              
              // Title - optimized for landscape
              const Center(
                child: Text(
                  'Trax Radio UK',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Visualizer - optimized for landscape with more height
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8.0),
                child: Linear3DVisualizer(
                  audioPlayer: _player,
                  height: 120,
                  width: constraints.maxWidth * 0.6,
                  barCount: 60,
                  enableBeatDetection: true,
                  enable3DEffects: true,
                ),
              ),

              // Play/Pause button
              Center(
                child: IconButton(
                  iconSize: 70,
                  color: Colors.white,
                  icon: _isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 4,
                        )
                      : Icon(_isPlaying ? Icons.pause_circle : Icons.play_circle),
                  onPressed: _isLoading ? null : _togglePlayPause,
                ),
              ),

              // Version info
              const Spacer(),
              const Padding(
                padding: EdgeInsets.only(bottom: 8.0),
                child: Text(
                  'V1.0.0 Beta',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Right side - DJ info and turntable
        Expanded(
          flex: 2,
          child: Column(
            children: [
              // Top spacing
              const SizedBox(height: 4),
              
              // Metadata Widget
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: MetadataDisplay(),
              ),

              // Current DJ Widget
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                child: CurrentDJWidget(),
              ),
              
              // Next DJ Widget
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                child: NextDJWidget(),
              ),

              // Turntable - smaller for landscape
              Expanded(
                child: Center(
                  child: SizedBox(
                    width: constraints.maxWidth * 0.25,
                    height: constraints.maxWidth * 0.25,
                    child: TurntableWidget(
                      size: constraints.maxWidth * 0.25,
                      isPlaying: _isPlaying,
                      isLandscape: true,
                    ),
                  ),
                ),
              ),

              // Developer info
              const Padding(
                padding: EdgeInsets.only(bottom: 8.0),
                child: Text(
                  'Developed by DJXSR',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}


