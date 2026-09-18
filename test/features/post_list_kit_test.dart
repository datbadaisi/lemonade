import 'package:bluerum/shared/widgets/post_list/post_list_index.dart';
import 'package:bluerum/shared/widgets/post_list/post_list_memory.dart';
import 'package:bluerum/shared/widgets/post_list/post_list_vm_cache.dart';
import 'package:bluerum/shared/models/post.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PostListMemoryPolicy', () {
    test('LRU prefers dropping non-media', () {
      final policy = PostListMemoryPolicy(maxKeptRows: 3);
      void touch(int id, {bool media = false}) {
        policy.touch(
          id,
          hasMedia: media,
          requestKeepAliveUpdate: () {},
        );
      }

      touch(1);
      touch(2);
      touch(3, media: true);
      touch(4);
      expect(policy.shouldKeep(1), isFalse);
      expect(policy.shouldKeep(3), isTrue);
      expect(policy.shouldKeep(4), isTrue);
    });

    test('maxKeptRows 0 never keeps (pure virtualization)', () {
      final policy = PostListMemoryPolicy(); // default 0
      expect(policy.allowsKeepAlive, isFalse);
      policy.touch(
        1,
        hasMedia: true,
        requestKeepAliveUpdate: () {},
      );
      expect(policy.shouldKeep(1), isFalse);
      policy.touch(
        2,
        hasMedia: false,
        requestKeepAliveUpdate: () {},
      );
      expect(policy.shouldKeep(2), isFalse);
    });
  });

  group('PostListIndexMap', () {
    test('fromPostIds maps ids', () {
      final map = PostListIndexMap.fromPostIds(const [10, 20, 30]);
      expect(map.indexForKeyValue(10), 0);
      expect(map.indexForKeyValue(30), 2);
      expect(map.indexForKeyValue(99), isNull);
    });

    test('fromKeyedEntries maps mixed keys', () {
      final map = PostListIndexMap.fromKeyedEntries(const [
        'hdr_Posts',
        5,
        'cmt_9',
      ]);
      expect(map.indexForKeyValue('hdr_Posts'), 0);
      expect(map.indexForKeyValue(5), 1);
      expect(map.indexForKeyValue('cmt_9'), 2);
    });
  });

  group('PostListVmCache', () {
    test('reuses vm until identity changes', () {
      final cache = PostListVmCache();
      final pv = PostView(
        post: Post(
          id: 1,
          name: 'Title',
          creatorId: 1,
          communityId: 1,
          published: '2020-01-01T00:00:00Z',
          body: 'hello **world**',
        ),
        creator: const Person(id: 1, name: 'u'),
        community: const Community(id: 1, name: 'c', title: 'C'),
        counts: const PostAggregates(postId: 1, comments: 0, score: 1),
      );
      final a = cache.vmFor(pv);
      final b = cache.vmFor(pv);
      expect(identical(a, b), isTrue);

      final changed = pv.copyWith(
        post: pv.post.copyWith(body: 'changed'),
      );
      final c = cache.vmFor(changed);
      expect(identical(a, c), isFalse);
      expect(c.bodyPreview.contains('changed'), isTrue);
    });
  });
}
