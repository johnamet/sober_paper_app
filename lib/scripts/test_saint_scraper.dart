import '../services/saint_of_the_day_scraper_service.dart';
import 'package:intl/intl.dart';

void main() async {
  print('=================================================');
  print('Testing Saint of the Day Scraper');
  print('From: Franciscan Media');
  print('=================================================');
  print('');
  
  final scraper = SaintOfTheDayScraperService();
  
  // TEST 1: Fetch today's saint
  print('TEST 1: Fetching today\'s saint');
  print('-------------------------------------------------');
  try {
    final todaySaint = await scraper.fetchTodaySaint();
    
    if (todaySaint != null) {
      print('✓ SUCCESS: Today\'s saint fetched');
      print('');
      _printSaintDetails(todaySaint);
    } else {
      print('✗ FAILED: No saint returned for today');
    }
  } catch (e) {
    print('✗ ERROR: $e');
  }
  
  print('');
  print('=================================================');
  print('');
  
  // TEST 2: Fetch upcoming saints
  print('TEST 2: Fetching upcoming saints (next 7 days)');
  print('-------------------------------------------------');
  try {
    final upcomingSaints = await scraper.fetchUpcomingSaints(daysAhead: 7);
    
    if (upcomingSaints.isNotEmpty) {
      print('✓ SUCCESS: Found ${upcomingSaints.length} upcoming saints');
      print('');
      
      for (var saint in upcomingSaints) {
        final dateStr = DateFormat('MMM d, yyyy').format(saint.date);
        print('• $dateStr: ${saint.name}');
        if (saint.hasFeastType) {
          print('  Type: ${saint.feastType}');
        }
        print('  Image: ${saint.imageUrl.isNotEmpty ? "✓" : "✗"}');
        print('  Summary: ${saint.hasSummary ? "✓" : "✗"}');
        print('');
      }
    } else {
      print('✗ FAILED: No upcoming saints found');
    }
  } catch (e) {
    print('✗ ERROR: $e');
  }
  
  print('');
  print('=================================================');
  print('');
  
  // TEST 3: Fetch saint by specific date (tomorrow)
  print('TEST 3: Fetching saint for tomorrow');
  print('-------------------------------------------------');
  try {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final tomorrowSaint = await scraper.fetchSaintByDate(tomorrow);
    
    if (tomorrowSaint != null) {
      print('✓ SUCCESS: Tomorrow\'s saint fetched');
      print('');
      _printSaintDetails(tomorrowSaint);
    } else {
      print('✗ FAILED: No saint found for tomorrow');
    }
  } catch (e) {
    print('✗ ERROR: $e');
  }
  
  print('');
  print('=================================================');
  print('');
  
  // TEST 4: Fetch full details for today's saint (with story and patron saint info)
  print('TEST 4: Fetching full details with story and patron saint info');
  print('-------------------------------------------------');
  try {
    // Get today's saint
    final detailedSaint = await scraper.fetchTodaySaint();
    
    if (detailedSaint != null) {
      // The fetchTodaySaint already calls _fetchFullReflection internally
      print('✓ SUCCESS: Full details fetched');
      print('');
      _printDetailedSaintInfo(detailedSaint);
    } else {
      print('✗ FAILED: Could not fetch detailed saint info');
    }
  } catch (e) {
    print('✗ ERROR: $e');
  }
  
  print('');
  print('=================================================');
  print('All Tests Complete!');
  print('=================================================');
  
  scraper.dispose();
}

void _printSaintDetails(dynamic saint) {
  print('Name: ${saint.name}');
  print('Date: ${DateFormat('EEEE, MMMM d, yyyy').format(saint.date)}');
  
  if (saint.hasFeastType) {
    print('Feast Type: ${saint.feastType}');
  }
  
  print('Image URL: ${saint.imageUrl.isNotEmpty ? saint.imageUrl : "N/A"}');
  print('Reflection URL: ${saint.reflectionUrl}');
  
  if (saint.hasSummary) {
    print('');
    print('Summary:');
    print(saint.summary!.substring(0, saint.summary!.length > 200 ? 200 : saint.summary!.length));
    if (saint.summary!.length > 200) print('...');
  }
  
  if (saint.hasFullReflection) {
    print('');
    print('Full Reflection (first 300 chars):');
    print(saint.fullReflection!.substring(0, saint.fullReflection!.length > 300 ? 300 : saint.fullReflection!.length));
    if (saint.fullReflection!.length > 300) print('...');
  }
  
  if (saint.hasBibleVerse) {
    print('');
    if (saint.hasVerseReference) {
      print('Bible Verse (${saint.verseReference}):');
    } else {
      print('Bible Verse:');
    }
    print('"${saint.bibleVerse}"');
  }
  
  if (saint.hasPrayer) {
    print('');
    print('Prayer (first 200 chars):');
    print(saint.prayer!.substring(0, saint.prayer!.length > 200 ? 200 : saint.prayer!.length));
    if (saint.prayer!.length > 200) print('...');
  }
}

void _printDetailedSaintInfo(dynamic saint) {
  print('Name: ${saint.name}');
  print('Date: ${DateFormat('EEEE, MMMM d, yyyy').format(saint.date)}');
  
  if (saint.hasFeastType) {
    print('Feast Type: ${saint.feastType}');
  }
  
  print('');
  print('═══════════════════════════════════════════════');
  
  if (saint.hasFullReflection) {
    // Split the full reflection to show story and reflection separately
    final sections = saint.fullReflection!.split('\n\n---\n\n');
    
    for (var section in sections) {
      if (section.startsWith('SAINT\'S STORY')) {
        print('');
        print('📖 SAINT\'S STORY');
        print('═══════════════════════════════════════════════');
        final story = section.replaceFirst('SAINT\'S STORY\n\n', '');
        print(story);
      } else if (section.startsWith('REFLECTION')) {
        print('');
        print('💭 REFLECTION');
        print('═══════════════════════════════════════════════');
        final reflection = section.replaceFirst('REFLECTION\n\n', '');
        print(reflection);
      }
    }
  }
  
  if (saint.hasBibleVerse) {
    print('');
    print('📜 BIBLE VERSE');
    print('═══════════════════════════════════════════════');
    if (saint.hasVerseReference) {
      print('Reference: ${saint.verseReference}');
    }
    print('"${saint.bibleVerse}"');
  }
  
  if (saint.hasPrayer) {
    print('');
    print('🙏 PRAYER & PATRON SAINT');
    print('═══════════════════════════════════════════════');
    
    // Check if prayer contains patron saint info
    final prayerParts = saint.prayer!.split('\n\n---\n\n');
    
    for (var part in prayerParts) {
      if (part.startsWith('PATRON SAINT OF')) {
        print('⭐ PATRON SAINT OF:');
        final patronInfo = part.replaceFirst('PATRON SAINT OF\n\n', '');
        print(patronInfo);
        print('');
      } else {
        print('Prayer:');
        print(part);
      }
    }
  }
  
  print('');
  print('═══════════════════════════════════════════════');
}
