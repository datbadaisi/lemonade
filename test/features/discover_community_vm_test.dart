import 'package:flutter_test/flutter_test.dart';
import 'package:bluerum/features/search/presentation/discover_community_vm.dart';
import 'package:bluerum/shared/models/post.dart';

CommunityView _view({
  required int id,
  String name = 'tech',
  String title = 'Technology',
  String? description,
  String? icon,
  int subscribers = 1200,
  int activeWeek = 340,
  String subscribed = 'NotSubscribed',
}) {
  return CommunityView(
    community: Community(
      id: id,
      name: name,
      title: title,
      description: description,
      icon: icon,
    ),
    counts: CommunityAggregates(
      communityId: id,
      subscribers: subscribers,
      usersActiveWeek: activeWeek,
    ),
    subscribed: subscribed,
  );
}

void main() {
  group('formatCompactCount', () {
    test('formats small, k, and M', () {
      expect(formatCompactCount(42), '42');
      expect(formatCompactCount(1200), '1.2k');
      expect(formatCompactCount(15000), '15k');
      expect(formatCompactCount(2300000), '2.3M');
      expect(formatCompactCount(12000000), '12M');
    });
  });

  group('chunkDiscoverColumns', () {
    test('chunks into fixed column size', () {
      final cols = chunkDiscoverColumns([1, 2, 3, 4, 5], rowsPerColumn: 3);
      expect(cols, [
        [1, 2, 3],
        [4, 5],
      ]);
    });

    test('empty list', () {
      expect(chunkDiscoverColumns<int>([], rowsPerColumn: 2), isEmpty);
    });
  });

  group('DiscoverCommunityRowVm', () {
    test('strips markdown description once', () {
      final vm = DiscoverCommunityRowVm.fromView(
        _view(
          id: 1,
          description: '**Hello** [world](https://x.test) and more',
        ),
      );
      expect(vm.descriptionPlain, contains('Hello'));
      expect(vm.descriptionPlain, contains('world'));
      expect(vm.descriptionPlain, isNot(contains('**')));
      expect(vm.descriptionPlain, isNot(contains('](')));
      expect(vm.statsLine, '1.2k members · 340 active/wk');
      expect(vm.title, 'Technology');
      expect(vm.hasDescription, isTrue);
    });

    test('empty description stays empty', () {
      final vm = DiscoverCommunityRowVm.fromView(_view(id: 2));
      expect(vm.descriptionPlain, isEmpty);
      expect(vm.hasDescription, isFalse);
    });

    test('falls back title to name', () {
      final vm = DiscoverCommunityRowVm.fromView(
        _view(id: 3, title: '', name: 'onlyname'),
      );
      expect(vm.title, 'onlyname');
    });
  });

  group('DiscoverCommunityVmCache', () {
    test('returns same instance when identity unchanged', () {
      final cache = DiscoverCommunityVmCache();
      final a = _view(id: 9, description: '**a**');
      final first = cache.vmFor(a);
      final second = cache.vmFor(a);
      expect(identical(first, second), isTrue);
    });

    test('rebuilds when description changes', () {
      final cache = DiscoverCommunityVmCache();
      final first = cache.vmFor(_view(id: 9, description: 'one'));
      final second = cache.vmFor(_view(id: 9, description: '**two**'));
      expect(identical(first, second), isFalse);
      expect(second.descriptionPlain, 'two');
    });

    test('warm + retainOnly trims stale ids', () {
      final cache = DiscoverCommunityVmCache();
      cache.warm([_view(id: 1), _view(id: 2), _view(id: 3)]);
      expect(cache.peek(2), isNotNull);
      cache.retainOnly({1, 3});
      expect(cache.peek(2), isNull);
      expect(cache.peek(1), isNotNull);
    });
  });
}
