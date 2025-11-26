import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../firebase_options.dart';

/// Service for initializing and configuring Firebase
class FirebaseService {
  static FirebaseService? _instance;
  static FirebaseService get instance => _instance ??= FirebaseService._();

  FirebaseService._();

  bool _initialized = false;
  bool get isInitialized => _initialized;

  /// Initialize Firebase with configuration
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // Enable Firestore offline persistence
      await _configureFirestore();

      // Configure Auth
      await _configureAuth();

      _initialized = true;
    } catch (e) {
      throw Exception('Failed to initialize Firebase: $e');
    }
  }

  /// Configure Firestore settings
  Future<void> _configureFirestore() async {
    try {
      final firestore = FirebaseFirestore.instance;

      // Enable offline persistence
      firestore.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );
    } catch (e) {
      // Ignore if already configured
    }
  }

  /// Configure Firebase Auth settings
  Future<void> _configureAuth() async {
    try {
      final auth = FirebaseAuth.instance;

      // Set persistence to local (survives app restarts)
      await auth.setPersistence(Persistence.LOCAL);
    } catch (e) {
      // Ignore if already configured
    }
  }

  /// Get current Firebase user
  User? getCurrentUser() {
    return FirebaseAuth.instance.currentUser;
  }

  /// Check if user is authenticated
  bool isUserAuthenticated() {
    return FirebaseAuth.instance.currentUser != null;
  }

  /// Stream of auth state changes
  Stream<User?> authStateChanges() {
    return FirebaseAuth.instance.authStateChanges();
  }
}
