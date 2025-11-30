import 'package:intl/intl.dart';
import '../services/living_faith_reflection_scraper_service.dart';

/// Test script for Living Faith reflection scraper
void main() async {
  print('===== LIVING FAITH REFLECTION SCRAPER TEST =====\n');

  final scraper = LivingFaithReflectionScraperService();

  try {
    // Test 1: Today's reflection
    print('Test 1: Fetching today\'s reflection...');
    final today = await scraper.fetchTodayReflection();
    if (today != null) {
      _printReflection(today);
    } else {
      print('❌ Failed to fetch today\'s reflection\n');
    }

    // Test 2: Specific date (the sample date we analyzed)
    print('\n' + '=' * 50);
    print('Test 2: Fetching reflection for November 29, 2025...');
    final specificDate = DateTime(2025, 11, 29);
    final reflection = await scraper.fetchReflectionByDate(specificDate);
    if (reflection != null) {
      _printReflection(reflection);
    } else {
      print('❌ Failed to fetch reflection for ${DateFormat('yyyy-MM-dd').format(specificDate)}\n');
    }

    // Test 3: Different date
    print('\n' + '=' * 50);
    print('Test 3: Fetching reflection for yesterday...');
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final yesterdayReflection = await scraper.fetchReflectionByDate(yesterday);
    if (yesterdayReflection != null) {
      _printReflection(yesterdayReflection);
    } else {
      print('❌ Failed to fetch reflection for ${DateFormat('yyyy-MM-dd').format(yesterday)}\n');
    }

    // Test 4: Recent reflections
    print('\n' + '=' * 50);
    print('Test 4: Fetching recent reflections (last 7 days)...');
    final recentReflections = await scraper.fetchRecentReflections();
    print('✅ Fetched ${recentReflections.length} reflections:');
    for (var r in recentReflections) {
      print('  - ${DateFormat('yyyy-MM-dd').format(r.date)}: ${r.title}');
    }

    print('\n' + '=' * 50);
    print('✅ ALL TESTS COMPLETED');
    print('=' * 50);
  } catch (e, stackTrace) {
    print('❌ ERROR: $e');
    print('Stack trace: $stackTrace');
  } finally {
    scraper.dispose();
  }
}

void _printReflection(reflection) {
  print('✅ Successfully fetched reflection:');
  print('  Date: ${DateFormat('yyyy-MM-dd').format(reflection.date)}');
  print('  Title: ${reflection.title}');
  print('  Author: ${reflection.author ?? 'N/A'}');
  
  if (reflection.bibleVerse != null) {
    print('  Bible Verse: ${reflection.bibleVerse}');
    print('  Reference: ${reflection.verseReference ?? 'N/A'}');
  } else {
    print('  Bible Verse: N/A');
  }
  
  print('  Content Length: ${reflection.content.length} characters');
  print('  Content Preview: ${reflection.content.substring(0, reflection.content.length > 100 ? 100 : reflection.content.length)}...');
  
  print('  Prayer: ${reflection.prayer.substring(0, reflection.prayer.length > 100 ? 100 : reflection.prayer.length)}...');
  
  print('  Image URL: ${reflection.imageUrl ?? 'N/A'}');
  print('  Fetched At: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(reflection.fetchedAt)}');
}
