import 'package:hive/hive.dart';

part 'catholic_reading_model.g.dart';

/// Represents a single reading (First Reading, Gospel, etc.)
@HiveType(typeId: 10)
class Reading {
  @HiveField(0)
  final String type; // e.g., "First Reading", "Gospel"
  
  @HiveField(1)
  final String reference; // e.g., "Wisdom 13:1-9"
  
  @HiveField(2)
  final String text;

  Reading({
    required this.type,
    required this.reference,
    required this.text,
  });

  Map<String, dynamic> toJson() => {
        'type': type,
        'reference': reference,
        'text': text,
      };

  factory Reading.fromJson(Map<String, dynamic> json) => Reading(
        type: json['type'] as String,
        reference: json['reference'] as String,
        text: json['text'] as String,
      );

  Reading copyWith({
    String? type,
    String? reference,
    String? text,
  }) {
    return Reading(
      type: type ?? this.type,
      reference: reference ?? this.reference,
      text: text ?? this.text,
    );
  }
}

/// Represents the daily Catholic readings
@HiveType(typeId: 11)
class DailyCatholicReading {
  @HiveField(0)
  final String date; // e.g., "Friday, November 14, 2025"
  
  @HiveField(1)
  final String? feast; // Optional feast day or memorial
  
  @HiveField(2)
  final List<Reading> readings;
  
  @HiveField(3)
  final DateTime fetchDate; // When this was fetched
  
  @HiveField(4)
  final String? massVideoUrl; // Optional Mass video link

  DailyCatholicReading({
    required this.date,
    this.feast,
    required this.readings,
    required this.fetchDate,
    this.massVideoUrl,
  });

  Map<String, dynamic> toJson() => {
        'date': date,
        'feast': feast,
        'readings': readings.map((r) => r.toJson()).toList(),
        'fetchDate': fetchDate.toIso8601String(),
        'massVideoUrl': massVideoUrl,
      };

  factory DailyCatholicReading.fromJson(Map<String, dynamic> json) =>
      DailyCatholicReading(
        date: json['date'] as String,
        feast: json['feast'] as String?,
        readings: (json['readings'] as List)
            .map((r) => Reading.fromJson(r as Map<String, dynamic>))
            .toList(),
        fetchDate: DateTime.parse(json['fetchDate'] as String),
        massVideoUrl: json['massVideoUrl'] as String?,
      );

  DailyCatholicReading copyWith({
    String? date,
    String? feast,
    List<Reading>? readings,
    DateTime? fetchDate,
    String? massVideoUrl,
  }) {
    return DailyCatholicReading(
      date: date ?? this.date,
      feast: feast ?? this.feast,
      readings: readings ?? this.readings,
      fetchDate: fetchDate ?? this.fetchDate,
      massVideoUrl: massVideoUrl ?? this.massVideoUrl,
    );
  }

  /// Check if cached data is still fresh (less than 24 hours old)
  bool get isFresh {
    final now = DateTime.now();
    final difference = now.difference(fetchDate);
    return difference.inHours < 24;
  }

  /// Get age of cached data in days
  int get ageInDays {
    final now = DateTime.now();
    final difference = now.difference(fetchDate);
    return difference.inDays;
  }
}

/// Represents a Mass video/audio link
@HiveType(typeId: 12)
class MassMedia {
  @HiveField(0)
  final String date;
  
  @HiveField(1)
  final String url;
  
  @HiveField(2)
  final String title;
  
  @HiveField(3)
  final MediaType type;

  MassMedia({
    required this.date,
    required this.url,
    required this.title,
    required this.type,
  });

  Map<String, dynamic> toJson() => {
        'date': date,
        'url': url,
        'title': title,
        'type': type.toString(),
      };

  factory MassMedia.fromJson(Map<String, dynamic> json) => MassMedia(
        date: json['date'] as String,
        url: json['url'] as String,
        title: json['title'] as String,
        type: MediaType.values.firstWhere(
          (e) => e.toString() == json['type'],
          orElse: () => MediaType.video,
        ),
      );
}

@HiveType(typeId: 13)
enum MediaType {
  @HiveField(0)
  video,
  @HiveField(1)
  audio,
  @HiveField(2)
  livestream,
}
