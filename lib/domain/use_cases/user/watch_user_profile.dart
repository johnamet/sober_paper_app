import '../../entities/user.dart';
import '../../../data/repositories/user_repository.dart';

class WatchUserProfile {
  final UserRepository _userRepository;

  WatchUserProfile(this._userRepository);

  Stream<User?> call(String userId) {
    if (userId.isEmpty) {
      throw ArgumentError('User ID cannot be empty');
    }

    return _userRepository.watchUserProfile(userId);
  }
}
