import '../services/catholic_reflection_scraper_service.dart';

void main() async {
  print('=================================================');
  print('Testing Direct URL Scraping');
  print('=================================================');
  print('');
  
  final scraper = CatholicReflectionScraperService();
  
  // Test with a known URL from the example
  final testUrl = 'https://catholic-daily-reflections.com/2025/11/28/jesus-i-trust-in-you-3/';
  
  print('Testing direct URL fetch: $testUrl');
  print('-------------------------------------------------');
  
  try {
    final reflection = await scraper.fetchReflectionByUrl(testUrl, null);
    
    if (reflection != null) {
      print('✓ SUCCESS: Reflection fetched');
      print('');
      print('Title: ${reflection.title}');
      print('Date: ${reflection.date}');
      print('Author: ${reflection.author ?? "N/A"}');
      print('');
      
      if (reflection.hasBibleVerse) {
        print('Bible Verse Reference: ${reflection.verseReference}');
        print('Bible Verse: ${reflection.bibleVerse}');
      } else {
        print('Bible Verse: Not available');
      }
      print('');
      
      print('Content (first 300 chars):');
      print(reflection.content.substring(
        0,
        reflection.content.length > 300 ? 300 : reflection.content.length
      ));
      print('...');
      print('');
      
      print('Prayer (first 200 chars):');
      print(reflection.prayer.substring(
        0,
        reflection.prayer.length > 200 ? 200 : reflection.prayer.length
      ));
      print('...');
      print('');
      
      print('Image URL: ${reflection.imageUrl ?? "N/A"}');
    } else {
      print('✗ FAILED: No reflection returned');
    }
  } catch (e) {
    print('✗ ERROR: $e');
  }
  
  print('');
  print('=================================================');
  print('Test Complete!');
  print('=================================================');
}
