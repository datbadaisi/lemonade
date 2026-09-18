import 'package:bluerum/features/feed/data/feed_repository_impl.dart';
import 'package:bluerum/features/feed/domain/feed_repository.dart';
import 'package:bluerum/features/feed/presentation/feed_controller.dart';
import 'package:bluerum/features/feed/presentation/post_interaction_providers.dart';
import 'package:bluerum/shared/models/post.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('feed controller applies filters and exposes repository errors', () async {
    final repository = _FakeFeedRepository()..failure = StateError('offline');
    final container = ProviderContainer(
      overrides: [feedRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    await container
        .read(feedControllerProvider.notifier)
        .changeFilter(sort: 'New', type: 'Subscribed');

    final state = container.read(feedControllerProvider);
    expect(repository.sort, 'New');
    expect(repository.type, 'Subscribed');
    expect(state.isLoading, isFalse);
    expect(state.error, isA<StateError>());
  });

  test('load publishes postIds and postsById; loadMore merges', () async {
    final repository = _FakeFeedRepository()
      ..pages = {
        1: [_post(1), _post(2)],
        2: [_post(2), _post(3)], // id 2 duplicate
      };
    final container = ProviderContainer(
      overrides: [feedRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    await container.read(feedControllerProvider.notifier).load();
    var list = container.read(feedControllerProvider);
    var map = container.read(feedPostsByIdProvider);
    expect(list.postIds, [1, 2]);
    expect(map.keys.toSet(), {1, 2});
    expect(list.hasMore, isFalse); // page size 20, we returned 2

    // Force hasMore by returning full pages
    repository.pages = {
      1: List.generate(20, (i) => _post(i + 1)),
      2: List.generate(5, (i) => _post(100 + i)),
    };
    await container.read(feedControllerProvider.notifier).load();
    list = container.read(feedControllerProvider);
    expect(list.postIds.length, 20);
    expect(list.hasMore, isTrue);

    await container.read(feedControllerProvider.notifier).loadMore();
    list = container.read(feedControllerProvider);
    map = container.read(feedPostsByIdProvider);
    expect(list.postIds.length, 25);
    expect(map.length, 25);
    expect(list.postIds.contains(100), isTrue);
  });

  test('prependPost inserts head and dedupes', () async {
    final repository = _FakeFeedRepository()
      ..pages = {
        1: [_post(1), _post(2)],
      };
    final container = ProviderContainer(
      overrides: [feedRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    await container.read(feedControllerProvider.notifier).load();
    container.read(feedControllerProvider.notifier).prependPost(_post(99));
    var list = container.read(feedControllerProvider);
    expect(list.postIds.first, 99);
    expect(container.read(feedPostsByIdProvider).containsKey(99), isTrue);

    container.read(feedControllerProvider.notifier).prependPost(_post(99));
    list = container.read(feedControllerProvider);
    expect(list.postIds.where((id) => id == 99).length, 1);
    expect(list.postIds.first, 99);
  });

  test('loadMore discarded when loadEpoch changes mid-flight', () async {
    final repository = _FakeFeedRepository()
      ..pages = {
        1: List.generate(20, (i) => _post(i + 1)),
      }
      ..delay = const Duration(milliseconds: 40);
    final container = ProviderContainer(
      overrides: [feedRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    await container.read(feedControllerProvider.notifier).load();
    expect(container.read(feedControllerProvider).postIds.length, 20);

    // Start loadMore then change filter before it completes.
    final more = container.read(feedControllerProvider.notifier).loadMore();
    repository.pages = {
      1: [_post(500)],
    };
    repository.delay = Duration.zero;
    await container
        .read(feedControllerProvider.notifier)
        .changeFilter(sort: 'New', type: 'All');
    await more;

    final list = container.read(feedControllerProvider);
    expect(list.postIds, [500]);
    expect(list.postIds.contains(1), isFalse);
  });

  test('effectiveMyVote overlay null uses base; non-null overrides', () {
    final base = _post(1).copyWith(myVote: 1);
    expect(effectiveMyVote(base, null), 1);
    expect(effectiveMyVote(base, 0), 0);
    expect(displayScore(base, 0), base.counts.score - 1);
    expect(displayScore(base, 1), base.counts.score);
  });

  test('keepExisting refresh reuses unchanged PostView instances', () async {
    final p1 = _post(1);
    final p2 = _post(2);
    final repository = _FakeFeedRepository()
      ..pages = {
        1: [p1, p2],
      };
    final container = ProviderContainer(
      overrides: [feedRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    await container.read(feedControllerProvider.notifier).load();
    final before = container.read(feedPostsByIdProvider);
    expect(identical(before[1], p1), isTrue);

    // Same surface data, new list instances (as a real network response would).
    repository.pages = {
      1: [_post(1), _post(2)],
    };
    await container.read(feedControllerProvider.notifier).refresh();
    final after = container.read(feedPostsByIdProvider);
    // Unchanged posts keep prior instances → cards/VMs do not mass-rebuild.
    expect(identical(after[1], p1), isTrue);
    expect(identical(after[2], p2), isTrue);
    expect(container.read(feedControllerProvider).isLoading, isFalse);
  });

  test('keepExisting refresh replaces PostView when score changes', () async {
    final p1 = _post(1);
    final repository = _FakeFeedRepository()
      ..pages = {
        1: [p1],
      };
    final container = ProviderContainer(
      overrides: [feedRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    await container.read(feedControllerProvider.notifier).load();

    final updated = _post(1).copyWith(
      counts: PostAggregates(postId: 1, score: 99, comments: 0),
    );
    repository.pages = {
      1: [updated],
    };
    await container.read(feedControllerProvider.notifier).refresh();
    final after = container.read(feedPostsByIdProvider)[1]!;
    expect(identical(after, p1), isFalse);
    expect(after.counts.score, 99);
  });
}

PostView _post(int id) {
  return PostView(
    post: Post(
      id: id,
      name: 'Post $id',
      creatorId: 1,
      communityId: 1,
      published: '2020-01-01T00:00:00Z',
    ),
    creator: const Person(id: 1, name: 'u'),
    community: const Community(id: 1, name: 'c', title: 'C'),
    counts: PostAggregates(postId: id, score: 10, comments: 0),
  );
}

final class _FakeFeedRepository implements FeedRepository {
  Object? failure;
  String? sort;
  String? type;
  Duration delay = Duration.zero;
  Map<int, List<PostView>> pages = const {};

  @override
  Future<List<PostView>> getPosts({
    required String sort,
    required String type,
    required int page,
    required int limit,
  }) async {
    this.sort = sort;
    this.type = type;
    if (delay > Duration.zero) await Future<void>.delayed(delay);
    if (failure != null) throw failure!;
    return pages[page] ?? const [];
  }

  @override
  Future<PostView> save({required int postId, required bool save}) =>
      throw UnimplementedError();

  @override
  Future<PostView> vote({required int postId, required int score}) =>
      throw UnimplementedError();
}
