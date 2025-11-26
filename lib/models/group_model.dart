import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/entities/group.dart';

/// Model for Group with JSON serialization
class GroupModel {
  final Group group;

  const GroupModel(this.group);

  /// Convert from Firestore document
  factory GroupModel.fromJson(Map<String, dynamic> json) {
    return GroupModel(
      Group(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String,
        createdBy: json['createdBy'] as String,
        createdAt: (json['createdAt'] as Timestamp).toDate(),
        memberIds: List<String>.from(json['memberIds'] as List),
        memberCount: json['memberCount'] as int,
        isPrivate: json['isPrivate'] as bool? ?? false,
        maxMembers: json['maxMembers'] as int? ?? 50,
        category: _categoryFromString(json['category'] as String),
      ),
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toJson() {
    return {
      'id': group.id,
      'name': group.name,
      'description': group.description,
      'createdBy': group.createdBy,
      'createdAt': Timestamp.fromDate(group.createdAt),
      'memberIds': group.memberIds,
      'memberCount': group.memberCount,
      'isPrivate': group.isPrivate,
      'maxMembers': group.maxMembers,
      'category': group.category.name,
    };
  }

  static GroupCategory _categoryFromString(String category) {
    switch (category) {
      case 'support':
        return GroupCategory.support;
      case 'prayer':
        return GroupCategory.prayer;
      case 'discussion':
        return GroupCategory.discussion;
      default:
        return GroupCategory.support;
    }
  }
}
