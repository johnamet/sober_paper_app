/// Catholic prayer with optional Latin version
class Prayer {
  final String id;
  final String title;
  final PrayerCategory category;
  final String content;
  final String? latinVersion;
  final String? notes;
  final int order;

  const Prayer({
    required this.id,
    required this.title,
    required this.category,
    required this.content,
    this.latinVersion,
    this.notes,
    required this.order,
  });

  /// Check if prayer has a Latin version available
  bool get hasLatinVersion => latinVersion != null;

  /// Check if prayer has additional notes
  bool get hasNotes => notes != null;

  Prayer copyWith({
    String? id,
    String? title,
    PrayerCategory? category,
    String? content,
    String? latinVersion,
    String? notes,
    int? order,
  }) {
    return Prayer(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      content: content ?? this.content,
      latinVersion: latinVersion ?? this.latinVersion,
      notes: notes ?? this.notes,
      order: order ?? this.order,
    );
  }
}

/// Category of Catholic prayer
enum PrayerCategory {
  /// Morning prayers
  morning,
  
  /// Evening prayers
  evening,
  
  /// Rosary and Marian prayers
  rosary,
  
  /// Emergency/crisis prayers
  emergency,
  
  /// Liturgical prayers
  liturgy,
}
