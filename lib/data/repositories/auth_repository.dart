import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'dart:math';
import '../../domain/entities/user.dart';
import '../../models/user_model.dart';

/// Repository for authentication operations
class AuthRepository {
  final auth.FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthRepository({
    auth.FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  })  : _auth = firebaseAuth ?? auth.FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  /// Register new user with email and password
  Future<User> registerWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      // Create Firebase Auth account
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = credential.user!.uid;

      // Create user document in Firestore
      final user = User(
        uid: uid,
        displayName: displayName,
        email: email,
        isAnonymous: false,
        createdAt: DateTime.now(),
        preferences: const UserPreferences(),
        stats: const UserStats(),
      );

      await _firestore
          .collection('users')
          .doc(uid)
          .set(UserModel(user).toJson());

      return user;
    } on auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Failed to register: $e');
    }
  }

  /// Login with email and password
  Future<User> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      // Sign in with Firebase Auth
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = credential.user!.uid;

      // Fetch user document from Firestore
      final doc = await _firestore.collection('users').doc(uid).get();

      if (!doc.exists) {
        throw Exception('User profile not found');
      }

      final user = UserModel.fromJson(doc.data()!).user;

      // Update last active timestamp
      await _firestore.collection('users').doc(uid).update({
        'lastActive': Timestamp.fromDate(DateTime.now()),
      });

      // Return entity with updated lastActive
      return user.copyWith(lastActive: DateTime.now());
    } on auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Failed to login: $e');
    }
  }

  /// Login anonymously
  Future<User> loginAnonymously() async {
    try {
      // Create anonymous account
      final credential = await _auth.signInAnonymously();
      final uid = credential.user!.uid;

      // Generate random display name
      final random = Random();
      final randomDigits = random.nextInt(10000).toString().padLeft(4, '0');
      final displayName = 'Anonymous_$randomDigits';

      // Create user document
      final user = User(
        uid: uid,
        displayName: displayName,
        isAnonymous: true,
        createdAt: DateTime.now(),
        preferences: const UserPreferences(),
        stats: const UserStats(),
      );

      await _firestore
          .collection('users')
          .doc(uid)
          .set(UserModel(user).toJson());

      return user;
    } on auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Failed to login anonymously: $e');
    }
  }

  /// Logout current user
  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Failed to logout: $e');
    }
  }

  /// Get current logged in user
  Future<User?> getCurrentUser() async {
    try {
      final authUser = _auth.currentUser;
      if (authUser == null) return null;

      final doc = await _firestore.collection('users').doc(authUser.uid).get();

      if (!doc.exists) return null;

      return UserModel.fromJson(doc.data()!).user;
    } catch (e) {
      throw Exception('Failed to get current user: $e');
    }
  }

  /// Stream of auth state changes
  Stream<User?> authStateChanges() {
    return _auth.authStateChanges().asyncMap((authUser) async {
      if (authUser == null) return null;

      try {
        final doc = await _firestore.collection('users').doc(authUser.uid).get();

        if (!doc.exists) return null;

        return UserModel.fromJson(doc.data()!).user;
      } catch (e) {
        return null;
      }
    });
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Failed to send password reset email: $e');
    }
  }

  /// Upgrade anonymous account to permanent
  Future<User> upgradeAnonymousAccount({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final authUser = _auth.currentUser;
      if (authUser == null || !authUser.isAnonymous) {
        throw Exception('No anonymous user to upgrade');
      }

      // Create credential and link
      final credential = auth.EmailAuthProvider.credential(
        email: email,
        password: password,
      );

      await authUser.linkWithCredential(credential);

      // Update Firestore document
      await _firestore.collection('users').doc(authUser.uid).update({
        'email': email,
        'displayName': displayName,
        'isAnonymous': false,
        'lastActive': Timestamp.fromDate(DateTime.now()),
      });

      // Fetch updated user
      final doc = await _firestore.collection('users').doc(authUser.uid).get();
      return UserModel.fromJson(doc.data()!).user;
    } on auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Failed to upgrade account: $e');
    }
  }

  /// Handle Firebase Auth exceptions
  Exception _handleAuthException(auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return Exception('This email is already registered');
      case 'invalid-email':
        return Exception('Invalid email address');
      case 'operation-not-allowed':
        return Exception('Operation not allowed');
      case 'weak-password':
        return Exception('Password is too weak');
      case 'user-disabled':
        return Exception('This account has been disabled');
      case 'user-not-found':
        return Exception('No account found with this email');
      case 'wrong-password':
        return Exception('Incorrect password');
      default:
        return Exception('Authentication error: ${e.message}');
    }
  }
}
