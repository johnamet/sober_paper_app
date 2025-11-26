import '../../entities/message.dart';
import '../../../data/repositories/community_repository.dart';

class SendDirectMessage {
  final CommunityRepository _communityRepository;

  SendDirectMessage(this._communityRepository);

  Future<Message> call({
    required String senderId,
    required String senderName,
    required String recipientId,
    required String content,
  }) async {
    if (senderId.isEmpty || recipientId.isEmpty || content.trim().isEmpty) {
      throw ArgumentError('Sender, recipient, and message content are required');
    }

    if (senderId == recipientId) {
      throw ArgumentError('Cannot send message to yourself');
    }

    return await _communityRepository.sendDirectMessage(
      senderId: senderId,
      senderName: senderName,
      recipientId: recipientId,
      content: content.trim(),
    );
  }
}
