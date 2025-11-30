import '../../entities/group.dart';
import '../../../data/repositories/community_repository.dart';

class GetUserGroups {
  final CommunityRepository _communityRepository;

  GetUserGroups(this._communityRepository);

  Future<List<Group>> call(String userId) async {
    if (userId.isEmpty) {
      throw ArgumentError('User ID is required');
    }

    return await _communityRepository.getUserGroups(userId);
  }
}
