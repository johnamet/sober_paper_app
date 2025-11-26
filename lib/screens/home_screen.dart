import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';
import '../core/constants/app_spacing.dart';
import '../core/constants/app_strings.dart';
import '../core/widgets/paper_card.dart';
import '../providers/providers.dart';
import 'panic_modal.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool isReflectionExpanded = false;

  String get encouragingQuote {
    final dayOfYear = DateTime.now().day + DateTime.now().month * 31;
    final index = dayOfYear % AppStrings.encouragingQuotes.length;
    return AppStrings.encouragingQuotes[index];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paperCream,
      appBar: AppBar(
        title: Text(
          AppStrings.appName,
          style: AppTextStyles.h1,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              // TODO: Navigate to profile
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSobrietyCounterCard(),
            const SizedBox(height: AppSpacing.sectionSpacing),
            _buildDailyReflectionCard(),
            const SizedBox(height: AppSpacing.sectionSpacing),
            _buildQuickActionsSection(),
            const SizedBox(height: AppSpacing.sectionSpacing),
            _buildStreakSummary(),
          ],
        ),
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

  Widget _buildSobrietyCounterCard() {
    final currentStreak = ref.watch(currentStreakProvider);
    final userProfile = ref.watch(currentUserProfileProvider);

    // Get longest streak from user profile
    final longestStreak = userProfile.when(
      data: (user) => user?.stats.longestStreak ?? 0,
      loading: () => 0,
      error: (_, __) => 0,
    );

    return PaperCard(
      child: Column(
        children: [
          const Icon(Icons.church, size: 32, color: AppColors.crossGold),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '✟ Day $currentStreak ✟',
            style: AppTextStyles.counter.copyWith(fontSize: 48),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '"$encouragingQuote"',
            style: AppTextStyles.prayer.copyWith(fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildBadge('🔥 Current', '$currentStreak days'),
              _buildBadge('📿 Best', '$longestStreak days'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String label, String value) {
    return Column(
      children: [
        Text(label, style: AppTextStyles.caption),
        const SizedBox(height: 4),
        Text(value, style: AppTextStyles.h3.copyWith(color: AppColors.graceGreen)),
      ],
    );
  }

  Widget _buildDailyReflectionCard() {
    final todayReflection = ref.watch(todayReflectionProvider);

    return todayReflection.when(
      data: (reflection) {
        if (reflection == null) {
          return PaperCard(
            child: Column(
              children: [
                Text('Today\'s Reflection', style: AppTextStyles.h2),
                const Divider(color: AppColors.paperEdge, height: 24),
                Text(
                  'No reflection available today. Check back tomorrow!',
                  style: AppTextStyles.bodyMedium,
                ),
              ],
            ),
          );
        }

        return PaperCard(
          onTap: () {
            setState(() {
              isReflectionExpanded = !isReflectionExpanded;
            });
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Today\'s Reflection', style: AppTextStyles.h2),
              const Divider(color: AppColors.paperEdge, height: 24),
              Text(
                '"${reflection.title}"',
                style: AppTextStyles.prayer,
                maxLines: isReflectionExpanded ? null : 2,
                overflow: isReflectionExpanded ? null : TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                '- ${reflection.author}',
                style: AppTextStyles.caption.copyWith(fontStyle: FontStyle.italic),
              ),
              if (isReflectionExpanded) ...[
                const SizedBox(height: AppSpacing.md),
                Text(
                  reflection.content,
                  style: AppTextStyles.bodyMedium,
                ),
              ],
              const SizedBox(height: 12),
              Center(
                child: Text(
                  isReflectionExpanded ? 'Tap to Close ↑' : 'Read More ↓',
                  style: AppTextStyles.caption.copyWith(color: AppColors.holyBlue),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const PaperCard(
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, st) => PaperCard(
        child: Column(
          children: [
            Text('Today\'s Reflection', style: AppTextStyles.h2),
            const Divider(color: AppColors.paperEdge, height: 24),
            Text(
              'Unable to load reflection. Please check your connection.',
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsSection() {
    return Column(
      children: [
        _buildQuickActionButton(
          icon: Icons.calendar_today_outlined,
          label: 'Sobriety Calendar',
          onTap: () => Navigator.pushNamed(context, '/calendar'),
        ),
        const SizedBox(height: AppSpacing.md),
        _buildQuickActionButton(
          icon: Icons.church_outlined,
          label: 'Morning Prayer',
          onTap: () => Navigator.pushNamed(context, '/reflections'),
        ),
        const SizedBox(height: AppSpacing.md),
        _buildQuickActionButton(
          icon: Icons.message_outlined,
          label: 'Message Sponsor',
          onTap: () => Navigator.pushNamed(context, '/chat'),
        ),
      ],
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return PaperCard(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: AppColors.inkBrown, size: 28),
          const SizedBox(width: AppSpacing.md),
          Text(label, style: AppTextStyles.h3),
          const Spacer(),
          const Icon(Icons.chevron_right, color: AppColors.inkFaded),
        ],
      ),
    );
  }

  Widget _buildStreakSummary() {
    final currentStreak = ref.watch(currentStreakProvider);
    final totalCleanDays = ref.watch(totalCleanDaysProvider);
    final userProfile = ref.watch(currentUserProfileProvider);

    final longestStreak = userProfile.when(
      data: (user) => user?.stats.longestStreak ?? 0,
      loading: () => 0,
      error: (_, __) => 0,
    );

    return PaperCard(
      backgroundColor: AppColors.hopeYellow.withOpacity(0.3),
      child: Column(
        children: [
          _buildStreakRow('Current Streak:', '🔥 $currentStreak days'),
          const SizedBox(height: 8),
          _buildStreakRow('Longest Streak:', '🏆 $longestStreak days'),
          const SizedBox(height: 8),
          _buildStreakRow('Total Clean Days:', '🌟 $totalCleanDays days'),
        ],
      ),
    );
  }

  Widget _buildStreakRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodyMedium),
        Text(value, style: AppTextStyles.bodyMedium.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.graceGreen,
        )),
      ],
    );
  }
}
