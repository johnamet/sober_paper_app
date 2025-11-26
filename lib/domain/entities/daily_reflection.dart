/// Daily spiritual reflection content
class DailyReflection {
  final String date; // Format: YYYY-MM-DD
  final String title;
  final String content;
  final String? bibleVerse;
  final String? verseReference;
  final String prayer;
  final String? author;
  final DateTime createdAt;

  const DailyReflection({
    required this.date,
    required this.title,
    required this.content,
    this.bibleVerse,
    this.verseReference,
    required this.prayer,
    this.author,
    required this.createdAt,
  });

  /// Check if reflection has a verse reference
  bool get hasVerseReference => verseReference != null;

  /// Check if reflection has a Bible verse
  bool get hasBibleVerse => bibleVerse != null;

  /// Check if reflection has an author attribution
  bool get hasAuthor => author != null;

  /// Parse date string to DateTime
  DateTime get dateAsDateTime => DateTime.parse(date);

  DailyReflection copyWith({
    String? date,
    String? title,
    String? content,
    String? bibleVerse,
    String? verseReference,
    String? prayer,
    String? author,
    DateTime? createdAt,
  }) {
    return DailyReflection(
      date: date ?? this.date,
      title: title ?? this.title,
      content: content ?? this.content,
      bibleVerse: bibleVerse ?? this.bibleVerse,
      verseReference: verseReference ?? this.verseReference,
      prayer: prayer ?? this.prayer,
      author: author ?? this.author,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
