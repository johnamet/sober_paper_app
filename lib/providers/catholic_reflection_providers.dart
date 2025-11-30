import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/catholic_reflection_repository.dart';
import '../models/catholic_reflection_model.dart';
import '../services/living_faith_reflection_scraper_service.dart';

/// Provider for the scraper service
final catholicReflectionScraperProvider = Provider<LivingFaithReflectionScraperService>((ref) {
  return LivingFaithReflectionScraperService();
});

/// Provider for the repository
final catholicReflectionRepositoryProvider = Provider<CatholicReflectionRepository>((ref) {
  final scraper = ref.watch(catholicReflectionScraperProvider);
  return CatholicReflectionRepository(scraper: scraper);
});

/// Provider for today's reflection
final todayReflectionProvider = FutureProvider<DailyReflection?>((ref) async {
  final repository = ref.watch(catholicReflectionRepositoryProvider);
  return repository.getTodayReflection();
});

/// Provider for reflection by date
final reflectionByDateProvider = FutureProvider.family<DailyReflection?, DateTime>((ref, date) async {
  final repository = ref.watch(catholicReflectionRepositoryProvider);
  return repository.getReflection(date);
});

/// Provider for recent reflections
final recentReflectionsProvider = FutureProvider<List<DailyReflection>>((ref) async {
  final repository = ref.watch(catholicReflectionRepositoryProvider);
  return repository.getRecentReflections();
});

/// Notifier for selected date (for date picker)
class SelectedReflectionDateNotifier extends Notifier<DateTime> {
  @override
  DateTime build() => DateTime.now();

  void setDate(DateTime date) {
    state = date;
  }

  void setToday() {
    state = DateTime.now();
  }
}

final selectedReflectionDateProvider = NotifierProvider<SelectedReflectionDateNotifier, DateTime>(
  () => SelectedReflectionDateNotifier(),
);

/// Provider for reflection based on selected date
final selectedDateReflectionProvider = FutureProvider<DailyReflection?>((ref) async {
  final date = ref.watch(selectedReflectionDateProvider);
  final repository = ref.watch(catholicReflectionRepositoryProvider);
  return repository.getReflection(date);
});
