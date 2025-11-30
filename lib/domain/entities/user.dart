class User {
  final String uid;
  final String displayName;
  final String? email;
  final bool isAnonymous;
  final DateTime? sobrietyStartDate;
  final String? sponsorId;
  final bool isVolunteer;
  final bool isAvailable;
  final DateTime? lastActive;
  final DateTime? createdAt;
  final UserPreferences preferences;
  final UserStats stats;

  const User({
    required this.uid,
    required this.displayName,
    this.email,
    required this.isAnonymous,
    this.sobrietyStartDate,
    this.sponsorId,
    this.isVolunteer = false,
    this.isAvailable = false,
    this.lastActive,
    this.createdAt,
    this.preferences = const UserPreferences(),
    this.stats = const UserStats(),
  });

  int get daysClean {
    if (sobrietyStartDate == null) return 0;
    return DateTime.now().difference(sobrietyStartDate!).inDays;
  }

  bool get hasSponsor => sponsorId != null;
  bool get hasSetSobrietyDate => sobrietyStartDate != null;

  User copyWith({
    String? displayName,
    String? email,
    DateTime? sobrietyStartDate,
    String? sponsorId,
    bool? isVolunteer,
    bool? isAvailable,
    DateTime? lastActive,
    UserPreferences? preferences,
    UserStats? stats,
  }) {
    return User(
      uid: uid,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      isAnonymous: isAnonymous,
      sobrietyStartDate: sobrietyStartDate ?? this.sobrietyStartDate,
      sponsorId: sponsorId ?? this.sponsorId,
      isVolunteer: isVolunteer ?? this.isVolunteer,
      isAvailable: isAvailable ?? this.isAvailable,
      lastActive: lastActive ?? this.lastActive,
      createdAt: createdAt ?? createdAt,
      preferences: preferences ?? this.preferences,
      stats: stats ?? this.stats,
    );
  }
}

class UserPreferences {
  final bool enablePanicAlerts;
  final bool enableDailyReminders;
  final bool enableCelebrations;
  final String privacyLevel;
  final bool notifications;
  final String? dailyReminderTime;

  const UserPreferences({
    this.enablePanicAlerts = true,
    this.enableDailyReminders = true,
    this.enableCelebrations = true,
    this.privacyLevel = 'moderate',
    this.notifications = true,
    this.dailyReminderTime,
  });

  UserPreferences copyWith({
    bool? enablePanicAlerts,
    bool? enableDailyReminders,
    bool? enableCelebrations,
    String? privacyLevel,
    bool? notifications,
    String? dailyReminderTime,
  }) {
    return UserPreferences(
      enablePanicAlerts: enablePanicAlerts ?? this.enablePanicAlerts,
      enableDailyReminders: enableDailyReminders ?? this.enableDailyReminders,
      enableCelebrations: enableCelebrations ?? this.enableCelebrations,
      privacyLevel: privacyLevel ?? this.privacyLevel,
      notifications: notifications ?? this.notifications,
      dailyReminderTime: dailyReminderTime ?? this.dailyReminderTime,
    );
  }
}

class UserStats {
  final int totalDaysClean;
  final int longestStreak;
  final int currentStreak;
  final int totalRelapses;
  final int totalReflections;
  final int totalPrayers;

  const UserStats({
    this.totalDaysClean = 0,
    this.longestStreak = 0,
    this.currentStreak = 0,
    this.totalRelapses = 0,
    this.totalReflections = 0,
    this.totalPrayers = 0,
  });

  UserStats copyWith({
    int? totalDaysClean,
    int? longestStreak,
    int? currentStreak,
    int? totalRelapses,
    int? totalReflections,
    int? totalPrayers,
  }) {
    return UserStats(
      totalDaysClean: totalDaysClean ?? this.totalDaysClean,
      longestStreak: longestStreak ?? this.longestStreak,
      currentStreak: currentStreak ?? this.currentStreak,
      totalRelapses: totalRelapses ?? this.totalRelapses,
      totalReflections: totalReflections ?? this.totalReflections,
      totalPrayers: totalPrayers ?? this.totalPrayers,
    );
  }
}
