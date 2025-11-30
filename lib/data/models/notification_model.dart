import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/notification.dart';

/// Firestore model for AppNotification
class NotificationModel {
  final AppNotification notification;

  const NotificationModel(this.notification);

  /// Convert from Firestore document
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      AppNotification(
        id: json['id'] as String,
        userId: json['userId'] as String,
        type: NotificationType.values.firstWhere(
          (e) => e.name == json['type'],
          orElse: () => NotificationType.system,
        ),
        title: json['title'] as String,
        message: json['message'] as String,
        data: json['data'] != null 
            ? Map<String, dynamic>.from(json['data'] as Map)
            : null,
        isRead: json['isRead'] as bool? ?? false,
        createdAt: (json['createdAt'] as Timestamp).toDate(),
        readAt: json['readAt'] != null 
            ? (json['readAt'] as Timestamp).toDate()
            : null,
      ),
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toJson() {
    return {
      'userId': notification.userId,
      'type': notification.type.name,
      'title': notification.title,
      'message': notification.message,
      'data': notification.data,
      'isRead': notification.isRead,
      'createdAt': Timestamp.fromDate(notification.createdAt),
      'readAt': notification.readAt != null
          ? Timestamp.fromDate(notification.readAt!)
          : null,
    };
  }
}
