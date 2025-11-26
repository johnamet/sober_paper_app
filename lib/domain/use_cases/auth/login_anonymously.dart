import '../../entities/user.dart';
import '../../../data/repositories/auth_repository.dart';

class LoginAnonymously {
  final AuthRepository _authRepository;

  LoginAnonymously(this._authRepository);

  Future<User> call() async {
    return await _authRepository.loginAnonymously();
  }
}
