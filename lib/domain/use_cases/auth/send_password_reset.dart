import '../../../data/repositories/auth_repository.dart';

class SendPasswordReset {
  final AuthRepository _authRepository;

  SendPasswordReset(this._authRepository);

  Future<void> call(String email) async {
    if (email.isEmpty) {
      throw ArgumentError('Email cannot be empty');
    }

    if (!_isValidEmail(email)) {
      throw ArgumentError('Invalid email format');
    }

    await _authRepository.sendPasswordResetEmail(email);
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }
}
