import 'package:hive/hive.dart';

part 'saint_of_the_day_model.g.dart';

@HiveType(typeId: 15)
class SaintOfTheDay extends HiveObject {
  @HiveField(0)
  final DateTime date;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String? feastType; // e.g., Memorial, Feast, Solemnity

  @HiveField(3)
  final String imageUrl;

  @HiveField(4)
  final String reflectionUrl;

  @HiveField(5)
  final String? summary; // Short bio from list

  @HiveField(6)
  String? fullReflection;

  @HiveField(7)
  String? bibleVerse;

  @HiveField(8)
  String? verseReference;

  @HiveField(9)
  String? prayer;

  @HiveField(10)
  final DateTime fetchedAt;

  SaintOfTheDay({
    required this.date,
    required this.name,
    this.feastType,
    required this.imageUrl,
    required this.reflectionUrl,
    this.summary,
    this.fullReflection,
    this.bibleVerse,
    this.verseReference,
    this.prayer,
    DateTime? fetchedAt,
  }) : fetchedAt = fetchedAt ?? DateTime.now();

  bool get hasFeastType => feastType != null && feastType!.isNotEmpty;
  bool get hasSummary => summary != null && summary!.isNotEmpty;
  bool get hasFullReflection => fullReflection != null && fullReflection!.isNotEmpty;
  bool get hasBibleVerse => bibleVerse != null && bibleVerse!.isNotEmpty;
  bool get hasVerseReference => verseReference != null && verseReference!.isNotEmpty;
  bool get hasPrayer => prayer != null && prayer!.isNotEmpty;

  @override
  String toString() => '$name - ${date.toString().split(' ')[0]}';
}
