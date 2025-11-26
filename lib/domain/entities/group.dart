/// Support or discussion group for community interaction
class Group {
  final String id;
  final String name;
  final String description;
  final String createdBy;
  final DateTime createdAt;
  final List<String> memberIds;
  final int memberCount;
  final bool isPrivate;
  final int maxMembers;
  final GroupCategory category;

  const Group({
    required this.id,
    required this.name,
    required this.description,
    required this.createdBy,
    required this.createdAt,
    required this.memberIds,
    required this.memberCount,
    this.isPrivate = false,
    this.maxMembers = 50,
    required this.category,
  });

  /// Check if group has reached maximum capacity
  bool get isFull => memberCount >= maxMembers;

  /// Check if a specific user is a member
  bool isMember(String userId) => memberIds.contains(userId);

  /// Calculate available slots in the group
  int get availableSlots => maxMembers - memberCount;

  Group copyWith({
    String? id,
    String? name,
    String? description,
    String? createdBy,
    DateTime? createdAt,
    List<String>? memberIds,
    int? memberCount,
    bool? isPrivate,
    int? maxMembers,
    GroupCategory? category,
  }) {
    return Group(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      memberIds: memberIds ?? this.memberIds,
      memberCount: memberCount ?? this.memberCount,
      isPrivate: isPrivate ?? this.isPrivate,
      maxMembers: maxMembers ?? this.maxMembers,
      category: category ?? this.category,
    );
  }
}

/// Category/type of group
enum GroupCategory {
  /// General support group
  support,
  
  /// Prayer and spiritual focus
  prayer,
  
  /// General discussion
  discussion,
}
