import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';

import 'dart:async';
import 'dj_service.dart';
import 'splash_screen.dart';
import 'widgets/current_dj_widget.dart';
import 'widgets/next_dj_widget.dart';
import 'widgets/metadata_display.dart';
import 'widgets/linear_3d_visualizer.dart';
import 'metadata_service.dart';
import 'stream_service.dart';
import 'performance_optimizer.dart';
import 'dj_profile_service.dart';
// import 'widgets/turntable_widget.dart'; // Temporarily removed for Alpha testing

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize performance optimizations first
  await PerformanceOptimizer.initialize();
  
  // Initialize DJ service with lazy loading
  unawaited(DJService.initialize());
  
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
  final MetadataService _metadataService = MetadataService();
  final StreamService _streamService = StreamService();
  bool _isPlaying = false;
  bool _isLoading = false;
  bool _hasShownLandscapeMessage = false; // Track if we've shown the message
  Timer? _scheduleRefreshTimer;

  // Beta expiration date - DISABLED FOR NOW
  // static final DateTime _betaExpirationDate = DateTime(2024, 2, 15); // Adjust this date as needed

  @override
  void initState() {
    super.initState();
    
    // Initialize services asynchronously to improve startup time
    _initializeServicesAsync();
    
    // Set up player state listener
    _setupPlayerListener();
    
    // Start battery optimization monitoring
    BatteryOptimizer.startMonitoring();
  }

  /// Initialize services asynchronously for better startup performance
  Future<void> _initializeServicesAsync() async {
    // Configure audio session for background playback
    await _configureAudioSession();
    
    // Metadata service initializes automatically
    
    // Initialize DJ profile service (lazy loading)
    unawaited(DJProfileService().initialize());
    
    // Schedule periodic DJ schedule refresh with optimized interval
    _scheduleRefreshTimer = Timer.periodic(const Duration(minutes: 30), (timer) {
      if (mounted) {
        DJService.refreshSchedule();
      }
    });
  }

  /// Set up player state listener with optimized updates
  void _setupPlayerListener() {
    _player.playerStateStream.listen((state) {
      if (!mounted) return;
      
      setState(() {
        _isPlaying = state.playing;
        _isLoading = state.processingState == ProcessingState.loading ||
            state.processingState == ProcessingState.buffering;
      });
    });
  }


  Future<void> _configureAudioSession() async {
    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration(
      avAudioSessionCategory: AVAudioSessionCategory.playback,
      avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.allowBluetooth |
          AVAudioSessionCategoryOptions.mixWithOthers,
      avAudioSessionMode: AVAudioSessionMode.defaultMode,
      avAudioSessionRouteSharingPolicy: AVAudioSessionRouteSharingPolicy.defaultPolicy,
      avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
      androidAudioAttributes: AndroidAudioAttributes(
        contentType: AndroidAudioContentType.music,
        flags: AndroidAudioFlags.none,
        usage: AndroidAudioUsage.media,
      ),
      androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
      androidWillPauseWhenDucked: false,
    ));
  }

  void _startBackgroundService() {
    // This will be handled by the Android service
    // The audio session configuration ensures background playback
  }

  // Metadata service handles all track information updates

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

  Future<void> _prepareAndPlayWithFallback() async {
    try {
      // Get stream URLs from auto-detection service
      final streamUrls = await _streamService.getStreamUrls();
      Object? lastError;
      
      for (final url in streamUrls) {
        try {
          await _player.setAudioSource(
            AudioSource.uri(Uri.parse(url)),
            preload: false,
          );
          await _player.play();
          return; // success
        } catch (e) {
          lastError = e;
        }
      }
      
      if (!mounted) return;
      throw lastError ?? Exception('Unable to connect to any stream URL');
    } catch (e) {
      if (!mounted) return;
      throw Exception('Failed to get stream configuration: $e');
    }
  }

  Future<void> _togglePlayPause() async {
    if (_isPlaying) {
      await _player.pause();
      
      // Track pause event
      // FirebaseAnalytics.instance.logEvent(
      //   name: 'radio_pause',
      //   parameters: {
      //     'session_duration': DateTime.now().millisecondsSinceEpoch,
      //   },
      // );
    } else {
      try {
        setState(() {
          _isLoading = true;
        });
        
        // Start metadata service for live updates
        _metadataService.startMetadataUpdates();
        
        // Wait a moment for initial metadata to load
        await Future.delayed(const Duration(milliseconds: 500));
        
        // Get current metadata for initial setup
        final initialTitle = _metadataService.currentTitle;
        final initialArtist = _metadataService.currentArtist;
        
        // Prepare and play with HTTPS→HTTP fallback
        await _prepareAndPlayWithFallback();
        
        // Start background service for continuous playback
        _startBackgroundService();
        
        // Metadata service handles track information display
        
        // Track play event
        // FirebaseAnalytics.instance.logEvent(
        //   name: 'radio_play',
        //   parameters: {
        //     'stream_url': _primaryStreamUrl,
        //     'device_type': 'mobile',
        //   },
        // );
        
        setState(() {
          _isLoading = false;
        });
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        
        // Track error event
        // FirebaseAnalytics.instance.logEvent(
        //   name: 'radio_error',
        //   parameters: {
        //     'error_message': e.toString(),
        //     'stream_url': streamUrl,
        //   },
        // );
        
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
        
        // DJ Profile Widget - Expanded to fill space (Live or Auto DJ)
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: widgetSpacing * 0.5),
            child: const DJProfileWidget(
              showPicture: true,
              showBio: false,
              showSocialMedia: false,
            ),
          ),
        ),
        
        // Next DJ Widget - moved above play/pause button
        Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: widgetSpacing * 0.1),
          child: const NextDJWidget(),
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

  @override
  void dispose() {
    // Clean up resources for better memory management
    _metadataService.stopMetadataUpdates();
    _player.dispose();
    _scheduleRefreshTimer?.cancel();
    
    // Stop performance optimization monitoring
    BatteryOptimizer.stopMonitoring();
    
    super.dispose();
  }
}


