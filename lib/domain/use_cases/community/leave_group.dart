import '../../../data/repositories/community_repository.dart';

class LeaveGroup {
  final CommunityRepository _communityRepository;

  LeaveGroup(this._communityRepository);

  Future<void> call({
    required String groupId,
    required String userId,
  }) async {
    if (groupId.isEmpty || userId.isEmpty) {
      throw ArgumentError('Group ID and user ID are required');
    }

    // Get the group to verify membership and check if user is the creator
    final group = await _communityRepository.getGroup(groupId);
    
    if (group == null) {
      throw Exception('Group not found');
    }

    if (!group.isMember(userId)) {
      throw Exception('Not a member of this group');
    }

    if (group.createdBy == userId && group.memberCount > 1) {
      throw Exception('Creator cannot leave group with other members. Transfer ownership first.');
    }

    return await _communityRepository.leaveGroup(
      groupId: groupId,
      userId: userId,
    );
  }
}
