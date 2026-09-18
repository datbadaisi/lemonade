import 'package:bluerum/features/post/presentation/comment_list_extents.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('formatCommentTimeAgo', () {
    setUp(clearCommentTimeAgoCache);

    test('caches by published string', () {
      const published = '2020-01-01T00:00:00Z';
      final a = formatCommentTimeAgo(
        published,
        now: DateTime.utc(2020, 1, 1, 2),
      );
      final b = formatCommentTimeAgo(
        published,
        now: DateTime.utc(2099, 1, 1), // cache hit ignores new now
      );
      expect(a, '2 hr. ago');
      expect(b, a);
    });

    test('just now for fresh', () {
      final now = DateTime.utc(2024, 6, 1, 12);
      final label = formatCommentTimeAgo(
        now.toIso8601String(),
        now: now,
      );
      expect(label, 'just now');
    });
  });
}
