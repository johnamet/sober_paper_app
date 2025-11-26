import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/panic_request.dart';
import '../../models/panic_request_model.dart';

/// Repository for panic request management
class PanicRepository {
  final FirebaseFirestore _firestore;

  PanicRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Create a new panic request
  Future<PanicRequest> createRequest({
    required String requesterId,
    required String requesterName,
    required int requesterDayCount,
    required ConnectionType connectionType,
  }) async {
    try {
      final request = PanicRequest(
        id: '', // Will be set by Firestore
        requesterId: requesterId,
        requesterName: requesterName,
        requesterDayCount: requesterDayCount,
        timestamp: DateTime.now(),
        status: PanicStatus.pending,
        connectionType: connectionType,
      );

      final docRef = await _firestore
          .collection('panic_requests')
          .add(PanicRequestModel(request).toJson());

      // Return with generated ID
      return request.copyWith(id: docRef.id);
    } catch (e) {
      throw Exception('Failed to create panic request: $e');
    }
  }

  /// Respond to a panic request (volunteer action)
  Future<void> respondToRequest({
    required String requestId,
    required String volunteerId,
    String? response,
  }) async {
    try {
      await _firestore.collection('panic_requests').doc(requestId).update({
        'volunteerId': volunteerId,
        'response': response,
        'status': 'responded',
        'respondedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw Exception('Failed to respond to panic request: $e');
    }
  }

  /// Cancel a panic request (user action)
  Future<void> cancelRequest(String requestId) async {
    try {
      await _firestore.collection('panic_requests').doc(requestId).update({
        'status': 'cancelled',
        'resolvedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw Exception('Failed to cancel panic request: $e');
    }
  }

  /// Resolve a panic request (mark as completed)
  Future<void> resolveRequest(String requestId) async {
    try {
      await _firestore.collection('panic_requests').doc(requestId).update({
        'status': 'resolved',
        'resolvedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw Exception('Failed to resolve panic request: $e');
    }
  }

  /// Get a specific panic request
  Future<PanicRequest?> getRequest(String requestId) async {
    try {
      final doc = await _firestore
          .collection('panic_requests')
          .doc(requestId)
          .get();

      if (!doc.exists) return null;

      final model = PanicRequestModel.fromJson({
        ...doc.data()!,
        'id': doc.id,
      });

      return model.request;
    } catch (e) {
      throw Exception('Failed to get panic request: $e');
    }
  }

  /// Get all panic requests for a user
  Future<List<PanicRequest>> getUserRequests(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('panic_requests')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final model = PanicRequestModel.fromJson({
          ...doc.data(),
          'id': doc.id,
        });
        return model.request;
      }).toList();
    } catch (e) {
      throw Exception('Failed to get user panic requests: $e');
    }
  }

  /// Get pending panic requests (for volunteers)
  Future<List<PanicRequest>> getPendingRequests() async {
    try {
      final snapshot = await _firestore
          .collection('panic_requests')
          .where('status', isEqualTo: 'pending')
          .orderBy('createdAt', descending: false)
          .get();

      return snapshot.docs.map((doc) {
        final model = PanicRequestModel.fromJson({
          ...doc.data(),
          'id': doc.id,
        });
        return model.request;
      }).toList();
    } catch (e) {
      throw Exception('Failed to get pending panic requests: $e');
    }
  }

  /// Stream of panic requests for a user
  Stream<List<PanicRequest>> watchUserRequests(String userId) {
    return _firestore
        .collection('panic_requests')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final model = PanicRequestModel.fromJson({
          ...doc.data(),
          'id': doc.id,
        });
        return model.request;
      }).toList();
    });
  }

  /// Stream of pending panic requests (for volunteers)
  Stream<List<PanicRequest>> watchPendingRequests() {
    return _firestore
        .collection('panic_requests')
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final model = PanicRequestModel.fromJson({
          ...doc.data(),
          'id': doc.id,
        });
        return model.request;
      }).toList();
    });
  }

  /// Stream of a specific panic request
  Stream<PanicRequest?> watchRequest(String requestId) {
    return _firestore
        .collection('panic_requests')
        .doc(requestId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;

      final model = PanicRequestModel.fromJson({
        ...doc.data()!,
        'id': doc.id,
      });
      return model.request;
    });
  }

  /// Delete a panic request
  Future<void> deleteRequest(String requestId) async {
    try {
      await _firestore.collection('panic_requests').doc(requestId).delete();
    } catch (e) {
      throw Exception('Failed to delete panic request: $e');
    }
  }
}
