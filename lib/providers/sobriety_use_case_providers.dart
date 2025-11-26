import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/use_cases/sobriety/log_sobriety_day.dart';
import '../domain/use_cases/sobriety/get_sobriety_logs.dart';
import '../domain/use_cases/sobriety/calculate_current_streak.dart';
import '../domain/use_cases/sobriety/get_total_clean_days.dart';
import '../domain/use_cases/sobriety/watch_sobriety_logs.dart';
import 'repository_providers.dart';

// ============================================================================
// SOBRIETY USE CASE PROVIDERS
// ============================================================================

final logSobrietyDayProvider = Provider<LogSobrietyDay>((ref) {
  return LogSobrietyDay(ref.watch(sobrietyRepositoryProvider));
});

final getSobrietyLogsProvider = Provider<GetSobrietyLogs>((ref) {
  return GetSobrietyLogs(ref.watch(sobrietyRepositoryProvider));
});

final calculateCurrentStreakProvider = Provider<CalculateCurrentStreak>((ref) {
  return CalculateCurrentStreak(ref.watch(sobrietyRepositoryProvider));
});

final getTotalCleanDaysProvider = Provider<GetTotalCleanDays>((ref) {
  return GetTotalCleanDays(ref.watch(sobrietyRepositoryProvider));
});

final watchSobrietyLogsProvider = Provider<WatchSobrietyLogs>((ref) {
  return WatchSobrietyLogs(ref.watch(sobrietyRepositoryProvider));
});
