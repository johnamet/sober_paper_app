import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/entities/sponsorship.dart';

/// Model for Sponsorship with JSON serialization
class SponsorshipModel {
  final Sponsorship sponsorship;

  const SponsorshipModel(this.sponsorship);

  /// Convert from Firestore document
  factory SponsorshipModel.fromJson(Map<String, dynamic> json) {
    return SponsorshipModel(
      Sponsorship(
        id: json['id'] as String,
        sponsorId: json['sponsorId'] as String,
        sponsoredUserId: json['sponsoredUserId'] as String,
        requestedAt: (json['requestedAt'] as Timestamp).toDate(),
        acceptedAt: json['acceptedAt'] != null
            ? (json['acceptedAt'] as Timestamp).toDate()
            : null,
        status: _statusFromString(json['status'] as String),
        endedAt: json['endedAt'] != null
            ? (json['endedAt'] as Timestamp).toDate()
            : null,
        endReason: json['endReason'] as String?,
      ),
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toJson() {
    return {
      'id': sponsorship.id,
      'sponsorId': sponsorship.sponsorId,
      'sponsoredUserId': sponsorship.sponsoredUserId,
      'requestedAt': Timestamp.fromDate(sponsorship.requestedAt),
      'acceptedAt': sponsorship.acceptedAt != null
          ? Timestamp.fromDate(sponsorship.acceptedAt!)
          : null,
      'status': sponsorship.status.name,
      'endedAt': sponsorship.endedAt != null
          ? Timestamp.fromDate(sponsorship.endedAt!)
          : null,
      'endReason': sponsorship.endReason,
    };
  }

  static SponsorshipStatus _statusFromString(String status) {
    switch (status) {
      case 'pending':
        return SponsorshipStatus.pending;
      case 'active':
        return SponsorshipStatus.active;
      case 'ended':
        return SponsorshipStatus.ended;
      default:
        return SponsorshipStatus.pending;
    }
  }
}
