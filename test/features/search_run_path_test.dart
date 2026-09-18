import 'package:bluerum/features/search/domain/run_search.dart';
import 'package:bluerum/features/search/domain/search_repository.dart';
import 'package:bluerum/shared/models/search.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('runSearch drives SearchRepository.search (UI entry)', () async {
    final repo = _RecordingSearchRepo();
    final result = await runSearch(
      repo,
      query: 'lemmy',
      type: 'Posts',
      sort: 'New',
      listingType: 'Local',
      communityId: 3,
      page: 2,
      limit: 10,
    );
    expect(repo.lastQuery, 'lemmy');
    expect(repo.lastType, 'Posts');
    expect(repo.lastSort, 'New');
    expect(repo.lastListing, 'Local');
    expect(repo.lastCommunityId, 3);
    expect(repo.lastPage, 2);
    expect(repo.lastLimit, 10);
    expect(result.type, 'Posts');
  });
}

final class _RecordingSearchRepo implements SearchRepository {
  String? lastQuery;
  String? lastType;
  String? lastSort;
  String? lastListing;
  int? lastCommunityId;
  int? lastPage;
  int? lastLimit;

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
    lastSort = sort;
    lastListing = listingType;
    lastCommunityId = communityId;
    lastPage = page;
    lastLimit = limit;
    return SearchResult(type: type);
  }
}
