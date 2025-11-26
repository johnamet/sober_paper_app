import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/entities/message.dart';

/// Model for Message with JSON serialization
class MessageModel {
  final Message message;

  const MessageModel(this.message);

  /// Convert from Firestore document
  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      Message(
        id: json['id'] as String,
        conversationId: json['conversationId'] as String,
        conversationType: _typeFromString(json['conversationType'] as String),
        senderId: json['senderId'] as String,
        senderName: json['senderName'] as String,
        content: json['content'] as String,
        timestamp: (json['timestamp'] as Timestamp).toDate(),
        flaggedForReview: json['flaggedForReview'] as bool? ?? false,
        reviewedAt: json['reviewedAt'] != null
            ? (json['reviewedAt'] as Timestamp).toDate()
            : null,
        deletedAt: json['deletedAt'] != null
            ? (json['deletedAt'] as Timestamp).toDate()
            : null,
      ),
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toJson() {
    return {
      'id': message.id,
      'conversationId': message.conversationId,
      'conversationType': message.conversationType.name,
      'senderId': message.senderId,
      'senderName': message.senderName,
      'content': message.content,
      'timestamp': Timestamp.fromDate(message.timestamp),
      'flaggedForReview': message.flaggedForReview,
      'reviewedAt': message.reviewedAt != null
          ? Timestamp.fromDate(message.reviewedAt!)
          : null,
      'deletedAt': message.deletedAt != null
          ? Timestamp.fromDate(message.deletedAt!)
          : null,
    };
  }

  static ConversationType _typeFromString(String type) {
    switch (type) {
      case 'group':
        return ConversationType.group;
      case 'direct':
        return ConversationType.direct;
      default:
        return ConversationType.direct;
    }
  }
}
