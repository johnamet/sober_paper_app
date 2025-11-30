import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/catholic_reading_model.dart';
import '../providers/catholic_reading_providers.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_spacing.dart';

class CatholicReadingsScreen extends ConsumerStatefulWidget {
  const CatholicReadingsScreen({super.key});

  @override
  ConsumerState<CatholicReadingsScreen> createState() =>
      _CatholicReadingsScreenState();
}

class _CatholicReadingsScreenState
    extends ConsumerState<CatholicReadingsScreen> {
  @override
  Widget build(BuildContext context) {
    final selectedDate = ref.watch(selectedReadingDateProvider);
    final readingsAsync = ref.watch(selectedDateReadingsProvider);
    final massVideoAsync = ref.watch(massVideoUrlProvider(selectedDate));

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'Daily Readings',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            fontStyle: FontStyle.italic,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => _selectDate(context),
            tooltip: 'Select Date',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _refreshReadings(),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background church image
          Positioned.fill(
            child: Image.asset(
              'assets/images/church_background.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF1a4d6d),
                      Color(0xFF2d5a7b),
                      Color(0xFF1e3a4f),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Dark overlay
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
          // Main content
          SafeArea(
            child: RefreshIndicator(
              onRefresh: _refreshReadings,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppSpacing.screenPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSpacing.md),
                    // Date selector
                    _buildDateSelector(selectedDate),
                    const SizedBox(height: AppSpacing.md),

                    // Mass video button
                    massVideoAsync.when(
                      data: (url) {
                        if (url != null) {
                          return Column(
                            children: [
                              _buildMassVideoButton(url),
                              const SizedBox(height: AppSpacing.md),
                            ],
                          );
                        }
                        return const SizedBox.shrink();
                      },
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),

                    // Readings content
                    readingsAsync.when(
                      data: (readings) {
                        if (readings == null) {
                          return _buildNoReadings();
                        }
                        return _buildReadingsContent(readings);
                      },
                      loading: () => _buildLoading(),
                      error: (error, stack) => _buildError(error.toString()),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.1),
                  Colors.white.withOpacity(0.05),
                ],
              ),
            ),
            padding: const EdgeInsets.all(20),
            child: child,
          ),
        ),
      ),
    );
  }

  Widget _buildDateSelector(DateTime selectedDate) {
    final dateStr = DateFormat('EEEE, MMMM d, yyyy').format(selectedDate);
    final isToday = _isSameDay(selectedDate, DateTime.now());

    return _buildGlassCard(
      child: Row(
        children: [
          Icon(
            Icons.calendar_today,
            color: AppColors.crossGold,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dateStr,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                if (isToday)
                  Text(
                    'Today',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.holyBlue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
          if (!isToday)
            TextButton(
              onPressed: () {
                ref.read(selectedReadingDateProvider.notifier).selectToday();
              },
              child: Text(
                'Today',
                style: TextStyle(color: AppColors.crossGold),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMassVideoButton(String url) {
    return _buildGlassCard(
      child: InkWell(
        onTap: () => _launchUrl(url),
        borderRadius: BorderRadius.circular(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.holyBlue.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.play_circle_filled,
                color: AppColors.holyBlue,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Watch Daily Mass',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'From Our Lady of Angels Chapel',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.white.withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReadingsContent(DailyCatholicReading readings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Feast day if available
        if (readings.feast != null) ...[
          _buildGlassCard(
            child: Row(
              children: [
                const Icon(
                  Icons.celebration,
                  color: AppColors.crossGold,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    readings.feast!,
                    style: TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      color: Colors.white.withOpacity(0.95),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],

        // Individual readings
        ...readings.readings.map((reading) => _buildReading(reading)),
      ],
    );
  }

  Widget _buildReading(Reading reading) {
    return Column(
      children: [
        _buildGlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Reading type header
              Row(
                children: [
                  Icon(
                    _getReadingIcon(reading.type),
                    color: _getReadingColor(reading.type),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getReadingColor(reading.type).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      reading.type,
                      style: TextStyle(
                        fontSize: 12,
                        color: _getReadingColor(reading.type),
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Reference
              if (reading.reference.isNotEmpty) ...[
                Text(
                  reading.reference,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Reading text in a bordered container
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _getReadingColor(reading.type).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  reading.text,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white.withOpacity(0.9),
                    height: 1.8,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
      ],
    );
  }

  IconData _getReadingIcon(String type) {
    if (type.contains('Gospel')) {
      return Icons.auto_stories;
    } else if (type.contains('Psalm')) {
      return Icons.music_note;
    } else if (type.contains('Second')) {
      return Icons.description;
    }
    return Icons.menu_book;
  }

  Widget _buildLoading() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          children: [
            CircularProgressIndicator(color: AppColors.crossGold),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Loading readings...',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(String error) {
    return _buildGlassCard(
      child: Column(
        children: [
          const Icon(
            Icons.error_outline,
            color: AppColors.panicRed,
            size: 48,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Failed to Load Readings',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            error,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          ElevatedButton.icon(
            onPressed: _refreshReadings,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.crossGold,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoReadings() {
    return _buildGlassCard(
      child: Column(
        children: [
          const Icon(
            Icons.event_busy,
            color: Colors.white54,
            size: 48,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'No Readings Available',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Readings for this date are not available.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getReadingColor(String type) {
    if (type.contains('Gospel')) {
      return AppColors.holyBlue;
    } else if (type.contains('Psalm')) {
      return AppColors.crossGold;
    } else if (type.contains('Second')) {
      return AppColors.graceGreen;
    }
    return AppColors.holyBlue;
  }

  Future<void> _selectDate(BuildContext context) async {
    final selectedDate = ref.read(selectedReadingDateProvider);
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.holyBlue,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      ref.read(selectedReadingDateProvider.notifier).selectDate(picked);
    }
  }

  Future<void> _refreshReadings() async {
    final selectedDate = ref.read(selectedReadingDateProvider);
    final repository = ref.read(catholicReadingRepositoryProvider);
    
    try {
      await repository.refreshReadings(selectedDate);
      ref.invalidate(selectedDateReadingsProvider);
      ref.invalidate(massVideoUrlProvider(selectedDate));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Readings refreshed'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to refresh: $e'),
            backgroundColor: AppColors.panicRed,
          ),
        );
      }
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open Mass video'),
            backgroundColor: AppColors.panicRed,
          ),
        );
      }
    }
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
