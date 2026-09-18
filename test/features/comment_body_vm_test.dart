import 'package:bluerum/features/post/presentation/comment_body_vm.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CommentBodyVm', () {
    test('plain short comment skips rich path and AST', () {
      final vm = CommentBodyVm.fromContent(
        commentId: 1,
        content: 'Just a short reply',
      );
      expect(vm.needsRich, isFalse);
      expect(vm.paintKind, CommentBodyPaintKind.plain);
      expect(vm.listPlain, 'Just a short reply');
      expect(vm.hasMedia, isFalse);
      expect(vm.media, isEmpty);
    });

    test('bare URL is linksOnly not fullRich', () {
      final vm = CommentBodyVm.fromContent(
        commentId: 2,
        content: 'See https://example.com for more',
      );
      expect(vm.paintKind, CommentBodyPaintKind.linksOnly);
      expect(vm.linkSegments.any((s) => s.isLink), isTrue);
      expect(
        vm.linkSegments.where((s) => s.isLink).first.href,
        'https://example.com',
      );
    });

    test('markdown link is fullRich (not raw linksOnly segments)', () {
      final vm = CommentBodyVm.fromContent(
        commentId: 21,
        content: 'Read [docs](https://example.com/docs) please',
      );
      expect(vm.paintKind, CommentBodyPaintKind.fullRich);
      expect(vm.markdownSource.contains('[docs]'), isTrue);
      expect(vm.listPlain.contains('docs'), isTrue);
      expect(vm.listPlain.contains(']('), isFalse);
      expect(vm.linkSegments, isEmpty);
    });

    test('relative markdown link is fullRich not raw plain', () {
      final vm = CommentBodyVm.fromContent(
        commentId: 210,
        content: 'See [community](/c/til) please',
      );
      expect(vm.paintKind, CommentBodyPaintKind.fullRich);
      expect(vm.listPlain.contains('community'), isTrue);
      expect(vm.listPlain.contains(']('), isFalse);
    });

    test('spoiler fence is fullRich with interactive source kept', () {
      const body = '''
Before
::: spoiler Secret Title
hidden stuff
:::
After''';
      final vm = CommentBodyVm.fromContent(commentId: 211, content: body);
      expect(vm.paintKind, CommentBodyPaintKind.fullRich);
      expect(vm.markdownSource.contains(':::'), isTrue);
      expect(vm.markdownSource.toLowerCase().contains('spoiler'), isTrue);
      // listPlain collapses for height estimates only — paint uses markdownSource.
      expect(vm.listPlain.contains('Secret Title'), isTrue);
      expect(vm.listPlain.contains(':::'), isFalse);
    });

    test('strikethrough marks fullRich', () {
      final vm = CommentBodyVm.fromContent(
        commentId: 212,
        content: 'This is ~~gone~~ now',
      );
      expect(vm.paintKind, CommentBodyPaintKind.fullRich);
    });

    test('bold marks fullRich', () {
      final vm = CommentBodyVm.fromContent(
        commentId: 22,
        content: 'See **docs** at https://example.com',
      );
      expect(vm.paintKind, CommentBodyPaintKind.fullRich);
      expect(vm.listPlain.contains('docs'), isTrue);
      expect(vm.listPlain.contains('**'), isFalse);
      expect(vm.markdownSource.contains('**docs**'), isTrue);
    });

    test('image markdown extracted and stripped from markdown source', () {
      const body =
          'Hello\n\n![pic](https://cdn.example.com/a.png)\n\nMore text';
      final vm = CommentBodyVm.fromContent(commentId: 3, content: body);
      expect(vm.hasMedia, isTrue);
      expect(vm.media.length, 1);
      expect(vm.media.first.url, 'https://cdn.example.com/a.png');
      expect(vm.markdownSource.contains('![pic]'), isFalse);
      expect(vm.listPlain.toLowerCase().contains('hello'), isTrue);
    });

    test('empty content is stable empty vm', () {
      final vm = CommentBodyVm.fromContent(commentId: 4, content: '');
      expect(vm.hasText, isFalse);
      expect(vm.needsRich, isFalse);
      expect(vm.paintKind, CommentBodyPaintKind.plain);
      expect(vm.listPlain, isEmpty);
    });

    test('estimateListHeight grows with text and media', () {
      final plain = CommentBodyVm.fromContent(
        commentId: 5,
        content: 'Hi',
      );
      final withMedia = CommentBodyVm.fromContent(
        commentId: 6,
        content: 'Hi\n\n![x](https://cdn.example.com/a.png)',
      );
      final hPlain = plain.estimateListHeight(contentWidth: 360);
      final hMedia = withMedia.estimateListHeight(contentWidth: 360);
      expect(hMedia, greaterThan(hPlain));
    });
  });

  group('CommentBodyVmStore', () {
    test('obtain caches by content version', () {
      final store = CommentBodyVmStore();
      final a = store.obtain(commentId: 10, content: 'Hello');
      final b = store.obtain(commentId: 10, content: 'Hello');
      expect(identical(a, b), isTrue);
      expect(store.length, 1);

      final c = store.obtain(commentId: 10, content: 'Hello edited');
      expect(identical(a, c), isFalse);
      expect(store.length, 1);
      expect(c.listPlain, 'Hello edited');
    });

    test('prepareAll is idempotent', () {
      final store = CommentBodyVmStore();
      store.prepareAll([
        (id: 1, content: 'a'),
        (id: 2, content: '**b**'),
      ]);
      store.prepareAll([
        (id: 1, content: 'a'),
        (id: 2, content: '**b**'),
      ]);
      expect(store.length, 2);
      expect(store.peek(2)?.paintKind, CommentBodyPaintKind.fullRich);
    });

    test('retainIds drops stale comments', () {
      final store = CommentBodyVmStore();
      store.obtain(commentId: 1, content: 'a');
      store.obtain(commentId: 2, content: 'b');
      store.retainIds({1});
      expect(store.peek(1), isNotNull);
      expect(store.peek(2), isNull);
      expect(store.length, 1);
    });
  });

  group('buildLinkSegments', () {
    test('splits plain and bare url', () {
      final segs = CommentBodyVm.buildLinkSegments('go https://a.com now');
      expect(segs.length, 3);
      expect(segs[0].text, 'go ');
      expect(segs[1].isLink, isTrue);
      expect(segs[2].text, ' now');
    });
  });
}
