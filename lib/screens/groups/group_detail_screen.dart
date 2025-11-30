import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/widgets/paper_card.dart';
import '../../domain/entities/group.dart';
import '../../providers/providers.dart';
import 'group_chat_screen.dart';

/// Screen showing details of a support group
/// 
/// Features:
/// - View group info (name, description, category)
/// - See member count and capacity
/// - Join/Leave group
/// - Navigate to group chat
class GroupDetailScreen extends ConsumerWidget {
  final String groupId;

  const GroupDetailScreen({
    super.key,
    required this.groupId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupAsync = ref.watch(groupDetailProvider(groupId));
    final currentUserId = ref.watch(currentUserIdProvider);

    return Scaffold(
      backgroundColor: AppColors.paperCream,
      body: groupAsync.when(
        data: (group) {
          if (group == null) {
            return _GroupNotFound();
          }

          final isMember = group.isMember(currentUserId ?? '');
          final isCreator = group.createdBy == currentUserId;

          return CustomScrollView(
            slivers: [
              _GroupAppBar(group: group),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.screenPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _GroupInfoCard(group: group),
                      const SizedBox(height: AppSpacing.lg),
                      _MembershipCard(
                        group: group,
                        isMember: isMember,
                        isCreator: isCreator,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      if (isMember)
                        _GroupActionsCard(group: group),
                      if (!isMember && !group.isFull)
                        _JoinGroupCard(group: group),
                      if (!isMember && group.isFull)
                        _GroupFullCard(),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _ErrorView(
          message: 'Failed to load group details',
          onRetry: () => ref.invalidate(groupDetailProvider(groupId)),
        ),
      ),
    );
  }
}

/// App bar with group header
class _GroupAppBar extends StatelessWidget {
  final Group group;

  const _GroupAppBar({required this.group});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: _getCategoryColor(group.category),
      foregroundColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          group.name,
          style: AppTextStyles.h2.copyWith(color: Colors.white),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                _getCategoryColor(group.category),
                _getCategoryColor(group.category).withOpacity(0.8),
              ],
            ),
          ),
          child: Center(
            child: Icon(
              _getCategoryIcon(group.category),
              size: 80,
              color: Colors.white.withOpacity(0.3),
            ),
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(GroupCategory category) {
    switch (category) {
      case GroupCategory.support:
        return AppColors.panicRed;
      case GroupCategory.prayer:
        return AppColors.crossGold;
      case GroupCategory.discussion:
        return AppColors.holyBlue;
    }
  }

  IconData _getCategoryIcon(GroupCategory category) {
    switch (category) {
      case GroupCategory.support:
        return Icons.favorite;
      case GroupCategory.prayer:
        return Icons.church;
      case GroupCategory.discussion:
        return Icons.forum;
    }
  }
}

/// Card showing group information
class _GroupInfoCard extends StatelessWidget {
  final Group group;

  const _GroupInfoCard({required this.group});

  @override
  Widget build(BuildContext context) {
    return PaperCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _CategoryBadge(category: group.category),
              const Spacer(),
              if (group.isPrivate)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.warningAmber.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.lock, size: 14, color: AppColors.warningAmber),
                      const SizedBox(width: 4),
                      Text(
                        'Private',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.warningAmber,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text('About', style: AppTextStyles.h3),
          const SizedBox(height: AppSpacing.sm),
          Text(
            group.description,
            style: AppTextStyles.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.lg),
          const Divider(color: AppColors.paperEdge),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              _InfoItem(
                icon: Icons.calendar_today_outlined,
                label: 'Created',
                value: _formatDate(group.createdAt),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

/// Category badge
class _CategoryBadge extends StatelessWidget {
  final GroupCategory category;

  const _CategoryBadge({required this.category});

  @override
  Widget build(BuildContext context) {
    String label;
    Color color;
    IconData icon;

    switch (category) {
      case GroupCategory.support:
        label = 'Support Group';
        color = AppColors.panicRed;
        icon = Icons.favorite_outline;
        break;
      case GroupCategory.prayer:
        label = 'Prayer Group';
        color = AppColors.crossGold;
        icon = Icons.church_outlined;
        break;
      case GroupCategory.discussion:
        label = 'Discussion Group';
        color = AppColors.holyBlue;
        icon = Icons.forum_outlined;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Info item widget
class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.inkFaded),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTextStyles.caption),
            Text(
              value,
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Membership status card
class _MembershipCard extends StatelessWidget {
  final Group group;
  final bool isMember;
  final bool isCreator;

  const _MembershipCard({
    required this.group,
    required this.isMember,
    required this.isCreator,
  });

  @override
  Widget build(BuildContext context) {
    return PaperCard(
      backgroundColor: isMember
          ? AppColors.graceGreen.withOpacity(0.1)
          : AppColors.paperWhite,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.holyBlue.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.people_outline,
              color: AppColors.holyBlue,
              size: 24,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${group.memberCount} of ${group.maxMembers} members',
                  style: AppTextStyles.h3,
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: group.memberCount / group.maxMembers,
                  backgroundColor: AppColors.paperEdge,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    group.isFull ? AppColors.warningAmber : AppColors.holyBlue,
                  ),
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(3),
                ),
                const SizedBox(height: 4),
                Text(
                  isMember
                      ? (isCreator ? 'You created this group' : 'You are a member')
                      : '${group.availableSlots} spots available',
                  style: AppTextStyles.caption.copyWith(
                    color: isMember ? AppColors.graceGreen : AppColors.inkFaded,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Actions for group members
class _GroupActionsCard extends ConsumerWidget {
  final Group group;

  const _GroupActionsCard({required this.group});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => GroupChatScreen(
                  groupId: group.id,
                  groupName: group.name,
                ),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.holyBlue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: const Icon(Icons.chat_bubble_outline),
          label: Text('Open Group Chat', style: AppTextStyles.button),
        ),
        const SizedBox(height: AppSpacing.md),
        _LeaveGroupButton(group: group),
      ],
    );
  }
}

/// Leave group button
class _LeaveGroupButton extends ConsumerStatefulWidget {
  final Group group;

  const _LeaveGroupButton({required this.group});

  @override
  ConsumerState<_LeaveGroupButton> createState() => _LeaveGroupButtonState();
}

class _LeaveGroupButtonState extends ConsumerState<_LeaveGroupButton> {
  bool _isLeaving = false;

  Future<void> _leaveGroup() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Leave Group?', style: AppTextStyles.h2),
        content: Text(
          'Are you sure you want to leave "${widget.group.name}"?',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: AppTextStyles.bodyMedium),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.panicRed),
            child: Text('Leave', style: AppTextStyles.bodyMedium),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLeaving = true);

    try {
      final currentUserId = ref.read(currentUserIdProvider);
      
      if (currentUserId == null) {
        throw Exception('Please log in');
      }

      await ref.read(leaveGroupProvider)(
        groupId: widget.group.id,
        userId: currentUserId,
      );

      ref.invalidate(userGroupsProvider);
      ref.invalidate(publicGroupsProvider);
      ref.invalidate(groupDetailProvider(widget.group.id));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Left ${widget.group.name}'),
            backgroundColor: AppColors.inkBrown,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to leave: ${e.toString()}'),
            backgroundColor: AppColors.panicRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLeaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = ref.watch(currentUserIdProvider);
    final isCreator = widget.group.createdBy == currentUserId;

    return OutlinedButton.icon(
      onPressed: _isLeaving ? null : _leaveGroup,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.panicRed,
        side: BorderSide(color: AppColors.panicRed.withOpacity(0.5)),
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      icon: _isLeaving
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.exit_to_app),
      label: Text(
        isCreator && widget.group.memberCount > 1
            ? 'Cannot leave (you are the creator)'
            : 'Leave Group',
        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.panicRed),
      ),
    );
  }
}

/// Card for joining a group
class _JoinGroupCard extends ConsumerStatefulWidget {
  final Group group;

  const _JoinGroupCard({required this.group});

  @override
  ConsumerState<_JoinGroupCard> createState() => _JoinGroupCardState();
}

class _JoinGroupCardState extends ConsumerState<_JoinGroupCard> {
  bool _isJoining = false;

  Future<void> _joinGroup() async {
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

      ref.invalidate(userGroupsProvider);
      ref.invalidate(publicGroupsProvider);
      ref.invalidate(groupDetailProvider(widget.group.id));

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
    return ElevatedButton.icon(
      onPressed: _isJoining ? null : _joinGroup,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.graceGreen,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      icon: _isJoining
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : const Icon(Icons.group_add),
      label: Text('Join This Group', style: AppTextStyles.button),
    );
  }
}

/// Card showing group is full
class _GroupFullCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PaperCard(
      backgroundColor: AppColors.warningAmber.withOpacity(0.1),
      child: Row(
        children: [
          Icon(
            Icons.group_off,
            color: AppColors.warningAmber,
            size: 24,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Group is Full',
                  style: AppTextStyles.h3.copyWith(color: AppColors.warningAmber),
                ),
                Text(
                  'This group has reached its maximum capacity',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Group not found view
class _GroupNotFound extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paperCream,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.inkBlack,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 80,
              color: AppColors.inkFaded.withOpacity(0.4),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Group Not Found',
              style: AppTextStyles.h2.copyWith(color: AppColors.inkBrown),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'This group may have been deleted or is no longer available.',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.inkFaded),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            TextButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Go Back'),
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

/// Error view with retry
class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paperCream,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.inkBlack,
      ),
      body: Center(
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
