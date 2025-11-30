import '../../entities/group.dart';
import '../../../data/repositories/community_repository.dart';

class JoinGroup {
  final CommunityRepository _communityRepository;

  JoinGroup(this._communityRepository);

  Future<void> call({
    required String groupId,
    required String userId,
  }) async {
    if (groupId.isEmpty || userId.isEmpty) {
      throw ArgumentError('Group ID and user ID are required');
    }

    // Get the group first to validate it exists and is not full
    final group = await _communityRepository.getGroup(groupId);
    
    if (group == null) {
      throw Exception('Group not found');
    }

    if (group.isFull) {
      throw Exception('Group has reached maximum capacity');
    }

    if (group.isMember(userId)) {
      throw Exception('Already a member of this group');
    }

    return await _communityRepository.joinGroup(
      groupId: groupId,
      userId: userId,
    );
  }
}
