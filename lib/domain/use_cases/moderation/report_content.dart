import '../../entities/report.dart';
import '../../../data/repositories/moderation_repository.dart';

class ReportContent {
  final ModerationRepository _moderationRepository;

  ReportContent(this._moderationRepository);

  Future<Report> call({
    required String reportedBy,
    required String reason,
    String? description,
    String? reportedUserId,
    String? reportedMessageId,
    String? reportedGroupId,
  }) async {
    if (reportedBy.isEmpty || reason.isEmpty) {
      throw ArgumentError('Reporter ID and reason are required');
    }

    // At least one content identifier must be provided
    if (reportedUserId == null && 
        reportedMessageId == null && 
        reportedGroupId == null) {
      throw ArgumentError('At least one content identifier must be provided');
    }

    return await _moderationRepository.reportContent(
      reportedBy: reportedBy,
      reason: reason,
      description: description ?? '',
      reportedUserId: reportedUserId,
      reportedMessageId: reportedMessageId,
      reportedGroupId: reportedGroupId,
    );
  }
}
