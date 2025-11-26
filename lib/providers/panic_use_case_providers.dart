import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/use_cases/panic/create_panic_request.dart';
import '../domain/use_cases/panic/respond_to_panic_request.dart';
import '../domain/use_cases/panic/watch_pending_panic_requests.dart';
import 'repository_providers.dart';

// ============================================================================
// PANIC USE CASE PROVIDERS
// ============================================================================

final createPanicRequestProvider = Provider<CreatePanicRequest>((ref) {
  return CreatePanicRequest(ref.watch(panicRepositoryProvider));
});

final respondToPanicRequestProvider = Provider<RespondToPanicRequest>((ref) {
  return RespondToPanicRequest(ref.watch(panicRepositoryProvider));
});

final watchPendingPanicRequestsProvider = Provider<WatchPendingPanicRequests>((ref) {
  return WatchPendingPanicRequests(ref.watch(panicRepositoryProvider));
});
