import '../../entities/user.dart';
import '../../../data/repositories/auth_repository.dart';

class UpgradeAnonymousAccount {
  final AuthRepository _authRepository;

  UpgradeAnonymousAccount(this._authRepository);

  Future<User> call({
    required String email,
    required String password,
    required String displayName,
  }) async {
    // Validation
    if (email.isEmpty || password.isEmpty || displayName.isEmpty) {
      throw ArgumentError('All fields are required');
    }

    if (!_isValidEmail(email)) {
      throw ArgumentError('Invalid email format');
    }

    if (password.length < 6) {
      throw ArgumentError('Password must be at least 6 characters');
    }

    return await _authRepository.upgradeAnonymousAccount(
      email: email,
      password: password,
      displayName: displayName,
    );
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }
}
