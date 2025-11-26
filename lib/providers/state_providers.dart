import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import '../domain/entities/user.dart';
import '../domain/entities/sobriety_log.dart';
import '../domain/entities/panic_request.dart';
import '../domain/entities/daily_reflection.dart';
import 'repository_providers.dart';

// ============================================================================
// AUTH STATE PROVIDERS
// ============================================================================

/// Firebase Auth User Stream Provider
final firebaseAuthUserProvider = StreamProvider<auth.User?>((ref) {
  return auth.FirebaseAuth.instance.authStateChanges();
});

/// Current User ID Provider
final currentUserIdProvider = Provider<String?>((ref) {
  final authUser = ref.watch(firebaseAuthUserProvider).value;
  return authUser?.uid;
});

/// Check if user is authenticated
final isAuthenticatedProvider = Provider<bool>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  return userId != null;
});

/// Check if user is anonymous
final isAnonymousProvider = Provider<bool>((ref) {
  final authUser = ref.watch(firebaseAuthUserProvider).value;
  return authUser?.isAnonymous ?? false;
});

// ============================================================================
// USER PROFILE STATE PROVIDERS
// ============================================================================

/// Current User Profile Stream Provider
final currentUserProfileProvider = StreamProvider<User?>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  
  if (userId == null) {
    return Stream.value(null);
  }

  final repository = ref.watch(userRepositoryProvider);
  return repository.watchUserProfile(userId);
});

/// User Profile by ID Provider (family)
final userProfileProvider = StreamProvider.family<User?, String>((ref, userId) {
  final repository = ref.watch(userRepositoryProvider);
  return repository.watchUserProfile(userId);
});

// ============================================================================
// SOBRIETY STATE PROVIDERS
// ============================================================================

/// Current User Sobriety Logs Stream Provider
final currentUserSobrietyLogsProvider = StreamProvider<Map<DateTime, SobrietyLog>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  
  if (userId == null) {
    return Stream.value({});
  }

  final repository = ref.watch(sobrietyRepositoryProvider);
  final endDate = DateTime.now();
  final startDate = endDate.subtract(const Duration(days: 365));
  
  return repository.watchSobrietyLogs(
    userId: userId,
    startDate: startDate,
    endDate: endDate,
  );
});

/// Current Streak Provider (computed from logs)
final currentStreakProvider = Provider<int>((ref) {
  final logs = ref.watch(currentUserSobrietyLogsProvider).value ?? {};
  
  if (logs.isEmpty) return 0;

  int streak = 0;
  DateTime checkDate = DateTime.now();

  while (true) {
    final dateKey = DateTime(checkDate.year, checkDate.month, checkDate.day);
    final log = logs[dateKey];

    if (log == null || !log.isClean) {
      break;
    }

    streak++;
    checkDate = checkDate.subtract(const Duration(days: 1));
  }

  return streak;
});

/// Total Clean Days Provider (computed from logs)
final totalCleanDaysProvider = Provider<int>((ref) {
  final logs = ref.watch(currentUserSobrietyLogsProvider).value ?? {};
  return logs.values.where((log) => log.isClean).length;
});

// ============================================================================
// PANIC REQUEST STATE PROVIDERS
// ============================================================================

/// Pending Panic Requests Stream Provider
final pendingPanicRequestsProvider = StreamProvider<List<PanicRequest>>((ref) {
  final repository = ref.watch(panicRepositoryProvider);
  return repository.watchPendingRequests();
});

/// User's Panic Requests Stream Provider
final userPanicRequestsProvider = StreamProvider<List<PanicRequest>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  
  if (userId == null) {
    return Stream.value([]);
  }

  final repository = ref.watch(panicRepositoryProvider);
  return repository.watchUserRequests(userId);
});

/// Active Panic Request Count Provider
final activePanicRequestCountProvider = Provider<int>((ref) {
  final requests = ref.watch(pendingPanicRequestsProvider).value ?? [];
  return requests.where((r) => r.isPending || r.isActive).length;
});

// ============================================================================
// REFLECTION STATE PROVIDERS
// ============================================================================

/// Today's Reflection Provider
final todayReflectionProvider = FutureProvider<DailyReflection?>((ref) async {
  final repository = ref.watch(reflectionRepositoryProvider);
  return await repository.getTodayReflection();
});

// ============================================================================
// UI STATE PROVIDERS (using simple Provider for UI state)
// ============================================================================

// Note: For mutable UI state, consider using riverpod_annotation package
// or managing state in your widgets with StatefulWidget

/// Loading State Provider (read-only, use ref.read() to get, override in tests)
final isLoadingProvider = Provider<bool>((ref) => false);

/// Error Message Provider
final errorMessageProvider = Provider<String?>((ref) => null);

/// Success Message Provider  
final successMessageProvider = Provider<String?>((ref) => null);

/// Selected Tab Index Provider
final selectedTabIndexProvider = Provider<int>((ref) => 0);

/// Theme Mode Provider (false = light, true = dark)
final themeModeProvider = Provider<bool>((ref) => false);
