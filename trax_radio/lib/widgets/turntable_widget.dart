import 'package:flutter/material.dart';

class TurntableWidget extends StatefulWidget {
  final double size;
  final bool isPlaying;
  final bool isLandscape;

  const TurntableWidget({
    super.key,
    required this.size,
    required this.isPlaying,
    required this.isLandscape,
  });

  @override
  State<TurntableWidget> createState() => _TurntableWidgetState();
}

class _TurntableWidgetState extends State<TurntableWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
  }

  @override
  void didUpdateWidget(TurntableWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying && !oldWidget.isPlaying) {
      _controller.repeat();
    } else if (!widget.isPlaying && oldWidget.isPlaying) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const recordFactor = 0.7;
    
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Spinning Record
          Transform.translate(
            offset: Offset(-0.13 * widget.size, -0.014 * widget.size),
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
          // Turntable Base
          Image.asset(
            'assets/turntable.png',
            fit: BoxFit.contain,
            width: widget.size,
            height: widget.size,
          ),
        ],
      ),
    );
  }
} 