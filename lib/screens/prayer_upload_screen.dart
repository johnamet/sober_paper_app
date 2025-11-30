import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/prayer_upload_service.dart';

/// Debug screen to upload prayers and manage Firestore data
/// Navigate to this screen to upload prayers from the JSON file
class PrayerUploadScreen extends StatefulWidget {
  const PrayerUploadScreen({super.key});

  @override
  State<PrayerUploadScreen> createState() => _PrayerUploadScreenState();
}

class _PrayerUploadScreenState extends State<PrayerUploadScreen> {
  final _uploadService = PrayerUploadService(FirebaseFirestore.instance);
  bool _isLoading = false;
  String _statusMessage = '';
  Map<String, dynamic>? _stats;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final stats = await _uploadService.getPrayerStats();
    setState(() {
      _stats = stats;
    });
  }

  Future<void> _uploadPrayers() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Checking if prayers already exist...';
    });

    try {
      // Check if already uploaded
      final alreadyUploaded = await _uploadService.arePrayersAlreadyUploaded();
      
      if (alreadyUploaded) {
        final shouldReupload = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Prayers Already Exist'),
            content: const Text(
              'Prayers are already in Firestore. Do you want to clear them and re-upload?'
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Re-upload'),
              ),
            ],
          ),
        );

        if (shouldReupload != true) {
          setState(() {
            _isLoading = false;
            _statusMessage = 'Upload cancelled';
          });
          return;
        }

        // Clear existing prayers
        setState(() {
          _statusMessage = 'Clearing existing prayers...';
        });
        await _uploadService.clearAllPrayers();
      }

      // Upload prayers
      setState(() {
        _statusMessage = 'Uploading prayers from JSON...';
      });

      final count = await _uploadService.uploadPrayersFromJson(
        'assets/catholic_prayer.json',
      );

      setState(() {
        _isLoading = false;
        _statusMessage = '✅ Successfully uploaded $count prayers!';
      });

      // Reload stats
      await _loadStats();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully uploaded $count prayers to Firestore!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = '❌ Error: $e';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading prayers: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _clearPrayers() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Prayers?'),
        content: const Text(
          'This will delete all prayers from Firestore. This action cannot be undone.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isLoading = true;
      _statusMessage = 'Clearing prayers...';
    });

    try {
      await _uploadService.clearAllPrayers();
      
      setState(() {
        _isLoading = false;
        _statusMessage = '✅ Cleared all prayers';
      });

      await _loadStats();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All prayers cleared from Firestore'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = '❌ Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prayer Upload Tool'),
        backgroundColor: Colors.brown[700],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Card
            Card(
              color: Colors.brown[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(
                      Icons.cloud_upload,
                      size: 48,
                      color: Colors.brown[700],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Upload Catholic Prayers to Firestore',
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'This will upload prayers from catholic_prayer.json to your Firestore database',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Stats Card
            if (_stats != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.bar_chart, color: Colors.brown[700]),
                          const SizedBox(width: 8),
                          Text(
                            'Firestore Statistics',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                      const Divider(),
                      const SizedBox(height: 8),
                      Text(
                        'Total Prayers: ${_stats!['total']}',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      if ((_stats!['byCategory'] as Map).isNotEmpty) ...[
                        Text(
                          'By Category:',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        ...(_stats!['byCategory'] as Map<String, int>)
                            .entries
                            .map((entry) => Padding(
                              padding: const EdgeInsets.only(left: 16, top: 4),
                              child: Text(
                                '• ${entry.key}: ${entry.value} prayers',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            )),
                      ],
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 24),

            // Upload Button
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _uploadPrayers,
              icon: const Icon(Icons.upload),
              label: const Text('Upload Prayers to Firestore'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.brown[700],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
            ),

            const SizedBox(height: 12),

            // Clear Button
            OutlinedButton.icon(
              onPressed: _isLoading ? null : _clearPrayers,
              icon: const Icon(Icons.delete_sweep),
              label: const Text('Clear All Prayers'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                padding: const EdgeInsets.all(16),
              ),
            ),

            const SizedBox(height: 12),

            // Refresh Stats Button
            TextButton.icon(
              onPressed: _isLoading ? null : _loadStats,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh Statistics'),
            ),

            const SizedBox(height: 24),

            // Status Message
            if (_statusMessage.isNotEmpty)
              Card(
                color: _statusMessage.contains('✅')
                    ? Colors.green[50]
                    : _statusMessage.contains('❌')
                        ? Colors.red[50]
                        : Colors.grey[100],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      if (_isLoading)
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      else
                        Icon(
                          _statusMessage.contains('✅')
                              ? Icons.check_circle
                              : _statusMessage.contains('❌')
                                  ? Icons.error
                                  : Icons.info,
                          color: _statusMessage.contains('✅')
                              ? Colors.green
                              : _statusMessage.contains('❌')
                                  ? Colors.red
                                  : Colors.grey,
                        ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _statusMessage,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 24),

            // Instructions Card
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue[700]),
                        const SizedBox(width: 8),
                        Text(
                          'Instructions',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const Divider(),
                    const SizedBox(height: 8),
                    const Text(
                      '1. Tap "Upload Prayers to Firestore" to populate the database\n'
                      '2. The app will check if prayers already exist\n'
                      '3. If they exist, you\'ll be asked if you want to re-upload\n'
                      '4. Wait for the success message\n'
                      '5. Prayers will now be available throughout the app\n'
                      '\n'
                      'Note: This screen is for development purposes. '
                      'Remove it before releasing to production.',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
