import 'package:bluerum/features/feed/presentation/feed_fidelity_upgrade.dart';
import 'package:bluerum/features/feed/presentation/feed_post_proxy_tile.dart';
import 'package:bluerum/features/feed/presentation/post_card_vm.dart';
import 'package:bluerum/shared/models/post.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FeedFidelityUpgradeQueue', () {
    tearDown(FeedFidelityUpgradeQueue.clear);

    testWidgets('runs at most maxPerFrame upgrades per frame', (tester) async {
      final ran = <int>[];
      for (var i = 0; i < 3; i++) {
        final id = i;
        FeedFidelityUpgradeQueue.enqueue(() => ran.add(id));
      }

      // maxPerFrame == 1: one full-card upgrade per frame.
      await tester.pump();
      expect(ran, [0]);

      await tester.pump();
      expect(ran, [0, 1]);

      await tester.pump();
      expect(ran, [0, 1, 2]);
    });

    testWidgets('clear drops pending upgrades', (tester) async {
      final ran = <int>[];
      FeedFidelityUpgradeQueue.enqueue(() => ran.add(1));
      FeedFidelityUpgradeQueue.enqueue(() => ran.add(2));
      FeedFidelityUpgradeQueue.clear();
      await tester.pump();
      await tester.pump();
      expect(ran, isEmpty);
    });
  });

  group('FeedPostProxyTile', () {
    testWidgets('lays out at given height without overflow', (tester) async {
      final vm = PostCardVm.fromPostView(
        PostView(
          post: Post(
            id: 42,
            name: 'Hello fling proxy title that is somewhat long',
            creatorId: 1,
            communityId: 2,
            published: '2020-01-01T00:00:00Z',
            body: 'body text that should not appear on proxy',
            url: 'https://example.com/pic.jpg',
            thumbnailUrl: 'https://example.com/pic.jpg',
          ),
          creator: const Person(id: 1, name: 'alice'),
          community: const Community(id: 2, name: 'news', title: 'News'),
          counts: const PostAggregates(postId: 42, comments: 3, score: 10),
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FeedPostProxyTile(
              vm: vm,
              height: vm.heightForContentWidth(360),
            ),
          ),
        ),
      );

      expect(find.textContaining('c/news'), findsOneWidget);
      expect(find.textContaining('u/alice'), findsOneWidget);
      expect(find.textContaining('Hello fling'), findsOneWidget);
      // Content-complete shell keeps body preview (no blank-out flicker).
      expect(find.textContaining('body text'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    test('estimatedHeight is positive for media posts', () {
      final vm = PostCardVm.fromPostView(
        PostView(
          post: Post(
            id: 1,
            name: 'T',
            creatorId: 1,
            communityId: 1,
            published: '2020-01-01T00:00:00Z',
            url: 'https://example.com/a.jpg',
          ),
          creator: const Person(id: 1, name: 'u'),
          community: const Community(id: 1, name: 'c', title: 'C'),
          counts: const PostAggregates(postId: 1, comments: 0, score: 0),
        ),
      );
      expect(vm.estimatedHeight, greaterThan(120));
      expect(vm.hasMedia, isTrue);
    });
  });
}
