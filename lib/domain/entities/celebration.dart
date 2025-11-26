/// Celebration of sobriety milestone
class Celebration {
  final String id;
  final String userId;
  final String userName;
  final int dayCount;
  final String? message;
  final DateTime timestamp;
  final int reactionCount;
  final int commentCount;

  const Celebration({
    required this.id,
    required this.userId,
    required this.userName,
    required this.dayCount,
    this.message,
    required this.timestamp,
    this.reactionCount = 0,
    this.commentCount = 0,
  });

  /// Check if celebration has a custom message
  bool get hasMessage => message != null;

  /// Check if this is a major milestone (30, 90, 180, 365 days)
  bool get isMajorMilestone => [30, 90, 180, 365].contains(dayCount);

  Celebration copyWith({
    String? id,
    String? userId,
    String? userName,
    int? dayCount,
    String? message,
    DateTime? timestamp,
    int? reactionCount,
    int? commentCount,
  }) {
    return Celebration(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      dayCount: dayCount ?? this.dayCount,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      reactionCount: reactionCount ?? this.reactionCount,
      commentCount: commentCount ?? this.commentCount,
    );
  }
}
