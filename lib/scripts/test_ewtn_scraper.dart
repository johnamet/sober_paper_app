import '../services/ewtn_scraper_service.dart';

void main() async {
  print('═══════════════════════════════════════════════════════════');
  print('Testing EWTN Scraper Service');
  print('═══════════════════════════════════════════════════════════');
  print('');
  
  final scraper = EWTNScraperService();
  final testDate = DateTime(2025, 11, 28);
  
  print('🔍 Testing with date: November 28, 2025');
  print('');
  
  try {
    print('📡 Fetching readings...');
    final readings = await scraper.fetchReadingsForDate(testDate);
    
    if (readings == null) {
      print('❌ No readings returned (null)');
      return;
    }
    
    print('✅ Successfully fetched readings!');
    print('');
    print('═══════════════════════════════════════════════════════════');
    print('READINGS DATA:');
    print('═══════════════════════════════════════════════════════════');
    print('');
    print('📅 Date: ${readings.date}');
    print('🎉 Feast: ${readings.feast ?? "No feast/memorial"}');
    print('🎬 Mass Video: ${readings.massVideoUrl ?? "Not fetched"}');
    print('📖 Number of Readings: ${readings.readings.length}');
    print('');
    
    if (readings.readings.isEmpty) {
      print('⚠️  WARNING: No readings were extracted!');
    } else {
      print('═══════════════════════════════════════════════════════════');
      print('READING DETAILS:');
      print('═══════════════════════════════════════════════════════════');
      print('');
      
      for (var i = 0; i < readings.readings.length; i++) {
        final reading = readings.readings[i];
        print('─────────────────────────────────────────────────────────');
        print('Reading ${i + 1}:');
        print('─────────────────────────────────────────────────────────');
        print('Type: ${reading.type}');
        print('Reference: ${reading.reference}');
        print('Text Length: ${reading.text.length} characters');
        print('');
        print('First 200 characters of text:');
        print(reading.text.length > 200 
          ? '${reading.text.substring(0, 200)}...' 
          : reading.text);
        print('');
      }
    }
    
    print('═══════════════════════════════════════════════════════════');
    print('CACHE INFO:');
    print('═══════════════════════════════════════════════════════════');
    print('Fetch Date: ${readings.fetchDate}');
    print('Is Fresh: ${readings.isFresh}');
    print('');
    
    print('✅ Test completed successfully!');
    
  } catch (e, stackTrace) {
    print('');
    print('═══════════════════════════════════════════════════════════');
    print('❌ ERROR OCCURRED:');
    print('═══════════════════════════════════════════════════════════');
    print('Error: $e');
    print('');
    print('Stack Trace:');
    print(stackTrace);
  }
}
