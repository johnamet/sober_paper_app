/// Report of inappropriate content or user behavior
class Report {
  final String id;
  final String reportedBy;
  final String? reportedUserId;
  final String? reportedMessageId;
  final String? reportedGroupId;
  final String reason;
  final String description;
  final ReportStatus status;
  final String? reviewedBy;
  final DateTime? reviewedAt;
  final DateTime createdAt;

  const Report({
    required this.id,
    required this.reportedBy,
    this.reportedUserId,
    this.reportedMessageId,
    this.reportedGroupId,
    required this.reason,
    required this.description,
    required this.status,
    this.reviewedBy,
    this.reviewedAt,
    required this.createdAt,
  });

  /// Check if report is still pending review
  bool get isPending => status == ReportStatus.pending;

  /// Check if report has been reviewed
  bool get isReviewed => reviewedAt != null;

  /// Check if report is about a user
  bool get isUserReport => reportedUserId != null;

  /// Check if report is about a message
  bool get isMessageReport => reportedMessageId != null;

  Report copyWith({
    String? id,
    String? reportedBy,
    String? reportedUserId,
    String? reportedMessageId,
    String? reportedGroupId,
    String? reason,
    String? description,
    ReportStatus? status,
    String? reviewedBy,
    DateTime? reviewedAt,
    DateTime? createdAt,
  }) {
    return Report(
      id: id ?? this.id,
      reportedBy: reportedBy ?? this.reportedBy,
      reportedUserId: reportedUserId ?? this.reportedUserId,
      reportedMessageId: reportedMessageId ?? this.reportedMessageId,
      reportedGroupId: reportedGroupId ?? this.reportedGroupId,
      reason: reason ?? this.reason,
      description: description ?? this.description,
      status: status ?? this.status,
      reviewedBy: reviewedBy ?? this.reviewedBy,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Status of a moderation report
enum ReportStatus {
  /// Awaiting moderator review
  pending,
  
  /// Reviewed by moderator
  reviewed,
  
  /// Action was taken based on report
  actionTaken,
  
  /// Report was dismissed
  dismissed,
}
