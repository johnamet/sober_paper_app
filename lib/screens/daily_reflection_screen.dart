import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_spacing.dart';
import '../models/catholic_reflection_model.dart';
import '../providers/catholic_reflection_providers.dart';

class DailyReflectionScreen extends ConsumerStatefulWidget {
  const DailyReflectionScreen({super.key});

  @override
  ConsumerState<DailyReflectionScreen> createState() => _DailyReflectionScreenState();
}

class _DailyReflectionScreenState extends ConsumerState<DailyReflectionScreen> {
  @override
  Widget build(BuildContext context) {
    final selectedDate = ref.watch(selectedReflectionDateProvider);
    final reflectionAsync = ref.watch(selectedDateReflectionProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'Daily Reflection',
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
            icon: const Icon(Icons.today),
            onPressed: () {
              ref.read(selectedReflectionDateProvider.notifier).setToday();
            },
            tooltip: 'Today',
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
              onRefresh: () async {
                ref.invalidate(selectedDateReflectionProvider);
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppSpacing.screenPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: AppSpacing.md),
                    _buildDateSelector(selectedDate),
                    const SizedBox(height: AppSpacing.sectionSpacing),
                    reflectionAsync.when(
                      loading: () => _buildLoadingState(),
                      error: (error, stack) => _buildErrorState(error),
                      data: (reflection) {
                        if (reflection == null) {
                          return _buildNoReflectionState(selectedDate);
                        }
                        return _buildReflectionContent(reflection);
                      },
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

  Widget _buildDateSelector(DateTime selectedDate) {
    final dateFormatter = DateFormat('EEEE, MMMM d, yyyy');

    return _buildGlassCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, color: Colors.white),
            onPressed: () {
              final newDate = selectedDate.subtract(const Duration(days: 1));
              ref.read(selectedReflectionDateProvider.notifier).setDate(newDate);
            },
          ),
          Expanded(
            child: InkWell(
              onTap: () => _showDatePicker(context),
              child: Column(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    color: AppColors.crossGold,
                    size: 24,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dateFormatter.format(selectedDate),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, color: Colors.white),
            onPressed: () {
              final newDate = selectedDate.add(const Duration(days: 1));
              final today = DateTime.now();
              if (newDate.isBefore(today.add(const Duration(days: 1)))) {
                ref.read(selectedReflectionDateProvider.notifier).setDate(newDate);
              }
            },
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

  Widget _buildReflectionContent(DailyReflection reflection) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Image Card (if available)
        if (reflection.imageUrl != null && reflection.imageUrl!.isNotEmpty) ...[
          _buildGlassCard(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                reflection.imageUrl!,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],

        // Title Card
        _buildGlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.auto_awesome,
                    color: AppColors.crossGold,
                    size: 24,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      reflection.title,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              if (reflection.author != null && reflection.author!.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'by ${reflection.author}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.6),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
        ),

        // Bible Verse Card (if available)
        if (reflection.hasBibleVerse) ...[
          const SizedBox(height: AppSpacing.md),
          _buildGlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.menu_book,
                      color: AppColors.holyBlue,
                      size: 20,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      reflection.verseReference ?? 'Scripture',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.holyBlue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.holyBlue.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    reflection.bibleVerse!,
                    style: TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      color: Colors.white,
                      height: 1.6,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        // Main Content Card
        const SizedBox(height: AppSpacing.md),
        _buildGlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.article_outlined,
                    color: AppColors.crossGold,
                    size: 20,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    'Reflection',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Divider(
                color: Colors.white.withOpacity(0.3),
                height: 32,
                thickness: 1,
              ),
              Text(
                reflection.content,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.white.withOpacity(0.9),
                  height: 1.8,
                ),
              ),
            ],
          ),
        ),

        // Prayer Card
        const SizedBox(height: AppSpacing.md),
        _buildGlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.church,
                    color: AppColors.crossGold,
                    size: 20,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    'Prayer',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Divider(
                color: Colors.white.withOpacity(0.3),
                height: 32,
                thickness: 1,
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.crossGold.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.format_quote,
                      color: AppColors.crossGold.withOpacity(0.5),
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        reflection.prayer,
                        style: TextStyle(
                          fontSize: 15,
                          fontStyle: FontStyle.italic,
                          color: Colors.white.withOpacity(0.95),
                          height: 1.8,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return _buildGlassCard(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: AppColors.crossGold),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Loading reflection...',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    return _buildGlassCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.cloud_off,
            size: 48,
            color: Colors.white.withOpacity(0.5),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Unable to load reflection',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Please check your connection and try again.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          ElevatedButton.icon(
            onPressed: () {
              ref.invalidate(selectedDateReflectionProvider);
            },
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

  Widget _buildNoReflectionState(DateTime date) {
    return _buildGlassCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.event_busy,
            size: 48,
            color: Colors.white.withOpacity(0.5),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'No reflection available',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'No reflection found for ${DateFormat('MMMM d, yyyy').format(date)}.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          TextButton.icon(
            onPressed: () {
              ref.read(selectedReflectionDateProvider.notifier).setToday();
            },
            icon: const Icon(Icons.today, color: AppColors.crossGold),
            label: Text(
              'View Today',
              style: TextStyle(color: AppColors.crossGold),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showDatePicker(BuildContext context) async {
    final selectedDate = ref.read(selectedReflectionDateProvider);
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.crossGold,
              onPrimary: Colors.white,
              surface: AppColors.paperCream,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != selectedDate) {
      ref.read(selectedReflectionDateProvider.notifier).setDate(picked);
    }
  }
}
