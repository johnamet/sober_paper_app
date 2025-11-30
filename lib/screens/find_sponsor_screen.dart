import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_colors.dart';
import '../providers/state_providers.dart';
import '../providers/repository_providers.dart';

class FindSponsorScreen extends ConsumerWidget {
  const FindSponsorScreen({super.key});

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
  Widget build(BuildContext context, WidgetRef ref) {
    final availableSponsorsAsync = ref.watch(availableSponsorsProvider);
    final currentUser = ref.watch(currentUserProfileProvider).value;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Find a Sponsor',
          style: TextStyle(
            fontSize: 24,
            color: Colors.white.withOpacity(0.95),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white.withOpacity(0.95)),
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
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildGlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.supervisor_account,
                              color: const Color(0xFFD4AF37).withOpacity(0.9),
                              size: 28,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'What is a Sponsor?',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white.withOpacity(0.95),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'A sponsor is someone who has experience in recovery and can provide guidance, support, and accountability on your journey to freedom.',
                          style: TextStyle(
                            fontSize: 15,
                            height: 1.6,
                            color: Colors.white.withOpacity(0.85),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'They will:',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildBulletPoint('Listen without judgment'),
                        _buildBulletPoint('Share their own experience'),
                        _buildBulletPoint('Help you stay accountable'),
                        _buildBulletPoint('Pray with and for you'),
                        _buildBulletPoint('Be available during difficult times'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildGlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.people_alt,
                              color: Colors.blue.withOpacity(0.9),
                              size: 26,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Available Sponsors',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white.withOpacity(0.95),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Browse volunteers who are available to be sponsors:',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.75),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Display available sponsors from provider
                  availableSponsorsAsync.when(
                    data: (sponsors) {
                      if (sponsors.isEmpty) {
                        return _buildNoSponsorsCard();
                      }

                      return Column(
                        children: sponsors
                            .map((sponsor) => Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: _buildSponsorCard(
                                    context: context,
                                    ref: ref,
                                    sponsor: sponsor,
                                    currentUserId: currentUser?.uid,
                                  ),
                                ))
                            .toList(),
                      );
                    },
                    loading: () => Center(
                      child: _buildGlassCard(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Loading sponsors...',
                              style: TextStyle(color: Colors.white.withOpacity(0.85)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    error: (error, stack) => _buildErrorCard(error.toString()),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: TextStyle(
              fontSize: 15,
              color: const Color(0xFFD4AF37).withOpacity(0.9),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.8),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSponsorCard({
    required BuildContext context,
    required WidgetRef ref,
    required sponsor,
    required String? currentUserId,
  }) {
    final name = sponsor.displayName;
    final daysClean = sponsor.daysClean;

    return _buildGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.graceGreen.withOpacity(0.8),
                      AppColors.graceGreen.withOpacity(0.6),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.graceGreen.withOpacity(0.3),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    name[0].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white.withOpacity(0.95),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.local_fire_department,
                          size: 18,
                          color: Colors.orange.withOpacity(0.9),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$daysClean days clean',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.graceGreen.withOpacity(0.9),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Available to provide guidance and support on your recovery journey.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.8),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: currentUserId != null
                  ? () => _requestSponsorship(
                        context: context,
                        ref: ref,
                        sponsorId: sponsor.uid,
                        sponsorName: sponsor.displayName,
                      )
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.graceGreen.withOpacity(0.8),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Request as Sponsor',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoSponsorsCard() {
    return _buildGlassCard(
      child: Column(
        children: [
          Icon(
            Icons.search_off,
            size: 56,
            color: Colors.white.withOpacity(0.5),
          ),
          const SizedBox(height: 20),
          Text(
            'No Available Sponsors',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white.withOpacity(0.95),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'There are currently no volunteers available to be sponsors. Please check back later or reach out in support groups.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.75),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard(String error) {
    return _buildGlassCard(
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            size: 56,
            color: AppColors.panicRed.withOpacity(0.9),
          ),
          const SizedBox(height: 20),
          Text(
            'Error Loading Sponsors',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white.withOpacity(0.95),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            error,
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withOpacity(0.7),
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Future<void> _requestSponsorship({
    required BuildContext context,
    required WidgetRef ref,
    required String sponsorId,
    required String sponsorName,
  }) async {
    final currentUser = ref.read(currentUserProfileProvider).value;
    
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in to request a sponsor'),
          backgroundColor: AppColors.panicRed,
        ),
      );
      return;
    }

    // Check if user already has a sponsor
    if (currentUser.hasSponsor) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You already have a sponsor'),
          backgroundColor: AppColors.panicRed,
        ),
      );
      return;
    }

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2B2B2B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
        title: Text(
          'Request Sponsor',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white.withOpacity(0.95),
          ),
        ),
        content: Text(
          'Send a sponsorship request to $sponsorName?',
          style: TextStyle(
            fontSize: 15,
            color: Colors.white.withOpacity(0.85),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: TextStyle(
                fontSize: 15,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.graceGreen.withOpacity(0.8),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Send Request',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      // Create sponsorship request
      final communityRepository = ref.read(communityRepositoryProvider);
      await communityRepository.createSponsorship(
        sponsorId: sponsorId,
        sponsoredUserId: currentUser.uid,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sponsorship request sent to $sponsorName'),
            backgroundColor: AppColors.graceGreen,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send request: $e'),
            backgroundColor: AppColors.panicRed,
          ),
        );
      }
    }
  }
}
