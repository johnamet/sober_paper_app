// DEPRECATED: This file is being replaced by the new provider architecture
// Use providers from lib/providers/providers.dart instead
// This file is kept temporarily for backwards compatibility

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/sobriety_repository.dart';
// import '../models/sobriety_log_model.dart'; // Model not found
import 'user_provider.dart';
import '../domain/entities/sobriety_log.dart'; // Use entity instead

// Provider for SobrietyRepository
final sobrietyRepositoryProviderOld = Provider<SobrietyRepository>((ref) {
  return SobrietyRepository();
});

// Provider for sobriety logs in a date range
final sobrietyLogsProviderOld = StreamProvider.family<Map<DateTime, SobrietyLog>, DateRange>(
  (ref, dateRange) {
    final userId = ref.watch(userIdProvider);
    if (userId == null) {
      return Stream.value({});
    }

    final repository = ref.watch(sobrietyRepositoryProviderOld);
    return repository.watchSobrietyLogs(
      userId: userId,
      startDate: dateRange.startDate,
      endDate: dateRange.endDate,
    );
  },
);

// Provider for current streak
final currentStreakProviderOld = FutureProvider<int>((ref) async {
  final userId = ref.watch(userIdProvider);
  if (userId == null) return 0;

  final repository = ref.watch(sobrietyRepositoryProviderOld);
  return repository.calculateCurrentStreak(userId);
});

// Provider for total clean days
final totalCleanDaysProviderOld = FutureProvider<int>((ref) async {
  final userId = ref.watch(userIdProvider);
  if (userId == null) return 0;

  final repository = ref.watch(sobrietyRepositoryProviderOld);
  return repository.getTotalCleanDays(userId);
});

// Provider for total relapses
final totalRelapsesProviderOld = FutureProvider<int>((ref) async {
  final userId = ref.watch(userIdProvider);
  if (userId == null) return 0;

  final repository = ref.watch(sobrietyRepositoryProviderOld);
  return repository.getTotalRelapses(userId);
});

// Date range class for provider parameter
class DateRange {
  final DateTime startDate;
  final DateTime endDate;

  DateRange({
    required this.startDate,
    required this.endDate,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DateRange &&
        other.startDate == startDate &&
        other.endDate == endDate;
  }

  @override
  int get hashCode => startDate.hashCode ^ endDate.hashCode;
}
