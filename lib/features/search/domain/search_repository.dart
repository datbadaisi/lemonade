import 'package:bluerum/shared/models/search.dart';

abstract interface class SearchRepository {
  Future<SearchResult> search({
    required String query,
    required String type,
    required String sort,
    required String listingType,
    int? communityId,
    int page,
    int limit,
  });
}
