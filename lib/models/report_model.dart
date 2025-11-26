import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/entities/report.dart';

/// Model for Report with JSON serialization
class ReportModel {
  final Report report;

  const ReportModel(this.report);

  /// Convert from Firestore document
  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      Report(
        id: json['id'] as String,
        reportedBy: json['reportedBy'] as String,
        reportedUserId: json['reportedUserId'] as String?,
        reportedMessageId: json['reportedMessageId'] as String?,
        reportedGroupId: json['reportedGroupId'] as String?,
        reason: json['reason'] as String,
        description: json['description'] as String,
        status: _statusFromString(json['status'] as String),
        reviewedBy: json['reviewedBy'] as String?,
        reviewedAt: json['reviewedAt'] != null
            ? (json['reviewedAt'] as Timestamp).toDate()
            : null,
        createdAt: (json['createdAt'] as Timestamp).toDate(),
      ),
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toJson() {
    return {
      'id': report.id,
      'reportedBy': report.reportedBy,
      'reportedUserId': report.reportedUserId,
      'reportedMessageId': report.reportedMessageId,
      'reportedGroupId': report.reportedGroupId,
      'reason': report.reason,
      'description': report.description,
      'status': report.status.name,
      'reviewedBy': report.reviewedBy,
      'reviewedAt': report.reviewedAt != null
          ? Timestamp.fromDate(report.reviewedAt!)
          : null,
      'createdAt': Timestamp.fromDate(report.createdAt),
    };
  }

  static ReportStatus _statusFromString(String status) {
    switch (status) {
      case 'pending':
        return ReportStatus.pending;
      case 'reviewed':
        return ReportStatus.reviewed;
      case 'actionTaken':
        return ReportStatus.actionTaken;
      case 'dismissed':
        return ReportStatus.dismissed;
      default:
        return ReportStatus.pending;
    }
  }
}
