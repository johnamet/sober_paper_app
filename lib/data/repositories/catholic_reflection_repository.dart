import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import '../../models/catholic_reflection_model.dart';
import '../../services/living_faith_reflection_scraper_service.dart';

/// Repository for managing Catholic daily reflections with offline caching
class CatholicReflectionRepository {
  static const String _boxName = 'catholic_reflections';
  final LivingFaithReflectionScraperService _scraper;

  Box<DailyReflection>? _box;

  CatholicReflectionRepository({LivingFaithReflectionScraperService? scraper})
      : _scraper = scraper ?? LivingFaithReflectionScraperService();

  /// Initialize the Hive box
  Future<void> initialize() async {
    if (_box == null || !_box!.isOpen) {
      _box = await Hive.openBox<DailyReflection>(_boxName);
      print('Catholic Reflections box initialized with ${_box!.length} cached items');
    }
  }

  /// Get reflection for a specific date
  Future<DailyReflection?> getReflection(DateTime date) async {
    await initialize();
    final key = DateFormat('yyyy-MM-dd').format(date);

    // Return cached (reflections never change once published)
    if (_box!.containsKey(key)) {
      print('Returning cached reflection for $key');
      return _box!.get(key);
    }

    // Fetch and cache
    print('No cache found. Fetching fresh reflection for $key');
    final reflection = await _scraper.fetchReflectionByDate(date);
    if (reflection != null) {
      await _box!.put(key, reflection);
      print('Cached new reflection: ${reflection.title}');
    }
    return reflection;
  }

  /// Get today's reflection
  Future<DailyReflection?> getTodayReflection() async {
    return getReflection(DateTime.now());
  }

  /// Get recent reflections (with intelligent caching)
  Future<List<DailyReflection>> getRecentReflections({int days = 7}) async {
    await initialize();

    // Try to get from cache first
    final cachedList = <DailyReflection>[];
    final today = DateTime.now();

    for (int i = 0; i < days; i++) {
      final date = today.subtract(Duration(days: i));
      final key = DateFormat('yyyy-MM-dd').format(date);
      
      if (_box!.containsKey(key)) {
        final reflection = _box!.get(key);
        if (reflection != null) {
          cachedList.add(reflection);
        }
      }
    }

    // If we have enough cached reflections, return them
    if (cachedList.length >= days - 2) {
      print('Returning ${cachedList.length} cached reflections');
      cachedList.sort((a, b) => b.date.compareTo(a.date));
      return cachedList;
    }

    // Otherwise, fetch fresh list
    print('Fetching fresh list of recent reflections');
    final freshList = await _scraper.fetchRecentReflections();
    
    // Cache all fetched reflections
    for (var reflection in freshList) {
      final key = DateFormat('yyyy-MM-dd').format(reflection.date);
      await _box!.put(key, reflection);
    }
    
    freshList.sort((a, b) => b.date.compareTo(a.date));
    return freshList;
  }

  /// Force refresh a specific date
  Future<DailyReflection?> refreshReflection(DateTime date) async {
    await initialize();
    final key = DateFormat('yyyy-MM-dd').format(date);
    
    print('Force refreshing reflection for $key');
    final reflection = await _scraper.fetchReflectionByDate(date);
    
    if (reflection != null) {
      await _box!.put(key, reflection);
      print('Refreshed and cached: ${reflection.title}');
    }
    
    return reflection;
  }

  /// Clear all cached reflections
  Future<void> clearCache() async {
    await initialize();
    await _box!.clear();
    print('Cleared all cached reflections');
  }

  /// Clear old reflections (older than 90 days)
  Future<void> clearOldCache() async {
    await initialize();
    final cutoffDate = DateTime.now().subtract(const Duration(days: 90));
    final keysToDelete = <String>[];

    for (var key in _box!.keys) {
      try {
        final date = DateFormat('yyyy-MM-dd').parse(key as String);
        if (date.isBefore(cutoffDate)) {
          keysToDelete.add(key);
        }
      } catch (e) {
        // Invalid key format, remove it
        keysToDelete.add(key as String);
      }
    }

    if (keysToDelete.isNotEmpty) {
      await _box!.deleteAll(keysToDelete);
      print('Deleted ${keysToDelete.length} old reflections');
    }
  }

  /// Get cache statistics
  Map<String, dynamic> getCacheStats() {
    if (_box == null) {
      return {
        'total': 0,
        'oldest': null,
        'newest': null,
      };
    }

    final dates = <DateTime>[];
    for (var key in _box!.keys) {
      try {
        final date = DateFormat('yyyy-MM-dd').parse(key as String);
        dates.add(date);
      } catch (e) {
        // Skip invalid keys
      }
    }

    dates.sort();

    return {
      'total': dates.length,
      'oldest': dates.isEmpty ? null : DateFormat('yyyy-MM-dd').format(dates.first),
      'newest': dates.isEmpty ? null : DateFormat('yyyy-MM-dd').format(dates.last),
    };
  }

  /// Dispose resources
  void dispose() {
    _scraper.dispose();
  }
}
