import '../../../data/repositories/user_repository.dart';

class UpdateUserStats {
  final UserRepository _userRepository;

  UpdateUserStats(this._userRepository);

  Future<void> call({
    required String uid,
    int? totalDaysClean,
    int? longestStreak,
    int? currentStreak,
    int? totalRelapses,
    int? totalReflections,
    int? totalPrayers,
  }) async {
    if (uid.isEmpty) {
      throw ArgumentError('User ID cannot be empty');
    }

    // Ensure at least one stat is provided
    if (totalDaysClean == null &&
        longestStreak == null &&
        currentStreak == null &&
        totalRelapses == null &&
        totalReflections == null &&
        totalPrayers == null) {
      throw ArgumentError('At least one stat must be provided for update');
    }

    await _userRepository.updateUserStats(
      uid: uid,
      totalDaysClean: totalDaysClean,
      longestStreak: longestStreak,
      currentStreak: currentStreak,
      totalRelapses: totalRelapses,
      totalReflections: totalReflections,
      totalPrayers: totalPrayers,
    );
  }
}
