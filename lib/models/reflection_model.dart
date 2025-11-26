// This file is kept for backwards compatibility
// The DailyReflection entity is now in lib/domain/entities/daily_reflection.dart
// The DailyReflectionModel is in lib/models/daily_reflection_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/entities/daily_reflection.dart';

/// Legacy class for backwards compatibility
/// Use DailyReflectionModel instead
@Deprecated('Use DailyReflectionModel from daily_reflection_model.dart')
class ReflectionModel {
  final DailyReflection reflection;

  const ReflectionModel(this.reflection);

  factory ReflectionModel.fromJson(Map<String, dynamic> json) {
    return ReflectionModel(
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
