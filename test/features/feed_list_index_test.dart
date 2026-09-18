import 'package:bluerum/features/ads/domain/ads_config.dart';
import 'package:bluerum/features/feed/presentation/feed_list_index.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FeedListIndexMap / withFeedAds', () {
    test('maps post ids and ad slots with ads on', () {
      final ids = List<int>.generate(12, (i) => 100 + i);
      final map = buildHomeFeedIndexMap(
        postIds: ids,
        showAds: true,
        postsPerAd: AdsConfig.homePostsPerAd,
      );

      // postsPerAd = 8 → list: P0..P7 A0 P8..P11 (only 1 ad for 12 posts)
      expect(map.indexForKeyValue(100), 0);
      expect(map.indexForKeyValue(107), 7);
      expect(map.indexForKeyValue('home-ad-slot-0'), 8);
      expect(map.indexForKeyValue(108), 9);
      expect(map.indexForKeyValue('home-ad-slot-1'), isNull);
      expect(map.indexForKeyValue(999), isNull);
    });

    test('maps post ids only when ads off', () {
      final map = buildHomeFeedIndexMap(
        postIds: const [1, 2, 3],
        showAds: false,
        postsPerAd: AdsConfig.homePostsPerAd,
      );
      expect(map.indexForKeyValue(1), 0);
      expect(map.indexForKeyValue(3), 2);
      expect(map.indexForKeyValue('home-ad-slot-0'), isNull);
    });
  });
}
