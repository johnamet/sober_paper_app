/// Sponsorship relationship between users
/// Represents the connection between a sponsor and sponsee in recovery
class Sponsorship {
  final String id;
  final String sponsorId;
  final String sponsoredUserId;
  final DateTime requestedAt;
  final DateTime? acceptedAt;
  final SponsorshipStatus status;
  final DateTime? endedAt;
  final String? endReason;

  const Sponsorship({
    required this.id,
    required this.sponsorId,
    required this.sponsoredUserId,
    required this.requestedAt,
    this.acceptedAt,
    required this.status,
    this.endedAt,
    this.endReason,
  });

  /// Check if sponsorship is still pending acceptance
  bool get isPending => status == SponsorshipStatus.pending;

  /// Check if sponsorship is currently active
  bool get isActive => status == SponsorshipStatus.active;

  /// Check if sponsorship has ended
  bool get isEnded => status == SponsorshipStatus.ended;

  /// Calculate how long the sponsorship has been active
  Duration? get activeDuration {
    if (!isActive || acceptedAt == null) return null;
    return DateTime.now().difference(acceptedAt!);
  }

  Sponsorship copyWith({
    String? id,
    String? sponsorId,
    String? sponsoredUserId,
    DateTime? requestedAt,
    DateTime? acceptedAt,
    SponsorshipStatus? status,
    DateTime? endedAt,
    String? endReason,
  }) {
    return Sponsorship(
      id: id ?? this.id,
      sponsorId: sponsorId ?? this.sponsorId,
      sponsoredUserId: sponsoredUserId ?? this.sponsoredUserId,
      requestedAt: requestedAt ?? this.requestedAt,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      status: status ?? this.status,
      endedAt: endedAt ?? this.endedAt,
      endReason: endReason ?? this.endReason,
    );
  }
}

/// Status of a sponsorship relationship
enum SponsorshipStatus {
  /// Request sent but not yet accepted
  pending,
  
  /// Active sponsorship relationship
  active,
  
  /// Sponsorship has been terminated
  ended,
}
