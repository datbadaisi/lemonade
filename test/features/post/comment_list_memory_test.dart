import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bluerum/features/post/presentation/comment_list_memory.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CommentListMemoryPolicy', () {
    test('boostImageCache is refcounted across nested detail routes', () {
      CommentListMemoryPolicy.debugResetBoostDepth();
      addTearDown(CommentListMemoryPolicy.debugResetBoostDepth);

      final cache = PaintingBinding.instance.imageCache;
      expect(cache.maximumSize, CommentListMemoryPolicy.defaultImageCacheCount);

      CommentListMemoryPolicy.boostImageCache();
      expect(CommentListMemoryPolicy.debugBoostDepth, 1);
      expect(cache.maximumSize, CommentListMemoryPolicy.imageCacheCount);

      // Nested continue-thread / second detail must not thrash limits.
      CommentListMemoryPolicy.boostImageCache();
      expect(CommentListMemoryPolicy.debugBoostDepth, 2);
      expect(cache.maximumSize, CommentListMemoryPolicy.imageCacheCount);

      expect(CommentListMemoryPolicy.restoreImageCache(), isFalse);
      expect(CommentListMemoryPolicy.debugBoostDepth, 1);
      expect(cache.maximumSize, CommentListMemoryPolicy.imageCacheCount);

      expect(CommentListMemoryPolicy.restoreImageCache(), isTrue);
      expect(CommentListMemoryPolicy.debugBoostDepth, 0);
      expect(cache.maximumSize, CommentListMemoryPolicy.defaultImageCacheCount);
    });

    test(
      'LRU keeps recent ids within budget and prefers dropping non-media',
      () {
        final policy = CommentListMemoryPolicy(maxKeptRows: 3);
        final updates = <int>[];

        void touch(int id, {bool media = false}) {
          policy.touch(
            id,
            hasMedia: media,
            requestKeepAliveUpdate: () => updates.add(id),
          );
        }

        touch(1);
        touch(2);
        touch(3, media: true);
        expect(policy.shouldKeep(1), isTrue);
        expect(policy.shouldKeep(2), isTrue);
        expect(policy.shouldKeep(3), isTrue);

        // Over budget: drop oldest non-media (1) before media (3).
        touch(4);
        expect(policy.shouldKeep(1), isFalse);
        expect(policy.shouldKeep(2), isTrue);
        expect(policy.shouldKeep(3), isTrue);
        expect(policy.shouldKeep(4), isTrue);
        expect(updates, contains(1));
      },
    );

    test('recordHeight and averageHeight', () {
      final policy = CommentListMemoryPolicy();
      policy.recordHeight(1, 100);
      policy.recordHeight(2, 200);
      expect(policy.heightOf(1), 100);
      expect(policy.averageHeight(), 150);
    });

    test('bounds old height samples for long threads', () {
      final policy = CommentListMemoryPolicy(maxMeasuredRows: 2);
      policy.recordHeight(1, 100);
      policy.recordHeight(2, 200);
      policy.recordHeight(3, 300);

      expect(policy.measuredHeightCount, 2);
      expect(policy.heightOf(1), isNull);
      expect(policy.heightOf(2), 200);
      expect(policy.heightOf(3), 300);
    });
  });
}
