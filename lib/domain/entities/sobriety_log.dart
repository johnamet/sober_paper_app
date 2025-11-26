/// Daily sobriety log entry
class SobrietyLog {
  final String id;
  final String userId;
  final DateTime date;
  final SobrietyStatus status;
  final String? mood;
  final List<String> triggers;
  final String? notes;
  final DateTime createdAt;

  const SobrietyLog({
    required this.id,
    required this.userId,
    required this.date,
    required this.status,
    this.mood,
    this.triggers = const [],
    this.notes,
    required this.createdAt,
  });

  /// Check if day was logged as clean
  bool get isClean => status == SobrietyStatus.clean;

  /// Check if day was logged as relapse
  bool get isRelapse => status == SobrietyStatus.relapse;

  /// Check if mood was recorded
  bool get hasMood => mood != null;

  /// Check if triggers were recorded
  bool get hasTriggers => triggers.isNotEmpty;

  SobrietyLog copyWith({
    String? id,
    String? userId,
    DateTime? date,
    SobrietyStatus? status,
    String? mood,
    List<String>? triggers,
    String? notes,
    DateTime? createdAt,
  }) {
    return SobrietyLog(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      status: status ?? this.status,
      mood: mood ?? this.mood,
      triggers: triggers ?? this.triggers,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Status of sobriety for a day
enum SobrietyStatus {
  /// Day logged as clean/sober
  clean,
  
  /// Day logged as relapse
  relapse,
}
