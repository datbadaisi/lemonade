import 'package:bluerum/features/search/domain/search_repository.dart';
import 'package:bluerum/shared/models/search.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('search repository forwards query and type', () async {
    final fake = _FakeSearchRepo();
    final result = await fake.search(
      query: 'lemmy',
      type: 'Posts',
      sort: 'TopAll',
      listingType: 'All',
    );
    expect(fake.lastQuery, 'lemmy');
    expect(fake.lastType, 'Posts');
    expect(result.posts, isEmpty);
  });
}

final class _FakeSearchRepo implements SearchRepository {
  String? lastQuery;
  String? lastType;

  @override
  Future<SearchResult> search({
    required String query,
    required String type,
    required String sort,
    required String listingType,
    int? communityId,
    int page = 1,
    int limit = 20,
  }) async {
    lastQuery = query;
    lastType = type;
    return SearchResult(type: type);
  }
}
