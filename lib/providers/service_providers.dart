import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/firebase_service.dart';
import '../services/moderation_service.dart';
import '../services/notification_service.dart';

// ============================================================================
// SERVICE PROVIDERS
// ============================================================================

/// Firebase Service Provider
final firebaseServiceProvider = Provider<FirebaseService>((ref) {
  return FirebaseService.instance;
});

/// Moderation Service Provider
final moderationServiceProvider = Provider<ModerationService>((ref) {
  return ModerationService.instance;
});

/// Notification Service Provider
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService.instance;
});
