import '../../entities/message.dart';
import '../../../data/repositories/community_repository.dart';

class SendGroupMessage {
  final CommunityRepository _communityRepository;

  SendGroupMessage(this._communityRepository);

  Future<Message> call({
    required String groupId,
    required String senderId,
    required String senderName,
    required String content,
  }) async {
    if (groupId.isEmpty || senderId.isEmpty || content.trim().isEmpty) {
      throw ArgumentError('Group ID, sender ID, and message content are required');
    }

    // Verify the user is a member of the group
    final group = await _communityRepository.getGroup(groupId);
    
    if (group == null) {
      throw Exception('Group not found');
    }

    if (!group.isMember(senderId)) {
      throw Exception('Must be a member of the group to send messages');
    }

    return await _communityRepository.sendMessage(
      groupId: groupId,
      senderId: senderId,
      senderName: senderName,
      content: content.trim(),
    );
  }
}
