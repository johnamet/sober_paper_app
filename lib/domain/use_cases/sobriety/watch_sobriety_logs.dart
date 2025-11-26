import '../../entities/sobriety_log.dart';
import '../../../data/repositories/sobriety_repository.dart';

class WatchSobrietyLogs {
  final SobrietyRepository _sobrietyRepository;

  WatchSobrietyLogs(this._sobrietyRepository);

  Stream<Map<DateTime, SobrietyLog>> call({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    if (userId.isEmpty) {
      throw ArgumentError('User ID cannot be empty');
    }

    final start = startDate ?? DateTime.now().subtract(const Duration(days: 365));
    final end = endDate ?? DateTime.now();

    return _sobrietyRepository.watchSobrietyLogs(
      userId: userId,
      startDate: start,
      endDate: end,
    );
  }
}
