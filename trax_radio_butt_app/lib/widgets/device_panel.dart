import 'package:flutter/material.dart';
import '../models/audio_device.dart';
import '../services/audio_service.dart';

/// Widget for managing audio devices
class DevicePanel extends StatefulWidget {
  const DevicePanel({super.key});

  @override
  State<DevicePanel> createState() => _DevicePanelState();
}

class _DevicePanelState extends State<DevicePanel> {
  final AudioService _audioService = AudioService();
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeAudioService();
  }

  /// Initialize the audio service
  Future<void> _initializeAudioService() async {
    final success = await _audioService.initialize();
    if (mounted) {
      setState(() {
        _isInitialized = success;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🎵 Trax Radio BUTT App'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      body: _isInitialized ? _buildMainContent() : _buildLoadingState(),
    );
  }

  /// Build loading state
  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
          ),
          SizedBox(height: 16),
          Text(
            'Initializing Audio Service...',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  /// Build main content
  Widget _buildMainContent() {
    return ListenableBuilder(
      listenable: _audioService,
      builder: (context, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatusCard(),
              const SizedBox(height: 16),
              _buildDeviceSelection(),
              const SizedBox(height: 16),
              _buildAudioLevels(),
              const SizedBox(height: 16),
              _buildControlButtons(),
            ],
          ),
        );
      },
    );
  }

  /// Build status card
  Widget _buildStatusCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _audioService.isRecording ? Icons.radio : Icons.radio_button_unchecked,
                  color: _audioService.isRecording ? Colors.green : Colors.grey,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Stream Status',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _audioService.isRecording ? '🟢 Live Streaming' : '🔴 Not Streaming',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _audioService.isRecording ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Input: ${_audioService.selectedInputDevice?.name ?? 'None'}',
              style: const TextStyle(fontSize: 14),
            ),
            Text(
              'Output: ${_audioService.selectedOutputDevice?.name ?? 'None'}',
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  /// Build device selection
  Widget _buildDeviceSelection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Audio Devices',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildDeviceDropdown(
              title: 'Input Device',
              devices: _audioService.availableDevices
                  .where((device) => device.type == AudioDeviceType.input)
                  .toList(),
              selectedDevice: _audioService.selectedInputDevice,
              onDeviceSelected: (device) => _audioService.selectInputDevice(device),
            ),
            const SizedBox(height: 16),
            _buildDeviceDropdown(
              title: 'Output Device',
              devices: _audioService.availableDevices
                  .where((device) => device.type == AudioDeviceType.output)
                  .toList(),
              selectedDevice: _audioService.selectedOutputDevice,
              onDeviceSelected: (device) => _audioService.selectOutputDevice(device),
            ),
          ],
        ),
      ),
    );
  }

  /// Build device dropdown
  Widget _buildDeviceDropdown({
    required String title,
    required List<AudioDevice> devices,
    required AudioDevice? selectedDevice,
    required Function(AudioDevice) onDeviceSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<AudioDevice>(
          value: selectedDevice,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          items: devices.map((device) {
            return DropdownMenuItem(
              value: device,
              child: Row(
                children: [
                  Icon(
                    device.isDJController
                        ? Icons.music_note
                        : device.isUSBAudio
                            ? Icons.usb
                            : Icons.speaker,
                    size: 20,
                    color: Colors.deepPurple,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          device.displayName,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          device.capabilities,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (device) {
            if (device != null) {
              onDeviceSelected(device);
            }
          },
        ),
      ],
    );
  }

  /// Build audio levels
  Widget _buildAudioLevels() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Audio Levels',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildLevelMeter('Input Level', _audioService.inputLevel, Colors.blue),
            const SizedBox(height: 16),
            _buildLevelMeter('Output Level', _audioService.outputLevel, Colors.green),
          ],
        ),
      ),
    );
  }

  /// Build level meter
  Widget _buildLevelMeter(String label, double level, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Text('${(level * 100).toInt()}%'),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 20,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(10),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: level,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Build control buttons
  Widget _buildControlButtons() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Stream Controls',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _audioService.isRecording
                        ? null
                        : () => _audioService.startRecording(),
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Start Streaming'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _audioService.isRecording
                        ? () => _audioService.stopRecording()
                        : null,
                    icon: const Icon(Icons.stop),
                    label: const Text('Stop Streaming'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _audioService.refreshDevices(),
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh Devices'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}





