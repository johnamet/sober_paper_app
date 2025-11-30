import '../../entities/group.dart';
import '../../../data/repositories/community_repository.dart';

class GetGroup {
  final CommunityRepository _communityRepository;

  GetGroup(this._communityRepository);

  Future<Group?> call(String groupId) async {
    if (groupId.isEmpty) {
      throw ArgumentError('Group ID is required');
    }

    return await _communityRepository.getGroup(groupId);
  }
}
