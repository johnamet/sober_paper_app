import '../../entities/prayer.dart';
import '../../../data/repositories/reflection_repository.dart';

class SearchPrayers {
  final ReflectionRepository _reflectionRepository;

  SearchPrayers(this._reflectionRepository);

  Future<List<Prayer>> call(String query, {PrayerCategory? category}) async {
    if (query.isEmpty) {
      throw ArgumentError('Search query cannot be empty');
    }

    final results = await _reflectionRepository.searchPrayers(query);
    
    // Filter by category if provided
    if (category != null) {
      return results.where((prayer) => prayer.category == category).toList();
    }
    
    return results;
  }
}
