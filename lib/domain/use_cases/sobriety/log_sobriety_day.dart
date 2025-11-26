import '../../entities/sobriety_log.dart';
import '../../../data/repositories/sobriety_repository.dart';

class LogSobrietyDay {
  final SobrietyRepository _sobrietyRepository;

  LogSobrietyDay(this._sobrietyRepository);

  Future<void> call({
    required String userId,
    required DateTime date,
    required SobrietyStatus status,
    String? notes,
    int? moodRating,
    List<String>? triggers,
  }) async {
    if (userId.isEmpty) {
      throw ArgumentError('User ID cannot be empty');
    }

    if (moodRating != null && (moodRating < 1 || moodRating > 10)) {
      throw ArgumentError('Mood rating must be between 1 and 10');
    }

    await _sobrietyRepository.logSobrietyDay(
      userId: userId,
      date: date,
      status: status.name, // Convert enum to string
      notes: notes,
      mood: moodRating?.toString(),
      triggers: triggers,
    );
  }
}
