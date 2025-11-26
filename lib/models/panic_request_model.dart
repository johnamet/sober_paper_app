import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/entities/panic_request.dart';

/// Model for PanicRequest with JSON serialization
class PanicRequestModel {
  final PanicRequest request;

  const PanicRequestModel(this.request);

  /// Convert from Firestore document
  factory PanicRequestModel.fromJson(Map<String, dynamic> json) {
    return PanicRequestModel(
      PanicRequest(
        id: json['id'] as String,
        requesterId: json['requesterId'] as String,
        requesterName: json['requesterName'] as String,
        requesterDayCount: json['requesterDayCount'] as int? ?? 0,
        timestamp: (json['timestamp'] as Timestamp).toDate(),
        status: _statusFromString(json['status'] as String),
        responderId: json['responderId'] as String?,
        responderName: json['responderName'] as String?,
        connectionType: _connectionTypeFromString(json['connectionType'] as String),
        resolvedAt: json['resolvedAt'] != null
            ? (json['resolvedAt'] as Timestamp).toDate()
            : null,
      ),
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toJson() {
    return {
      'id': request.id,
      'requesterId': request.requesterId,
      'requesterName': request.requesterName,
      'requesterDayCount': request.requesterDayCount,
      'timestamp': Timestamp.fromDate(request.timestamp),
      'status': request.status.name,
      'responderId': request.responderId,
      'responderName': request.responderName,
      'connectionType': request.connectionType.name,
      'resolvedAt': request.resolvedAt != null 
          ? Timestamp.fromDate(request.resolvedAt!) 
          : null,
    };
  }

  static PanicStatus _statusFromString(String status) {
    switch (status) {
      case 'pending':
        return PanicStatus.pending;
      case 'active':
        return PanicStatus.active;
      case 'resolved':
        return PanicStatus.resolved;
      case 'cancelled':
        return PanicStatus.cancelled;
      default:
        return PanicStatus.pending;
    }
  }

  static ConnectionType _connectionTypeFromString(String type) {
    switch (type) {
      case 'chat':
        return ConnectionType.chat;
      case 'call':
        return ConnectionType.call;
      default:
        return ConnectionType.chat;
    }
  }
}
