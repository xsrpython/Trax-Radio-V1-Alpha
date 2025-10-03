import 'dart:async';
import 'package:flutter/material.dart';
import '../metadata_service.dart';

class MetadataDisplay extends StatefulWidget {
  const MetadataDisplay({Key? key}) : super(key: key);

  @override
  State<MetadataDisplay> createState() => _MetadataDisplayState();
}

class _MetadataDisplayState extends State<MetadataDisplay>
    with TickerProviderStateMixin {
  final MetadataService _metadataService = MetadataService();
  Timer? _updateTimer;
  String _currentTrack = 'Loading...';
  late AnimationController _scrollController;
  late Animation<double> _scrollAnimation;

  @override
  void initState() {
    super.initState();
    _setupScrollAnimation();
    _loadMetadata();
    _startUpdates();
  }

  void _setupScrollAnimation() {
    _scrollController = AnimationController(
      duration: const Duration(seconds: 8), // Slower animation
      vsync: this,
    );

    _scrollAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scrollController,
      curve: Curves.easeInOut, // Smoother curve
    ));

    _scrollController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _scrollController.reset();
        _scrollController.forward();
      }
    });

    _scrollController.forward();
  }

  void _loadMetadata() {
    setState(() {
      _currentTrack = _metadataService.currentTrack;
    });
  }

  void _startUpdates() {
    _metadataService.startMetadataUpdates();
    _updateTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      if (mounted) {
        _loadMetadata();
      }
    });
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    _scrollController.dispose();
    _metadataService.stopMetadataUpdates();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, // Fill available width
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blueAccent.withOpacity(0.5), width: 4),
      ),
             child: Row(
         mainAxisSize: MainAxisSize.max,
         children: [
          const Icon(
            Icons.music_note,
            color: Colors.blueAccent,
            size: 16,
          ),
          const SizedBox(width: 8),
                     const Text(
             'Track: ',
             style: TextStyle(
               color: Colors.white,
               fontSize: 14,
               fontWeight: FontWeight.w600,
               letterSpacing: 0.5,
             ),
           ),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRect(
              child: AnimatedBuilder(
                animation: _scrollAnimation,
                builder: (context, child) {
                  // Only scroll if text is long enough to need it
                  final shouldScroll = _currentTrack.length > 15;
                  final offset = shouldScroll ? -(_scrollAnimation.value * 300) : 0.0;
                  
                  return Transform.translate(
                    offset: Offset(offset, 0),
                    child: Text(
                      _currentTrack,
                      style: const TextStyle(
                        color: Colors.blueAccent,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                      overflow: TextOverflow.visible,
                      maxLines: 1,
                      softWrap: false,
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.blueAccent.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'LIVE',
              style: TextStyle(
                color: Colors.blueAccent,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 