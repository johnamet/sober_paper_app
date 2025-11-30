import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';
import '../core/constants/app_spacing.dart';
import '../core/constants/app_strings.dart';
import '../core/constants/route_constants.dart';
import '../providers/providers.dart';
import 'panic_modal.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String get encouragingQuote {
    final dayOfYear = DateTime.now().day + DateTime.now().month * 31;
    final index = dayOfYear % AppStrings.encouragingQuotes.length;
    return AppStrings.encouragingQuotes[index];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.add, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              'Freedom Path',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w300,
                fontStyle: FontStyle.italic,
                color: Colors.white.withOpacity(0.95),
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle, color: Colors.white.withOpacity(0.9)),
            onPressed: () {
              Navigator.pushNamed(context, Routes.profile);
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background church image with blur
          Positioned.fill(
            child: Image.asset(
              'assets/images/church_background.png', // You'll need to add this
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                // Fallback gradient if image not available
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color(0xFF1a4d6d),
                        const Color(0xFF2d5a7b),
                        const Color(0xFF1e3a4f),
                      ],
                    ),
                  ),
                );
              },
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppSpacing.md),
                  
                  // Sobriety card - Featured at top!
                  _buildSobrietyCard(),
                  const SizedBox(height: AppSpacing.lg),

                  // Main grid
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left column - Saint card
                      Expanded(
                        child: _buildSaintCard(),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      
                      // Right column - Daily items
                      Expanded(
                        child: Column(
                          children: [
                            _buildDailyReflectionCard(),
                            const SizedBox(height: AppSpacing.md),
                            _buildDailyReadingsCard(),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: AppSpacing.md),

                  // Bottom section
                  _buildPrayersCard(),
                  
                  const SizedBox(height: AppSpacing.md),
                  _buildQuickActionsCard(),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => const PanicModal(),
          );
        },
        backgroundColor: AppColors.panicRed,
        icon: const Icon(Icons.crisis_alert),
        label: Text('PANIC', style: AppTextStyles.button),
      ),
    );
  }

  Widget _buildSaintCard() {
    final todaySaintAsync = ref.watch(todaySaintProvider);

    return todaySaintAsync.when(
      data: (saint) {
        final saintName = saint?.name ?? 'Saint of the Day';
        final summary = saint?.summary ?? 'Discover today\'s saint';
        final displaySummary = summary.length > 80 
            ? '${summary.substring(0, 80)}...' 
            : summary;

        return _buildGlassCard(
          height: 420,
          onTap: () => Navigator.pushNamed(context, Routes.saintOfTheDay),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Saint of the Day',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withOpacity(0.95),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              
              // Saint image with halo effect
              Expanded(
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: saint?.imageUrl != null
                          ? Image.network(
                              saint!.imageUrl,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  _buildSaintPlaceholder(),
                            )
                          : _buildSaintPlaceholder(),
                    ),
                    // Halo effect at top
                    Positioned(
                      top: 20,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          width: 60,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.amber.withOpacity(0.6),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: AppSpacing.md),
              Text(
                saintName.replaceAll('Saint ', 'St. '),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withOpacity(0.95),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                displaySummary,
                style: TextStyle(
                  fontSize: 13,
                  height: 3,
                  color: Colors.white.withOpacity(0.7),
                ),
                maxLines:10 ,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
      loading: () => _buildGlassCard(
        height: 420,
        child: Center(
          child: CircularProgressIndicator(
            color: Colors.white.withOpacity(0.7),
          ),
        ),
      ),
      error: (err, stack) => _buildGlassCard(
        height: 420,
        onTap: () => Navigator.pushNamed(context, Routes.saintOfTheDay),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Saint of the Day',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white.withOpacity(0.95),
              ),
            ),
            const Spacer(),
            Center(
              child: Icon(
                Icons.church,
                size: 80,
                color: Colors.white.withOpacity(0.3),
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _buildSaintPlaceholder() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.withOpacity(0.3),
            Colors.purple.withOpacity(0.3),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.church,
          size: 80,
          color: Colors.white.withOpacity(0.5),
        ),
      ),
    );
  }

  Widget _buildDailyReflectionCard() {
    final reflectionAsync = ref.watch(selectedDateReflectionProvider);

    
    return _buildGlassCard(
      height: 200,
      onTap: () => Navigator.pushNamed(context, Routes.dailyReflection),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.holyBlue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.menu_book,
                  color: AppColors.holyBlue,
                  size: 24,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Daily Reflection',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withOpacity(0.95),
                      ),
                    ),
                    reflectionAsync.when(
                      data: (reflection) {
                        if (reflection?.verseReference != null) {
                          return Text(
                            reflection!.verseReference!,
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.holyBlue.withOpacity(0.8),
                              fontWeight: FontWeight.w500,
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: reflectionAsync.when(
              data: (reflection) {
                print("Home reflection ${reflection?.toString()}");
                if (reflection?.bibleVerse != null && reflection!.bibleVerse!.isNotEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.holyBlue.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.format_quote,
                          color: AppColors.holyBlue.withOpacity(0.4),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            reflection.bibleVerse!,
                            style: TextStyle(
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                              color: Colors.white.withOpacity(0.85),
                              height: 1.5,
                            ),
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return Text(
                  '"Every truth from the scripture, your own hearts is writing"',
                  style: TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: Colors.white.withValues(alpha: 0.7),
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                );
              },
              loading: () => Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.holyBlue.withOpacity(0.5),
                  ),
                ),
              ),
              error: (_, __) => Text(
                '"Every truth from the scripture, your own hearts is writing"',
                style: TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: Colors.white.withOpacity(0.7),
                  height: 1.4,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyReadingsCard() {
    final readingsAsync = ref.watch(todayCatholicReadingsProvider);
    final reflectionAsync = ref.watch(selectedDateReflectionProvider);

    return _buildGlassCard(
      height: 208,
      onTap: () => Navigator.pushNamed(context, Routes.catholicReadings),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Daily Readings',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.95),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: readingsAsync.when(
              data: (readings) {
                if (readings == null || readings.readings.isEmpty) {
                  return _buildDefaultReadingItems();
                }
                
                return reflectionAsync.when(
                  data: (reflection) {
                    return SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Show reflection title if available
                          if (reflection != null && reflection.title.isNotEmpty)
                            _buildReadingItem(
                              Icons.auto_awesome,
                              reflection.title.length > 12
                                  ? '${reflection.title.substring(0, 12)}...'
                                  : reflection.title,
                            ),
                          if (reflection != null && reflection.title.isNotEmpty) 
                            const SizedBox(height: 12),
                          
                          // Show first 2 reading references
                          ...readings.readings.take(2).map((reading) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: _buildReadingItem(
                                  _getReadingIconForType(reading.type),
                                  reading.reference,
                                ),
                              )),
                        ],
                      ),
                    );
                  },
                  loading: () => _buildDefaultReadingItems(),
                  error: (_, __) => _buildDefaultReadingItems(),
                );
              },
              loading: () => Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
              ),
              error: (_, __) => _buildDefaultReadingItems(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultReadingItems() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildReadingItem(
          Icons.auto_awesome,
          DateFormat('MMM d, yyyy').format(DateTime.now()),
        ),
        const SizedBox(height: 8),
        _buildReadingItem(Icons.calendar_today, 'Readings'),
        const SizedBox(height: 8),
        _buildReadingItem(Icons.wb_sunny_outlined, 'The Day'),
      ],
    );
  }

  IconData _getReadingIconForType(String type) {
    if (type.toLowerCase().contains('gospel')) {
      return Icons.auto_stories;
    } else if (type.toLowerCase().contains('psalm')) {
      return Icons.music_note;
    } else if (type.toLowerCase().contains('second')) {
      return Icons.description;
    } else {
      return Icons.menu_book;
    }
  }

  Widget _buildReadingItem(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.white.withValues(alpha: .8)),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withValues(alpha: 0.85),
          
          ),
          softWrap: true,
        ),
      ],
    );
  }

  Widget _buildPrayersCard() {
    return _buildGlassCard(
      height: 180,
      onTap: () => Navigator.pushNamed(context, Routes.resources),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Prayers',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.95),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Our Father',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withOpacity(0.75),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Hail Mary',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withOpacity(0.75),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Glory Be',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withOpacity(0.75),
            ),
          ),
          const Spacer(),
          Icon(
            Icons.church,
            size: 32,
            color: Colors.white.withOpacity(0.2),
          ),
        ],
      ),
    );
  }

  Widget _buildSobrietyCard() {
    final currentStreak = ref.watch(currentStreakProvider);
    final userProfile = ref.watch(currentUserProfileProvider);

    final longestStreak = userProfile.when(
      data: (user) => user?.stats.longestStreak ?? 0,
      loading: () => 0,
      error: (_, __) => 0,
    );

    final startDate = userProfile.when(
      data: (user) => user?.sobrietyStartDate,
      loading: () => null,
      error: (_, __) => null,
    );

    return _buildGlassCard(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            // Fire icon with glow effect
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.orange.withOpacity(0.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.4),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Icon(
                Icons.local_fire_department,
                color: Colors.orange.withOpacity(0.95),
                size: 48,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            
            // Main streak display
            Text(
              'YOUR SOBRIETY JOURNEY',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 2,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$currentStreak',
                  style: TextStyle(
                    fontSize: 72,
                    fontWeight: FontWeight.bold,
                    height: 1,
                    color: Colors.white.withOpacity(0.95),
                  ),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    'DAYS',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: AppSpacing.md),
            
            // Stats row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatBadge(
                  Icons.emoji_events,
                  'Best',
                  '$longestStreak days',
                  Colors.amber,
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.white.withOpacity(0.2),
                ),
                _buildStatBadge(
                  Icons.calendar_today,
                  'Started',
                  startDate != null 
                      ? DateFormat('MMM d').format(startDate)
                      : 'Not set',
                  Colors.blue,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBadge(IconData icon, String label, String value, Color color) {
    return Column(
      children: [
        Icon(
          icon,
          color: color.withOpacity(0.9),
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.white.withOpacity(0.6),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white.withOpacity(0.9),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionsCard() {
    final userProfile = ref.watch(currentUserProfileProvider);
    final hasSponsor = userProfile.when(
      data: (user) => user?.hasSponsor ?? false,
      loading: () => false,
      error: (_, __) => false,
    );

    return _buildGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.95),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _buildQuickAction(
            Icons.calendar_today_outlined,
            'Sobriety Calendar',
            () => Navigator.pushNamed(context, Routes.calendar),
          ),
          const SizedBox(height: 8),
          _buildQuickAction(
            Icons.message_outlined,
            hasSponsor ? 'Message Sponsor' : 'Find a Sponsor',
            () {
              if (hasSponsor) {
                Navigator.pushNamed(context, Routes.community);
              } else {
                Navigator.pushNamed(context, Routes.findSponsor);
              }
            },
          ),
          const SizedBox(height: 8),
          _buildQuickAction(
            Icons.group_outlined,
            'Support Groups',
            () => Navigator.pushNamed(context, Routes.groupList),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Icon(icon, color: Colors.white.withOpacity(0.8), size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.85),
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.white.withOpacity(0.5),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassCard({
    required Widget child,
    double? height,
    VoidCallback? onTap,
  }) {
    final card = ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: height,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
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

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: card,
      );
    }

    return card;
  }
}