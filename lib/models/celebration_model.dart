import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/entities/celebration.dart';

/// Model for Celebration with JSON serialization
class CelebrationModel {
  final Celebration celebration;

  const CelebrationModel(this.celebration);

  /// Convert from Firestore document
  factory CelebrationModel.fromJson(Map<String, dynamic> json) {
    return CelebrationModel(
      Celebration(
        id: json['id'] as String,
        userId: json['userId'] as String,
        userName: json['userName'] as String,
        dayCount: json['dayCount'] as int,
        message: json['message'] as String?,
        timestamp: (json['timestamp'] as Timestamp).toDate(),
        reactionCount: json['reactionCount'] as int? ?? 0,
        commentCount: json['commentCount'] as int? ?? 0,
      ),
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toJson() {
    return {
      'id': celebration.id,
      'userId': celebration.userId,
      'userName': celebration.userName,
      'dayCount': celebration.dayCount,
      'message': celebration.message,
      'timestamp': Timestamp.fromDate(celebration.timestamp),
      'reactionCount': celebration.reactionCount,
      'commentCount': celebration.commentCount,
    };
  }
}
