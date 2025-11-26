import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/entities/daily_reflection.dart';

/// Model for DailyReflection with JSON serialization
class DailyReflectionModel {
  final DailyReflection reflection;

  const DailyReflectionModel(this.reflection);

  /// Convert from Firestore document
  factory DailyReflectionModel.fromJson(Map<String, dynamic> json) {
    return DailyReflectionModel(
      DailyReflection(
        date: json['date'] as String,
        title: json['title'] as String,
        content: json['content'] as String,
        bibleVerse: json['bibleVerse'] as String?,
        verseReference: json['verseReference'] as String?,
        prayer: json['prayer'] as String,
        author: json['author'] as String?,
        createdAt: (json['createdAt'] as Timestamp).toDate(),
      ),
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toJson() {
    return {
      'date': reflection.date,
      'title': reflection.title,
      'content': reflection.content,
      'bibleVerse': reflection.bibleVerse,
      'verseReference': reflection.verseReference,
      'prayer': reflection.prayer,
      'author': reflection.author,
      'createdAt': Timestamp.fromDate(reflection.createdAt),
    };
  }
}
