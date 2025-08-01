import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'dj_service.dart';
import 'splash_screen.dart';
import 'widgets/current_dj_widget.dart';
import 'widgets/next_dj_widget.dart';

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
    print('🔍 DEBUG: Main build method executing!');
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
                  print('🔍 DEBUG: LayoutBuilder executing!');
                  print('🔍 DEBUG: Constraints: ${constraints.maxWidth} x ${constraints.maxHeight}');
                  final isLandscape = constraints.maxWidth > constraints.maxHeight;
                  
                  // Use separate layouts for portrait and landscape
                  if (isLandscape) {
                    print('🔍 DEBUG: Using landscape layout');
                    return _buildLandscapeLayout(constraints);
                  } else {
                    print('🔍 DEBUG: Using portrait layout');
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

  // Dedicated portrait layout - dynamic and responsive
  Widget _buildPortraitLayout(BoxConstraints constraints) {
    // Dynamic sizing based on screen dimensions
    final screenHeight = constraints.maxHeight;
    final screenWidth = constraints.maxWidth;
    
    // Calculate dynamic sizes
    final titleFontSize = screenHeight * 0.05; // 5% of screen height
    final topSpacing = screenHeight * 0.01; // 1% of screen height
    final visualizerHeight = screenHeight * 0.02; // 2% of screen height
    final visualizerSpacing = screenHeight * 0.01; // 1% of screen height
    final widgetSpacing = screenHeight * 0.015; // 1.5% of screen height
    final playButtonSize = screenWidth * 0.25; // 25% of screen width
    final bottomPadding = screenHeight * 0.02; // 2% of screen height
    final horizontalPadding = screenWidth * 0.02; // 2% of screen width
    
    // DEBUG: Print all calculations
    print('=== PORTRAIT LAYOUT DEBUG ===');
    print('Screen Height: $screenHeight');
    print('Screen Width: $screenWidth');
    print('Title Font Size: $titleFontSize');
    print('Top Spacing: $topSpacing');
    print('Widget Spacing: $widgetSpacing');
    print('Play Button Size: $playButtonSize');
    print('Bottom Padding: $bottomPadding');
    print('Horizontal Padding: $horizontalPadding');
    
    // Calculate total space used
    final totalSpaceUsed = topSpacing + titleFontSize + (screenHeight * 0.02) + (widgetSpacing * 0.1 * 3) + 20; // 20px for play button padding
    print('Total Space Used: $totalSpaceUsed');
    print('Remaining Space: ${screenHeight - totalSpaceUsed}');
    print('========================');
    
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

  // Dedicated landscape layout - dynamic and responsive
  Widget _buildLandscapeLayout(BoxConstraints constraints) {
    // Dynamic sizing based on screen dimensions
    final screenHeight = constraints.maxHeight;
    final screenWidth = constraints.maxWidth;
    
    // Calculate dynamic sizes for landscape
    final titleFontSize = screenHeight * 0.06; // 6% of screen height
    final topSpacing = screenHeight * 0.01; // 1% of screen height
    final visualizerHeight = screenHeight * 0.015; // 1.5% of screen height
    final visualizerSpacing = screenHeight * 0.01; // 1% of screen height
    final widgetSpacing = screenHeight * 0.015; // 1.5% of screen height
    final playButtonSize = screenWidth * 0.15; // 15% of screen width
    final bottomPadding = screenHeight * 0.01; // 1% of screen height
    final horizontalPadding = screenWidth * 0.02; // 2% of screen width
    
    // DEBUG: Print all calculations
    print('=== LANDSCAPE LAYOUT DEBUG ===');
    print('Screen Height: $screenHeight');
    print('Screen Width: $screenWidth');
    print('Title Font Size: $titleFontSize');
    print('Top Spacing: $topSpacing');
    print('Widget Spacing: $widgetSpacing');
    print('Play Button Size: $playButtonSize');
    print('Bottom Padding: $bottomPadding');
    print('Horizontal Padding: $horizontalPadding');
    
    // Calculate total space used
    final totalSpaceUsed = topSpacing + titleFontSize + (widgetSpacing * 0.3) + (widgetSpacing * 0.6) + 1 + 20; // 1px for Next DJ, 20px for play button padding
    print('Total Space Used: $totalSpaceUsed');
    print('Remaining Space: ${screenHeight - totalSpaceUsed}');
    print('========================');
    
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
        


        // Metadata Widget - dynamic padding
        Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: widgetSpacing * 0.3),
          child: const MetadataDisplay(),
        ),

        // Current DJ Widget - dynamic padding
        Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: widgetSpacing * 0.6),
          child: const CurrentDJWidget(),
        ),
        
        // Next DJ Widget
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 1),
          child: Transform.scale(
            scale: 0.75,
            child: const NextDJWidget(),
          ),
        ),
        
        // Flexible space that adapts to content
        Flexible(
          child: Container(), // Empty container takes available space but doesn't force it
        ),
        
        // Play/Pause button with minimal bottom padding
        Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: IconButton(
                  iconSize: playButtonSize,
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


