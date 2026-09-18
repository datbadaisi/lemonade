import 'package:bluerum/features/ads/domain/ads_placement.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('feed placement (6 posts per ad)', () {
    const n = 6;

    test('no ads when disabled or empty', () {
      expect(
        feedItemCount(postCount: 12, postsPerAd: n, showAds: false),
        12,
      );
      expect(
        feedItemCount(postCount: 0, postsPerAd: n, showAds: true),
        0,
      );
      expect(
        isFeedAdAt(index: 5, postCount: 12, postsPerAd: n, showAds: false),
        isFalse,
      );
    });

    test('inserts ad after every 6 posts', () {
      // 6 posts → 7 items (ad at index 6)
      expect(feedItemCount(postCount: 6, postsPerAd: n, showAds: true), 7);
      expect(
        isFeedAdAt(index: 6, postCount: 6, postsPerAd: n, showAds: true),
        isTrue,
      );
      for (var i = 0; i < 6; i++) {
        expect(
          isFeedAdAt(index: i, postCount: 6, postsPerAd: n, showAds: true),
          isFalse,
        );
        expect(
          feedPostIndex(listIndex: i, postsPerAd: n, showAds: true),
          i,
        );
      }

      // 12 posts → 14 items, ads at 6 and 13
      expect(feedItemCount(postCount: 12, postsPerAd: n, showAds: true), 14);
      expect(
        isFeedAdAt(index: 6, postCount: 12, postsPerAd: n, showAds: true),
        isTrue,
      );
      expect(
        isFeedAdAt(index: 13, postCount: 12, postsPerAd: n, showAds: true),
        isTrue,
      );
      expect(
        feedPostIndex(listIndex: 7, postsPerAd: n, showAds: true),
        6,
      );
      expect(
        feedPostIndex(listIndex: 12, postsPerAd: n, showAds: true),
        11,
      );
    });

    test('fewer than N posts means zero ads', () {
      expect(feedItemCount(postCount: 5, postsPerAd: n, showAds: true), 5);
      for (var i = 0; i < 5; i++) {
        expect(
          isFeedAdAt(index: i, postCount: 5, postsPerAd: n, showAds: true),
          isFalse,
        );
      }
    });
  });

  group('comment display entries (9 roots per ad)', () {
    const rootsPerAd = 9;

    /// Flat list where every row is a root (depth 0).
    List<CommentDisplayEntry> allRoots(int count, {required bool showAds}) {
      return buildCommentDisplayEntries(
        rowCount: count,
        isRootAt: (_) => true,
        rootsPerAd: rootsPerAd,
        showAds: showAds,
      );
    }

    test('no ads when disabled or short thread', () {
      final off = allRoots(20, showAds: false);
      expect(off.length, 20);
      expect(off.every((e) => !e.isAd), isTrue);

      final short = allRoots(8, showAds: true);
      expect(short.length, 8);
      expect(short.every((e) => !e.isAd), isTrue);
    });

    test('ad after 9th root comment', () {
      final entries = allRoots(9, showAds: true);
      expect(entries.length, 10);
      expect(entries[8].isAd, isFalse);
      expect(entries[8].rowIndex, 8);
      expect(entries[9].isAd, isTrue);
      expect(entries[9].adSlot, 0);
    });

    test('inserts ad after full 9th root thread, not under its replies', () {
      // Pattern: root, reply, reply × 9 → roots at 0,3,6,...,24
      // 9th root at 24, replies at 25–26 → ad after 26 (end of thread).
      final depths = <int>[];
      for (var r = 0; r < 9; r++) {
        depths.add(0);
        depths.add(1);
        depths.add(1);
      }
      // Next root (10th) so we can assert ad sits between threads.
      depths
        ..add(0)
        ..add(1);

      final entries = buildCommentDisplayEntries(
        rowCount: depths.length,
        isRootAt: (i) => depths[i] == 0,
        rootsPerAd: rootsPerAd,
        showAds: true,
      );
      final ads = entries.where((e) => e.isAd).toList();
      expect(ads.length, 1);

      final adAt = entries.indexWhere((e) => e.isAd);
      // Last row of 9th thread is reply at 26.
      expect(entries[adAt - 1].rowIndex, 26);
      // Next item is 10th root at 27 — not a child of root 9.
      expect(entries[adAt + 1].rowIndex, 27);
      expect(entries[adAt + 1].isAd, isFalse);
      expect(entries.length, depths.length + 1);
    });

    test('ad after last root when it is the Nth and has no following root', () {
      // 9 roots, last has two replies — ad still after entire last thread.
      final depths = <int>[];
      for (var r = 0; r < 8; r++) {
        depths.add(0);
      }
      depths
        ..add(0)
        ..add(1)
        ..add(1);

      final entries = buildCommentDisplayEntries(
        rowCount: depths.length,
        isRootAt: (i) => depths[i] == 0,
        rootsPerAd: rootsPerAd,
        showAds: true,
      );
      expect(entries.last.isAd, isTrue);
      expect(entries[entries.length - 2].rowIndex, depths.length - 1);
    });
  });
}
