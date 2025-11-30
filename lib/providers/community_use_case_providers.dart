import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/use_cases/community/create_group.dart';
import '../domain/use_cases/community/join_group.dart';
import '../domain/use_cases/community/leave_group.dart';
import '../domain/use_cases/community/get_user_groups.dart';
import '../domain/use_cases/community/browse_public_groups.dart';
import '../domain/use_cases/community/send_group_message.dart';
import '../domain/use_cases/community/get_group.dart';
import '../domain/use_cases/community/send_direct_message.dart';
import 'repository_providers.dart';

// ============================================================================
// COMMUNITY USE CASE PROVIDERS
// ============================================================================

final createGroupProvider = Provider<CreateGroup>((ref) {
  return CreateGroup(ref.watch(communityRepositoryProvider));
});

final joinGroupProvider = Provider<JoinGroup>((ref) {
  return JoinGroup(ref.watch(communityRepositoryProvider));
});

final leaveGroupProvider = Provider<LeaveGroup>((ref) {
  return LeaveGroup(ref.watch(communityRepositoryProvider));
});

final getUserGroupsProvider = Provider<GetUserGroups>((ref) {
  return GetUserGroups(ref.watch(communityRepositoryProvider));
});

final browsePublicGroupsProvider = Provider<BrowsePublicGroups>((ref) {
  return BrowsePublicGroups(ref.watch(communityRepositoryProvider));
});

final sendGroupMessageProvider = Provider<SendGroupMessage>((ref) {
  return SendGroupMessage(ref.watch(communityRepositoryProvider));
});

final getGroupProvider = Provider<GetGroup>((ref) {
  return GetGroup(ref.watch(communityRepositoryProvider));
});

final sendDirectMessageProvider = Provider<SendDirectMessage>((ref) {
  return SendDirectMessage(ref.watch(communityRepositoryProvider));
});
