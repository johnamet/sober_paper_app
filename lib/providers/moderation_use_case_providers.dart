import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/use_cases/moderation/report_content.dart';
import 'repository_providers.dart';

// ============================================================================
// MODERATION USE CASE PROVIDERS
// ============================================================================

final reportContentProvider = Provider<ReportContent>((ref) {
  return ReportContent(ref.watch(moderationRepositoryProvider));
});
