import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/state_providers.dart';
import '../../providers/repository_providers.dart';
import '../../domain/entities/user.dart';
import '../../core/constants/app_colors.dart';

class FindSponsorScreen extends ConsumerStatefulWidget {
  const FindSponsorScreen({super.key});

  @override
  ConsumerState<FindSponsorScreen> createState() => _FindSponsorScreenState();
}

class _FindSponsorScreenState extends ConsumerState<FindSponsorScreen> {
  String _searchQuery = '';
  
  @override
  Widget build(BuildContext context) {
    final availableSponsorsAsync = ref.watch(availableSponsorsProvider);
    final user = ref.watch(currentUserProfileProvider);

    return Scaffold(
      backgroundColor: AppColors.paperCream,
      appBar: AppBar(
        backgroundColor: AppColors.paperWhite,
        elevation: 0,
        title: const Text(
          'Find a Sponsor',
          style: TextStyle(
            color: AppColors.inkBlack,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.inkBlack),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.paperWhite,
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search sponsors...',
                hintStyle: const TextStyle(color: AppColors.inkFaded),
                prefixIcon: const Icon(Icons.search, color: AppColors.inkBrown),
                filled: true,
                fillColor: AppColors.paperCream,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          
          // Sponsors List
          Expanded(
            child: availableSponsorsAsync.when(
              data: (sponsors) {
                if (sponsors.isEmpty) {
                  return _buildEmptyState();
                }
                
                final filteredSponsors = _searchQuery.isEmpty
                    ? sponsors
                    : sponsors.where((sponsor) {
                        return sponsor.displayName.toLowerCase().contains(_searchQuery);
                      }).toList();
                
                if (filteredSponsors.isEmpty) {
                  return _buildNoResultsState();
                }
                
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredSponsors.length,
                  itemBuilder: (context, index) {
                    return _buildSponsorCard(
                      context,
                      filteredSponsors[index],
                      user.value,
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => _buildErrorState(error.toString()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSponsorCard(BuildContext context, User sponsor, User? currentUser) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: AppColors.paperWhite,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.paperEdge, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.holyBlue.withOpacity(0.2),
                  child: Text(
                    sponsor.displayName.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.holyBlue,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sponsor.displayName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.inkBlack,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (sponsor.sobrietyStartDate != null)
                        Text(
                          '${sponsor.daysClean} days clean',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.graceGreen,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                ),
                // Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.crossGold.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.crossGold, width: 1),
                  ),
                  child: const Text(
                    'SPONSOR',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.crossGold,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _viewProfile(context, sponsor),
                    icon: const Icon(Icons.person_outline, size: 18),
                    label: const Text('View Profile'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.holyBlue,
                      side: const BorderSide(color: AppColors.holyBlue, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _requestSponsorship(context, sponsor, currentUser),
                    icon: const Icon(Icons.handshake, size: 18),
                    label: const Text('Request'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.holyBlue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.people_outline,
              size: 80,
              color: AppColors.inkFaded,
            ),
            const SizedBox(height: 24),
            const Text(
              'No Sponsors Available',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.inkBlack,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'There are currently no users volunteering as sponsors. Check back later!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.inkBrown,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.search_off,
              size: 80,
              color: AppColors.inkFaded,
            ),
            const SizedBox(height: 24),
            const Text(
              'No Results Found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.inkBlack,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Try adjusting your search terms',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.inkBrown,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 80,
              color: AppColors.panicRed,
            ),
            const SizedBox(height: 24),
            const Text(
              'Something Went Wrong',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.inkBlack,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.inkBrown,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => ref.refresh(availableSponsorsProvider),
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.holyBlue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _viewProfile(BuildContext context, User sponsor) {
    // TODO: Navigate to user profile screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Viewing ${sponsor.displayName}\'s profile'),
        backgroundColor: AppColors.holyBlue,
      ),
    );
  }

  void _requestSponsorship(BuildContext context, User sponsor, User? currentUser) async {
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must be logged in to request sponsorship'),
          backgroundColor: AppColors.panicRed,
        ),
      );
      return;
    }

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.paperWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Request Sponsorship',
          style: TextStyle(color: AppColors.inkBlack),
        ),
        content: Text(
          'Send a sponsorship request to ${sponsor.displayName}?',
          style: const TextStyle(color: AppColors.inkBrown),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: AppColors.inkBrown)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.holyBlue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Send Request'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await ref.read(communityRepositoryProvider).createSponsorship(
          sponsorId: sponsor.uid,
          sponsoredUserId: currentUser.uid,
        );

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Sponsorship request sent to ${sponsor.displayName}'),
              backgroundColor: AppColors.graceGreen,
            ),
          );
          
          // Refresh the sponsors list by invalidating the provider
          ref.invalidate(availableSponsorsProvider);
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to send request: ${e.toString()}'),
              backgroundColor: AppColors.panicRed,
            ),
          );
        }
      }
    }
  }
}
