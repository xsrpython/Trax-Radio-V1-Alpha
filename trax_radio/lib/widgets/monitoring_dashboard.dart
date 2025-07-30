import 'package:flutter/material.dart';
import '../monitoring_service.dart';

class MonitoringDashboard extends StatefulWidget {
  const MonitoringDashboard({Key? key}) : super(key: key);

  @override
  State<MonitoringDashboard> createState() => _MonitoringDashboardState();
}

class _MonitoringDashboardState extends State<MonitoringDashboard> {
  final MonitoringService _monitoringService = MonitoringService();
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 40,
      right: 5,
      child: Container(
        width: _isExpanded ? 250 : 40,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.4,
        ),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.red.withOpacity(0.7),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.3),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.monitor,
                    color: Colors.white,
                    size: 20,
                  ),
                  if (_isExpanded) ...[
                    const SizedBox(width: 8),
                    const Text(
                      'REAL-TIME MONITORING',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                  const Spacer(),
                  IconButton(
                    icon: Icon(
                      _isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: Colors.white,
                      size: 16,
                    ),
                    onPressed: () {
                      setState(() {
                        _isExpanded = !_isExpanded;
                      });
                    },
                  ),
                ],
              ),
            ),
            
            if (_isExpanded) ...[
              // Monitoring Content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStatusSection(),
                      const SizedBox(height: 16),
                      _buildOverflowSection(),
                      const SizedBox(height: 16),
                      _buildDJChangesSection(),
                      const SizedBox(height: 16),
                      _buildMetadataSection(),
                      const SizedBox(height: 16),
                      _buildControlsSection(),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusSection() {
    final summary = _monitoringService.getMonitoringSummary();
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📊 MONITORING STATUS',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          _buildStatusRow('Status', summary['isMonitoring'] ? '🟢 ACTIVE' : '🔴 INACTIVE'),
          _buildStatusRow('Overflow Events', '${summary['overflowEvents']}'),
          _buildStatusRow('DJ Changes', '${summary['djChangeEvents']}'),
          _buildStatusRow('Metadata Events', '${summary['metadataEvents']}'),
          _buildStatusRow('Current DJ', summary['currentDJ'] ?? 'Unknown'),
          _buildStatusRow('Next DJ', summary['nextDJ'] ?? 'Unknown'),
        ],
      ),
    );
  }

  Widget _buildOverflowSection() {
    final overflowEvents = _monitoringService.overflowEvents;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning, color: Colors.orange, size: 16),
              const SizedBox(width: 8),
              const Text(
                '⚠️ OVERFLOW EVENTS',
                style: TextStyle(
                  color: Colors.orange,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                '${overflowEvents.length}',
                style: const TextStyle(
                  color: Colors.orange,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (overflowEvents.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...overflowEvents.take(3).map((event) => _buildOverflowEvent(event)),
            if (overflowEvents.length > 3)
              Text(
                '... and ${overflowEvents.length - 3} more',
                style: TextStyle(
                  color: Colors.orange.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildDJChangesSection() {
    final djChangeEvents = _monitoringService.djChangeEvents;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.music_note, color: Colors.blue, size: 16),
              const SizedBox(width: 8),
              const Text(
                '🎧 DJ CHANGES',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                '${djChangeEvents.length}',
                style: const TextStyle(
                  color: Colors.blue,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (djChangeEvents.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...djChangeEvents.take(3).map((event) => _buildDJChangeEvent(event)),
            if (djChangeEvents.length > 3)
              Text(
                '... and ${djChangeEvents.length - 3} more',
                style: TextStyle(
                  color: Colors.blue.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetadataSection() {
    final metadataEvents = _monitoringService.metadataEvents;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info, color: Colors.green, size: 16),
              const SizedBox(width: 8),
              const Text(
                '🎵 METADATA EVENTS',
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                '${metadataEvents.length}',
                style: const TextStyle(
                  color: Colors.green,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (metadataEvents.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...metadataEvents.take(3).map((event) => _buildMetadataEvent(event)),
            if (metadataEvents.length > 3)
              Text(
                '... and ${metadataEvents.length - 3} more',
                style: TextStyle(
                  color: Colors.green.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildControlsSection() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              _monitoringService.clearMonitoringData();
              setState(() {});
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
            child: const Text('CLEAR DATA', style: TextStyle(fontSize: 12)),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              _monitoringService.stopMonitoring();
              setState(() {});
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
            child: const Text('STOP', style: TextStyle(fontSize: 12)),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            '$label:',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverflowEvent(OverflowEvent event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${event.widgetName} - ${event.overflowType}',
            style: const TextStyle(
              color: Colors.orange,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Content: ${event.content.length} chars',
            style: TextStyle(
              color: Colors.orange.withOpacity(0.8),
              fontSize: 10,
            ),
          ),
          Text(
            'Resolution: ${event.resolution}',
            style: TextStyle(
              color: Colors.orange.withOpacity(0.8),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDJChangeEvent(DJChangeEvent event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${event.previousCurrentDJ} → ${event.newCurrentDJ}',
            style: const TextStyle(
              color: Colors.blue,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (event.isCrossover)
            Text(
              '🔄 CROSSOVER DETECTED',
              style: TextStyle(
                color: Colors.red,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          Text(
            'Next: ${event.newNextDJ} at ${event.nextDJTime}',
            style: TextStyle(
              color: Colors.blue.withOpacity(0.8),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataEvent(MetadataEvent event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${event.artist} - ${event.title}',
            style: const TextStyle(
              color: Colors.green,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            'Listeners: ${event.listeners} | Bitrate: ${event.bitrate} kbps',
            style: TextStyle(
              color: Colors.green.withOpacity(0.8),
              fontSize: 10,
            ),
          ),
          if (event.isNewTrack)
            Text(
              '🆕 NEW TRACK',
              style: TextStyle(
                color: Colors.yellow,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }
} 