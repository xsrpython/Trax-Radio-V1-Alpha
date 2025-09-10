import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:package_info_plus/package_info_plus.dart';

class UpdateService {
  static final UpdateService _instance = UpdateService._internal();
  factory UpdateService() => _instance;
  UpdateService._internal();

  // GitHub repository info - UPDATE THESE WITH YOUR ACTUAL REPO
  static const String _githubOwner = 'xerpython'; // Your GitHub username
  static const String _githubRepo = 'TraxRadio'; // Your repository name
  static const String _githubApiUrl = 'https://api.github.com/repos/$_githubOwner/$_githubRepo/releases/latest';

  String? _latestVersion;
  String? _downloadUrl;
  String? _releaseNotes;
  String? _currentVersion;
  bool _isUpdateAvailable = false;
  bool _isDownloading = false;
  double _downloadProgress = 0.0;
  String? _downloadedApkPath;

  // Getters
  String? get latestVersion => _latestVersion;
  String? get downloadUrl => _downloadUrl;
  String? get releaseNotes => _releaseNotes;
  String? get currentVersion => _currentVersion;
  bool get isUpdateAvailable => _isUpdateAvailable;
  bool get isDownloading => _isDownloading;
  double get downloadProgress => _downloadProgress;
  String? get downloadedApkPath => _downloadedApkPath;

  // Initialize the service
  Future<void> initialize() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      _currentVersion = packageInfo.version;
      debugPrint('UpdateService: Current version: $_currentVersion');
    } catch (e) {
      debugPrint('UpdateService: Error getting current version: $e');
    }
  }

  // Check for updates
  Future<bool> checkForUpdates() async {
    try {
      debugPrint('UpdateService: Checking for updates...');
      
      final response = await http.get(
        Uri.parse(_githubApiUrl),
        headers: {
          'Accept': 'application/vnd.github.v3+json',
          'User-Agent': 'TraxRadio/1.0',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _latestVersion = data['tag_name']?.replaceAll('v', '') ?? '';
        _releaseNotes = data['body'] ?? '';
        
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

        debugPrint('UpdateService: Latest version: $_latestVersion');
        debugPrint('UpdateService: Download URL: $_downloadUrl');

        if (_latestVersion != null && _currentVersion != null) {
          _isUpdateAvailable = _isVersionNewer(_latestVersion!, _currentVersion!);
          debugPrint('UpdateService: Update available: $_isUpdateAvailable');
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

  // Compare version strings (e.g., "1.0.1" vs "1.0.0")
  bool _isVersionNewer(String latest, String current) {
    try {
      final latestParts = latest.split('.').map(int.parse).toList();
      final currentParts = current.split('.').map(int.parse).toList();

      // Pad with zeros to ensure same length
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

  // Download APK
  Future<bool> downloadUpdate({Function(double)? onProgress}) async {
    if (_downloadUrl == null) {
      debugPrint('UpdateService: No download URL available');
      return false;
    }

    try {
      _isDownloading = true;
      _downloadProgress = 0.0;

      debugPrint('UpdateService: Starting download from $_downloadUrl');

      final response = await http.get(
        Uri.parse(_downloadUrl!),
        headers: {'User-Agent': 'TraxRadio/1.0'},
      );

      if (response.statusCode == 200) {
        // Get downloads directory
        final directory = await getApplicationDocumentsDirectory();
        final downloadsDir = Directory('${directory.path}/downloads');
        if (!await downloadsDir.exists()) {
          await downloadsDir.create(recursive: true);
        }

        // Create APK file
        final apkFile = File('${downloadsDir.path}/trax-radio-uk-${_latestVersion}.apk');
        final sink = apkFile.openWrite();

        // Download with progress tracking
        final totalBytes = response.contentLength ?? 0;
        int downloadedBytes = 0;

        for (final chunk in response.stream) {
          sink.add(chunk);
          downloadedBytes += chunk.length;
          
          if (totalBytes > 0) {
            _downloadProgress = downloadedBytes / totalBytes;
            onProgress?.call(_downloadProgress);
          }
        }

        await sink.close();
        _downloadedApkPath = apkFile.path;
        _isDownloading = false;
        _downloadProgress = 1.0;

        debugPrint('UpdateService: Download completed: $_downloadedApkPath');
        return true;
      } else {
        debugPrint('UpdateService: Download failed: ${response.statusCode}');
        _isDownloading = false;
        return false;
      }
    } catch (e) {
      debugPrint('UpdateService: Download error: $e');
      _isDownloading = false;
      return false;
    }
  }

  // Install APK (requires user permission)
  Future<bool> installUpdate() async {
    if (_downloadedApkPath == null) {
      debugPrint('UpdateService: No downloaded APK available');
      return false;
    }

    try {
      final file = File(_downloadedApkPath!);
      if (!await file.exists()) {
        debugPrint('UpdateService: Downloaded APK file not found');
        return false;
      }

      debugPrint('UpdateService: Installing APK: $_downloadedApkPath');
      
      // This will open the APK file, which should trigger Android's installer
      // The user will need to manually confirm the installation
      final result = await Process.run('am', [
        'start',
        '-a',
        'android.intent.action.VIEW',
        '-d',
        'file://$_downloadedApkPath',
        '-t',
        'application/vnd.android.package-archive'
      ]);

      if (result.exitCode == 0) {
        debugPrint('UpdateService: APK installation initiated');
        return true;
      } else {
        debugPrint('UpdateService: Failed to initiate APK installation: ${result.stderr}');
        return false;
      }
    } catch (e) {
      debugPrint('UpdateService: Installation error: $e');
      return false;
    }
  }

  // Reset update state
  void reset() {
    _isUpdateAvailable = false;
    _isDownloading = false;
    _downloadProgress = 0.0;
    _downloadedApkPath = null;
  }

  // Get update info for display
  Map<String, dynamic> getUpdateInfo() {
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
}
