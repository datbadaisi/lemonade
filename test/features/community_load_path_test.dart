import 'package:bluerum/features/community/domain/community_repository.dart';
import 'package:bluerum/features/community/domain/load_community.dart';
import 'package:bluerum/shared/models/post.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('loadCommunity drives CommunityRepository.get (UI entry)', () async {
    final repo = _RecordingCommunityRepo();
    final view = await loadCommunity(repo, name: 'tech');
    expect(repo.lastName, 'tech');
    expect(repo.lastId, isNull);
    expect(view.community.name, 'tech');
  });
}

final class _RecordingCommunityRepo implements CommunityRepository {
  int? lastId;
  String? lastName;

  @override
  Future<CommunityView> get({int? id, String? name}) async {
    lastId = id;
    lastName = name;
    return CommunityView(
      community: Community(id: 1, name: name ?? '', title: name ?? ''),
      subscribed: 'NotSubscribed',
      blocked: false,
      counts: CommunityAggregates(
        communityId: 1,
        subscribers: 0,
        posts: 0,
        comments: 0,
        published: '',
        usersActiveDay: 0,
        usersActiveWeek: 0,
        usersActiveMonth: 0,
        usersActiveHalfYear: 0,
        subscribersLocal: 0,
      ),
      bannedFromCommunity: false,
    );
  }

  @override
  Future<CommunityView> follow({
    required int communityId,
    required bool follow,
  }) => throw UnimplementedError();

  @override
  Future<bool> block({required int communityId, required bool block}) =>
      throw UnimplementedError();
}
