import 'dart:convert';
import 'dart:io';

/// Simple standalone script to upload prayers to Firestore via REST API
/// Run with: dart run lib/scripts/upload_prayers_rest.dart
Future<void> main() async {
  print('🙏 Starting Catholic Prayers Upload...\n');

  // Read the JSON file
  final file = File('catholic_prayer.json');
  if (!await file.exists()) {
    print('❌ Error: catholic_prayer.json file not found!');
    print('   Make sure the file exists in the project root directory.');
    return;
  }

  print('📖 Reading prayers from catholic_prayer.json...');
  final jsonString = await file.readAsString();
  final List<dynamic> prayersJson = json.decode(jsonString);

  print('✅ Found ${prayersJson.length} prayers to upload\n');
  
  print('\n📊 Prayer Statistics:');
  print('   - Total prayers: ${prayersJson.length}');
  
  // Count by category
  final categories = <String, int>{};
  for (var prayer in prayersJson) {
    final category = prayer['category'] as String;
    categories[category] = (categories[category] ?? 0) + 1;
  }
  
  print('   - By category:');
  categories.forEach((cat, count) {
    print('     • $cat: $count prayers');
  });
  
  print('\n✨ Prayer data is ready!');
  print('\n📝 Next steps:');
  print('   1. Open Firebase Console: https://console.firebase.google.com');
  print('   2. Navigate to your project > Firestore Database');
  print('   3. Import the catholic_prayer.json file');
  print('   OR');
  print('   4. Use the Firebase CLI: firebase firestore:import prayers catholic_prayer.json');
  print('\n   OR use the app to upload prayers on first run.');
  
  exit(0);
}
