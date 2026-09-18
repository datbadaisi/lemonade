import 'package:bluerum/shared/models/search.dart';

import 'search_repository.dart';

/// Search entry used by Search presentation tabs.
Future<SearchResult> runSearch(
  SearchRepository repository, {
  required String query,
  required String type,
  required String sort,
  required String listingType,
  int? communityId,
  int page = 1,
  int limit = 20,
}) => repository.search(
  query: query,
  type: type,
  sort: sort,
  listingType: listingType,
  communityId: communityId,
  page: page,
  limit: limit,
);
