import '../services/catholic_reflection_scraper_service.dart';

void main() async {
  print('=================================================');
  print('Testing Catholic Reflection Scraper Service');
  print('=================================================');
  print('');
  
  final scraper = CatholicReflectionScraperService();
  
  // Test 1: Fetch today's reflection
  print('TEST 1: Fetching today\'s reflection...');
  print('-------------------------------------------------');
  try {
    final today = DateTime.now();
    final todayReflection = await scraper.fetchReflectionByDate(today);
    
    if (todayReflection != null) {
      print('✓ SUCCESS: Today\'s reflection fetched');
      print('');
      print('Date: ${todayReflection.date}');
      print('Title: ${todayReflection.title}');
      print('Author: ${todayReflection.author ?? "N/A"}');
      print('');
      print('Content (first 200 chars):');
      print(todayReflection.content.substring(
        0, 
        todayReflection.content.length > 200 ? 200 : todayReflection.content.length
      ));
      print('...');
      print('');
      
      if (todayReflection.hasBibleVerse) {
        print('Bible Verse Reference: ${todayReflection.verseReference}');
        print('Bible Verse: ${todayReflection.bibleVerse}');
      } else {
        print('Bible Verse: Not available');
      }
      print('');
      
      print('Prayer (first 150 chars):');
      print(todayReflection.prayer.substring(
        0,
        todayReflection.prayer.length > 150 ? 150 : todayReflection.prayer.length
      ));
      print('...');
      print('');
      
      print('Fetched At: ${todayReflection.fetchedAt}');
    } else {
      print('✗ FAILED: No reflection returned');
    }
  } catch (e) {
    print('✗ ERROR: $e');
  }
  
  print('');
  print('=================================================');
  
  // Test 2: Fetch a specific past date
  print('');
  print('TEST 2: Fetching reflection from a specific date...');
  print('-------------------------------------------------');
  try {
    // Test with a date from last month
    final pastDate = DateTime.now().subtract(const Duration(days: 30));
    print('Fetching reflection for: ${pastDate.toLocal().toString().split(' ')[0]}');
    print('');
    
    final pastReflection = await scraper.fetchReflectionByDate(pastDate);
    
    if (pastReflection != null) {
      print('✓ SUCCESS: Past reflection fetched');
      print('');
      print('Date: ${pastReflection.date}');
      print('Title: ${pastReflection.title}');
      print('Author: ${pastReflection.author ?? "N/A"}');
      print('Has Bible Verse: ${pastReflection.hasBibleVerse}');
      print('Content Length: ${pastReflection.content.length} characters');
      print('Prayer Length: ${pastReflection.prayer.length} characters');
    } else {
      print('✗ FAILED: No reflection returned for past date');
    }
  } catch (e) {
    print('✗ ERROR: $e');
  }
  
  print('');
  print('=================================================');
  
  // Test 3: Fetch recent reflections (last 7 days)
  print('');
  print('TEST 3: Fetching recent reflections (last 7 days)...');
  print('-------------------------------------------------');
  try {
    final recentReflections = await scraper.fetchRecentReflections();
    
    if (recentReflections.isNotEmpty) {
      print('✓ SUCCESS: Fetched ${recentReflections.length} recent reflections');
      print('');
      
      for (var i = 0; i < recentReflections.length; i++) {
        final reflection = recentReflections[i];
        print('Reflection ${i + 1}:');
        print('  Date: ${reflection.date.toLocal().toString().split(' ')[0]}');
        print('  Title: ${reflection.title}');
        print('  Has Bible Verse: ${reflection.hasBibleVerse}');
        print('  Content Length: ${reflection.content.length} chars');
        print('');
      }
    } else {
      print('✗ FAILED: No recent reflections returned');
    }
  } catch (e) {
    print('✗ ERROR: $e');
  }
  
  print('');
  print('=================================================');
  
  // Test 4: Test date range
  print('');
  print('TEST 4: Testing date handling...');
  print('-------------------------------------------------');
  try {
    final testDates = [
      DateTime(2024, 1, 1),   // New Year's Day
      DateTime(2024, 12, 25), // Christmas
      DateTime(2024, 3, 31),  // Easter (approximate)
      DateTime.now(),         // Today
    ];
    
    print('Testing ${testDates.length} different dates...');
    print('');
    
    int successCount = 0;
    for (final date in testDates) {
      try {
        final reflection = await scraper.fetchReflectionByDate(date);
        if (reflection != null) {
          successCount++;
          print('✓ ${date.toLocal().toString().split(' ')[0]}: ${reflection.title}');
        } else {
          print('✗ ${date.toLocal().toString().split(' ')[0]}: No reflection');
        }
      } catch (e) {
        print('✗ ${date.toLocal().toString().split(' ')[0]}: Error - $e');
      }
    }
    
    print('');
    print('Successfully fetched: $successCount/${testDates.length} dates');
  } catch (e) {
    print('✗ ERROR: $e');
  }
  
  print('');
  print('=================================================');
  print('All Tests Complete!');
  print('=================================================');
}
