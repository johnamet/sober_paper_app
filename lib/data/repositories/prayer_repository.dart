import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/prayer.dart';

/// Repository for managing Catholic prayers from Firestore
/// Firestore provides built-in offline persistence and caching
class PrayerRepository {
  final FirebaseFirestore _firestore;

  PrayerRepository(this._firestore);

  /// Get daily prayers from Firestore
  Future<List<Prayer>> getDailyPrayers() async {
    try {
      final allPrayers = await getAllPrayers();
      return _selectDailyPrayers(allPrayers);
    } catch (e) {
      print('Error fetching daily prayers: $e');
      return _getFallbackPrayers();
    }
  }

  /// Get all prayers from Firestore
  Future<List<Prayer>> getAllPrayers() async {
    try {
      final snapshot = await _firestore
          .collection('prayers')
          .orderBy('order')
          .get();
      
      return snapshot.docs.map((doc) => _prayerFromFirestore(doc)).toList();
    } catch (e) {
      print('Error fetching all prayers from Firestore: $e');
      return _getFallbackPrayers();
    }
  }

  /// Get prayers for emergency/panic situations from Firestore
  Future<List<Prayer>> getEmergencyPrayers() async {
    try {
      final snapshot = await _firestore
          .collection('prayers')
          .where('category', isEqualTo: 'emergency')
          .orderBy('order')
          .get();
      
      return snapshot.docs.map((doc) => _prayerFromFirestore(doc)).toList();
    } catch (e) {
      print('Error fetching emergency prayers: $e');
      // Return fallback emergency prayers
      return [
        const Prayer(
          id: 'emergency_1',
          title: 'Jesus Prayer',
          category: PrayerCategory.emergency,
          content: 'Lord Jesus Christ, Son of God, have mercy on me, a sinner.',
          order: 1,
        ),
        const Prayer(
          id: 'emergency_2',
          title: 'Act of Contrition',
          category: PrayerCategory.emergency,
          content: 'My God, I am sorry for my sins with all my heart. '
                   'In choosing to do wrong and failing to do good, '
                   'I have sinned against you whom I should love above all things. '
                   'I firmly intend, with your help, to do penance, to sin no more, '
                   'and to avoid whatever leads me to sin. '
                   'Our Savior Jesus Christ suffered and died for us. '
                   'In his name, my God, have mercy.',
          order: 2,
        ),
      ];
    }
  }

  /// Get prayers by category from Firestore
  Future<List<Prayer>> getPrayersByCategory(PrayerCategory category) async {
    try {
      final snapshot = await _firestore
          .collection('prayers')
          .where('category', isEqualTo: category.name)
          .orderBy('order')
          .get();
      
      return snapshot.docs.map((doc) => _prayerFromFirestore(doc)).toList();
    } catch (e) {
      print('Error fetching prayers by category: $e');
      return [];
    }
  }

  /// Convert Firestore document to Prayer entity
  Prayer _prayerFromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return Prayer(
      id: data['id'] as String,
      title: data['title'] as String,
      category: _parsePrayerCategory(data['category'] as String),
      content: data['content'] as String,
      latinVersion: data['latinVersion'] as String?,
      notes: data['notes'] as String?,
      order: data['order'] as int,
    );
  }

  /// Select prayers suitable for daily reflection
  List<Prayer> _selectDailyPrayers(List<Prayer> allPrayers) {
    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
    
    // Rotate prayers based on day of year to provide variety
    final selectedPrayers = <Prayer>[];
    
    // Morning prayers (rotate through available morning prayers)
    final morningPrayers = allPrayers
        .where((p) => p.category == PrayerCategory.morning)
        .toList();
    if (morningPrayers.isNotEmpty) {
      selectedPrayers.add(morningPrayers[dayOfYear % morningPrayers.length]);
    }
    
    // Add Acts of Faith, Hope, Love (good for midday reflection)
    final virtuesPrayers = allPrayers
        .where((p) => p.title.contains('Act of'))
        .toList();
    if (virtuesPrayers.isNotEmpty) {
      final index = (dayOfYear ~/ 3) % virtuesPrayers.length;
      selectedPrayers.add(virtuesPrayers[index]);
    }
    
    // Add Marian prayer
    final marianPrayers = allPrayers
        .where((p) => 
          p.title.contains('Mary') || 
          p.title.contains('Hail') ||
          p.title.contains('Memorare'))
        .toList();
    if (marianPrayers.isNotEmpty) {
      final index = (dayOfYear ~/ 7) % marianPrayers.length;
      selectedPrayers.add(marianPrayers[index]);
    }
    
    // If we need more, add other prayers
    if (selectedPrayers.length < 3) {
      final remaining = allPrayers
          .where((p) => !selectedPrayers.contains(p))
          .take(3 - selectedPrayers.length);
      selectedPrayers.addAll(remaining);
    }
    
    return selectedPrayers;
  }

  /// Parse prayer category from string (Firestore format)
  PrayerCategory _parsePrayerCategory(String categoryStr) {
    switch (categoryStr.toLowerCase()) {
      case 'morning':
        return PrayerCategory.morning;
      case 'evening':
        return PrayerCategory.evening;
      case 'rosary':
        return PrayerCategory.rosary;
      case 'emergency':
        return PrayerCategory.emergency;
      case 'liturgy':
        return PrayerCategory.liturgy;
      default:
        return PrayerCategory.morning;
    }
  }

  /// Fallback prayers if all else fails
  List<Prayer> _getFallbackPrayers() {
    return [
      const Prayer(
        id: 'fallback_1',
        title: 'Morning Offering',
        category: PrayerCategory.morning,
        content: 'O Jesus, through the Immaculate Heart of Mary, '
                 'I offer you my prayers, works, joys and sufferings of this day '
                 'for all the intentions of your Sacred Heart, '
                 'in union with the Holy Sacrifice of the Mass throughout the world, '
                 'for the salvation of souls, the reparation for sins, '
                 'the reunion of all Christians, '
                 'and in particular for the intentions of the Holy Father this month. Amen.',
        order: 1,
      ),
      const Prayer(
        id: 'fallback_2',
        title: 'Act of Contrition',
        category: PrayerCategory.emergency,
        content: 'My God, I am sorry for my sins with all my heart. '
                 'In choosing to do wrong and failing to do good, '
                 'I have sinned against you whom I should love above all things. '
                 'I firmly intend, with your help, to do penance, to sin no more, '
                 'and to avoid whatever leads me to sin. '
                 'Our Savior Jesus Christ suffered and died for us. '
                 'In his name, my God, have mercy. Amen.',
        order: 2,
      ),
      const Prayer(
        id: 'fallback_3',
        title: 'Hail Mary',
        category: PrayerCategory.rosary,
        content: 'Hail, Mary, full of grace, the Lord is with thee. '
                 'Blessed art thou among women and blessed is the fruit of thy womb, Jesus. '
                 'Holy Mary, Mother of God, pray for us sinners, '
                 'now and at the hour of our death. Amen.',
        order: 3,
      ),
    ];
  }

  /// Clear Firestore cache (forces fresh data from server)
  Future<void> clearCache() async {
    try {
      // Firestore handles its own cache, but we can clear settings if needed
      // For now, this is a no-op as Firestore manages offline persistence
      await _firestore.clearPersistence();
    } catch (e) {
      print('Error clearing Firestore cache: $e');
    }
  }
}
