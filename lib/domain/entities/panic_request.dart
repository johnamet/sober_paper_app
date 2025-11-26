/// Emergency panic button request
class PanicRequest {
  final String id;
  final String requesterId;
  final String requesterName;
  final int requesterDayCount;
  final DateTime timestamp;
  final PanicStatus status;
  final String? responderId;
  final String? responderName;
  final ConnectionType connectionType;
  final DateTime? resolvedAt;

  const PanicRequest({
    required this.id,
    required this.requesterId,
    required this.requesterName,
    required this.requesterDayCount,
    required this.timestamp,
    required this.status,
    this.responderId,
    this.responderName,
    required this.connectionType,
    this.resolvedAt,
  });

  /// Check if request is awaiting response
  bool get isPending => status == PanicStatus.pending;

  /// Check if request has been accepted and is active
  bool get isActive => status == PanicStatus.active;

  /// Check if request has been resolved
  bool get isResolved => status == PanicStatus.resolved;

  /// Check if request was cancelled
  bool get isCancelled => status == PanicStatus.cancelled;

  /// Check if request has a responder
  bool get hasResponder => responderId != null;

  /// Calculate how long request has been waiting
  Duration get waitTime => DateTime.now().difference(timestamp);

  PanicRequest copyWith({
    String? id,
    String? requesterId,
    String? requesterName,
    int? requesterDayCount,
    DateTime? timestamp,
    PanicStatus? status,
    String? responderId,
    String? responderName,
    ConnectionType? connectionType,
    DateTime? resolvedAt,
  }) {
    return PanicRequest(
      id: id ?? this.id,
      requesterId: requesterId ?? this.requesterId,
      requesterName: requesterName ?? this.requesterName,
      requesterDayCount: requesterDayCount ?? this.requesterDayCount,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      responderId: responderId ?? this.responderId,
      responderName: responderName ?? this.responderName,
      connectionType: connectionType ?? this.connectionType,
      resolvedAt: resolvedAt ?? this.resolvedAt,
    );
  }
}

/// Status of panic request
enum PanicStatus {
  /// Waiting for volunteer response
  pending,
  
  /// Volunteer has accepted and is helping
  active,
  
  /// Request has been resolved
  resolved,
  
  /// Request was cancelled by requester
  cancelled,
}

/// Type of connection for panic response
enum ConnectionType {
  /// Text-based chat
  chat,
  
  /// Voice/video call
  call,
}
