/// Message in a group or direct conversation
class Message {
  final String id;
  final String conversationId;
  final ConversationType conversationType;
  final String senderId;
  final String senderName;
  final String content;
  final DateTime timestamp;
  final bool flaggedForReview;
  final DateTime? reviewedAt;
  final DateTime? deletedAt;

  const Message({
    required this.id,
    required this.conversationId,
    required this.conversationType,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.timestamp,
    this.flaggedForReview = false,
    this.reviewedAt,
    this.deletedAt,
  });

  /// Check if message has been deleted
  bool get isDeleted => deletedAt != null;

  /// Check if message needs moderation review
  bool get needsReview => flaggedForReview && reviewedAt == null;

  /// Check if message is in a group conversation
  bool get isGroup => conversationType == ConversationType.group;

  /// Check if message is in a direct conversation
  bool get isDirect => conversationType == ConversationType.direct;

  Message copyWith({
    String? id,
    String? conversationId,
    ConversationType? conversationType,
    String? senderId,
    String? senderName,
    String? content,
    DateTime? timestamp,
    bool? flaggedForReview,
    DateTime? reviewedAt,
    DateTime? deletedAt,
  }) {
    return Message(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      conversationType: conversationType ?? this.conversationType,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      flaggedForReview: flaggedForReview ?? this.flaggedForReview,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}

/// Type of conversation
enum ConversationType {
  /// Group conversation
  group,
  
  /// One-on-one direct message
  direct,
}
