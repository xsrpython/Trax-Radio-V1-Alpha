import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'dj_service.dart';
import 'splash_screen.dart';
import 'widgets/current_dj_widget.dart';
import 'widgets/next_dj_widget.dart';
import 'widgets/equalizer_visualizer.dart';
import 'widgets/metadata_display.dart';
// import 'widgets/turntable_widget.dart'; // Temporarily removed for Alpha testing

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
      title: 'Trax Radio',
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
        // Top spacing
        const SizedBox(height: 8),
        
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
        
        const SizedBox(height: 2),
        
        // Visualizer - moved down by 100px
        Padding(
          padding: const EdgeInsets.only(top: 100.0, bottom: 12.0),
          child: EqualizerVisualizer(
            audioPlayer: _player,
            height: 72,
            width: constraints.maxWidth,
            barCount: 20,
            enableBeatDetection: true,
            enable3DEffects: true,
          ),
        ),

        // Spacer to push widgets to bottom area
        const Spacer(),
        
        // All widgets positioned above play button
        // Metadata Widget
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: MetadataDisplay(),
        ),

        // Current DJ Widget
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: CurrentDJWidget(),
        ),
        
        // Next DJ Widget
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: NextDJWidget(),
        ),
        
        // Small spacing before play button
        const SizedBox(height: 20),
        
        // Play/Pause button at the very bottom
        Padding(
          padding: const EdgeInsets.only(bottom: 20.0),
          child: Center(
            child: IconButton(
              iconSize: 150,
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
        ),
      ],
    );
  }

  // Dedicated landscape layout - placeholder for now
  Widget _buildLandscapeLayout(BoxConstraints constraints) {
    return Column(
      children: [
        // Top spacing
        const SizedBox(height: 4),
        
        // Title - optimized for landscape
        const Center(
          child: Text(
            'Trax Radio UK',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ),
        
        const SizedBox(height: 1),
        
        // Visualizer - optimized for landscape
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: EqualizerVisualizer(
            audioPlayer: _player,
            height: 40,
            width: constraints.maxWidth,
            barCount: 15,
            enableBeatDetection: true,
            enable3DEffects: true,
          ),
        ),

        // Metadata Widget
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 1),
          child: MetadataDisplay(),
        ),

        // Current DJ Widget
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          child: CurrentDJWidget(),
        ),
        
        // Next DJ Widget
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 1),
          child: Transform.scale(
            scale: 0.75,
            child: const NextDJWidget(),
          ),
        ),
        
        // Play/Pause button and version info
        Padding(
          padding: const EdgeInsets.only(bottom: 2.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: IconButton(
                  iconSize: 70,
                  color: Colors.white,
                  icon: _isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        )
                      : Icon(_isPlaying ? Icons.pause_circle : Icons.play_circle),
                  onPressed: _isLoading ? null : _togglePlayPause,
                ),
              ),
              // Version and developer info removed for Alpha testing
            ],
          ),
        ),
      ],
    );
  }
}


