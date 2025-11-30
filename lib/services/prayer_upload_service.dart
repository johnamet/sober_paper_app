import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart' show rootBundle;

/// Service to upload prayers from JSON asset to Firestore
/// This should be run once to populate the Firestore database
class PrayerUploadService {
  final FirebaseFirestore _firestore;

  PrayerUploadService(this._firestore);

  /// Uploads prayers from the local JSON file to Firestore
  /// Returns the number of prayers uploaded
  Future<int> uploadPrayersFromJson(String jsonPath) async {
    try {
      print('📖 Reading prayers from $jsonPath...');
      
      // Read the JSON file
      final jsonString = await rootBundle.loadString(jsonPath);
      final List<dynamic> prayersJson = json.decode(jsonString);

      print('✅ Found ${prayersJson.length} prayers');
      print('📤 Uploading to Firestore...');

      // Get reference to prayers collection
      final prayersCollection = _firestore.collection('prayers');

      // Upload each prayer
      int uploadedCount = 0;
      for (var prayerData in prayersJson) {
        try {
          // Use the id from JSON as document ID
          final docId = prayerData['id'] as String;
          
          // Add createdAt timestamp
          final prayerWithTimestamp = Map<String, dynamic>.from(prayerData);
          prayerWithTimestamp['createdAt'] = FieldValue.serverTimestamp();

          // Upload to Firestore
          await prayersCollection.doc(docId).set(prayerWithTimestamp);
          
          uploadedCount++;
          
          // Log progress every 10 prayers
          if (uploadedCount % 10 == 0) {
            print('   Uploaded $uploadedCount/${prayersJson.length} prayers...');
          }
        } catch (e) {
          print('⚠️  Error uploading prayer ${prayerData['id']}: $e');
        }
      }

      print('✅ Successfully uploaded $uploadedCount prayers to Firestore!');
      return uploadedCount;
    } catch (e) {
      print('❌ Error uploading prayers: $e');
      rethrow;
    }
  }

  /// Checks if prayers are already in Firestore
  Future<bool> arePrayersAlreadyUploaded() async {
    try {
      final snapshot = await _firestore.collection('prayers').limit(1).get();
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking prayers: $e');
      return false;
    }
  }

  /// Clears all prayers from Firestore (use with caution!)
  Future<void> clearAllPrayers() async {
    try {
      print('🗑️  Clearing all prayers from Firestore...');
      
      final snapshot = await _firestore.collection('prayers').get();
      final batch = _firestore.batch();

      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      print('✅ Cleared ${snapshot.docs.length} prayers');
    } catch (e) {
      print('❌ Error clearing prayers: $e');
      rethrow;
    }
  }

  /// Gets prayer statistics from Firestore
  Future<Map<String, dynamic>> getPrayerStats() async {
    try {
      final snapshot = await _firestore.collection('prayers').get();
      
      final categoryCount = <String, int>{};
      for (var doc in snapshot.docs) {
        final category = doc.data()['category'] as String?;
        if (category != null) {
          categoryCount[category] = (categoryCount[category] ?? 0) + 1;
        }
      }

      return {
        'total': snapshot.docs.length,
        'byCategory': categoryCount,
      };
    } catch (e) {
      print('Error getting prayer stats: $e');
      return {'total': 0, 'byCategory': {}};
    }
  }
}
