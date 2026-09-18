import 'package:bluerum/features/feed/presentation/feed_list_memory.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FeedListMemoryPolicy', () {
    test('LRU keeps recent ids within budget and prefers dropping non-media',
        () {
      final policy = FeedListMemoryPolicy(maxKeptRows: 3);
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

      touch(4);
      expect(policy.shouldKeep(1), isFalse);
      expect(policy.shouldKeep(2), isTrue);
      expect(policy.shouldKeep(3), isTrue);
      expect(policy.shouldKeep(4), isTrue);
      expect(updates, contains(1));
    });

    test('recordHeight and averageHeight', () {
      final policy = FeedListMemoryPolicy();
      policy.recordHeight(1, 300);
      policy.recordHeight(2, 500);
      expect(policy.heightOf(1), 300);
      expect(policy.averageHeight(), 400);
    });

    test('clear drops keep set and notifies slots', () {
      final policy = FeedListMemoryPolicy(maxKeptRows: 4);
      var notified = 0;
      policy.touch(
        1,
        hasMedia: true,
        requestKeepAliveUpdate: () => notified++,
      );
      expect(policy.shouldKeep(1), isTrue);
      policy.clear();
      expect(policy.shouldKeep(1), isFalse);
      expect(notified, greaterThan(0));
    });
  });
}
