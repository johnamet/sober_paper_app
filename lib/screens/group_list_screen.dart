import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sober_paper/core/widgets/liturgical_paper_card.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';
import '../core/constants/app_spacing.dart';
import '../core/widgets/paper_card.dart';

class GroupListScreen extends ConsumerWidget {
  const GroupListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.paperCream,
      appBar: AppBar(
        title: Text(
          'Support Groups',
          style: AppTextStyles.h1,
        ),
        backgroundColor: AppColors.paperCream,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LiturgicalPaperCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Join a Community',
                    style: AppTextStyles.h2,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Connect with others who understand your journey. Share experiences, find encouragement, and build accountability in a safe, faith-based environment.',
                    style: AppTextStyles.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sectionSpacing),
            // TODO: Add group stream provider and list of groups
            _buildGroupCard(
              groupName: 'New to Recovery',
              description: 'A welcoming group for those just starting their journey to freedom.',
              memberCount: 42,
              lastActivity: 'Active now',
            ),
            const SizedBox(height: AppSpacing.md),
            _buildGroupCard(
              groupName: 'Men of Faith',
              description: 'Brothers supporting each other through prayer, accountability, and biblical truth.',
              memberCount: 28,
              lastActivity: '2h ago',
            ),
            const SizedBox(height: AppSpacing.md),
            _buildGroupCard(
              groupName: 'Women in Recovery',
              description: 'A safe space for women to share struggles and victories in their walk to freedom.',
              memberCount: 35,
              lastActivity: '5h ago',
            ),
            const SizedBox(height: AppSpacing.md),
            _buildGroupCard(
              groupName: 'Young Adults (18-25)',
              description: 'Connect with peers navigating recovery in college and early adulthood.',
              memberCount: 19,
              lastActivity: '1d ago',
            ),
            const SizedBox(height: AppSpacing.md),
            _buildGroupCard(
              groupName: 'Parents & Families',
              description: 'Support for those balancing recovery with the responsibilities of family life.',
              memberCount: 22,
              lastActivity: '3d ago',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupCard({
    required String groupName,
    required String description,
    required int memberCount,
    required String lastActivity,
  }) {
    return PaperCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.graceGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.groups,
                  color: AppColors.graceGreen,
                  size: 28,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(groupName, style: AppTextStyles.h3),
                    const SizedBox(height: 4),
                    Text(
                      '$memberCount members • $lastActivity',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.inkFaded,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(description, style: AppTextStyles.bodyMedium),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // TODO: Implement join group functionality
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.graceGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Join Group',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
