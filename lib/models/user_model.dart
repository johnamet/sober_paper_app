import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/entities/user.dart';

/// Model for User with JSON serialization
class UserModel {
  final User user;

  const UserModel(this.user);

  /// Convert from Firestore document
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      User(
        uid: json['uid'] as String,
        displayName: json['displayName'] as String,
        email: json['email'] as String?,
        isAnonymous: json['isAnonymous'] as bool,
        sobrietyStartDate: json['sobrietyStartDate'] != null
            ? (json['sobrietyStartDate'] as Timestamp).toDate()
            : null,
        sponsorId: json['sponsorId'] as String?,
        isVolunteer: json['isVolunteer'] as bool? ?? false,
        isAvailable: json['isAvailable'] as bool? ?? false,
        lastActive: json['lastActive'] != null
            ? (json['lastActive'] as Timestamp).toDate()
            : null,
        createdAt: json['createdAt'] != null
            ? (json['createdAt'] as Timestamp).toDate()
            : null,
        preferences: json['preferences'] != null
            ? _parsePreferences(json['preferences'])
            : const UserPreferences(),
        stats: json['stats'] != null
            ? _parseStats(json['stats'])
            : const UserStats(),
      ),
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toJson() {
    return {
      'uid': user.uid,
      'displayName': user.displayName,
      'email': user.email,
      'isAnonymous': user.isAnonymous,
      'sobrietyStartDate': user.sobrietyStartDate != null
          ? Timestamp.fromDate(user.sobrietyStartDate!)
          : null,
      'sponsorId': user.sponsorId,
      'isVolunteer': user.isVolunteer,
      'isAvailable': user.isAvailable,
      'lastActive': user.lastActive != null 
          ? Timestamp.fromDate(user.lastActive!) 
          : null,
      'createdAt': user.createdAt != null 
          ? Timestamp.fromDate(user.createdAt!) 
          : Timestamp.fromDate(DateTime.now()),
      'preferences': {
        'enablePanicAlerts': user.preferences.enablePanicAlerts,
        'enableDailyReminders': user.preferences.enableDailyReminders,
        'enableCelebrations': user.preferences.enableCelebrations,
        'privacyLevel': user.preferences.privacyLevel,
        'notifications': user.preferences.notifications,
        'dailyReminderTime': user.preferences.dailyReminderTime,
      },
      'stats': {
        'totalDaysClean': user.stats.totalDaysClean,
        'longestStreak': user.stats.longestStreak,
        'currentStreak': user.stats.currentStreak,
        'totalRelapses': user.stats.totalRelapses,
        'totalReflections': user.stats.totalReflections,
        'totalPrayers': user.stats.totalPrayers,
      },
    };
  }

  /// Parse UserPreferences from JSON
  static UserPreferences _parsePreferences(Map<String, dynamic> json) {
    return UserPreferences(
      enablePanicAlerts: json['enablePanicAlerts'] as bool? ?? true,
      enableDailyReminders: json['enableDailyReminders'] as bool? ?? true,
      enableCelebrations: json['enableCelebrations'] as bool? ?? true,
      privacyLevel: json['privacyLevel'] as String? ?? 'moderate',
      notifications: json['notifications'] as bool? ?? true,
      dailyReminderTime: json['dailyReminderTime'] as String?,
    );
  }

  /// Parse UserStats from JSON
  static UserStats _parseStats(Map<String, dynamic> json) {
    return UserStats(
      totalDaysClean: json['totalDaysClean'] as int? ?? 0,
      longestStreak: json['longestStreak'] as int? ?? 0,
      currentStreak: json['currentStreak'] as int? ?? 0,
      totalRelapses: json['totalRelapses'] as int? ?? 0,
      totalReflections: json['totalReflections'] as int? ?? 0,
      totalPrayers: json['totalPrayers'] as int? ?? 0,
    );
  }
}
