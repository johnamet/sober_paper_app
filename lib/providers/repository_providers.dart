import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/user_repository.dart';
import '../data/repositories/sobriety_repository.dart';
import '../data/repositories/panic_repository.dart';
import '../data/repositories/community_repository.dart';
import '../data/repositories/reflection_repository.dart';
import '../data/repositories/moderation_repository.dart';

// ============================================================================
// REPOSITORY PROVIDERS
// ============================================================================

/// Auth Repository Provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

/// User Repository Provider
final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository();
});

/// Sobriety Repository Provider
final sobrietyRepositoryProvider = Provider<SobrietyRepository>((ref) {
  return SobrietyRepository();
});

/// Panic Repository Provider
final panicRepositoryProvider = Provider<PanicRepository>((ref) {
  return PanicRepository();
});

/// Community Repository Provider
final communityRepositoryProvider = Provider<CommunityRepository>((ref) {
  return CommunityRepository();
});

/// Reflection Repository Provider
final reflectionRepositoryProvider = Provider<ReflectionRepository>((ref) {
  return ReflectionRepository();
});

/// Moderation Repository Provider
final moderationRepositoryProvider = Provider<ModerationRepository>((ref) {
  return ModerationRepository();
});
