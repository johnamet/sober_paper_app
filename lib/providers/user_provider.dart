import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import '../domain/entities/user.dart';
import '../data/repositories/user_repository.dart';

// Provider for UserRepository
final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository();
});

// Provider for current Firebase Auth user
final firebaseAuthUserProvider = StreamProvider<auth.User?>((ref) {
  return auth.FirebaseAuth.instance.authStateChanges();
});

// Provider for current app User profile
final currentUserProvider = StreamProvider<User?>((ref) {
  final authUser = ref.watch(firebaseAuthUserProvider).value;
  
  if (authUser == null) {
    return Stream.value(null);
  }

  final repository = ref.watch(userRepositoryProvider);
  return repository.watchUserProfile(authUser.uid);
});

// Provider for user ID
final userIdProvider = Provider<String?>((ref) {
  final authUser = ref.watch(firebaseAuthUserProvider).value;
  return authUser?.uid;
});
