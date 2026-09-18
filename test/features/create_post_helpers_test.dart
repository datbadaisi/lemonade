import 'package:bluerum/core/network/lemmy_api_client.dart';
import 'package:bluerum/features/create_post/domain/create_post_helpers.dart';
import 'package:bluerum/shared/widgets/media/upload_item.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  group('canCreatePost', () {
    test('requires non-empty title and community', () {
      expect(
        canCreatePost(
          title: '',
          hasCommunity: true,
          isPosting: false,
          uploads: const [],
        ),
        isFalse,
      );
      expect(
        canCreatePost(
          title: 'Hello',
          hasCommunity: false,
          isPosting: false,
          uploads: const [],
        ),
        isFalse,
      );
      expect(
        canCreatePost(
          title: 'Hello',
          hasCommunity: true,
          isPosting: false,
          uploads: const [],
        ),
        isTrue,
      );
    });

    test('blocks while posting or while media uploading / failed', () {
      final uploading = UploadItem(
        file: XFile('a.jpg', mimeType: 'image/jpeg'),
        isUploading: true,
      );
      final failed = UploadItem(
        file: XFile('b.jpg', mimeType: 'image/jpeg'),
        isUploading: false,
        error: 'fail',
      );
      expect(
        canCreatePost(
          title: 'Hello',
          hasCommunity: true,
          isPosting: true,
          uploads: const [],
        ),
        isFalse,
      );
      expect(
        canCreatePost(
          title: 'Hello',
          hasCommunity: true,
          isPosting: false,
          uploads: [uploading],
        ),
        isFalse,
      );
      expect(
        canCreatePost(
          title: 'Hello',
          hasCommunity: true,
          isPosting: false,
          uploads: [failed],
        ),
        isFalse,
      );
    });

    test('rejects titles over the Lemmy soft limit', () {
      final long = 'a' * (kPostTitleMaxLength + 1);
      expect(
        canCreatePost(
          title: long,
          hasCommunity: true,
          isPosting: false,
          uploads: const [],
        ),
        isFalse,
      );
    });
  });

  group('crossPostUrl', () {
    test('prefers original post url when present', () {
      expect(
        crossPostUrl(
          url: 'https://example.com/article',
          apId: 'https://lemmy.example/post/1',
        ),
        'https://example.com/article',
      );
    });

    test('falls back to ap_id for text posts without url', () {
      expect(
        crossPostUrl(url: null, apId: 'https://lemmy.example/post/1'),
        'https://lemmy.example/post/1',
      );
      expect(
        crossPostUrl(url: '  ', apId: 'https://lemmy.example/post/2'),
        'https://lemmy.example/post/2',
      );
    });
  });

  group('assemblePostBody', () {
    test(
      'appends successful image and video embeds from UploadItem metadata',
      () {
        final image = UploadItem(
          file: XFile('photo.jpg', mimeType: 'image/jpeg'),
          isUploading: false,
          url: 'https://example.com/pictrs/image/abc',
        );
        final video = UploadItem(
          file: XFile('clip.mp4', mimeType: 'video/mp4'),
          isUploading: false,
          url: 'https://example.com/pictrs/image/noext',
        );
        final failed = UploadItem(
          file: XFile('x.jpg', mimeType: 'image/jpeg'),
          isUploading: false,
          error: 'nope',
        );

        final body = assemblePostBody(
          rawBody: 'Hello [world](https://w.test)',
          uploads: [image, video, failed],
        );

        expect(
          body,
          'Hello [world](https://w.test)\n\n'
          '![image](https://example.com/pictrs/image/abc)\n\n'
          '![video](https://example.com/pictrs/image/noext)',
        );
      },
    );

    test('media-only body when raw text empty', () {
      final image = UploadItem(
        file: XFile('photo.jpg', mimeType: 'image/jpeg'),
        isUploading: false,
        url: 'https://cdn.test/a.jpg',
      );
      expect(
        assemblePostBody(rawBody: '  ', uploads: [image]),
        '![image](https://cdn.test/a.jpg)',
      );
    });
  });

  group('normalizePostUrl', () {
    test('returns null for empty and adds https scheme', () {
      expect(normalizePostUrl(null), isNull);
      expect(normalizePostUrl('  '), isNull);
      expect(normalizePostUrl('example.com'), 'https://example.com');
      expect(normalizePostUrl('https://a.com'), 'https://a.com');
    });
  });

  group('formatCreatePostError', () {
    test('unwraps LemmyApiException message', () {
      expect(
        formatCreatePostError(LemmyApiException('community_not_found')),
        'community_not_found',
      );
    });

    test('maps connection failures', () {
      expect(
        formatCreatePostError(Exception('SocketException: failed')),
        contains('Connection failed'),
      );
    });
  });

  group('UploadItem.isVideo', () {
    test('detects video via mime even when url has no extension', () {
      final item = UploadItem(
        file: XFile('clip.mp4', mimeType: 'video/mp4'),
        url: 'https://example.com/pictrs/image/hashonly',
        isUploading: false,
      );
      expect(item.isVideo, isTrue);
      expect(item.isSuccessful, isTrue);
    });
  });

  group('UploadItem.remote', () {
    test('is successful without re-upload and marks video by flag/name', () {
      final image = UploadItem.remote(url: 'https://cdn.test/a.jpg');
      expect(image.isRemote, isTrue);
      expect(image.isSuccessful, isTrue);
      expect(image.isVideo, isFalse);

      final video = UploadItem.remote(
        url: 'https://cdn.test/v.mp4',
        isVideo: true,
      );
      expect(video.isVideo, isTrue);
      expect(video.isSuccessful, isTrue);
    });
  });

  test('UploadItem cancellation aborts its registered transport', () {
    var aborted = false;
    final item = UploadItem(file: XFile('photo.jpg'));
    item.attachCancellation(() => aborted = true);
    item.cancel();
    expect(aborted, isTrue);
    expect(item.isSuccessful, isFalse);
  });

  group('splitPostBodyForEdit', () {
    test('returns empty for null/blank body', () {
      expect(splitPostBodyForEdit(null).text, isEmpty);
      expect(splitPostBodyForEdit(null).media, isEmpty);
      expect(splitPostBodyForEdit('').media, isEmpty);
    });

    test('keeps plain text and extracts image/video embeds', () {
      const body =
          'Hello [docs](https://d.test)\n\n'
          '![image](https://cdn.test/a.jpg)\n\n'
          'More text\n\n'
          '![video](https://cdn.test/v.mp4)';

      final split = splitPostBodyForEdit(body);
      expect(split.text, 'Hello [docs](https://d.test)\n\nMore text');
      expect(split.media, hasLength(2));
      expect(split.media[0].url, 'https://cdn.test/a.jpg');
      expect(split.media[0].isVideo, isFalse);
      expect(split.media[1].url, 'https://cdn.test/v.mp4');
      expect(split.media[1].isVideo, isTrue);
    });

    test('round-trips with assemblePostBody for create-style posts', () {
      final image = UploadItem.remote(url: 'https://cdn.test/a.jpg');
      final video = UploadItem.remote(
        url: 'https://cdn.test/v.mp4',
        isVideo: true,
      );
      final assembled = assemblePostBody(
        rawBody: 'Caption here',
        uploads: [image, video],
      );
      final split = splitPostBodyForEdit(assembled);
      expect(split.text, 'Caption here');
      expect(split.media.map((m) => m.url).toList(), [
        'https://cdn.test/a.jpg',
        'https://cdn.test/v.mp4',
      ]);
      expect(
        assemblePostBody(
          rawBody: split.text,
          uploads: split.media.map(
            (m) => UploadItem.remote(url: m.url, isVideo: m.isVideo),
          ),
        ),
        assembled,
      );
    });

    test('dedupes repeated embed urls', () {
      const body =
          '![image](https://cdn.test/a.jpg)\n![image](https://cdn.test/a.jpg)';
      final split = splitPostBodyForEdit(body);
      expect(split.media, hasLength(1));
    });
  });

  group('sameUploadUrls', () {
    test('compares successful urls in order', () {
      final media = [
        const SplitBodyMedia(url: 'https://a.test/1.jpg', isVideo: false),
        const SplitBodyMedia(url: 'https://a.test/2.mp4', isVideo: true),
      ];
      expect(
        sameUploadUrls([
          UploadItem.remote(url: 'https://a.test/1.jpg'),
          UploadItem.remote(url: 'https://a.test/2.mp4', isVideo: true),
        ], media),
        isTrue,
      );
      expect(
        sameUploadUrls([UploadItem.remote(url: 'https://a.test/1.jpg')], media),
        isFalse,
      );
    });
  });
}
