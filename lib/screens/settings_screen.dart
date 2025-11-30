import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';
import '../core/constants/app_spacing.dart';
import '../core/widgets/paper_card.dart';
import '../providers/providers.dart';
import '../domain/entities/user.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProfileProvider);

    return Scaffold(
      backgroundColor: AppColors.paperCream,
      appBar: AppBar(
        title: Text(
          'Settings',
          style: AppTextStyles.h1,
        ),
        backgroundColor: AppColors.paperCream,
        elevation: 0,
      ),
      body: userAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(
            color: AppColors.graceGreen,
          ),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: AppColors.panicRed,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Error loading settings',
                style: AppTextStyles.h2,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                error.toString(),
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        data: (user) {
          if (user == null) {
            return const Center(
              child: Text('No user data available'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildNotificationSettings(user),
                const SizedBox(height: AppSpacing.sectionSpacing),
                _buildPrivacySettings(user),
                const SizedBox(height: AppSpacing.sectionSpacing),
                if (user.isVolunteer) _buildVolunteerSettings(user),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildNotificationSettings(user) {
    return PaperCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.notifications,
                color: AppColors.graceGreen,
                size: 24,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Notifications',
                style: AppTextStyles.h2,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _buildSwitchTile(
            title: 'Enable Notifications',
            subtitle: 'Receive app notifications',
            value: user.preferences.notifications,
            onChanged: (value) => _updatePreferences(
              user,
              user.preferences.copyWith(notifications: value),
            ),
          ),
          const Divider(height: AppSpacing.lg),
          _buildSwitchTile(
            title: 'Daily Reminders',
            subtitle: 'Get reminded to log your daily reflection',
            value: user.preferences.enableDailyReminders,
            onChanged: (value) => _updatePreferences(
              user,
              user.preferences.copyWith(enableDailyReminders: value),
            ),
          ),
          const Divider(height: AppSpacing.lg),
          _buildSwitchTile(
            title: 'Panic Alerts',
            subtitle: 'Receive panic alerts from community members',
            value: user.preferences.enablePanicAlerts,
            onChanged: (value) => _updatePreferences(
              user,
              user.preferences.copyWith(enablePanicAlerts: value),
            ),
          ),
          const Divider(height: AppSpacing.lg),
          _buildSwitchTile(
            title: 'Celebrations',
            subtitle: 'Get notified about milestone achievements',
            value: user.preferences.enableCelebrations,
            onChanged: (value) => _updatePreferences(
              user,
              user.preferences.copyWith(enableCelebrations: value),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacySettings(user) {
    return PaperCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.privacy_tip,
                color: AppColors.crossGold,
                size: 24,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Privacy',
                style: AppTextStyles.h2,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Privacy Level',
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Control who can see your profile and activity',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.inkFaded,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _buildPrivacyOption(
            user: user,
            title: 'Public',
            description: 'Anyone can see your profile and activity',
            value: 'public',
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildPrivacyOption(
            user: user,
            title: 'Moderate',
            description: 'Only community members can see your profile',
            value: 'moderate',
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildPrivacyOption(
            user: user,
            title: 'Private',
            description: 'Only your sponsor and groups can see your activity',
            value: 'private',
          ),
        ],
      ),
    );
  }

  Widget _buildVolunteerSettings(user) {
    return PaperCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.volunteer_activism,
                color: AppColors.graceGreen,
                size: 24,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Volunteer Settings',
                style: AppTextStyles.h2,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _buildSwitchTile(
            title: 'Available for Sponsorship',
            subtitle: 'Allow others to request you as a sponsor',
            value: user.isAvailable,
            onChanged: (value) => _updateVolunteerAvailability(user, value),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'When available, you\'ll appear in the "Find a Sponsor" list and can receive sponsorship requests.',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.inkFaded,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.inkFaded,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: _isSaving ? null : onChanged,
          activeThumbColor: AppColors.graceGreen,
        ),
      ],
    );
  }

  Widget _buildPrivacyOption({
    required user,
    required String title,
    required String description,
    required String value,
  }) {
    final isSelected = user.preferences.privacyLevel == value;
    return InkWell(
      onTap: _isSaving
          ? null
          : () => _updatePreferences(
                user,
                user.preferences.copyWith(privacyLevel: value),
              ),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.graceGreen.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? AppColors.graceGreen
                : AppColors.inkFaded.withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? AppColors.graceGreen : AppColors.inkFaded,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isSelected ? AppColors.graceGreen : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.inkFaded,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updatePreferences(user, UserPreferences preferences) async {
    setState(() => _isSaving = true);
    try {
      final updateUseCase = ref.read(updateUserProfileProvider);
      await updateUseCase(
        uid: user.uid,
        preferences: preferences,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Settings updated'),
            backgroundColor: AppColors.graceGreen,
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.panicRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _updateVolunteerAvailability(user, bool isAvailable) async {
    setState(() => _isSaving = true);
    try {
      final updateUseCase = ref.read(updateUserProfileProvider);
      await updateUseCase(
        uid: user.uid,
        isVolunteer: true, // Ensure they stay as volunteer
        isAvailable: isAvailable,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isAvailable ? 'You are now available' : 'Availability disabled',
            ),
            backgroundColor: AppColors.graceGreen,
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.panicRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}
