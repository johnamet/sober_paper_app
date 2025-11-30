import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import '../../models/saint_of_the_day_model.dart';
import '../../services/saint_of_the_day_scraper_service.dart';

class SaintOfTheDayRepository {
  static const String _boxName = 'saint_of_the_day';
  static const int _cacheExpirationDays = 90;
  
  late Box<SaintOfTheDay> _box;
  final SaintOfTheDayScraperService _scraper;

  SaintOfTheDayRepository({SaintOfTheDayScraperService? scraper})
      : _scraper = scraper ?? SaintOfTheDayScraperService();

  /// Initialize the Hive box
  Future<void> init() async {
    if (!Hive.isBoxOpen(_boxName)) {
      _box = await Hive.openBox<SaintOfTheDay>(_boxName);
      await _clearOldCache();
    } else {
      _box = Hive.box<SaintOfTheDay>(_boxName);
    }
  }

  /// Get today's saint (from cache or fetch fresh)
  Future<SaintOfTheDay?> getTodaySaint() async {
    await init();
    
    final todayKey = _getDateKey(DateTime.now());
    final cached = _box.get(todayKey);
    
    // Return cached if available and fresh (less than 24 hours old)
    if (cached != null && _isCacheFresh(cached)) {
      return cached;
    }

    // Fetch fresh data
    try {
      final saint = await _scraper.fetchTodaySaint();
      if (saint != null) {
        await _box.put(todayKey, saint);
        return saint;
      }
      return cached; // Return stale cache if fetch fails
    } catch (e) {
      print('Error fetching today\'s saint: $e');
      return cached; // Return cached data on error
    }
  }

  /// Get saint for a specific date
  Future<SaintOfTheDay?> getSaintByDate(DateTime date) async {
    await init();
    
    final dateKey = _getDateKey(date);
    final cached = _box.get(dateKey);
    
    // Return cached if available and fresh
    if (cached != null && _isCacheFresh(cached)) {
      return cached;
    }

    // Fetch fresh data
    try {
      final saint = await _scraper.fetchSaintByDate(date);
      print(saint.toString());
      if (saint != null) {
        await _box.put(dateKey, saint);
        return saint;
      }
      return cached;
    } catch (e) {
      print('Error fetching saint by date: $e');
      return cached;
    }
  }

  /// Get upcoming saints (next few days)
  Future<List<SaintOfTheDay>> getUpcomingSaints({int daysAhead = 7}) async {
    await init();
    
    try {
      final saints = await _scraper.fetchUpcomingSaints(daysAhead: daysAhead);
      
      // Cache each saint
      for (var saint in saints) {
        final key = _getDateKey(saint.date);
        await _box.put(key, saint);
      }
      
      return saints;
    } catch (e) {
      print('Error fetching upcoming saints: $e');
      
      // Return cached saints if available
      final cachedSaints = <SaintOfTheDay>[];
      final now = DateTime.now();
      
      for (int i = 0; i < daysAhead; i++) {
        final date = now.add(Duration(days: i));
        final key = _getDateKey(date);
        final cached = _box.get(key);
        if (cached != null) {
          cachedSaints.add(cached);
        }
      }
      
      return cachedSaints;
    }
  }

  /// Clear old cached data (older than _cacheExpirationDays)
  Future<void> _clearOldCache() async {
    final now = DateTime.now();
    final keysToDelete = <String>[];

    for (var key in _box.keys) {
      final saint = _box.get(key);
      if (saint != null) {
        final age = now.difference(saint.fetchedAt).inDays;
        if (age > _cacheExpirationDays) {
          keysToDelete.add(key as String);
        }
      }
    }

    for (var key in keysToDelete) {
      await _box.delete(key);
    }

    if (keysToDelete.isNotEmpty) {
      print('Cleared ${keysToDelete.length} old saint entries from cache');
    }
  }

  /// Check if cached data is still fresh (less than 24 hours old)
  bool _isCacheFresh(SaintOfTheDay saint) {
    final age = DateTime.now().difference(saint.fetchedAt);
    return age.inHours < 24;
  }

  /// Generate cache key from date
  String _getDateKey(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  /// Clear all cache
  Future<void> clearCache() async {
    await init();
    await _box.clear();
  }

  void dispose() {
    _scraper.dispose();
  }
}
