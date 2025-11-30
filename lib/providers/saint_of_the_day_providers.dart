import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/saint_of_the_day_repository.dart';
import '../models/saint_of_the_day_model.dart';

// Repository provider
final saintRepositoryProvider = Provider<SaintOfTheDayRepository>((ref) {
  return SaintOfTheDayRepository();
});

// Today's saint provider
final todaySaintProvider = FutureProvider<SaintOfTheDay?>((ref) async {
  final repository = ref.watch(saintRepositoryProvider);
  return await repository.getTodaySaint();
});

// Upcoming saints provider
final upcomingSaintsProvider = FutureProvider.family<List<SaintOfTheDay>, int>(
  (ref, daysAhead) async {
    final repository = ref.watch(saintRepositoryProvider);
    return await repository.getUpcomingSaints(daysAhead: daysAhead);
  },
);

// Saint by date provider
final saintByDateProvider = FutureProvider.family<SaintOfTheDay?, DateTime>(
  (ref, date) async {
    final repository = ref.watch(saintRepositoryProvider);
    return await repository.getSaintByDate(date);
  },
);

// Selected date state notifier
class SelectedSaintDateNotifier extends Notifier<DateTime> {
  @override
  DateTime build() => DateTime.now();
  
  void setDate(DateTime date) {
    state = date;
  }
  
  void setToday() {
    state = DateTime.now();
  }
}

// Selected date state provider
final selectedSaintDateProvider = NotifierProvider<SelectedSaintDateNotifier, DateTime>(
  () => SelectedSaintDateNotifier(),
);

// Selected date saint provider (combines date selection with data fetching)
final selectedDateSaintProvider = FutureProvider<SaintOfTheDay?>((ref) async {
  final selectedDate = ref.watch(selectedSaintDateProvider);
  final repository = ref.watch(saintRepositoryProvider);
  return await repository.getSaintByDate(selectedDate);
});
