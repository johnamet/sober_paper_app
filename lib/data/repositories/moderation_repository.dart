import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/report.dart';
import '../../models/report_model.dart';

/// Repository for content moderation
class ModerationRepository {
  final FirebaseFirestore _firestore;

  ModerationRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Check content for inappropriate material (external API integration point)
  /// Returns true if content passes moderation, false if flagged
  Future<bool> checkContent(String content) async {
    try {
      // TODO: Integrate with external moderation API (e.g., Google Cloud Natural Language API)
      // For now, basic keyword filter as placeholder
      final lowerContent = content.toLowerCase();
      final inappropriateKeywords = ['spam', 'abuse', 'scam']; // Placeholder
      
      for (final keyword in inappropriateKeywords) {
        if (lowerContent.contains(keyword)) {
          return false;
        }
      }
      
      return true;
    } catch (e) {
      throw Exception('Failed to check content: $e');
    }
  }

  /// Report inappropriate content
  Future<Report> reportContent({
    required String reportedBy,
    String? reportedUserId,
    String? reportedMessageId,
    String? reportedGroupId,
    required String reason,
    required String description,
  }) async {
    try {
      final report = Report(
        id: '', // Will be set by Firestore
        reportedBy: reportedBy,
        reportedUserId: reportedUserId,
        reportedMessageId: reportedMessageId,
        reportedGroupId: reportedGroupId,
        reason: reason,
        description: description,
        status: ReportStatus.pending,
        createdAt: DateTime.now(),
      );

      final docRef = await _firestore
          .collection('reports')
          .add(ReportModel(report).toJson());

      return report.copyWith(id: docRef.id);
    } catch (e) {
      throw Exception('Failed to report content: $e');
    }
  }

  /// Get pending reports for moderation review
  Future<List<Report>> getPendingReports() async {
    try {
      final snapshot = await _firestore
          .collection('reports')
          .where('status', isEqualTo: ReportStatus.pending.name)
          .orderBy('createdAt', descending: false)
          .get();

      return snapshot.docs.map((doc) {
        final model = ReportModel.fromJson({
          ...doc.data(),
          'id': doc.id,
        });
        return model.report;
      }).toList();
    } catch (e) {
      throw Exception('Failed to get pending reports: $e');
    }
  }

  /// Get a specific report by ID
  Future<Report?> getReport(String reportId) async {
    try {
      final doc = await _firestore
          .collection('reports')
          .doc(reportId)
          .get();

      if (!doc.exists) return null;

      final model = ReportModel.fromJson({
        ...doc.data()!,
        'id': doc.id,
      });

      return model.report;
    } catch (e) {
      throw Exception('Failed to get report: $e');
    }
  }

  /// Get all reports created by a specific user
  Future<List<Report>> getUserReports(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('reports')
          .where('reportedBy', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final model = ReportModel.fromJson({
          ...doc.data(),
          'id': doc.id,
        });
        return model.report;
      }).toList();
    } catch (e) {
      throw Exception('Failed to get user reports: $e');
    }
  }

  /// Get all reports about a specific message
  Future<List<Report>> getMessageReports(String messageId) async {
    try {
      final snapshot = await _firestore
          .collection('reports')
          .where('reportedMessageId', isEqualTo: messageId)
          .orderBy('createdAt', descending: false)
          .get();

      return snapshot.docs.map((doc) {
        final model = ReportModel.fromJson({
          ...doc.data(),
          'id': doc.id,
        });
        return model.report;
      }).toList();
    } catch (e) {
      throw Exception('Failed to get message reports: $e');
    }
  }

  /// Review a report (moderator action)
  Future<void> reviewReport({
    required String reportId,
    required String reviewerId,
    required ReportStatus newStatus,
    String? reviewNotes,
  }) async {
    try {
      await _firestore.collection('reports').doc(reportId).update({
        'status': newStatus.name,
        'reviewerId': reviewerId,
        'reviewNotes': reviewNotes,
        'reviewedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw Exception('Failed to review report: $e');
    }
  }

  /// Approve a report (take action on reported content)
  Future<void> approveReport(String reportId, String reviewerId) async {
    await reviewReport(
      reportId: reportId,
      reviewerId: reviewerId,
      newStatus: ReportStatus.actionTaken,
    );
  }

  /// Dismiss a report (no action needed)
  Future<void> dismissReport(String reportId, String reviewerId, {String? reason}) async {
    await reviewReport(
      reportId: reportId,
      reviewerId: reviewerId,
      newStatus: ReportStatus.dismissed,
      reviewNotes: reason,
    );
  }

  /// Flag a message for automatic moderation
  Future<void> flagMessage({
    required String messageId,
    required String reason,
  }) async {
    try {
      await _firestore.collection('flagged_messages').doc(messageId).set({
        'messageId': messageId,
        'reason': reason,
        'flaggedAt': Timestamp.fromDate(DateTime.now()),
        'status': 'pending',
      });
    } catch (e) {
      throw Exception('Failed to flag message: $e');
    }
  }

  /// Stream of pending reports for real-time moderation
  Stream<List<Report>> watchPendingReports() {
    return _firestore
        .collection('reports')
        .where('status', isEqualTo: ReportStatus.pending.name)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final model = ReportModel.fromJson({
          ...doc.data(),
          'id': doc.id,
        });
        return model.report;
      }).toList();
    });
  }

  /// Delete a report
  Future<void> deleteReport(String reportId) async {
    try {
      await _firestore.collection('reports').doc(reportId).delete();
    } catch (e) {
      throw Exception('Failed to delete report: $e');
    }
  }
}
