import 'package:hive/hive.dart';

part 'catholic_reflection_model.g.dart';

/// Hive-compatible model for daily Catholic reflections
@HiveType(typeId: 14)
class DailyReflection {
  @HiveField(0)
  final DateTime date;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String content;

  @HiveField(3)
  final String? bibleVerse;

  @HiveField(4)
  final String? verseReference;

  @HiveField(5)
  final String prayer;

  @HiveField(6)
  final String? author;

  @HiveField(7)
  final DateTime fetchedAt;

  @HiveField(8)
  final String? imageUrl;

  DailyReflection({
    required this.date,
    required this.title,
    required this.content,
    this.bibleVerse,
    this.verseReference,
    required this.prayer,
    this.author,
    required this.fetchedAt,
    this.imageUrl,
  });

  /// Check if reflection has a verse reference
  bool get hasVerseReference => verseReference != null && verseReference!.isNotEmpty;

  /// Check if reflection has a Bible verse
  bool get hasBibleVerse => bibleVerse != null && bibleVerse!.isNotEmpty;

  /// Check if reflection has an author attribution
  bool get hasAuthor => author != null && author!.isNotEmpty;

  /// Get formatted date string
  String get dateString => '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'title': title,
        'content': content,
        'bibleVerse': bibleVerse,
        'verseReference': verseReference,
        'prayer': prayer,
        'author': author,
        'fetchedAt': fetchedAt.toIso8601String(),
      };

  factory DailyReflection.fromJson(Map<String, dynamic> json) => DailyReflection(
        date: DateTime.parse(json['date'] as String),
        title: json['title'] as String,
        content: json['content'] as String,
        bibleVerse: json['bibleVerse'] as String?,
        verseReference: json['verseReference'] as String?,
        prayer: json['prayer'] as String,
        author: json['author'] as String?,
        fetchedAt: DateTime.parse(json['fetchedAt'] as String),
      );

  DailyReflection copyWith({
    DateTime? date,
    String? title,
    String? content,
    String? bibleVerse,
    String? verseReference,
    String? prayer,
    String? author,
    DateTime? fetchedAt,
  }) {
    return DailyReflection(
      date: date ?? this.date,
      title: title ?? this.title,
      content: content ?? this.content,
      bibleVerse: bibleVerse ?? this.bibleVerse,
      verseReference: verseReference ?? this.verseReference,
      prayer: prayer ?? this.prayer,
      author: author ?? this.author,
      fetchedAt: fetchedAt ?? this.fetchedAt,
    );
  }
}
