import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/use_cases/auth/login_with_email.dart';
import '../domain/use_cases/auth/register_with_email.dart';
import '../domain/use_cases/auth/login_anonymously.dart';
import '../domain/use_cases/auth/logout.dart';
import '../domain/use_cases/auth/get_current_user.dart';
import '../domain/use_cases/auth/send_password_reset.dart';
import '../domain/use_cases/auth/upgrade_anonymous_account.dart';
import 'repository_providers.dart';

// ============================================================================
// AUTH USE CASE PROVIDERS
// ============================================================================

final loginWithEmailProvider = Provider<LoginWithEmail>((ref) {
  return LoginWithEmail(ref.watch(authRepositoryProvider));
});

final registerWithEmailProvider = Provider<RegisterWithEmail>((ref) {
  return RegisterWithEmail(ref.watch(authRepositoryProvider));
});

final loginAnonymouslyProvider = Provider<LoginAnonymously>((ref) {
  return LoginAnonymously(ref.watch(authRepositoryProvider));
});

final logoutProvider = Provider<Logout>((ref) {
  return Logout(ref.watch(authRepositoryProvider));
});

final getCurrentUserProvider = Provider<GetCurrentUser>((ref) {
  return GetCurrentUser(ref.watch(authRepositoryProvider));
});

final sendPasswordResetProvider = Provider<SendPasswordReset>((ref) {
  return SendPasswordReset(ref.watch(authRepositoryProvider));
});

final upgradeAnonymousAccountProvider = Provider<UpgradeAnonymousAccount>((ref) {
  return UpgradeAnonymousAccount(ref.watch(authRepositoryProvider));
});
