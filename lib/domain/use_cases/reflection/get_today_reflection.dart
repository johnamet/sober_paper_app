import '../../entities/daily_reflection.dart';
import '../../../data/repositories/reflection_repository.dart';

class GetTodayReflection {
  final ReflectionRepository _reflectionRepository;

  GetTodayReflection(this._reflectionRepository);

  Future<DailyReflection?> call() async {
    return await _reflectionRepository.getTodayReflection();
  }
}
