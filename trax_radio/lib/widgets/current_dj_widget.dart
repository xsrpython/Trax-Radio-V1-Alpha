import 'package:flutter/material.dart';
import 'dart:async';
import '../dj_service.dart';
import 'package:timezone/timezone.dart' as tz;

class CurrentDJWidget extends StatefulWidget {
  const CurrentDJWidget({super.key});

  @override
  State<CurrentDJWidget> createState() => _CurrentDJWidgetState();
}

class _CurrentDJWidgetState extends State<CurrentDJWidget>
    with TickerProviderStateMixin {
  String _currentDJ = 'Loading...';
  bool _isLoading = true;
  Timer? _timer;
  late AnimationController _scrollController;
  late Animation<double> _scrollAnimation;
  String _timezoneInfo = '';

  @override
  void initState() {
    super.initState();
    _setupScrollAnimation();
    _updateCurrentDJ();
    _updateTimezoneInfo();
    _startTimer();
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

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (mounted) {
        _updateCurrentDJ();
        _updateTimezoneInfo();
      }
    });
  }

  void _updateCurrentDJ() {
    final currentDJ = DJService.getCurrentDJ();
    final newDJ = currentDJ?.name ?? 'Auto DJ';
    
    if (mounted && (newDJ != _currentDJ || _isLoading)) {
      setState(() {
        _currentDJ = newDJ;
        _isLoading = false;
      });
    }
  }

  void _updateTimezoneInfo() {
    try {
      final userLocation = tz.local;
      final ukLocation = tz.getLocation('Europe/London');
      final userTime = tz.TZDateTime.now(userLocation);
      final ukTime = tz.TZDateTime.now(ukLocation);
      
      final timezoneInfo = '${userLocation.name} ${userTime.hour.toString().padLeft(2, '0')}:${userTime.minute.toString().padLeft(2, '0')} | UK ${ukTime.hour.toString().padLeft(2, '0')}:${ukTime.minute.toString().padLeft(2, '0')}';
      
      if (mounted) {
        setState(() {
          _timezoneInfo = timezoneInfo;
        });
      }
    } catch (e) {
      print('Error updating timezone info: $e');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.7),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.greenAccent.withOpacity(0.5), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.music_note,
                color: Colors.white,
                size: 16,
              ),
              const SizedBox(width: 8),
              const Text(
                'Now Playing: ',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 120,
                child: ClipRect(
                  child: AnimatedBuilder(
                    animation: _scrollAnimation,
                    builder: (context, child) {
                      // Only scroll if text is long enough to need it
                      final shouldScroll = _currentDJ.length > 8;
                      final offset = shouldScroll ? -(_scrollAnimation.value * 200) : 0.0;
                      
                      return Transform.translate(
                        offset: Offset(offset, 0),
                        child: Text(
                          _currentDJ,
                          style: const TextStyle(
                            color: Colors.greenAccent,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                            shadows: [
                              Shadow(
                                offset: Offset(1, 1),
                                blurRadius: 3.0,
                                color: Colors.black,
                              ),
                            ],
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
            ],
          ),
        ),
        if (_timezoneInfo.isNotEmpty) ...[
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _timezoneInfo,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 10,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ],
    );
  }
} 