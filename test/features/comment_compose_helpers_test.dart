import 'package:bluerum/features/comment/domain/comment_compose_helpers.dart';
import 'package:bluerum/features/create_post/domain/create_post_helpers.dart';
import 'package:bluerum/shared/widgets/media/upload_item.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  group('canSubmitComment', () {
    test('requires non-empty content', () {
      expect(
        canSubmitComment(
          rawBody: '',
          isPosting: false,
          uploads: const [],
        ),
        isFalse,
      );
      expect(
        canSubmitComment(
          rawBody: 'hello',
          isPosting: false,
          uploads: const [],
        ),
        isTrue,
      );
    });

    test('allows media-only comments', () {
      final image = UploadItem(
        file: XFile('a.jpg', mimeType: 'image/jpeg'),
        isUploading: false,
        url: 'https://cdn.test/a.jpg',
      );
      expect(
        canSubmitComment(
          rawBody: '',
          isPosting: false,
          uploads: [image],
        ),
        isTrue,
      );
    });

    test('blocks while posting / uploading / failed media', () {
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
        canSubmitComment(
          rawBody: 'x',
          isPosting: true,
          uploads: const [],
        ),
        isFalse,
      );
      expect(
        canSubmitComment(
          rawBody: 'x',
          isPosting: false,
          uploads: [uploading],
        ),
        isFalse,
      );
      expect(
        canSubmitComment(
          rawBody: 'x',
          isPosting: false,
          uploads: [failed],
        ),
        isFalse,
      );
    });
  });

  group('isCommentEditUnchanged', () {
    test('compares raw markdown not display text', () {
      const original = 'See [docs](https://example.com) please';
      // After setRawText, display is "See docs please" but rawText restores links.
      expect(
        isCommentEditUnchanged(
          editorRawText: original,
          originalContent: original,
        ),
        isTrue,
      );
      expect(
        isCommentEditUnchanged(
          editorRawText: 'See docs please',
          originalContent: original,
        ),
        isFalse,
      );
      expect(
        isCommentEditUnchanged(
          editorRawText: 'See [docs](https://example.com) please!',
          originalContent: original,
        ),
        isFalse,
      );
    });

    test('trims whitespace', () {
      expect(
        isCommentEditUnchanged(
          editorRawText: '  hello  ',
          originalContent: 'hello',
        ),
        isTrue,
      );
    });

    test('splits media embeds — text + tray must both match', () {
      const original = 'Nice shot\n\n![image](https://cdn.test/a.jpg)';
      final media = [UploadItem.remote(url: 'https://cdn.test/a.jpg')];

      expect(
        isCommentEditUnchanged(
          editorRawText: 'Nice shot',
          originalContent: original,
          uploads: media,
        ),
        isTrue,
      );
      // Editor still has raw embed → treated as text change.
      expect(
        isCommentEditUnchanged(
          editorRawText: original,
          originalContent: original,
          uploads: media,
        ),
        isFalse,
      );
      // Media removed from tray.
      expect(
        isCommentEditUnchanged(
          editorRawText: 'Nice shot',
          originalContent: original,
          uploads: const [],
        ),
        isFalse,
      );
    });
  });

  group('assemblePostBody for comments', () {
    test('embeds video by mime even without url extension', () {
      final video = UploadItem(
        file: XFile('clip.mp4', mimeType: 'video/mp4'),
        isUploading: false,
        url: 'https://example.com/pictrs/image/hash',
      );
      final body = assemblePostBody(rawBody: 'hi', uploads: [video]);
      expect(body, contains('![video](https://example.com/pictrs/image/hash)'));
    });
  });
}
