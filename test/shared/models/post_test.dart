import 'package:bluerum/shared/models/post.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Post preserves Lemmy coercions and keeps image proxy URLs', () {
    const proxyUrl =
        'https://lemmy.zip/api/v3/image_proxy?url=https%3A%2F%2Fcdn.example%2Fa.png';
    final post = Post.fromJson(const {
      'id': '42',
      'name': 'Test post',
      'creator_id': '7',
      'community_id': 8.0,
      'language_id': '3',
      'url': proxyUrl,
      'thumbnail_url': proxyUrl,
      'url_content_type': 'image/png',
    });

    expect(post.id, 42);
    expect(post.creatorId, 7);
    expect(post.communityId, 8);
    expect(post.languageId, 3);
    // Keep image_proxy so the home instance can serve blocked origins.
    expect(post.url, proxyUrl);
    expect(post.thumbnailUrl, proxyUrl);
    expect(post.urlContentType, 'image/png');
    expect(post.local, isTrue);
  });
}
