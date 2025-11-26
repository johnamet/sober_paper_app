import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/firebase_collections.dart';
import '../../domain/entities/sobriety_log.dart';
import '../../models/sobriety_log_model.dart';

class SobrietyRepository {
  final FirebaseFirestore _firestore;

  SobrietyRepository({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Log a sobriety day entry
  Future<void> logSobrietyDay({
    required String userId,
    required DateTime date,
    required String status, // 'clean', 'relapse'
    String? notes,
    String? mood,
    List<String>? triggers,
  }) async {
    try {
      // Use date as document ID (YYYY-MM-DD format) for easy querying
      final dateId = _formatDateId(date);
      final docRef = _firestore
          .collection(FirebaseCollections.users)
          .doc(userId)
          .collection(FirebaseCollections.sobrietyLogs)
          .doc(dateId);

      final logData = {
        'userId': userId,
        'date': Timestamp.fromDate(date),
        'dateId': dateId,
        'status': status,
        'notes': notes,
        'mood': mood,
        'triggers': triggers ?? [],
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await docRef.set(logData, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to log sobriety day: $e');
    }
  }

  /// Get sobriety logs for a date range
  Future<Map<DateTime, SobrietyLog>> getSobrietyLogs({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final startDateId = _formatDateId(startDate);
      final endDateId = _formatDateId(endDate);

      final querySnapshot = await _firestore
          .collection(FirebaseCollections.users)
          .doc(userId)
          .collection(FirebaseCollections.sobrietyLogs)
          .where('dateId', isGreaterThanOrEqualTo: startDateId)
          .where('dateId', isLessThanOrEqualTo: endDateId)
          .orderBy('dateId')
          .get();

      final logs = <DateTime, SobrietyLog>{};

      for (final doc in querySnapshot.docs) {
        final data = doc.data();
        final model = SobrietyLogModel.fromJson(data);
        final entry = model.log;
        logs[entry.date] = entry;
      }

      return logs;
    } catch (e) {
      throw Exception('Failed to get sobriety logs: $e');
    }
  }

  /// Get sobriety log for a specific date
  Future<SobrietyLog?> getSobrietyLogForDate({
    required String userId,
    required DateTime date,
  }) async {
    try {
      final dateId = _formatDateId(date);
      final doc = await _firestore
          .collection(FirebaseCollections.users)
          .doc(userId)
          .collection(FirebaseCollections.sobrietyLogs)
          .doc(dateId)
          .get();

      if (!doc.exists) return null;

      return SobrietyLogModel.fromJson(doc.data()!).log;
    } catch (e) {
      throw Exception('Failed to get sobriety log: $e');
    }
  }

  /// Delete a sobriety log entry
  Future<void> deleteSobrietyLog({
    required String userId,
    required DateTime date,
  }) async {
    try {
      final dateId = _formatDateId(date);
      await _firestore
          .collection(FirebaseCollections.users)
          .doc(userId)
          .collection(FirebaseCollections.sobrietyLogs)
          .doc(dateId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete sobriety log: $e');
    }
  }

  /// Stream sobriety logs for real-time updates
  Stream<Map<DateTime, SobrietyLog>> watchSobrietyLogs({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) {
    final startDateId = _formatDateId(startDate);
    final endDateId = _formatDateId(endDate);

    return _firestore
        .collection(FirebaseCollections.users)
        .doc(userId)
        .collection(FirebaseCollections.sobrietyLogs)
        .where('dateId', isGreaterThanOrEqualTo: startDateId)
        .where('dateId', isLessThanOrEqualTo: endDateId)
        .orderBy('dateId')
        .snapshots()
        .map((snapshot) {
      final logs = <DateTime, SobrietyLog>{};

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final model = SobrietyLogModel.fromJson(data);
        final log = model.log;
        logs[log.date] = log;
      }

      return logs;
    });
  }

  /// Calculate current streak
  Future<int> calculateCurrentStreak(String userId) async {
    try {
      final today = DateTime.now();
      final querySnapshot = await _firestore
          .collection(FirebaseCollections.users)
          .doc(userId)
          .collection(FirebaseCollections.sobrietyLogs)
          .orderBy('dateId', descending: true)
          .limit(365) // Check up to 1 year
          .get();

      int streak = 0;
      DateTime checkDate = DateTime(today.year, today.month, today.day);

      for (final doc in querySnapshot.docs) {
        final data = doc.data();
        final logDate = (data['date'] as Timestamp).toDate();
        final normalizedLogDate = DateTime(logDate.year, logDate.month, logDate.day);
        final status = data['status'] as String;

        if (normalizedLogDate == checkDate) {
          if (status == 'clean') {
            streak++;
            checkDate = checkDate.subtract(const Duration(days: 1));
          } else {
            break; // Relapse breaks the streak
          }
        } else if (normalizedLogDate.isBefore(checkDate)) {
          break; // Gap in logs
        }
      }

      return streak;
    } catch (e) {
      throw Exception('Failed to calculate streak: $e');
    }
  }

  /// Get total clean days
  Future<int> getTotalCleanDays(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection(FirebaseCollections.users)
          .doc(userId)
          .collection(FirebaseCollections.sobrietyLogs)
          .where('status', isEqualTo: 'clean')
          .get();

      return querySnapshot.docs.length;
    } catch (e) {
      throw Exception('Failed to get total clean days: $e');
    }
  }

  /// Get total relapses
  Future<int> getTotalRelapses(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection(FirebaseCollections.users)
          .doc(userId)
          .collection(FirebaseCollections.sobrietyLogs)
          .where('status', isEqualTo: 'relapse')
          .get();

      return querySnapshot.docs.length;
    } catch (e) {
      throw Exception('Failed to get total relapses: $e');
    }
  }

  /// Format date as YYYY-MM-DD for consistent document IDs
  String _formatDateId(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
