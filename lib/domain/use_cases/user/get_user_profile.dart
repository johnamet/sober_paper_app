import '../../entities/user.dart';
import '../../../data/repositories/user_repository.dart';

class GetUserProfile {
  final UserRepository _userRepository;

  GetUserProfile(this._userRepository);

  Future<User> call(String userId) async {
    if (userId.isEmpty) {
      throw ArgumentError('User ID cannot be empty');
    }

    final user = await _userRepository.getUserProfile(userId);
    if (user == null) {
      throw Exception('User not found');
    }

    return user;
  }
}
