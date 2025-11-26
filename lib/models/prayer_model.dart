import '../domain/entities/prayer.dart';

/// Model for Prayer with JSON serialization
class PrayerModel {
  final Prayer prayer;

  const PrayerModel(this.prayer);

  /// Convert from JSON
  factory PrayerModel.fromJson(Map<String, dynamic> json) {
    return PrayerModel(
      Prayer(
        id: json['id'] as String,
        title: json['title'] as String,
        category: _categoryFromString(json['category'] as String),
        content: json['content'] as String,
        latinVersion: json['latinVersion'] as String?,
        notes: json['notes'] as String?,
        order: json['order'] as int,
      ),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': prayer.id,
      'title': prayer.title,
      'category': prayer.category.name,
      'content': prayer.content,
      'latinVersion': prayer.latinVersion,
      'notes': prayer.notes,
      'order': prayer.order,
    };
  }

  static PrayerCategory _categoryFromString(String category) {
    switch (category) {
      case 'morning':
        return PrayerCategory.morning;
      case 'evening':
        return PrayerCategory.evening;
      case 'rosary':
        return PrayerCategory.rosary;
      case 'emergency':
        return PrayerCategory.emergency;
      case 'liturgy':
        return PrayerCategory.liturgy;
      default:
        return PrayerCategory.morning;
    }
  }
}
