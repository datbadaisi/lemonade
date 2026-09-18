import 'package:bluerum/shared/models/search.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('SearchResult preserves Lemmy type_ and empty collections', () {
    final result = SearchResult.fromJson(const {
      'type_': 'Posts',
      'posts': [],
      'comments': [],
      'communities': [],
      'users': [],
    });

    expect(result.type, 'Posts');
    expect(result.posts, isEmpty);
    expect(result.comments, isEmpty);
    expect(result.communities, isEmpty);
    expect(result.users, isEmpty);
  });
}
