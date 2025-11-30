import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import '../../domain/entities/user.dart';
import '../../core/constants/firebase_collections.dart';
import '../../models/user_model.dart';

class UserRepository {
  final FirebaseFirestore _firestore;
  final auth.FirebaseAuth _auth;

  UserRepository({
    FirebaseFirestore? firestore,
    auth.FirebaseAuth? firebaseAuth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = firebaseAuth ?? auth.FirebaseAuth.instance;

  /// Create a new user profile in Firestore
  Future<void> createUserProfile({
    required String uid,
    required String displayName,
    required String email,
    bool isAnonymous = false,
    DateTime? sobrietyStartDate,
  }) async {
    try {
      final user = User(
        uid: uid,
        displayName: displayName,
        email: email,
        isAnonymous: isAnonymous,
        sobrietyStartDate: sobrietyStartDate,
        createdAt: DateTime.now(),
        preferences: const UserPreferences(),
        stats: const UserStats(),
      );

      await _firestore
          .collection(FirebaseCollections.users)
          .doc(uid)
          .set(UserModel(user).toJson());
    } catch (e) {
      throw Exception('Failed to create user profile: $e');
    }
  }

  /// Get user profile from Firestore
  Future<User?> getUserProfile(String uid) async {
    try {
      final doc = await _firestore
          .collection(FirebaseCollections.users)
          .doc(uid)
          .get();

      if (!doc.exists) {
        return null;
      }

      return UserModel.fromJson(doc.data()!).user;
    } catch (e) {
      throw Exception('Failed to get user profile: $e');
    }
  }

  /// Update user profile
  Future<void> updateUserProfile({
    required String uid,
    String? displayName,
    DateTime? sobrietyStartDate,
    String? sponsorId,
    bool? isVolunteer,
    bool? isAvailable,
    UserPreferences? preferences,
  }) async {
    try {
      final updates = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (displayName != null) updates['displayName'] = displayName;
      if (sobrietyStartDate != null) {
        updates['sobrietyStartDate'] = Timestamp.fromDate(sobrietyStartDate);
      }
      if (sponsorId != null) updates['sponsorId'] = sponsorId;
      if (isVolunteer != null) updates['isVolunteer'] = isVolunteer;
      if (isAvailable != null) updates['isAvailable'] = isAvailable;
      if (preferences != null) {
        updates['preferences'] = {
          'enablePanicAlerts': preferences.enablePanicAlerts,
          'enableDailyReminders': preferences.enableDailyReminders,
          'enableCelebrations': preferences.enableCelebrations,
          'privacyLevel': preferences.privacyLevel,
        };
      }

      await _firestore
          .collection(FirebaseCollections.users)
          .doc(uid)
          .update(updates);
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }

  /// Update user stats
  Future<void> updateUserStats({
    required String uid,
    int? totalDaysClean,
    int? longestStreak,
    int? currentStreak,
    int? totalRelapses,
    int? totalReflections,
    int? totalPrayers,
  }) async {
    try {
      final updates = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (totalDaysClean != null) {
        updates['stats.totalDaysClean'] = totalDaysClean;
      }
      if (longestStreak != null) {
        updates['stats.longestStreak'] = longestStreak;
      }
      if (currentStreak != null) {
        updates['stats.currentStreak'] = currentStreak;
      }
      if (totalRelapses != null) {
        updates['stats.totalRelapses'] = totalRelapses;
      }
      if (totalReflections != null) {
        updates['stats.totalReflections'] = totalReflections;
      }
      if (totalPrayers != null) {
        updates['stats.totalPrayers'] = totalPrayers;
      }

      await _firestore
          .collection(FirebaseCollections.users)
          .doc(uid)
          .update(updates);
    } catch (e) {
      throw Exception('Failed to update user stats: $e');
    }
  }

  /// Stream user profile changes
  Stream<User?> watchUserProfile(String uid) {
    return _firestore
        .collection(FirebaseCollections.users)
        .doc(uid)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;
      return UserModel.fromJson(doc.data()!).user;
    });
  }

  /// Get current authenticated user
  User? getCurrentAuthUser() {
    final authUser = _auth.currentUser;
    if (authUser == null) return null;

    return User(
      uid: authUser.uid,
      displayName: authUser.displayName ?? 'Anonymous',
      email: authUser.email ?? '',
      isAnonymous: authUser.isAnonymous,
    );
  }

  /// Delete user profile
  Future<void> deleteUserProfile(String uid) async {
    try {
      await _firestore.collection(FirebaseCollections.users).doc(uid).delete();
    } catch (e) {
      throw Exception('Failed to delete user profile: $e');
    }
  }

  /// Get all users who are volunteering as sponsors
  /// Filters: isVolunteer = true, isAvailable = true, daysClean >= 90
  Future<List<User>> getAvailableSponsors() async {
    try {
      final snapshot = await _firestore
          .collection(FirebaseCollections.users)
          .where('isVolunteer', isEqualTo: true)
          .where('isAvailable', isEqualTo: true)
          .orderBy('sobrietyStartDate', descending: false)
          .get();

      // Convert to User entities
      final users = snapshot.docs
          .map((doc) => UserModel.fromJson(doc.data()).user)
          .toList();

      // Filter by days clean >= 90
      final availableSponsors = users.where((user) {
        return user.daysClean >= 90;
      }).toList();

      return availableSponsors;
    } catch (e) {
      throw Exception('Failed to get available sponsors: $e');
    }
  }

  /// Stream available sponsors
  Stream<List<User>> watchAvailableSponsors() {
    return _firestore
        .collection(FirebaseCollections.users)
        .where('isVolunteer', isEqualTo: true)
        .where('isAvailable', isEqualTo: true)
        .orderBy('sobrietyStartDate', descending: false)
        .snapshots()
        .map((snapshot) {
      final users = snapshot.docs
          .map((doc) => UserModel.fromJson(doc.data()).user)
          .toList();

      // Filter by days clean >= 90
      return users.where((user) => user.daysClean >= 90).toList();
    });
  }
}
