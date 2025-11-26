import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/entities/sobriety_log.dart';

/// Model for SobrietyLog with JSON serialization
class SobrietyLogModel {
  final SobrietyLog log;

  const SobrietyLogModel(this.log);

  /// Convert from Firestore document
  factory SobrietyLogModel.fromJson(Map<String, dynamic> json) {
    return SobrietyLogModel(
      SobrietyLog(
        id: json['dateId'] as String? ?? json['id'] as String,
        userId: json['userId'] as String,
        date: (json['date'] as Timestamp).toDate(),
        status: _statusFromString(json['status'] as String),
        mood: json['mood'] as String?,
        triggers: (json['triggers'] as List<dynamic>?)?.cast<String>() ?? [],
        notes: json['notes'] as String?,
        createdAt: (json['createdAt'] as Timestamp).toDate(),
      ),
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toJson() {
    return {
      'id': log.id,
      'userId': log.userId,
      'date': Timestamp.fromDate(log.date),
      'status': log.status.name,
      'mood': log.mood,
      'triggers': log.triggers,
      'notes': log.notes,
      'createdAt': Timestamp.fromDate(log.createdAt),
    };
  }

  static SobrietyStatus _statusFromString(String status) {
    switch (status) {
      case 'clean':
        return SobrietyStatus.clean;
      case 'relapse':
        return SobrietyStatus.relapse;
      default:
        return SobrietyStatus.clean;
    }
  }
}
