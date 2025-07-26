import 'package:flutter/material.dart';
import 'dart:async';
import '../dj_service.dart';

class CurrentDJWidget extends StatefulWidget {
  const CurrentDJWidget({super.key});

  @override
  State<CurrentDJWidget> createState() => _CurrentDJWidgetState();
}

class _CurrentDJWidgetState extends State<CurrentDJWidget>
    with TickerProviderStateMixin {
  String _currentDJ = 'Loading...';
  Timer? _timer;
  late AnimationController _scrollController;
  late Animation<double> _scrollAnimation;

  @override
  void initState() {
    super.initState();
    _initializeDJService();
    _setupScrollAnimation();
  }

  void _setupScrollAnimation() {
    _scrollController = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    );

    _scrollAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scrollController,
      curve: Curves.linear,
    ));

    _scrollController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _scrollController.reset();
        _scrollController.forward();
      }
    });

    _scrollController.forward();
  }

  Future<void> _initializeDJService() async {
    await DJService.initialize();
    _updateCurrentDJ();
  }

  void _updateCurrentDJ() {
    final newDJ = DJService.getCurrentDJ();
    if (mounted && newDJ != _currentDJ) {
      setState(() {
        _currentDJ = newDJ;
      });
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24, width: 1),
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
          // Scrolling DJ Name
          SizedBox(
            width: 120,
            child: ClipRect(
              child: AnimatedBuilder(
                animation: _scrollAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(
                      -(_scrollAnimation.value * 200),
                      0,
                    ),
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
                      maxLines: 1, // Force single line
                      softWrap: false, // Prevent text wrapping
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Alternative simpler widget if you want just the text
class SimpleCurrentDJWidget extends StatefulWidget {
  const SimpleCurrentDJWidget({super.key});

  @override
  State<SimpleCurrentDJWidget> createState() => _SimpleCurrentDJWidgetState();
}

class _SimpleCurrentDJWidgetState extends State<SimpleCurrentDJWidget> {
  String _currentDJ = 'Trax Auto DJ';
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _initializeDJService();
    _startTimer();
  }

  Future<void> _initializeDJService() async {
    await DJService.initialize();
    _updateCurrentDJ();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _updateCurrentDJ();
    });
  }

  void _updateCurrentDJ() {
    final newDJ = DJService.getCurrentDJ();
    if (mounted && newDJ != _currentDJ) {
      setState(() {
        _currentDJ = newDJ;
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      'Live: $_currentDJ',
      style: const TextStyle(
        color: Colors.greenAccent,
        fontSize: 18,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.0,
      ),
    );
  }
} 