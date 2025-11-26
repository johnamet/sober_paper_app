import '../../../data/repositories/sobriety_repository.dart';

class CalculateCurrentStreak {
  final SobrietyRepository _sobrietyRepository;

  CalculateCurrentStreak(this._sobrietyRepository);

  Future<int> call(String userId) async {
    if (userId.isEmpty) {
      throw ArgumentError('User ID cannot be empty');
    }

    return await _sobrietyRepository.calculateCurrentStreak(userId);
  }
}
