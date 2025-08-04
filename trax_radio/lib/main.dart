import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'dj_service.dart';
import 'splash_screen.dart';
import 'widgets/current_dj_widget.dart';
import 'widgets/next_dj_widget.dart';

import 'widgets/metadata_display.dart';
import 'widgets/linear_3d_visualizer.dart';
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
  bool _hasShownLandscapeMessage = false; // Track if we've shown the message

  // Beta expiration date - DISABLED FOR NOW
  // static final DateTime _betaExpirationDate = DateTime(2024, 2, 15); // Adjust this date as needed

  @override
  void initState() {
    super.initState();
    
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
        setState(() {
          _isLoading = true;
        });
        
        // Set audio session for better compatibility
        await _player.setAudioSource(
          AudioSource.uri(Uri.parse(streamUrl)),
          preload: false,
        );
        
        await _player.play();
        
        setState(() {
          _isLoading = false;
        });
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        
        if (!mounted) return;
        
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
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return _buildPortraitLayout(constraints);
          },
        ),
      ),
    );
  }

  // Dedicated portrait layout - dynamic and responsive
  Widget _buildPortraitLayout(BoxConstraints constraints) {
    // Dynamic sizing based on screen dimensions
    final screenHeight = constraints.maxHeight;
    final screenWidth = constraints.maxWidth;
    
    // Calculate dynamic sizes
    final titleFontSize = screenHeight * 0.05; // 5% of screen height
    final topSpacing = screenHeight * 0.01; // 1% of screen height
    final visualizerHeight = screenHeight * 0.08; // 8% of screen height - increased for visibility
    final visualizerSpacing = screenHeight * 0.02; // 2% of screen height - increased spacing
    final widgetSpacing = screenHeight * 0.015; // 1.5% of screen height
    final playButtonSize = screenWidth * 0.25; // 25% of screen width
    final bottomPadding = screenHeight * 0.02; // 2% of screen height
    final horizontalPadding = screenWidth * 0.02; // 2% of screen width
    

    
    return Column(
      children: [
        // Top spacing - dynamic
        SizedBox(height: topSpacing),
        
        // Title - dynamic font size
        Center(
          child: Text(
            'Trax Radio UK',
            style: TextStyle(
              color: Colors.white,
              fontSize: titleFontSize,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ),
        
        // Spacing to move widgets down
        SizedBox(height: screenHeight * 0.02), // 2% of screen height
        
        // Visualizer - dynamic height
        Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: visualizerSpacing),
          child: Linear3DVisualizer(
            audioPlayer: _player,
            height: visualizerHeight,
            width: screenWidth,
            barCount: 80, // Increased bar count for better visibility
            enableBeatDetection: true,
            enable3DEffects: true,
          ),
        ),
        
        // All widgets positioned under title
        // Current DJ Widget - dynamic padding
        Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: widgetSpacing * 0.1),
          child: const CurrentDJWidget(),
        ),
        
        // Metadata Widget - dynamic padding
        Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: widgetSpacing * 0.1),
          child: const MetadataDisplay(),
        ),
        
        // Next DJ Widget - dynamic padding
        Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: widgetSpacing * 0.1),
          child: const NextDJWidget(),
        ),
        
        // Flexible space that adapts to content
        Flexible(
          child: Container(), // Empty container takes available space but doesn't force it
        ),
        
        // Play/Pause button with minimal bottom padding
        Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Center(
            child: IconButton(
                                iconSize: playButtonSize,
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


}


