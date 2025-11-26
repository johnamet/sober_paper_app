import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/daily_reflection.dart';
import '../../domain/entities/prayer.dart';
import '../../models/daily_reflection_model.dart';
import '../../models/prayer_model.dart';

/// Repository for daily reflections and prayers
class ReflectionRepository {
  final FirebaseFirestore _firestore;

  ReflectionRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Get today's daily reflection
  Future<DailyReflection?> getTodayReflection() async {
    final today = DateTime.now();
    return getReflectionForDate(today);
  }

  /// Get daily reflection for a specific date
  Future<DailyReflection?> getReflectionForDate(DateTime date) async {
    try {
      final dateId = _formatDateId(date);
      final doc = await _firestore
          .collection('daily_reflections')
          .doc(dateId)
          .get();

      if (!doc.exists) return null;

      final model = DailyReflectionModel.fromJson({
        ...doc.data()!,
        'id': doc.id,
      });

      return model.reflection;
    } catch (e) {
      throw Exception('Failed to get daily reflection: $e');
    }
  }

  /// Get reflections for a date range
  Future<List<DailyReflection>> getReflectionsInRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final startId = _formatDateId(startDate);
      final endId = _formatDateId(endDate);

      final snapshot = await _firestore
          .collection('daily_reflections')
          .where(FieldPath.documentId, isGreaterThanOrEqualTo: startId)
          .where(FieldPath.documentId, isLessThanOrEqualTo: endId)
          .get();

      return snapshot.docs.map((doc) {
        final model = DailyReflectionModel.fromJson({
          ...doc.data(),
          'id': doc.id,
        });
        return model.reflection;
      }).toList();
    } catch (e) {
      throw Exception('Failed to get reflections in range: $e');
    }
  }

  /// Get a specific prayer by ID
  Future<Prayer?> getPrayer(String prayerId) async {
    try {
      final doc = await _firestore
          .collection('prayers')
          .doc(prayerId)
          .get();

      if (!doc.exists) return null;

      final model = PrayerModel.fromJson({
        ...doc.data()!,
        'id': doc.id,
      });

      return model.prayer;
    } catch (e) {
      throw Exception('Failed to get prayer: $e');
    }
  }

  /// Get prayers by category
  Future<List<Prayer>> getPrayersByCategory(PrayerCategory category) async {
    try {
      final snapshot = await _firestore
          .collection('prayers')
          .where('category', isEqualTo: category.name)
          .orderBy('title')
          .get();

      return snapshot.docs.map((doc) {
        final model = PrayerModel.fromJson({
          ...doc.data(),
          'id': doc.id,
        });
        return model.prayer;
      }).toList();
    } catch (e) {
      throw Exception('Failed to get prayers by category: $e');
    }
  }

  /// Search prayers by query string
  Future<List<Prayer>> searchPrayers(String query) async {
    try {
      final snapshot = await _firestore
          .collection('prayers')
          .orderBy('title')
          .get();

      // Client-side filtering for search
      final lowerQuery = query.toLowerCase();
      final allPrayers = snapshot.docs.map((doc) {
        final model = PrayerModel.fromJson({
          ...doc.data(),
          'id': doc.id,
        });
        return model.prayer;
      }).toList();

      return allPrayers.where((prayer) {
        return prayer.title.toLowerCase().contains(lowerQuery) ||
            prayer.content.toLowerCase().contains(lowerQuery) ||
            prayer.category.name.toLowerCase().contains(lowerQuery);
      }).toList();
    } catch (e) {
      throw Exception('Failed to search prayers: $e');
    }
  }

  /// Get all prayer categories
  Future<List<PrayerCategory>> getPrayerCategories() async {
    try {
      // Return all available categories from the enum
      return PrayerCategory.values;
    } catch (e) {
      throw Exception('Failed to get prayer categories: $e');
    }
  }

  /// Get favorite prayers for a user
  Future<List<Prayer>> getFavoritePrayers(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('favorite_prayers')
          .get();

      final prayerIds = snapshot.docs.map((doc) => doc.id).toList();
      
      if (prayerIds.isEmpty) return [];

      final prayers = <Prayer>[];
      for (final prayerId in prayerIds) {
        final prayer = await getPrayer(prayerId);
        if (prayer != null) {
          prayers.add(prayer);
        }
      }

      return prayers;
    } catch (e) {
      throw Exception('Failed to get favorite prayers: $e');
    }
  }

  /// Add a prayer to favorites
  Future<void> addToFavorites({
    required String userId,
    required String prayerId,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('favorite_prayers')
          .doc(prayerId)
          .set({'addedAt': Timestamp.fromDate(DateTime.now())});
    } catch (e) {
      throw Exception('Failed to add prayer to favorites: $e');
    }
  }

  /// Remove a prayer from favorites
  Future<void> removeFromFavorites({
    required String userId,
    required String prayerId,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('favorite_prayers')
          .doc(prayerId)
          .delete();
    } catch (e) {
      throw Exception('Failed to remove prayer from favorites: $e');
    }
  }

  /// Check if a prayer is favorited by user
  Future<bool> isFavorite({
    required String userId,
    required String prayerId,
  }) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('favorite_prayers')
          .doc(prayerId)
          .get();

      return doc.exists;
    } catch (e) {
      throw Exception('Failed to check favorite status: $e');
    }
  }

  /// Format date as document ID (YYYY-MM-DD)
  String _formatDateId(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }
}
