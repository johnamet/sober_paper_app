import '../../entities/user.dart';
import '../../../data/repositories/auth_repository.dart';

class LoginWithEmail {
  final AuthRepository _authRepository;

  LoginWithEmail(this._authRepository);

  Future<User> call(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      throw ArgumentError('Email and password cannot be empty');
    }

    if (!_isValidEmail(email)) {
      throw ArgumentError('Invalid email format');
    }

    return await _authRepository.loginWithEmail(email: email, password: password);
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }
}
