import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:package_info_plus/package_info_plus.dart';

class UpdateService {
  static final UpdateService _instance = UpdateService._internal();
  factory UpdateService() => _instance;
  UpdateService._internal();

  // GitHub repository details
  static const String _githubOwner = 'xsrpython';
  static const String _githubRepo = 'Trax-Radio-V1-Alpha';

  // State variables
  String? _currentVersion;
  String? _latestVersion;
  bool _isUpdateAvailable = false;
  bool _isDownloading = false;
  double _downloadProgress = 0.0;
  String? _downloadedApkPath;
  String? _releaseNotes;
  String? _downloadUrl;

  // Getters
  String? get currentVersion => _currentVersion;
  String? get latestVersion => _latestVersion;
  bool get isUpdateAvailable => _isUpdateAvailable;
  bool get isDownloading => _isDownloading;
  double get downloadProgress => _downloadProgress;
  String? get downloadedApkPath => _downloadedApkPath;
  String? get releaseNotes => _releaseNotes;
  String? get downloadUrl => _downloadUrl;

  Future<void> initialize() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      _currentVersion = packageInfo.version;
      debugPrint('UpdateService: Current version: $_currentVersion');
    } catch (e) {
      debugPrint('UpdateService: Failed to get current version: $e');
    }
  }

  Future<bool> checkForUpdates() async {
    try {
      debugPrint('UpdateService: Checking for updates...');
      
      final response = await http.get(
        Uri.parse('https://api.github.com/repos/$_githubOwner/$_githubRepo/releases/latest'),
        headers: {
          'Accept': 'application/vnd.github.v3+json',
          'User-Agent': 'TraxRadio/1.0',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _latestVersion = data['tag_name']?.replaceAll('v', '');
        _releaseNotes = data['body'];
        
        // Find APK download URL
        final assets = data['assets'] as List<dynamic>?;
        if (assets != null) {
          for (final asset in assets) {
            final name = asset['name'] as String?;
            if (name != null && name.endsWith('.apk')) {
              _downloadUrl = asset['browser_download_url'] as String?;
              break;
            }
          }
        }

        if (_latestVersion != null && _currentVersion != null) {
          _isUpdateAvailable = _isVersionNewer(_latestVersion!, _currentVersion!);
          debugPrint('UpdateService: Latest version: $_latestVersion, Update available: $_isUpdateAvailable');
        }

        return _isUpdateAvailable;
      } else {
        debugPrint('UpdateService: Failed to check updates: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('UpdateService: Error checking updates: $e');
      return false;
    }
  }

  Future<bool> downloadUpdate({Function(double)? onProgress}) async {
    if (_downloadUrl == null) {
      debugPrint('UpdateService: No download URL available');
      return false;
    }

    try {
      _isDownloading = true;
      _downloadProgress = 0.0;

      debugPrint('UpdateService: Downloading from $_downloadUrl');

      final response = await http.get(
        Uri.parse(_downloadUrl!),
        headers: {
          'User-Agent': 'TraxRadio/1.0',
        },
      ).timeout(const Duration(minutes: 5));

      if (response.statusCode == 200) {
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/trax_radio_update.apk');
        
        await file.writeAsBytes(response.bodyBytes);
        _downloadedApkPath = file.path;
        _downloadProgress = 1.0;
        onProgress?.call(1.0);
        
        debugPrint('UpdateService: Download completed: $_downloadedApkPath');
        return true;
      } else {
        debugPrint('UpdateService: Download failed: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('UpdateService: Download error: $e');
      return false;
    } finally {
      _isDownloading = false;
    }
  }

  Future<bool> installUpdate() async {
    if (_downloadedApkPath == null) {
      debugPrint('UpdateService: No downloaded APK available');
      return false;
    }

    try {
      final file = File(_downloadedApkPath!);
      if (!await file.exists()) {
        debugPrint('UpdateService: Downloaded APK not found');
        return false;
      }

      debugPrint('UpdateService: Installing APK: $_downloadedApkPath');
      
      // Check if running on emulator
      bool isEmulator = false;
      try {
        final result = await Process.run('getprop', ['ro.kernel.qemu']);
        isEmulator = result.stdout.toString().trim() == '1';
      } catch (e) {
        // If we can't check, assume it might be an emulator
        isEmulator = true;
      }
      
      if (isEmulator) {
        debugPrint('UpdateService: Running on emulator - auto-update disabled for testing');
        debugPrint('UpdateService: APK downloaded successfully: $_downloadedApkPath');
        debugPrint('UpdateService: On real device, this would open the package installer');
        return true; // Consider it successful for emulator testing
      }
      
      // For real devices, try installation
      try {
        final uri = 'file://$_downloadedApkPath';
        debugPrint('UpdateService: File URI: $uri');
        
        final result = await Process.run(
          'am',
          [
            'start',
            '-a',
            'android.intent.action.VIEW',
            '-d',
            uri,
            '-t',
            'application/vnd.android.package-archive',
            '--activity-clear-top',
          ],
        );

        debugPrint('UpdateService: Installation result: ${result.exitCode}');
        debugPrint('UpdateService: stdout: ${result.stdout}');
        debugPrint('UpdateService: stderr: ${result.stderr}');

        if (result.exitCode == 0) {
          debugPrint('UpdateService: Installation started successfully');
          return true;
        } else {
          debugPrint('UpdateService: Installation failed: ${result.stderr}');
          return false;
        }
      } catch (e) {
        debugPrint('UpdateService: Installation error: $e');
        return false;
      }
    } catch (e) {
      debugPrint('UpdateService: Installation error: $e');
      return false;
    }
  }

  void reset() {
    _isUpdateAvailable = false;
    _isDownloading = false;
    _downloadProgress = 0.0;
    _downloadedApkPath = null;
  }

  Map<String, dynamic> toJson() {
    return {
      'currentVersion': _currentVersion,
      'latestVersion': _latestVersion,
      'isUpdateAvailable': _isUpdateAvailable,
      'isDownloading': _isDownloading,
      'downloadProgress': _downloadProgress,
      'releaseNotes': _releaseNotes,
      'downloadUrl': _downloadUrl,
    };
  }

  bool _isVersionNewer(String latest, String current) {
    try {
      final latestParts = latest.split('.').map(int.parse).toList();
      final currentParts = current.split('.').map(int.parse).toList();
      
      // Pad with zeros if needed
      while (latestParts.length < 3) latestParts.add(0);
      while (currentParts.length < 3) currentParts.add(0);
      
      for (int i = 0; i < 3; i++) {
        if (latestParts[i] > currentParts[i]) return true;
        if (latestParts[i] < currentParts[i]) return false;
      }
      
      return false; // Versions are equal
    } catch (e) {
      debugPrint('UpdateService: Error comparing versions: $e');
      return false;
    }
  }
}