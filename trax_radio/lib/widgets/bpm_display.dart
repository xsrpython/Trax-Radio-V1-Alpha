import 'package:flutter/material.dart';
import 'dart:async';
import '../bpm_service.dart';

class BPMDisplay extends StatefulWidget {
  const BPMDisplay({super.key});

  @override
  State<BPMDisplay> createState() => _BPMDisplayState();
}

class _BPMDisplayState extends State<BPMDisplay>
    with TickerProviderStateMixin {
  int _currentBPM = 0;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  StreamSubscription<int>? _bpmSubscription;
  bool _isActive = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _subscribeToBPM();
  }

  void _setupAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  void _subscribeToBPM() {
    _bpmSubscription = BMPService().bpmStream.listen((bpm) {
      if (mounted) {
        setState(() {
          _currentBPM = bpm;
          _isActive = bpm > 0;
        });
        
        // Pulse animation when BPM changes
        if (_isActive) {
          _pulseController.forward().then((_) {
            _pulseController.reverse();
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _bpmSubscription?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isActive) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.orange.withOpacity(0.6), width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.speed,
                  color: Colors.orange,
                  size: 16,
                ),
                const SizedBox(width: 8),
                const Text(
                  'BPM: ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '$_currentBPM',
                  style: const TextStyle(
                    color: Colors.orange,
                    fontSize: 18,
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
                ),
              ],
            ),
          ),
        );
      },
    );
  }
} 