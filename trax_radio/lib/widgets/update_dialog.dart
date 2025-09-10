import 'package:flutter/material.dart';
import '../update_service.dart';

class UpdateDialog extends StatefulWidget {
  final UpdateService updateService;
  final VoidCallback? onUpdateInstalled;

  const UpdateDialog({
    super.key,
    required this.updateService,
    this.onUpdateInstalled,
  });

  @override
  State<UpdateDialog> createState() => _UpdateDialogState();
}

class _UpdateDialogState extends State<UpdateDialog> {
  bool _isDownloading = false;
  double _downloadProgress = 0.0;
  String _statusMessage = '';

  @override
  void initState() {
    super.initState();
    _isDownloading = widget.updateService.isDownloading;
    _downloadProgress = widget.updateService.downloadProgress;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.grey[900],
      title: Row(
        children: [
          Icon(
            Icons.system_update,
            color: Colors.orange,
            size: 28,
          ),
          SizedBox(width: 12),
          Text(
            'Update Available',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      content: Container(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Version info
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Current Version',
                        style: TextStyle(
                          color: Colors.grey[300],
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        'v${widget.updateService.currentVersion ?? 'Unknown'}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Latest Version',
                        style: TextStyle(
                          color: Colors.grey[300],
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        'v${widget.updateService.latestVersion ?? 'Unknown'}',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 16),

            // Download progress
            if (_isDownloading) ...[
              Text(
                'Downloading update...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 8),
              LinearProgressIndicator(
                value: _downloadProgress,
                backgroundColor: Colors.grey[700],
                valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
              ),
              SizedBox(height: 8),
              Text(
                '${(_downloadProgress * 100).toInt()}%',
                style: TextStyle(
                  color: Colors.grey[300],
                  fontSize: 14,
                ),
              ),
            ],

            // Status message
            if (_statusMessage.isNotEmpty) ...[
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue[900],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _statusMessage,
                  style: TextStyle(
                    color: Colors.blue[100],
                    fontSize: 12,
                  ),
                ),
              ),
            ],

            // Release notes preview
            if (widget.updateService.releaseNotes != null && 
                widget.updateService.releaseNotes!.isNotEmpty) ...[
              SizedBox(height: 16),
              Text(
                'What\'s New:',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Container(
                height: 100,
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    widget.updateService.releaseNotes!,
                    style: TextStyle(
                      color: Colors.grey[300],
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        // Cancel button
        TextButton(
          onPressed: _isDownloading ? null : () => Navigator.of(context).pop(),
          child: Text(
            'Later',
            style: TextStyle(color: Colors.grey[400]),
          ),
        ),

        // Download/Install button
        ElevatedButton(
          onPressed: _isDownloading ? null : _handleUpdateAction,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
          ),
          child: Text(
            _isDownloading 
                ? 'Downloading...' 
                : widget.updateService.downloadedApkPath != null
                    ? 'Install Now'
                    : 'Download Update',
          ),
        ),
      ],
    );
  }

  Future<void> _handleUpdateAction() async {
    if (widget.updateService.downloadedApkPath != null) {
      // Install the downloaded APK
      await _installUpdate();
    } else {
      // Download the update
      await _downloadUpdate();
    }
  }

  Future<void> _downloadUpdate() async {
    setState(() {
      _isDownloading = true;
      _statusMessage = 'Starting download...';
    });

    try {
      final success = await widget.updateService.downloadUpdate(
        onProgress: (progress) {
          setState(() {
            _downloadProgress = progress;
            _statusMessage = 'Downloading... ${(progress * 100).toInt()}%';
          });
        },
      );

      if (success) {
        setState(() {
          _isDownloading = false;
          _statusMessage = 'Download completed! Ready to install.';
        });
      } else {
        setState(() {
          _isDownloading = false;
          _statusMessage = 'Download failed. Please try again.';
        });
      }
    } catch (e) {
      setState(() {
        _isDownloading = false;
        _statusMessage = 'Download error: $e';
      });
    }
  }

  Future<void> _installUpdate() async {
    setState(() {
      _statusMessage = 'Installing update...';
    });

    try {
      final success = await widget.updateService.installUpdate();
      
      if (success) {
        setState(() {
          _statusMessage = 'Installation initiated. Please follow the prompts.';
        });
        
        // Close dialog after a short delay
        Future.delayed(Duration(seconds: 2), () {
          if (mounted) {
            Navigator.of(context).pop();
            widget.onUpdateInstalled?.call();
          }
        });
      } else {
        setState(() {
          _statusMessage = 'Installation failed. Please try again.';
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Installation error: $e';
      });
    }
  }
}
