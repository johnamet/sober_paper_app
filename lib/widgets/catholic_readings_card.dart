import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/catholic_reading_providers.dart';
import '../screens/catholic_readings_screen.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';
import '../core/constants/app_spacing.dart';
import '../core/widgets/paper_card.dart';

/// A card widget that displays today's first reading snippet
/// and navigates to the full Catholic readings screen
class CatholicReadingsCard extends ConsumerWidget {
  const CatholicReadingsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final readingsAsync = ref.watch(todayCatholicReadingsProvider);

    return PaperCard(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CatholicReadingsScreen(),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.xs),
                    decoration: BoxDecoration(
                      color: AppColors.holyBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.menu_book,
                      color: AppColors.holyBlue,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Daily Readings',
                      style: AppTextStyles.h3.copyWith(
                        color: AppColors.inkBlack,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    color: AppColors.inkFaded,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              // Content
              readingsAsync.when(
                data: (readings) {
                  if (readings == null || readings.readings.isEmpty) {
                    return Text(
                      'Tap to view today\'s Catholic readings',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.inkFaded,
                      ),
                    );
                  }

                  // Show date and feast
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (readings.feast != null) ...[
                        Text(
                          readings.feast!,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.crossGold,
                            fontStyle: FontStyle.italic,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                      ],
                      Text(
                        '${readings.readings.length} reading${readings.readings.length != 1 ? 's' : ''} available',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.inkBrown,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Tap to read more →',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.holyBlue,
                        ),
                      ),
                    ],
                  );
                },
                loading: () => Row(
                  children: [
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'Loading today\'s readings...',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.inkFaded,
                      ),
                    ),
                  ],
                ),
                error: (_, __) => Text(
                  'Unable to load readings. Tap to try again.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.panicRed,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A compact button to navigate to Catholic readings screen
class CatholicReadingsButton extends StatelessWidget {
  const CatholicReadingsButton({super.key});

  @override
  Widget build(BuildContext context) {
    return PaperCard(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CatholicReadingsScreen(),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              const Icon(
                Icons.menu_book,
                color: AppColors.holyBlue,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Daily Catholic Readings',
                style: AppTextStyles.h3.copyWith(
                  color: AppColors.inkBlack,
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.chevron_right,
                color: AppColors.inkFaded,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
