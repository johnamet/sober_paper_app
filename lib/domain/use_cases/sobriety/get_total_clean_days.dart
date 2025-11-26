import '../../../data/repositories/sobriety_repository.dart';

class GetTotalCleanDays {
  final SobrietyRepository _sobrietyRepository;

  GetTotalCleanDays(this._sobrietyRepository);

  Future<int> call(String userId) async {
    if (userId.isEmpty) {
      throw ArgumentError('User ID cannot be empty');
    }

    return await _sobrietyRepository.getTotalCleanDays(userId);
  }
}
