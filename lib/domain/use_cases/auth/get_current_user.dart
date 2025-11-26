import '../../entities/user.dart';
import '../../../data/repositories/auth_repository.dart';

class GetCurrentUser {
  final AuthRepository _authRepository;

  GetCurrentUser(this._authRepository);

  Future<User?> call() async {
    return await _authRepository.getCurrentUser();
  }
}
