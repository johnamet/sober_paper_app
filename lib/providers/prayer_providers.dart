import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/prayer_repository.dart';
import '../domain/entities/prayer.dart';

/// Provider for Firestore instance
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

/// Provider for PrayerRepository
final prayerRepositoryProvider = Provider<PrayerRepository>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return PrayerRepository(firestore);
});

/// Provider for daily prayers
final dailyPrayersProvider = FutureProvider<List<Prayer>>((ref) async {
  final repository = ref.watch(prayerRepositoryProvider);
  return repository.getDailyPrayers();
});

/// Provider for all prayers
final allPrayersProvider = FutureProvider<List<Prayer>>((ref) async {
  final repository = ref.watch(prayerRepositoryProvider);
  return repository.getAllPrayers();
});

/// Provider for emergency prayers
final emergencyPrayersProvider = FutureProvider<List<Prayer>>((ref) async {
  final repository = ref.watch(prayerRepositoryProvider);
  return repository.getEmergencyPrayers();
});

/// Provider for prayers by category
final prayersByCategoryProvider = FutureProvider.family<List<Prayer>, PrayerCategory>(
  (ref, category) async {
    final repository = ref.watch(prayerRepositoryProvider);
    return repository.getPrayersByCategory(category);
  },
);

/// Provider to clear prayer cache
final clearPrayerCacheProvider = Provider<Future<void> Function()>((ref) {
  return () async {
    final repository = ref.read(prayerRepositoryProvider);
    await repository.clearCache();
    // Invalidate providers to force refetch
    ref.invalidate(dailyPrayersProvider);
    ref.invalidate(allPrayersProvider);
    ref.invalidate(emergencyPrayersProvider);
  };
});
