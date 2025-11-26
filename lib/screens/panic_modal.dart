import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';
import '../core/constants/app_spacing.dart';
import '../core/constants/app_strings.dart';
import '../core/widgets/paper_card.dart';
import '../providers/providers.dart';
import '../domain/entities/panic_request.dart';

class PanicModal extends ConsumerWidget {
  const PanicModal({super.key});

  Future<void> _callHotline() async {
    final uri = Uri(scheme: 'tel', path: AppStrings.crisisHotlineNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _createPanicRequest(BuildContext context, WidgetRef ref) async {
    final createRequest = ref.read(createPanicRequestProvider);
    final userId = ref.read(currentUserIdProvider);
    final userProfile = ref.read(currentUserProfileProvider).value;
    final currentStreak = ref.read(currentStreakProvider);

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in to request support'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      await createRequest.call(
        requesterId: userId,
        requesterName: userProfile?.displayName ?? 'Anonymous',
        requesterDayCount: currentStreak,
        connectionType: ConnectionType.chat,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Help is on the way! A volunteer will connect with you soon.'),
            backgroundColor: AppColors.graceGreen,
            duration: Duration(seconds: 4),
          ),
        );
        Navigator.pop(context);
      }
    } on ArgumentError catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send alert: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (_, controller) => Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: const BoxDecoration(
          color: AppColors.paperWhite,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: AppColors.paperShadow,
              blurRadius: 16,
              spreadRadius: 2,
            ),
          ],
        ),
        child: ListView(
          controller: controller,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.inkFaded,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            
            // Header
            Text(
              'Need Support Right Now?',
              style: AppTextStyles.h1.copyWith(color: AppColors.panicRed),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: AppSpacing.lg),
            
            // Panic button (large red circle)
            Center(
              child: GestureDetector(
                onTap: () => _createPanicRequest(context, ref),
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    color: AppColors.panicRed,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.panicRed.withOpacity(0.4),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.crisis_alert,
                        size: 48,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'PANIC',
                        style: AppTextStyles.h2.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: AppSpacing.lg),
            
            // While you wait section
            PaperCard(
              backgroundColor: AppColors.hopeYellow.withOpacity(0.2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '✍️ While you wait...',
                    style: AppTextStyles.h3,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    '• Breathe in... 1, 2, 3',
                    style: AppTextStyles.bodyMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '• Breathe out... 1, 2, 3',
                    style: AppTextStyles.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const Divider(color: AppColors.paperEdge),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    '✟ Quick Prayer ✟',
                    style: AppTextStyles.h3.copyWith(color: AppColors.prayerPurple),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    AppStrings.jesusPrayerShort,
                    style: AppTextStyles.prayer,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: AppSpacing.lg),
            
            // Call hotline button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _callHotline,
                icon: const Icon(Icons.phone),
                label: Text(
                  'Call Crisis Hotline Instead',
                  style: AppTextStyles.button.copyWith(color: AppColors.panicRed),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  side: const BorderSide(color: AppColors.panicRed, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: AppSpacing.md),
            
            // Hotline info
            Center(
              child: Column(
                children: [
                  Text(
                    '📞 ${AppStrings.crisisHotlineNumber} (24/7)',
                    style: AppTextStyles.caption,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppStrings.crisisTextLine,
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
