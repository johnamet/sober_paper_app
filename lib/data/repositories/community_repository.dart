import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/sponsorship.dart';
import '../../domain/entities/group.dart';
import '../../domain/entities/message.dart';
import '../../domain/entities/celebration.dart';
import '../../domain/entities/notification.dart';
import '../../models/sponsorship_model.dart';
import '../../models/group_model.dart';
import '../../models/message_model.dart';
import '../../models/celebration_model.dart';
import 'notification_repository.dart';

/// Repository for community features (sponsorships, groups, messages, celebrations)
class CommunityRepository {
  final FirebaseFirestore _firestore;
  final NotificationRepository _notificationRepository;

  CommunityRepository({
    FirebaseFirestore? firestore,
    NotificationRepository? notificationRepository,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _notificationRepository = notificationRepository ?? NotificationRepository();

  // ===== SPONSORSHIP METHODS =====

  /// Create a sponsorship request
  Future<Sponsorship> createSponsorship({
    required String sponsorId,
    required String sponsoredUserId,
  }) async {
    try {
      final sponsorship = Sponsorship(
        id: '', // Will be set by Firestore
        sponsorId: sponsorId,
        sponsoredUserId: sponsoredUserId,
        requestedAt: DateTime.now(),
        status: SponsorshipStatus.pending,
      );

      final docRef = await _firestore
          .collection('sponsorships')
          .add(SponsorshipModel(sponsorship).toJson());

      // Send notification to the sponsor
      await _notificationRepository.createNotification(
        userId: sponsorId,
        type: NotificationType.sponsorshipRequest,
        title: 'New Sponsorship Request',
        message: 'Someone wants you to be their sponsor!',
        data: {
          'sponsorshipId': docRef.id,
          'sponsoredUserId': sponsoredUserId,
        },
      );

      return sponsorship.copyWith(id: docRef.id);
    } catch (e) {
      throw Exception('Failed to create sponsorship: $e');
    }
  }

  /// Accept a sponsorship request
  Future<void> acceptSponsorship(String sponsorshipId) async {
    try {
      await _firestore.collection('sponsorships').doc(sponsorshipId).update({
        'status': SponsorshipStatus.active.name,
        'acceptedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw Exception('Failed to accept sponsorship: $e');
    }
  }

  /// Reject/decline a sponsorship request
  Future<void> rejectSponsorship(String sponsorshipId) async {
    try {
      await _firestore.collection('sponsorships').doc(sponsorshipId).update({
        'status': SponsorshipStatus.ended.name,
        'endedAt': Timestamp.fromDate(DateTime.now()),
        'endReason': 'declined',
      });
    } catch (e) {
      throw Exception('Failed to reject sponsorship: $e');
    }
  }

  /// Get pending sponsorship requests for a sponsor
  Stream<List<Sponsorship>> watchPendingSponsorshipRequests(String sponsorId) {
    return _firestore
        .collection('sponsorships')
        .where('sponsorId', isEqualTo: sponsorId)
        .where('status', isEqualTo: SponsorshipStatus.pending.name)
        .orderBy('requestedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final model = SponsorshipModel.fromJson({
          ...doc.data(),
          'id': doc.id,
        });
        return model.sponsorship;
      }).toList();
    });
  }

  /// Get active sponsorships where user is sponsor
  Stream<List<Sponsorship>> watchActiveSponsorships(String sponsorId) {
    return _firestore
        .collection('sponsorships')
        .where('sponsorId', isEqualTo: sponsorId)
        .where('status', isEqualTo: SponsorshipStatus.active.name)
        .orderBy('acceptedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final model = SponsorshipModel.fromJson({
          ...doc.data(),
          'id': doc.id,
        });
        return model.sponsorship;
      }).toList();
    });
  }

  /// Get user's current sponsor (if they are a sponsee)
  Stream<Sponsorship?> watchUserSponsor(String sponsoredUserId) {
    return _firestore
        .collection('sponsorships')
        .where('sponsoredUserId', isEqualTo: sponsoredUserId)
        .where('status', isEqualTo: SponsorshipStatus.active.name)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      
      final model = SponsorshipModel.fromJson({
        ...snapshot.docs.first.data(),
        'id': snapshot.docs.first.id,
      });
      return model.sponsorship;
    });
  }

  /// End a sponsorship
  Future<void> endSponsorship(String sponsorshipId) async {
    try {
      await _firestore.collection('sponsorships').doc(sponsorshipId).update({
        'status': SponsorshipStatus.ended.name,
        'endedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw Exception('Failed to end sponsorship: $e');
    }
  }

  /// Get a specific sponsorship
  Future<Sponsorship?> getSponsorship(String sponsorshipId) async {
    try {
      final doc = await _firestore
          .collection('sponsorships')
          .doc(sponsorshipId)
          .get();

      if (!doc.exists) return null;

      final model = SponsorshipModel.fromJson({
        ...doc.data()!,
        'id': doc.id,
      });

      return model.sponsorship;
    } catch (e) {
      throw Exception('Failed to get sponsorship: $e');
    }
  }

  /// Get all sponsorships where user is sponsor
  Future<List<Sponsorship>> getSponsorships(String sponsorId) async {
    try {
      final snapshot = await _firestore
          .collection('sponsorships')
          .where('sponsorId', isEqualTo: sponsorId)
          .where('status', isEqualTo: SponsorshipStatus.active.name)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final model = SponsorshipModel.fromJson({
          ...doc.data(),
          'id': doc.id,
        });
        return model.sponsorship;
      }).toList();
    } catch (e) {
      throw Exception('Failed to get sponsorships: $e');
    }
  }

  /// Get user's sponsor (if they are a sponsee)
  Future<Sponsorship?> getUserSponsor(String sponsoredUserId) async {
    try {
      final snapshot = await _firestore
          .collection('sponsorships')
          .where('sponsoredUserId', isEqualTo: sponsoredUserId)
          .where('status', isEqualTo: SponsorshipStatus.active.name)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;

      final doc = snapshot.docs.first;
      final model = SponsorshipModel.fromJson({
        ...doc.data(),
        'id': doc.id,
      });

      return model.sponsorship;
    } catch (e) {
      throw Exception('Failed to get user sponsor: $e');
    }
  }

  // ===== GROUP METHODS =====

  /// Create a new support group
  Future<Group> createGroup({
    required String name,
    required String description,
    required String createdBy,
    required GroupCategory category,
    bool isPrivate = false,
    int maxMembers = 50,
  }) async {
    try {
      final group = Group(
        id: '', // Will be set by Firestore
        name: name,
        description: description,
        createdBy: createdBy,
        createdAt: DateTime.now(),
        memberIds: [createdBy],
        memberCount: 1,
        isPrivate: isPrivate,
        maxMembers: maxMembers,
        category: category,
      );

      final docRef = await _firestore
          .collection('groups')
          .add(GroupModel(group).toJson());

      // Add creator as first member
      await addGroupMember(
        groupId: docRef.id,
        userId: createdBy,
        role: 'admin',
      );

      return group.copyWith(id: docRef.id);
    } catch (e) {
      throw Exception('Failed to create group: $e');
    }
  }

  /// Join a group
  Future<void> joinGroup({
    required String groupId,
    required String userId,
  }) async {
    try {
      await addGroupMember(groupId: groupId, userId: userId);
      
      // Increment member count
      await _firestore.collection('groups').doc(groupId).update({
        'memberCount': FieldValue.increment(1),
      });
    } catch (e) {
      throw Exception('Failed to join group: $e');
    }
  }

  /// Leave a group
  Future<void> leaveGroup({
    required String groupId,
    required String userId,
  }) async {
    try {
      await _firestore
          .collection('groups')
          .doc(groupId)
          .collection('members')
          .doc(userId)
          .delete();

      // Decrement member count
      await _firestore.collection('groups').doc(groupId).update({
        'memberCount': FieldValue.increment(-1),
      });
    } catch (e) {
      throw Exception('Failed to leave group: $e');
    }
  }

  /// Add a member to a group
  Future<void> addGroupMember({
    required String groupId,
    required String userId,
    String role = 'member',
  }) async {
    try {
      await _firestore
          .collection('groups')
          .doc(groupId)
          .collection('members')
          .doc(userId)
          .set({
        'userId': userId,
        'role': role,
        'joinedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw Exception('Failed to add group member: $e');
    }
  }

  /// Get a specific group
  Future<Group?> getGroup(String groupId) async {
    try {
      final doc = await _firestore.collection('groups').doc(groupId).get();

      if (!doc.exists) return null;

      final model = GroupModel.fromJson({
        ...doc.data()!,
        'id': doc.id,
      });

      return model.group;
    } catch (e) {
      throw Exception('Failed to get group: $e');
    }
  }

  /// Get groups the user is a member of
  Future<List<Group>> getUserGroups(String userId) async {
    try {
      // First get all group IDs the user is a member of
      final membershipSnapshot = await _firestore
          .collectionGroup('members')
          .where('userId', isEqualTo: userId)
          .get();

      final groupIds = membershipSnapshot.docs
          .map((doc) => doc.reference.parent.parent!.id)
          .toList();

      if (groupIds.isEmpty) return [];

      // Fetch the actual group documents
      final groups = <Group>[];
      for (final groupId in groupIds) {
        final group = await getGroup(groupId);
        if (group != null) {
          groups.add(group);
        }
      }

      return groups;
    } catch (e) {
      throw Exception('Failed to get user groups: $e');
    }
  }

  /// Browse public groups
  Future<List<Group>> browsePublicGroups({int limit = 20}) async {
    try {
      final snapshot = await _firestore
          .collection('groups')
          .where('isPrivate', isEqualTo: false)
          .orderBy('memberCount', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) {
        final model = GroupModel.fromJson({
          ...doc.data(),
          'id': doc.id,
        });
        return model.group;
      }).toList();
    } catch (e) {
      throw Exception('Failed to browse public groups: $e');
    }
  }

  // ===== MESSAGE METHODS =====

  /// Send a message to a group
  Future<Message> sendMessage({
    required String groupId,
    required String senderId,
    required String senderName,
    required String content,
  }) async {
    try {
      final message = Message(
        id: '', // Will be set by Firestore
        conversationId: groupId,
        conversationType: ConversationType.group,
        senderId: senderId,
        senderName: senderName,
        content: content,
        timestamp: DateTime.now(),
      );

      final docRef = await _firestore
          .collection('groups')
          .doc(groupId)
          .collection('messages')
          .add(MessageModel(message).toJson());

      return message.copyWith(id: docRef.id);
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  /// Send a direct message between users
  Future<Message> sendDirectMessage({
    required String senderId,
    required String senderName,
    required String recipientId,
    required String content,
  }) async {
    try {
      // Create conversation ID (sorted user IDs for consistency)
      final conversationId = [senderId, recipientId]..sort();
      final conversationIdStr = conversationId.join('_');

      final message = Message(
        id: '', // Will be set by Firestore
        conversationId: conversationIdStr,
        conversationType: ConversationType.direct,
        senderId: senderId,
        senderName: senderName,
        content: content,
        timestamp: DateTime.now(),
      );

      final docRef = await _firestore
          .collection('direct_messages')
          .add(MessageModel(message).toJson());

      return message.copyWith(id: docRef.id);
    } catch (e) {
      throw Exception('Failed to send direct message: $e');
    }
  }

  /// Get messages for a group
  Future<List<Message>> getGroupMessages({
    required String groupId,
    int limit = 50,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('groups')
          .doc(groupId)
          .collection('messages')
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) {
        final model = MessageModel.fromJson({
          ...doc.data(),
          'id': doc.id,
        });
        return model.message;
      }).toList();
    } catch (e) {
      throw Exception('Failed to get group messages: $e');
    }
  }

  /// Get direct messages between two users
  Future<List<Message>> getDirectMessages({
    required String userId1,
    required String userId2,
    int limit = 50,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('direct_messages')
          .where('senderId', whereIn: [userId1, userId2])
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      // Filter to only messages between these two users
      return snapshot.docs
          .where((doc) {
            final data = doc.data();
            final senderId = data['senderId'] as String;
            final recipientId = data['recipientId'] as String?;
            return (senderId == userId1 && recipientId == userId2) ||
                (senderId == userId2 && recipientId == userId1);
          })
          .map((doc) {
            final model = MessageModel.fromJson({
              ...doc.data(),
              'id': doc.id,
            });
            return model.message;
          })
          .toList();
    } catch (e) {
      throw Exception('Failed to get direct messages: $e');
    }
  }

  /// Stream of group messages (real-time)
  Stream<List<Message>> watchGroupMessages(String groupId) {
    return _firestore
        .collection('groups')
        .doc(groupId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final model = MessageModel.fromJson({
          ...doc.data(),
          'id': doc.id,
        });
        return model.message;
      }).toList();
    });
  }

  /// Stream of direct messages between two users (real-time)
  Stream<List<Message>> watchDirectMessages(String conversationId) {
    return _firestore
        .collection('direct_messages')
        .where('conversationId', isEqualTo: conversationId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final model = MessageModel.fromJson({
          ...doc.data(),
          'id': doc.id,
        });
        return model.message;
      }).toList();
    });
  }

  /// Delete a message
  Future<void> deleteMessage({
    required String messageId,
    String? groupId,
  }) async {
    try {
      if (groupId != null) {
        await _firestore
            .collection('groups')
            .doc(groupId)
            .collection('messages')
            .doc(messageId)
            .delete();
      } else {
        await _firestore.collection('direct_messages').doc(messageId).delete();
      }
    } catch (e) {
      throw Exception('Failed to delete message: $e');
    }
  }

  // ===== CELEBRATION METHODS =====

  /// Post a milestone celebration
  Future<Celebration> postCelebration({
    required String userId,
    required String userName,
    required int dayCount,
    String? message,
  }) async {
    try {
      final celebration = Celebration(
        id: '', // Will be set by Firestore
        userId: userId,
        userName: userName,
        dayCount: dayCount,
        message: message,
        timestamp: DateTime.now(),
      );

      final docRef = await _firestore
          .collection('celebrations')
          .add(CelebrationModel(celebration).toJson());

      return celebration.copyWith(id: docRef.id);
    } catch (e) {
      throw Exception('Failed to post celebration: $e');
    }
  }

  /// React to a celebration
  Future<void> reactToCelebration({
    required String celebrationId,
    required String userId,
    required String reactionType,
  }) async {
    try {
      await _firestore.collection('celebrations').doc(celebrationId).update({
        'reactions.$userId': reactionType,
      });
    } catch (e) {
      throw Exception('Failed to react to celebration: $e');
    }
  }

  /// Get recent celebrations
  Future<List<Celebration>> getRecentCelebrations({int limit = 20}) async {
    try {
      final snapshot = await _firestore
          .collection('celebrations')
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) {
        final model = CelebrationModel.fromJson({
          ...doc.data(),
          'id': doc.id,
        });
        return model.celebration;
      }).toList();
    } catch (e) {
      throw Exception('Failed to get recent celebrations: $e');
    }
  }

  /// Get celebrations for a specific user
  Future<List<Celebration>> getUserCelebrations(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('celebrations')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final model = CelebrationModel.fromJson({
          ...doc.data(),
          'id': doc.id,
        });
        return model.celebration;
      }).toList();
    } catch (e) {
      throw Exception('Failed to get user celebrations: $e');
    }
  }

  /// Stream of recent celebrations (real-time)
  Stream<List<Celebration>> watchCelebrations() {
    return _firestore
        .collection('celebrations')
        .orderBy('createdAt', descending: true)
        .limit(20)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final model = CelebrationModel.fromJson({
          ...doc.data(),
          'id': doc.id,
        });
        return model.celebration;
      }).toList();
    });
  }

  /// Delete a celebration
  Future<void> deleteCelebration(String celebrationId) async {
    try {
      await _firestore.collection('celebrations').doc(celebrationId).delete();
    } catch (e) {
      throw Exception('Failed to delete celebration: $e');
    }
  }
}
