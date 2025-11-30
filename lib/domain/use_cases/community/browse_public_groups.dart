import '../../entities/group.dart';
import '../../../data/repositories/community_repository.dart';

class BrowsePublicGroups {
  final CommunityRepository _communityRepository;

  BrowsePublicGroups(this._communityRepository);

  Future<List<Group>> call({int limit = 20}) async {
    if (limit < 1 || limit > 100) {
      throw ArgumentError('Limit must be between 1 and 100');
    }

    return await _communityRepository.browsePublicGroups(limit: limit);
  }
}
