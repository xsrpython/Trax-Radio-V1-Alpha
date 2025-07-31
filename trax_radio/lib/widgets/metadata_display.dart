import 'dart:async';
import 'package:flutter/material.dart';
import '../metadata_service.dart';

class MetadataDisplay extends StatefulWidget {
  const MetadataDisplay({Key? key}) : super(key: key);

  @override
  State<MetadataDisplay> createState() => _MetadataDisplayState();
}

class _MetadataDisplayState extends State<MetadataDisplay> {
  final MetadataService _metadataService = MetadataService();
  Timer? _updateTimer;
  String _currentTrack = 'Loading...';

  @override
  void initState() {
    super.initState();
    _loadMetadata();
    _startUpdates();
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
    _metadataService.stopMetadataUpdates();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blueAccent.withOpacity(0.5), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.blueAccent.withOpacity(0.2),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.music_note,
            color: Colors.blueAccent,
            size: 16,
          ),
          const SizedBox(width: 8),
          const Text(
            'NOW PLAYING: ',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              _currentTrack,
              style: const TextStyle(
                color: Colors.blueAccent,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
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
                fontSize: 10,
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