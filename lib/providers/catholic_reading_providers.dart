import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/catholic_reading_model.dart';
import '../data/repositories/catholic_reading_repository.dart';

/// Provider for the Catholic reading repository
final catholicReadingRepositoryProvider = Provider<CatholicReadingRepository>((ref) {
  return CatholicReadingRepository();
});

/// Provider for fetching readings for a specific date
final catholicReadingsProvider = FutureProvider.family<DailyCatholicReading?, DateTime>((ref, date) async {
  final repository = ref.watch(catholicReadingRepositoryProvider);
  return repository.getReadings(date);
});

/// Provider for today's readings
final todayCatholicReadingsProvider = FutureProvider<DailyCatholicReading?>((ref) async {
  final repository = ref.watch(catholicReadingRepositoryProvider);
  return repository.getTodayReadings();
});

/// Provider for Mass video URL for a specific date
final massVideoUrlProvider = FutureProvider.family<String?, DateTime>((ref, date) async {
  final repository = ref.watch(catholicReadingRepositoryProvider);
  return repository.getMassVideoUrl(date);
});

/// Notifier for managing selected date for readings
class ReadingDateNotifier extends Notifier<DateTime> {
  @override
  DateTime build() => DateTime.now();

  void selectDate(DateTime date) {
    state = date;
  }

  void selectToday() {
    state = DateTime.now();
  }
}

/// Provider for the selected reading date
final selectedReadingDateProvider = NotifierProvider<ReadingDateNotifier, DateTime>(
  ReadingDateNotifier.new,
);

/// Provider for readings based on selected date
final selectedDateReadingsProvider = FutureProvider<DailyCatholicReading?>((ref) async {
  final selectedDate = ref.watch(selectedReadingDateProvider);
  final repository = ref.watch(catholicReadingRepositoryProvider);
  return repository.getReadings(selectedDate);
});
