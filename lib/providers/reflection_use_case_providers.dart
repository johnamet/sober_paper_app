import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/use_cases/reflection/get_today_reflection.dart';
import '../domain/use_cases/reflection/search_prayers.dart';
import 'repository_providers.dart';

// ============================================================================
// REFLECTION USE CASE PROVIDERS
// ============================================================================

final getTodayReflectionProvider = Provider<GetTodayReflection>((ref) {
  return GetTodayReflection(ref.watch(reflectionRepositoryProvider));
});

final searchPrayersProvider = Provider<SearchPrayers>((ref) {
  return SearchPrayers(ref.watch(reflectionRepositoryProvider));
});
