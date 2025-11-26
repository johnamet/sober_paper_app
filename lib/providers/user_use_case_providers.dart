import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/use_cases/user/get_user_profile.dart';
import '../domain/use_cases/user/update_user_profile.dart';
import '../domain/use_cases/user/watch_user_profile.dart';
import '../domain/use_cases/user/update_user_stats.dart';
import 'repository_providers.dart';

// ============================================================================
// USER USE CASE PROVIDERS
// ============================================================================

final getUserProfileProvider = Provider<GetUserProfile>((ref) {
  return GetUserProfile(ref.watch(userRepositoryProvider));
});

final updateUserProfileProvider = Provider<UpdateUserProfile>((ref) {
  return UpdateUserProfile(ref.watch(userRepositoryProvider));
});

final watchUserProfileProvider = Provider<WatchUserProfile>((ref) {
  return WatchUserProfile(ref.watch(userRepositoryProvider));
});

final updateUserStatsProvider = Provider<UpdateUserStats>((ref) {
  return UpdateUserStats(ref.watch(userRepositoryProvider));
});
