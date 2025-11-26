import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/use_cases/community/create_group.dart';
import '../domain/use_cases/community/send_direct_message.dart';
import 'repository_providers.dart';

// ============================================================================
// COMMUNITY USE CASE PROVIDERS
// ============================================================================

final createGroupProvider = Provider<CreateGroup>((ref) {
  return CreateGroup(ref.watch(communityRepositoryProvider));
});

final sendDirectMessageProvider = Provider<SendDirectMessage>((ref) {
  return SendDirectMessage(ref.watch(communityRepositoryProvider));
});
