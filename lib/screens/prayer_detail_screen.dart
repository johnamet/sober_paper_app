import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../domain/entities/prayer.dart';

class PrayerDetailScreen extends StatefulWidget {
  final Prayer prayer;

  const PrayerDetailScreen({
    super.key,
    required this.prayer,
  });

  @override
  State<PrayerDetailScreen> createState() => _PrayerDetailScreenState();
}

class _PrayerDetailScreenState extends State<PrayerDetailScreen> {
  bool _showLatinVersion = false;

  Widget _buildGlassCard({
    required Widget child,
    EdgeInsets? padding,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: padding ?? const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.1),
                Colors.white.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Prayer',
          style: TextStyle(
            fontSize: 22,
            color: Colors.white.withOpacity(0.95),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white.withOpacity(0.95)),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareAsImage,
            tooltip: 'Share as image',
          ),
          IconButton(
            icon: const Icon(Icons.text_snippet),
            onPressed: _shareAsText,
            tooltip: 'Share as text',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/images/church_background.png',
              fit: BoxFit.cover,
            ),
          ),
          // Dark gradient overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.5),
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
          ),
          // Content
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Main prayer card
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: _buildGlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title with category badge
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  widget.prayer.title,
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white.withOpacity(0.95),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: _getCategoryColor(widget.prayer.category),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: _getCategoryColor(widget.prayer.category).withOpacity(0.3),
                                      blurRadius: 8,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: Text(
                                  _getCategoryLabel(widget.prayer.category),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Prayer content
                          SelectableText(
                            _showLatinVersion && widget.prayer.latinVersion != null
                                ? widget.prayer.latinVersion!
                                : widget.prayer.content,
                            style: TextStyle(
                              fontSize: 16,
                              height: 1.8,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),

                          // Notes if available
                          if (widget.prayer.notes != null) ...[
                            const SizedBox(height: 20),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFD4AF37).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFFD4AF37).withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    size: 20,
                                    color: const Color(0xFFD4AF37).withOpacity(0.9),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      widget.prayer.notes!,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontStyle: FontStyle.italic,
                                        color: Colors.white.withOpacity(0.85),
                                        height: 1.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          const SizedBox(height: 24),

                          // Latin version toggle
                          if (widget.prayer.latinVersion != null)
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.1),
                                  width: 1,
                                ),
                              ),
                              child: SwitchListTile(
                                title: Text(
                                  'Show Latin Version',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                subtitle: Text(
                                  'Original language',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.6),
                                    fontSize: 12,
                                  ),
                                ),
                                value: _showLatinVersion,
                                onChanged: (value) {
                                  setState(() {
                                    _showLatinVersion = value;
                                  });
                                },
                                activeColor: const Color(0xFFD4AF37),
                                activeTrackColor: const Color(0xFFD4AF37).withOpacity(0.5),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  // Action buttons
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        // Copy to clipboard
                        ElevatedButton.icon(
                          onPressed: _copyToClipboard,
                          icon: const Icon(Icons.copy),
                          label: const Text('Copy to Clipboard'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.withOpacity(0.8),
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 50),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Mark as prayed
                        ElevatedButton.icon(
                          onPressed: _markAsPrayed,
                          icon: const Icon(Icons.check_circle_outline),
                          label: const Text('Mark as Prayed'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.withOpacity(0.8),
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 50),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getCategoryLabel(PrayerCategory category) {
    switch (category) {
      case PrayerCategory.morning:
        return 'Morning';
      case PrayerCategory.evening:
        return 'Evening';
      case PrayerCategory.rosary:
        return 'Marian';
      case PrayerCategory.emergency:
        return 'Strength';
      case PrayerCategory.liturgy:
        return 'Liturgy';
    }
  }

  Color _getCategoryColor(PrayerCategory category) {
    switch (category) {
      case PrayerCategory.morning:
        return Colors.orange.withOpacity(0.8);
      case PrayerCategory.evening:
        return Colors.blue.withOpacity(0.8);
      case PrayerCategory.rosary:
        return Colors.purple.withOpacity(0.8);
      case PrayerCategory.emergency:
        return Colors.red.withOpacity(0.8);
      case PrayerCategory.liturgy:
        return Colors.green.withOpacity(0.8);
    }
  }

  Future<void> _copyToClipboard() async {
    final text = _showLatinVersion && widget.prayer.latinVersion != null
        ? widget.prayer.latinVersion!
        : widget.prayer.content;

    await Clipboard.setData(ClipboardData(
      text: '${widget.prayer.title}\n\n$text',
    ));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Prayer copied to clipboard'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _shareAsText() async {
    final text = '''
${widget.prayer.title}

${widget.prayer.content}

${widget.prayer.latinVersion != null ? '\nLatin Version:\n${widget.prayer.latinVersion}' : ''}

${widget.prayer.notes != null ? '\nNote: ${widget.prayer.notes}' : ''}

— Shared from Sober Paper App
''';

    await Share.share(
      text,
      subject: widget.prayer.title,
    );
  }

  Future<void> _shareAsImage() async {
    try {
      // Show the prayer card generation dialog
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => _PrayerCardGeneratorDialog(
          prayer: widget.prayer,
          showLatin: _showLatinVersion,
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sharing prayer: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _markAsPrayed() {
    // TODO: Implement prayer tracking
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Marked "${widget.prayer.title}" as prayed ✓'),
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            // TODO: Implement undo
          },
        ),
      ),
    );
  }
}

