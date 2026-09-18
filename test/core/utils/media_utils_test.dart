import 'package:bluerum/core/utils/media_utils.dart';
import 'package:bluerum/shared/models/post.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('isImageUrl', () {
    test('detects direct image paths', () {
      expect(isImageUrl('https://cdn.example/a.png'), isTrue);
      expect(isImageUrl('https://cdn.example/a.AVIF'), isTrue);
      expect(isImageUrl('https://cdn.example/page'), isFalse);
    });

    test('detects Lemmy image_proxy targets by nested url', () {
      const proxy =
          'https://lemmy.zip/api/v3/image_proxy?url=https%3A%2F%2Fpawb.social%2Fpictrs%2Fimage%2F3d3bd22f.png';
      expect(isImageUrl(proxy), isTrue);
    });
  });

  group('MediaItem / extractPostMedia', () {
    test('recognizes a pict-rs video by the persisted markdown marker', () {
      final media = extractMarkdownMedia(
        '![video](https://lemmy.example/pictrs/image/opaque-file-id)',
      );
      expect(media, hasLength(1));
      expect(media.single.type, MediaType.video);
      expect(media.single.videoType, VideoType.native);
    });

    test('recognizes supported YouTube URLs and derives a thumbnail', () {
      const url = 'https://youtu.be/dQw4w9WgXcQ';
      expect(isYouTubeUrl(url), isTrue);
      expect(
        getYouTubeThumbnail(url),
        'https://i.ytimg.com/vi/dQw4w9WgXcQ/hqdefault.jpg',
      );
    });

    test('rejects insecure and private-network media URLs', () {
      expect(isSafeNetworkMediaUrl('http://cdn.example/a.jpg'), isFalse);
      expect(isSafeNetworkMediaUrl('https://127.0.0.1/a.jpg'), isFalse);
      expect(isSafeNetworkMediaUrl('https://cdn.example/a.jpg'), isTrue);
    });

    test('keeps image_proxy load URLs (does not unwrap origin)', () {
      const proxy =
          'https://lemmy.zip/api/v3/image_proxy?url=https%3A%2F%2Fpawb.social%2Fpictrs%2Fimage%2F3d3bd22f.png';
      final item = MediaItem(url: proxy, type: MediaType.image);
      expect(item.url, proxy);
      expect(item.rawUrl, proxy);
    });

    test('treats url_content_type image/* as image media', () {
      const proxy =
          'https://lemmy.zip/api/v3/image_proxy?url=https%3A%2F%2Fpawb.social%2Fpictrs%2Fimage%2F3d3bd22f.png';
      final postView = PostView.fromJson({
        'post': {
          'id': 67082316,
          'name': 'No survivors',
          'url': proxy,
          'thumbnail_url': proxy,
          'url_content_type': 'image/png',
          'creator_id': 1,
          'community_id': 1,
          'published': '2026-06-30T15:30:06.226257Z',
          'ap_id': 'https://pawb.social/post/1',
        },
        'creator': {
          'id': 1,
          'name': 'ollie',
          'published': '2025-12-21T09:03:48.339104Z',
          'actor_id': 'https://pawb.social/u/ollie',
          'instance_id': 1,
        },
        'community': {
          'id': 1,
          'name': 'memes',
          'title': 'memes',
          'published': '2023-06-09T20:46:50.500025Z',
          'actor_id': 'https://lemmy.world/c/memes',
          'instance_id': 1,
        },
        'counts': {
          'post_id': 67082316,
          'comments': 0,
          'score': 0,
          'upvotes': 0,
          'downvotes': 0,
          'published': '2026-06-30T15:30:06.226257Z',
        },
      });

      final media = extractPostMedia(postView);
      expect(media, isNotEmpty);
      expect(media.first.type, MediaType.image);
      // No resize query on nested origin → keep proxy primary, origin fallback.
      expect(media.first.url, proxy);
      expect(
        media.first.fallbackUrl,
        'https://pawb.social/pictrs/image/3d3bd22f.png',
      );
    });
  });

  group('stripMarkdownMedia / proxy-origin dedupe', () {
    test('does not list body image twice when post.url is image_proxy', () {
      const proxy =
          'https://lemmy.zip/api/v3/image_proxy?url=https%3A%2F%2Fpawb.social%2Fpictrs%2Fimage%2Fabc.png';
      const origin = 'https://pawb.social/pictrs/image/abc.png';
      final postView = PostView.fromJson({
        'post': {
          'id': 1,
          'name': 'Pic',
          'url': proxy,
          'body': 'Hello\n\n![]($proxy)\n\nworld',
          'url_content_type': 'image/png',
          'creator_id': 1,
          'community_id': 1,
          'published': '2026-06-30T15:30:06.226257Z',
          'ap_id': 'https://pawb.social/post/1',
        },
        'creator': {
          'id': 1,
          'name': 'u',
          'published': '2025-12-21T09:03:48.339104Z',
          'actor_id': 'https://pawb.social/u/u',
          'instance_id': 1,
        },
        'community': {
          'id': 1,
          'name': 'c',
          'title': 'c',
          'published': '2023-06-09T20:46:50.500025Z',
          'actor_id': 'https://lemmy.world/c/c',
          'instance_id': 1,
        },
        'counts': {
          'post_id': 1,
          'comments': 0,
          'score': 0,
          'upvotes': 0,
          'downvotes': 0,
          'published': '2026-06-30T15:30:06.226257Z',
        },
      });

      final media = extractPostMedia(postView);
      expect(media, hasLength(1));
      expect(media.single.type, MediaType.image);

      final stripped = stripMarkdownMedia(postView.post.body!, media);
      expect(stripped, 'Hello\n\nworld');
      expect(stripped.contains('!['), isFalse);
      // load URL may be proxy or origin; body embed must still be stripped
      expect(
        mediaUrlDedupeKey(media.single.url),
        mediaUrlDedupeKey(origin),
      );
    });

    test('strips body markdown when load URL is origin and body has proxy', () {
      const proxy =
          'https://lemmy.zip/api/v3/image_proxy?url=https%3A%2F%2Fcdn.example%2Fpic.jpg%3Fw%3D1200';
      final media = [
        MediaItem(
          url:
              'https://cdn.example/pic.jpg?w=1200',
          type: MediaType.image,
          fallbackUrl: proxy,
        ),
      ];
      const body = 'Caption\n\n![]($proxy)';
      expect(stripMarkdownMedia(body, media), 'Caption');
    });
  });

  group('resolveMediaLoadUrls', () {
    test('prefers origin when nested URL has CDN resize params', () {
      const proxy =
          'https://lemmy.zip/api/v3/image_proxy?url=https%3A%2F%2Ftheintercept.com%2Fwp-content%2Fuploads%2F2026%2F07%2Fphoto.jpg%3Ffit%3D4812%252C2402%26w%3D1200%26h%3D800';
      final resolved = resolveMediaLoadUrls(proxy);
      expect(
        resolved.url,
        'https://theintercept.com/wp-content/uploads/2026/07/photo.jpg?fit=4812%2C2402&w=1200&h=800',
      );
      expect(resolved.fallbackUrl, proxy);
    });

    test('keeps proxy first when nested origin has no resize params', () {
      const proxy =
          'https://lemmy.zip/api/v3/image_proxy?url=https%3A%2F%2Fcdn.mos.cms.futurecdn.net%2F77phirBmFdjwgvvZh2Pr8Q-1920-80.png';
      final resolved = resolveMediaLoadUrls(proxy);
      expect(resolved.url, proxy);
      expect(
        resolved.fallbackUrl,
        'https://cdn.mos.cms.futurecdn.net/77phirBmFdjwgvvZh2Pr8Q-1920-80.png',
      );
    });

    test('extractPostMedia uses origin for external link thumbs with resize', () {
      const proxy =
          'https://lemmy.zip/api/v3/image_proxy?url=https%3A%2F%2Fstatic.independent.co.uk%2F2026%2F07%2F03%2F15%2Fphoto.JPG%3Fwidth%3D1200%26height%3D800';
      final postView = PostView.fromJson({
        'post': {
          'id': 67339772,
          'name': 'External link',
          'url':
              'https://www.independent.co.uk/news/world/americas/us-politics/example.html',
          'thumbnail_url': proxy,
          'url_content_type': 'text/html; charset=utf-8',
          'embed_title': 'External link',
          'creator_id': 1,
          'community_id': 1,
          'published': '2026-07-03T15:30:06.226257Z',
          'ap_id': 'https://lemmy.zip/post/67339772',
        },
        'creator': {
          'id': 1,
          'name': 'user',
          'published': '2025-12-21T09:03:48.339104Z',
          'actor_id': 'https://lemmy.zip/u/user',
          'instance_id': 1,
        },
        'community': {
          'id': 1,
          'name': 'news',
          'title': 'news',
          'published': '2023-06-09T20:46:50.500025Z',
          'actor_id': 'https://lemmy.zip/c/news',
          'instance_id': 1,
        },
        'counts': {
          'post_id': 67339772,
          'comments': 0,
          'score': 0,
          'upvotes': 0,
          'downvotes': 0,
          'published': '2026-07-03T15:30:06.226257Z',
        },
      });

      final media = extractPostMedia(postView);
      expect(media, hasLength(1));
      expect(media.first.type, MediaType.image);
      expect(
        media.first.url,
        'https://static.independent.co.uk/2026/07/03/15/photo.JPG?width=1200&height=800',
      );
      expect(media.first.fallbackUrl, proxy);
    });
  });
}
