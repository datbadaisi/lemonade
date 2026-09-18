import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bluerum/app/providers.dart';
import 'package:bluerum/core/network/lemmy_api_client.dart';
import 'package:bluerum/shared/models/search.dart';
import '../domain/search_repository.dart';

final searchRepositoryProvider = Provider<SearchRepository>(
  (ref) => LemmySearchRepository(ref.watch(lemmyApiClientProvider)),
);

final class LemmySearchRepository implements SearchRepository {
  const LemmySearchRepository(this._client);

  final LemmyApiService _client;

  @override
  Future<SearchResult> search({
    required String query,
    required String type,
    required String sort,
    required String listingType,
    int? communityId,
    int page = 1,
    int limit = 20,
  }) => _client.search(
    query: query,
    type: type,
    sort: sort,
    listingType: listingType,
    communityId: communityId,
    page: page,
    limit: limit,
  );
}