/// Dialog that generates and shares a prayer card as an image
class _PrayerCardGeneratorDialog extends StatefulWidget {
  final Prayer prayer;
  final bool showLatin;

  const _PrayerCardGeneratorDialog({
    required this.prayer,
    this.showLatin = false,
  });

  @override
  State<_PrayerCardGeneratorDialog> createState() => _PrayerCardGeneratorDialogState();
}

class _PrayerCardGeneratorDialogState extends State<_PrayerCardGeneratorDialog> {
  final GlobalKey _cardKey = GlobalKey();
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    _generateAndShare();
  }

  Future<void> _generateAndShare() async {
    setState(() {
      _isGenerating = true;
    });

    // Wait for the widget to be fully rendered and painted
    await Future.delayed(const Duration(milliseconds: 100));
    
    // Wait for the next frame to ensure the widget is laid out
    await WidgetsBinding.instance.endOfFrame;
    
    // Add another small delay to ensure painting is complete
    await Future.delayed(const Duration(milliseconds: 400));

    try {
      // Capture the widget as an image
      final boundary = _cardKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) throw Exception('Could not find render boundary');
      
      // Ensure boundary is fully painted before capturing
      if (boundary.debugNeedsPaint) {
        throw Exception('Widget is not ready for capture yet');
      }
      
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) throw Exception('Could not convert image to bytes');

      final pngBytes = byteData.buffer.asUint8List();

      // Save to temporary file
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/prayer_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(pngBytes);

      // Share the image
      await Share.shareXFiles(
        [XFile(file.path)],
        text: widget.prayer.title,
      );

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_isGenerating) ...[
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              const Text('Generating prayer card...'),
            ],
            // Hidden prayer card for rendering
            Opacity(
              opacity: 0.0,
              child: SizedBox(
                width: 800,
                child: RepaintBoundary(
                  key: _cardKey,
                  child: _PrayerCardWidget(
                    prayer: widget.prayer,
                    showLatin: widget.showLatin,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Beautiful prayer card widget for image generation
class _PrayerCardWidget extends StatelessWidget {
  final Prayer prayer;
  final bool showLatin;

  const _PrayerCardWidget({
    required this.prayer,
    this.showLatin = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 800,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFFFF8E7),
            const Color(0xFFFFF0D4),
          ],
        ),
        border: Border.all(
          color: const Color(0xFF8B7355),
          width: 3,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Decorative top border
          Container(
            height: 4,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  const Color(0xFF8B7355),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Title
          Text(
            prayer.title,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2B2B2B),
              fontFamily: 'serif',
            ),
          ),
          const SizedBox(height: 8),

          // Category badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF8B7355),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              _getCategoryLabel(prayer.category),
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Prayer content
          Text(
            showLatin && prayer.latinVersion != null
                ? prayer.latinVersion!
                : prayer.content,
            style: const TextStyle(
              fontSize: 20,
              height: 1.8,
              color: Color(0xFF2B2B2B),
              fontFamily: 'serif',
            ),
          ),

          const SizedBox(height: 32),

          // Decorative bottom border
          Container(
            height: 4,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  const Color(0xFF8B7355),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Footer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Sober Paper App',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF8B7355),
                  fontStyle: FontStyle.italic,
                ),
              ),
              Icon(
                Icons.auto_stories,
                color: const Color(0xFF8B7355),
                size: 20,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getCategoryLabel(PrayerCategory category) {
    switch (category) {
      case PrayerCategory.morning:
        return 'Morning Prayer';
      case PrayerCategory.evening:
        return 'Evening Prayer';
      case PrayerCategory.rosary:
        return 'Marian Prayer';
      case PrayerCategory.emergency:
        return 'Prayer for Strength';
      case PrayerCategory.liturgy:
        return 'Liturgical Prayer';
    }
  }
}
