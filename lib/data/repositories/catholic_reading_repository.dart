import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../../models/catholic_reading_model.dart';
import '../../services/ewtn_scraper_service.dart';

/// Repository for managing Catholic readings with smart caching
class CatholicReadingRepository {
  static const String _boxName = 'catholic_readings';
  static const int _cacheDaysValid = 30; // Consider data fresh for 30 days

  final EWTNScraperService _scraperService;
  Box<DailyCatholicReading>? _box;

  CatholicReadingRepository({EWTNScraperService? scraperService})
      : _scraperService = scraperService ?? EWTNScraperService();

  /// Initialize Hive box (safe to call multiple times)
  Future<void> initialize() async {
    if (_box == null || !_box!.isOpen) {
      _box = await Hive.openBox<DailyCatholicReading>(_boxName);
    }
  }

  /// Get readings for a specific date (with smart caching)
  Future<DailyCatholicReading?> getReadings(DateTime date) async {
    await initialize();

    final normalizedDate = DateTime(date.year, date.month, date.day);
    final key = _getDateKey(normalizedDate);

    // 1. Try cache first
    final cached = _box?.get(key);
    if (cached != null) {
      // Even if slightly stale, return cached version immediately
      // (Liturgical readings never change after the day passes)
      print('Returning cached readings for $key (age: ${cached.ageInDays} days)');
      return cached;
    }

    // 2. No cache → fetch from network
    print('No cache found. Fetching fresh readings for $key');
    try {
      final fresh = await _scraperService.fetchReadingsForDate(normalizedDate);

      if (fresh != null) {
        await _box?.put(key, fresh);
        print('Successfully cached readings for $key');
        return fresh;
      } else {
        print('No readings returned from scraper for $key');
        return null;
      }
    } catch (e) {
      print('Network error while fetching readings: $e');
      // Don't rethrow — better to return null than crash UI
      return null;
    }
  }

  /// Get today's readings
  Future<DailyCatholicReading?> getTodayReadings() async {
    return getReadings(DateTime.now());
  }

  /// Get Mass video URL (with caching)
  Future<String?> getMassVideoUrl(DateTime date) async {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final readings = await getReadings(normalizedDate);

    // Return cached URL if exists
    if (readings?.massVideoUrl != null && readings!.massVideoUrl!.isNotEmpty) {
      return readings.massVideoUrl;
    }

    // Otherwise fetch and cache
    try {
      final url = await _scraperService.fetchMassVideoUrl(normalizedDate);
      if (url != null && readings != null) {
        final updated = readings.copyWith(massVideoUrl: url);
        await _box?.put(_getDateKey(normalizedDate), updated);
      }
      return url;
    } catch (e) {
      print('Error fetching Mass video URL: $e');
      return null;
    }
  }

  /// Force refresh readings (bypass cache)
  Future<DailyCatholicReading?> refreshReadings(DateTime date) async {
    await initialize();
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final key = _getDateKey(normalizedDate);

    print('Force refreshing readings for $key');
    try {
      final fresh = await _scraperService.fetchReadingsForDate(normalizedDate);
      if (fresh != null) {
        await _box?.put(key, fresh);
        print('Refreshed and cached readings for $key');
      }
      return fresh;
    } catch (e) {
      print('Failed to refresh readings: $e');
      rethrow;
    }
  }

  /// Clear all cached readings
  Future<void> clearCache() async {
    await initialize();
    await _box?.clear();
    print('All cached readings cleared');
  }

  /// Remove entries older than 180 days (not 30 — readings never expire)
  Future<void> clearOldCache() async {
    await initialize();

    final cutoff = DateTime.now().subtract(const Duration(days: 180));
    final keysToDelete = <String>[];

    for (final key in _box?.keys ?? <dynamic>[]) {
      final reading = _box?.get(key);
      if (reading != null && reading.fetchDate.isBefore(cutoff)) {
        keysToDelete.add(key as String);
      }
    }

    if (keysToDelete.isNotEmpty) {
      await _box?.deleteAll(keysToDelete);
      print('Cleared ${keysToDelete.length} very old entries (>180 days)');
    }
  }

  /// Get cache statistics
  Future<Map<String, dynamic>> getCacheStats() async {
    await initialize();

    final total = _box?.length ?? 0;
    final now = DateTime.now();

    int recent = 0;
    int old = 0;

    for (final reading in _box?.values ?? <DailyCatholicReading>[]) {
      if (now.difference(reading.fetchDate).inDays <= 90) {
        recent++;
      } else {
        old++;
      }
    }

    return {
      'total': total,
      'recent_90_days': recent,
      'older_than_90_days': old,
      'cache_size_hint': '${(total * 15).toStringAsFixed(0)} KB approx', // ~15KB per entry
    };
  }

  /// Generate consistent cache key
  String _getDateKey(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  /// Close Hive box (call on app shutdown)
  Future<void> close() async {
    await _box?.close();
    _box = null;
  }
}