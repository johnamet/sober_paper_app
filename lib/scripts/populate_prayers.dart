import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';

/// Script to populate Firestore with Catholic prayers from JSON file
/// 
/// Run this script once to upload all prayers to Firestore:
/// ```
/// flutter run lib/scripts/populate_prayers.dart
/// ```
Future<void> main() async {
  print('🙏 Starting Catholic Prayers Upload to Firestore...\n');

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final firestore = FirebaseFirestore.instance;

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

  // Upload prayers to Firestore
  int successCount = 0;
  int errorCount = 0;

  final batch = firestore.batch();
  final prayersCollection = firestore.collection('prayers');

  for (var prayerData in prayersJson) {
    try {
      final prayerId = prayerData['id'] as String;
      final docRef = prayersCollection.doc(prayerId);

      // Prepare prayer data
      final Map<String, dynamic> firestoreData = {
        'id': prayerData['id'],
        'title': prayerData['title'],
        'category': prayerData['category'],
        'content': prayerData['content'],
        'latinVersion': prayerData['latinVersion'],
        'notes': prayerData['notes'],
        'order': prayerData['order'],
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      batch.set(docRef, firestoreData);
      successCount++;

      print('  ✓ Queued: ${prayerData['title']} (${prayerData['category']})');
    } catch (e) {
      errorCount++;
      print('  ✗ Error with prayer ${prayerData['id']}: $e');
    }
  }

  // Commit the batch
  print('\n📤 Uploading batch to Firestore...');
  try {
    await batch.commit();
    print('✅ Successfully uploaded $successCount prayers!');
  } catch (e) {
    print('❌ Error committing batch: $e');
    return;
  }

  if (errorCount > 0) {
    print('⚠️  $errorCount prayers had errors');
  }

  print('\n🎉 Upload complete!');
  print('📊 Summary:');
  print('   - Total prayers: ${prayersJson.length}');
  print('   - Successful: $successCount');
  print('   - Errors: $errorCount');
  
  // Create indexes document with statistics
  try {
    await firestore.collection('app_metadata').doc('prayers_stats').set({
      'totalPrayers': successCount,
      'categories': {
        'morning': prayersJson.where((p) => p['category'] == 'morning').length,
        'evening': prayersJson.where((p) => p['category'] == 'evening').length,
        'rosary': prayersJson.where((p) => p['category'] == 'rosary').length,
        'emergency': prayersJson.where((p) => p['category'] == 'emergency').length,
        'liturgy': prayersJson.where((p) => p['category'] == 'liturgy').length,
      },
      'lastUpdated': FieldValue.serverTimestamp(),
    });
    print('✅ Created prayer statistics document');
  } catch (e) {
    print('⚠️  Could not create statistics: $e');
  }

  print('\n✨ You can now use the prayers in your app!');
  exit(0);
}
