import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/entities/message.dart';
import '../domain/entities/group.dart';
import 'repository_providers.dart';
import 'state_providers.dart';

// ============================================================================
// CHAT PROVIDERS
// ============================================================================

/// Provider for direct messages between two users (real-time stream)
/// Use this to display a conversation between the current user and another user
final directMessagesProvider = StreamProvider.family<List<Message>, String>(
  (ref, otherUserId) {
    final currentUserId = ref.watch(currentUserIdProvider);
    
    if (currentUserId == null) {
      return Stream.value([]);
    }

    final repository = ref.watch(communityRepositoryProvider);
    
    // Create conversation ID (sorted for consistency)
    final conversationId = [currentUserId, otherUserId]..sort();
    final conversationIdStr = conversationId.join('_');
    
    // Watch direct messages for this conversation
    return repository.watchDirectMessages(conversationIdStr);
  },
);

/// Provider for getting a list of direct messages (one-time fetch)
final getDirectMessagesProvider = FutureProvider.family<List<Message>, DirectMessageParams>(
  (ref, params) async {
    final repository = ref.watch(communityRepositoryProvider);
    
    return repository.getDirectMessages(
      userId1: params.userId1,
      userId2: params.userId2,
      limit: params.limit,
    );
  },
);

/// Provider for group messages (real-time stream)
final groupMessagesProvider = StreamProvider.family<List<Message>, String>(
  (ref, groupId) {
    final repository = ref.watch(communityRepositoryProvider);
    return repository.watchGroupMessages(groupId);
  },
);

/// Parameters for getting direct messages
class DirectMessageParams {
  final String userId1;
  final String userId2;
  final int limit;

  DirectMessageParams({
    required this.userId1,
    required this.userId2,
    this.limit = 50,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DirectMessageParams &&
        other.userId1 == userId1 &&
        other.userId2 == userId2 &&
        other.limit == limit;
  }

  @override
  int get hashCode => userId1.hashCode ^ userId2.hashCode ^ limit.hashCode;
}

// ============================================================================
// SUPPORT GROUPS PROVIDERS
// ============================================================================

/// Provider for the current user's groups
final userGroupsProvider = FutureProvider<List<Group>>((ref) async {
  final currentUserId = ref.watch(currentUserIdProvider);
  
  if (currentUserId == null) {
    return [];
  }

  final repository = ref.watch(communityRepositoryProvider);
  return repository.getUserGroups(currentUserId);
});

/// Provider for browsing public groups
final publicGroupsProvider = FutureProvider<List<Group>>((ref) async {
  final repository = ref.watch(communityRepositoryProvider);
  return repository.browsePublicGroups(limit: 50);
});

/// Provider for getting a specific group by ID
final groupDetailProvider = FutureProvider.family<Group?, String>((ref, groupId) async {
  final repository = ref.watch(communityRepositoryProvider);
  return repository.getGroup(groupId);
});

/// Provider for sending messages (use case will be added if needed)
/// For now, we can use the repository directly via read()
