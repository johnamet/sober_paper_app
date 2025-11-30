import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/widgets/paper_card.dart';
import '../../domain/entities/group.dart';
import '../../providers/providers.dart';
import 'create_group_screen.dart';
import 'group_detail_screen.dart';

/// Support Groups screen showing user's groups and browse public groups
/// 
/// Features:
/// - View my groups (groups user has joined)
/// - Browse public groups to join
/// - Create new groups
/// - Navigate to group details and chat
class SupportGroupsScreen extends ConsumerStatefulWidget {
  const SupportGroupsScreen({super.key});

  @override
  ConsumerState<SupportGroupsScreen> createState() => _SupportGroupsScreenState();
}

class _SupportGroupsScreenState extends ConsumerState<SupportGroupsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paperCream,
      appBar: AppBar(
        title: Text('Support Groups', style: AppTextStyles.h1),
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.inkBlack,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.inkBlack,
          unselectedLabelColor: AppColors.inkFaded,
          indicatorColor: AppColors.holyBlue,
          labelStyle: AppTextStyles.h3,
          tabs: const [
            Tab(text: 'My Groups'),
            Tab(text: 'Browse'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _MyGroupsTab(),
          _BrowseGroupsTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateGroupScreen()),
          ).then((_) {
            // Refresh groups after creating
            ref.invalidate(userGroupsProvider);
            ref.invalidate(publicGroupsProvider);
          });
        },
        backgroundColor: AppColors.holyBlue,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text('Create Group', style: AppTextStyles.button),
      ),
    );
  }
}

/// Tab showing user's joined groups
class _MyGroupsTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userGroupsAsync = ref.watch(userGroupsProvider);

    return userGroupsAsync.when(
      data: (groups) {
        if (groups.isEmpty) {
          return _EmptyGroupsPlaceholder(
            title: 'No Groups Yet',
            message: 'Join a support group or create your own to connect with others on the same journey.',
            icon: Icons.group_outlined,
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(userGroupsProvider);
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            itemCount: groups.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: _GroupCard(
                  group: groups[index],
                  showJoinButton: false,
                ),
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _ErrorWidget(
        message: 'Failed to load your groups',
        onRetry: () => ref.invalidate(userGroupsProvider),
      ),
    );
  }
}

/// Tab for browsing public groups to join
class _BrowseGroupsTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final publicGroupsAsync = ref.watch(publicGroupsProvider);
    final userGroupsAsync = ref.watch(userGroupsProvider);

    return publicGroupsAsync.when(
      data: (publicGroups) {
        // Get user's group IDs to check membership
        final userGroupIds = userGroupsAsync.value?.map((g) => g.id).toSet() ?? {};

        if (publicGroups.isEmpty) {
          return _EmptyGroupsPlaceholder(
            title: 'No Public Groups',
            message: 'Be the first to create a public support group!',
            icon: Icons.explore_outlined,
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(publicGroupsProvider);
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            itemCount: publicGroups.length,
            itemBuilder: (context, index) {
              final group = publicGroups[index];
              final isMember = userGroupIds.contains(group.id);
              
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: _GroupCard(
                  group: group,
                  showJoinButton: !isMember,
                  isMember: isMember,
                ),
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _ErrorWidget(
        message: 'Failed to load public groups',
        onRetry: () => ref.invalidate(publicGroupsProvider),
      ),
    );
  }
}

/// Card widget displaying group information
class _GroupCard extends ConsumerWidget {
  final Group group;
  final bool showJoinButton;
  final bool isMember;

  const _GroupCard({
    required this.group,
    this.showJoinButton = false,
    this.isMember = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PaperCard(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => GroupDetailScreen(groupId: group.id),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _CategoryIcon(category: group.category),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.name,
                      style: AppTextStyles.h3,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _getCategoryLabel(group.category),
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
              if (group.isPrivate)
                Icon(
                  Icons.lock_outline,
                  size: 16,
                  color: AppColors.inkFaded,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            group.description,
            style: AppTextStyles.bodySmall,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Icon(Icons.people_outline, size: 16, color: AppColors.inkFaded),
              const SizedBox(width: 4),
              Text(
                '${group.memberCount}/${group.maxMembers} members',
                style: AppTextStyles.caption,
              ),
              const Spacer(),
              if (isMember)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.graceGreen.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Joined',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.graceGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              if (showJoinButton)
                _JoinButton(group: group),
            ],
          ),
        ],
      ),
    );
  }

  String _getCategoryLabel(GroupCategory category) {
    switch (category) {
      case GroupCategory.support:
        return 'Support Group';
      case GroupCategory.prayer:
        return 'Prayer Group';
      case GroupCategory.discussion:
        return 'Discussion Group';
    }
  }
}

/// Icon for group category
class _CategoryIcon extends StatelessWidget {
  final GroupCategory category;

  const _CategoryIcon({required this.category});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;

    switch (category) {
      case GroupCategory.support:
        icon = Icons.favorite_outline;
        color = AppColors.panicRed;
        break;
      case GroupCategory.prayer:
        icon = Icons.church_outlined;
        color = AppColors.crossGold;
        break;
      case GroupCategory.discussion:
        icon = Icons.forum_outlined;
        color = AppColors.holyBlue;
        break;
    }

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }
}

/// Join button for a group
class _JoinButton extends ConsumerStatefulWidget {
  final Group group;

  const _JoinButton({required this.group});

  @override
  ConsumerState<_JoinButton> createState() => _JoinButtonState();
}

class _JoinButtonState extends ConsumerState<_JoinButton> {
  bool _isJoining = false;

  Future<void> _joinGroup() async {
    if (_isJoining || widget.group.isFull) return;

    setState(() => _isJoining = true);

    try {
      final currentUserId = ref.read(currentUserIdProvider);
      
      if (currentUserId == null) {
        throw Exception('Please log in to join groups');
      }

      await ref.read(joinGroupProvider)(
        groupId: widget.group.id,
        userId: currentUserId,
      );

      // Refresh groups
      ref.invalidate(userGroupsProvider);
      ref.invalidate(publicGroupsProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Joined ${widget.group.name}!'),
            backgroundColor: AppColors.graceGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to join: ${e.toString()}'),
            backgroundColor: AppColors.panicRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isJoining = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.group.isFull) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.inkFaded.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          'Full',
          style: AppTextStyles.caption.copyWith(color: AppColors.inkFaded),
        ),
      );
    }

    return TextButton(
      onPressed: _isJoining ? null : _joinGroup,
      style: TextButton.styleFrom(
        backgroundColor: AppColors.holyBlue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: _isJoining
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Text('Join', style: AppTextStyles.button.copyWith(fontSize: 14)),
    );
  }
}

/// Placeholder widget for empty groups list
class _EmptyGroupsPlaceholder extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;

  const _EmptyGroupsPlaceholder({
    required this.title,
    required this.message,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: AppColors.inkFaded.withOpacity(0.4),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              title,
              style: AppTextStyles.h2.copyWith(color: AppColors.inkBrown),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.inkFaded),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Error widget with retry button
class _ErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorWidget({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
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
              message,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.panicRed),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.holyBlue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
