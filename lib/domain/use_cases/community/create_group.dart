import '../../entities/group.dart';
import '../../../data/repositories/community_repository.dart';

class CreateGroup {
  final CommunityRepository _communityRepository;

  CreateGroup(this._communityRepository);

  Future<Group> call({
    required String name,
    required String description,
    required String createdBy,
    required GroupCategory category,
    bool isPrivate = false,
    int maxMembers = 50,
  }) async {
    if (name.isEmpty || createdBy.isEmpty) {
      throw ArgumentError('Name and creator ID are required');
    }

    if (name.length < 3) {
      throw ArgumentError('Group name must be at least 3 characters');
    }

    return await _communityRepository.createGroup(
      name: name,
      description: description,
      createdBy: createdBy,
      category: category,
      isPrivate: isPrivate,
      maxMembers: maxMembers,
    );
  }
}
