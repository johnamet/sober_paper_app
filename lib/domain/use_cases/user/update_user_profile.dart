import '../../entities/user.dart';
import '../../../data/repositories/user_repository.dart';

class UpdateUserProfile {
  final UserRepository _userRepository;

  UpdateUserProfile(this._userRepository);

  Future<void> call({
    required String uid,
    String? displayName,
    DateTime? sobrietyStartDate,
    String? sponsorId,
    bool? isVolunteer,
    UserPreferences? preferences,
  }) async {
    if (uid.isEmpty) {
      throw ArgumentError('User ID cannot be empty');
    }

    await _userRepository.updateUserProfile(
      uid: uid,
      displayName: displayName,
      sobrietyStartDate: sobrietyStartDate,
      sponsorId: sponsorId,
      isVolunteer: isVolunteer,
      preferences: preferences,
    );
  }
}
