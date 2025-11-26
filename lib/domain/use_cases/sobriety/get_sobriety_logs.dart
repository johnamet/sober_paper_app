import '../../entities/sobriety_log.dart';
import '../../../data/repositories/sobriety_repository.dart';

class GetSobrietyLogs {
  final SobrietyRepository _sobrietyRepository;

  GetSobrietyLogs(this._sobrietyRepository);

  Future<Map<DateTime, SobrietyLog>> call({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (userId.isEmpty) {
      throw ArgumentError('User ID cannot be empty');
    }

    final start = startDate ?? DateTime.now().subtract(const Duration(days: 365));
    final end = endDate ?? DateTime.now();

    return await _sobrietyRepository.getSobrietyLogs(
      userId: userId,
      startDate: start,
      endDate: end,
    );
  }
}
