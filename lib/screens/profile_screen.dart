import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';
import '../core/constants/app_spacing.dart';
import '../core/constants/route_constants.dart';
import '../providers/providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProfileProvider);
    final currentStreak = ref.watch(currentStreakProvider);
    final totalDays = ref.watch(totalCleanDaysProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'My Profile',
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
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.pushNamed(context, Routes.editProfile);
            },
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
            child: userAsync.when(
              loading: () => Center(
                child: CircularProgressIndicator(
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
              error: (error, stack) => Center(
                child: _buildGlassCard(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.white.withOpacity(0.7),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Error loading profile',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withOpacity(0.95),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        error.toString(),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              data: (user) {
                if (user == null) {
                  return Center(
                    child: Text(
                      'No user data available',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  );
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.screenPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: AppSpacing.md),
                      _buildProfileHeader(context, user),
                      const SizedBox(height: AppSpacing.sectionSpacing),
                      _buildSobrietyStats(user, currentStreak, totalDays),
                      const SizedBox(height: AppSpacing.sectionSpacing),
                      _buildJourneyStats(user),
                      const SizedBox(height: AppSpacing.sectionSpacing),
                      _buildVolunteerSection(context, ref, user),
                      const SizedBox(height: AppSpacing.sectionSpacing),
                      _buildAccountSection(context, ref, user),
                      const SizedBox(height: AppSpacing.lg),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, user) {
    return _buildGlassCard(
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white.withOpacity(0.2),
            child: Text(
              user.displayName.isNotEmpty ? user.displayName[0].toUpperCase() : '?',
              style: TextStyle(
                color: Colors.white,
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            user.displayName,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.95),
            ),
            textAlign: TextAlign.center,
          ),
          if (user.email != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              user.email!,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.church,
                  size: 16,
                  color: Colors.white.withOpacity(0.9),
                ),
                const SizedBox(width: 4),
                Text(
                  user.isVolunteer ? 'Volunteer Sponsor' : 'Member',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSobrietyStats(user, int currentStreak, int totalDays) {
    final startDate = user.sobrietyStartDate;
    final formattedDate = startDate != null
        ? DateFormat('MMMM d, yyyy').format(startDate)
        : 'Not set';

    return _buildGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.favorite,
                color: Colors.red.withOpacity(0.9),
                size: 24,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Sobriety Journey',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withOpacity(0.95),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _buildStatRow(
            icon: Icons.calendar_today,
            label: 'Start Date',
            value: formattedDate,
            color: Colors.white.withOpacity(0.9),
          ),
          const SizedBox(height: AppSpacing.md),
          _buildStatRow(
            icon: Icons.local_fire_department,
            label: 'Current Streak',
            value: '$currentStreak days',
            color: Colors.orange.withOpacity(0.9),
          ),
          const SizedBox(height: AppSpacing.md),
          _buildStatRow(
            icon: Icons.emoji_events,
            label: 'Total Clean Days',
            value: '$totalDays days',
            color: Colors.green.withOpacity(0.9),
          ),
          const SizedBox(height: AppSpacing.md),
          _buildStatRow(
            icon: Icons.trending_up,
            label: 'Longest Streak',
            value: '${user.stats.longestStreak} days',
            color: Colors.white.withOpacity(0.9),
          ),
        ],
      ),
    );
  }

  Widget _buildJourneyStats(user) {
    return _buildGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_graph,
                color: Colors.amber.withOpacity(0.9),
                size: 24,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Activity Stats',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withOpacity(0.95),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.book,
                  label: 'Reflections',
                  value: '${user.stats.totalReflections}',
                  color: AppColors.graceGreen,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.church,
                  label: 'Prayers',
                  value: '${user.stats.totalPrayers}',
                  color: AppColors.crossGold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.refresh,
                  label: 'Relapses',
                  value: '${user.stats.totalRelapses}',
                  color: AppColors.panicRed,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.timeline,
                  label: 'Total Days',
                  value: '${user.stats.totalDaysClean}',
                  color: AppColors.inkLight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVolunteerSection(BuildContext context, WidgetRef ref, user) {
    return _buildGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.volunteer_activism,
                color: Colors.green.withOpacity(0.9),
                size: 24,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Volunteer Status',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withOpacity(0.95),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (user.isVolunteer) ...[
            Row(
              children: [
                Icon(
                  user.isAvailable ? Icons.check_circle : Icons.do_not_disturb,
                  color: user.isAvailable ? Colors.green.withOpacity(0.9) : Colors.white.withOpacity(0.5),
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  user.isAvailable ? 'Available for sponsorship' : 'Not available',
                  style: TextStyle(
                    fontSize: 14,
                    color: user.isAvailable ? Colors.green.withOpacity(0.9) : Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Thank you for volunteering to help others in their journey to freedom! You can manage your availability in settings.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.85),
                height: 1.4,
              ),
            ),
          ] else ...[
            Text(
              'You can become a volunteer sponsor to help others on their journey. Share your experience, strength, and hope with those who need it.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.85),
                height: 1.4,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final confirmed = await _showVolunteerDialog(context);
                  if (confirmed == true) {
                    try {
                      final updateUseCase = ref.read(updateUserProfileProvider);
                      await updateUseCase(
                        uid: user.uid,
                        isVolunteer: true,
                      );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Thank you for volunteering!'),
                            backgroundColor: AppColors.graceGreen,
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error: ${e.toString()}'),
                            backgroundColor: AppColors.panicRed,
                          ),
                        );
                      }
                    }
                  }
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
                  'Become a Volunteer',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAccountSection(BuildContext context, WidgetRef ref, user) {
    return _buildGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.settings,
                color: Colors.white.withOpacity(0.9),
                size: 24,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Account',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withOpacity(0.95),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _buildAccountOption(
            icon: Icons.notifications,
            title: 'Notifications',
            subtitle: user.preferences.notifications ? 'Enabled' : 'Disabled',
            onTap: () {
              Navigator.pushNamed(context, Routes.settings);
            },
          ),
          const Divider(height: AppSpacing.lg),
          _buildAccountOption(
            icon: Icons.privacy_tip,
            title: 'Privacy',
            subtitle: 'Privacy level: ${user.preferences.privacyLevel}',
            onTap: () {
              Navigator.pushNamed(context, Routes.settings);
            },
          ),
          const Divider(height: AppSpacing.lg),
          _buildAccountOption(
            icon: Icons.info,
            title: 'Member Since',
            subtitle: user.createdAt != null
                ? DateFormat('MMMM yyyy').format(user.createdAt!)
                : 'Unknown',
            onTap: null,
          ),
          const Divider(height: AppSpacing.lg),
          _buildAccountOption(
            icon: Icons.logout,
            title: 'Sign Out',
            subtitle: 'Log out of your account',
            titleColor: AppColors.panicRed,
            onTap: () async {
              final confirmed = await _showLogoutDialog(context);
              if (confirmed == true) {
                try {
                  final logout = ref.read(logoutProvider);
                  await logout();
                  if (context.mounted) {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      Routes.login,
                      (route) => false,
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error signing out: ${e.toString()}'),
                        backgroundColor: AppColors.panicRed,
                      ),
                    );
                  }
                }
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withOpacity(0.95),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white.withOpacity(0.95),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAccountOption({
    required IconData icon,
    required String title,
    required String subtitle,
    Color? titleColor,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(
              icon,
              color: titleColor ?? Colors.white.withOpacity(0.8),
              size: 24,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: titleColor ?? Colors.white.withOpacity(0.95),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
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

  Future<bool?> _showLogoutDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.paperCream,
        title: Text(
          'Sign Out',
          style: AppTextStyles.h2,
        ),
        content: Text(
          'Are you sure you want to sign out?',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.inkLight,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Sign Out',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.panicRed,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
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

  Future<bool?> _showVolunteerDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.paperCream,
        title: Text(
          'Become a Volunteer Sponsor',
          style: AppTextStyles.h2,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'As a volunteer sponsor, you will:',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            _buildDialogBullet('Be available to support others'),
            _buildDialogBullet('Share your experience and hope'),
            _buildDialogBullet('Provide accountability and prayer'),
            _buildDialogBullet('Help guide others to freedom'),
            const SizedBox(height: AppSpacing.md),
            Text(
              'You can always change your availability in settings.',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.inkFaded,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.inkLight,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Volunteer',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.graceGreen,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogBullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4, left: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ', style: AppTextStyles.bodyMedium),
          Expanded(
            child: Text(text, style: AppTextStyles.bodyMedium),
          ),
        ],
      ),
    );
  }
}
