import 'package:bluerum/features/ads/domain/ads_config.dart';
import 'package:bluerum/features/ads/domain/ads_placement.dart';
import 'package:bluerum/features/feed/presentation/feed_scroll_anchor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'switching both ways deep in a media feed keeps the visible post',
    (tester) async {
      final postIds = List<int>.generate(100, (index) => index + 1);
      final sliverKey = GlobalKey();
      final controller = ScrollController();
      final rowHeight = ValueNotifier<double>(360);
      addTearDown(controller.dispose);
      addTearDown(rowHeight.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ValueListenableBuilder<double>(
              valueListenable: rowHeight,
              builder: (context, height, _) => CustomScrollView(
                controller: controller,
                slivers: [
                  const SliverToBoxAdapter(child: SizedBox(height: 80)),
                  Builder(
                    key: sliverKey,
                    builder: (context) => SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (isFeedAdAt(
                            index: index,
                            postCount: postIds.length,
                            postsPerAd: AdsConfig.homePostsPerAd,
                            showAds: true,
                          )) {
                            return const SizedBox(height: 250);
                          }
                          final postIndex = feedPostIndex(
                            listIndex: index,
                            postsPerAd: AdsConfig.homePostsPerAd,
                            showAds: true,
                          );
                          return SizedBox(
                            key: ValueKey(postIds[postIndex]),
                            height: height + (postIndex % 3) * 24,
                            child: Text('Post ${postIds[postIndex]}'),
                          );
                        },
                        childCount: feedItemCount(
                          postCount: postIds.length,
                          postsPerAd: AdsConfig.homePostsPerAd,
                          showAds: true,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      controller.jumpTo(8500);
      await tester.pumpAndSettle();
      final anchor = captureFeedScrollAnchor(
        sliverKey: sliverKey,
        postIds: postIds,
        showAds: true,
        visibleTop: 0,
        visibleBottom: 600,
      );
      expect(anchor, isNotNull);

      rowHeight.value = 120;
      await tester.pumpAndSettle();
      final target = offsetForFeedScrollAnchor(
        sliverKey: sliverKey,
        anchor: anchor!,
        postIds: postIds,
        showAds: true,
        currentOffset: controller.offset,
      );
      expect(target, isNotNull);
      controller.jumpTo(target!);
      await tester.pumpAndSettle();

      final restored = captureFeedScrollAnchor(
        sliverKey: sliverKey,
        postIds: postIds,
        showAds: true,
        visibleTop: 0,
        visibleBottom: 600,
      );
      expect(restored?.postId, anchor.postId);
      final oldFraction = ((anchor.visibleTop - anchor.top) / anchor.height)
          .clamp(0.0, 1.0);
      final newFraction =
          ((restored!.visibleTop - restored.top) / restored.height).clamp(
            0.0,
            1.0,
          );
      expect(newFraction, closeTo(oldFraction, 0.01));

      rowHeight.value = 360;
      await tester.pumpAndSettle();
      final reverseTarget = offsetForFeedScrollAnchor(
        sliverKey: sliverKey,
        anchor: restored,
        postIds: postIds,
        showAds: true,
        currentOffset: controller.offset,
      );
      expect(reverseTarget, isNotNull);
      controller.jumpTo(reverseTarget!);
      await tester.pumpAndSettle();

      final reversed = captureFeedScrollAnchor(
        sliverKey: sliverKey,
        postIds: postIds,
        showAds: true,
        visibleTop: 0,
        visibleBottom: 600,
      );
      expect(reversed?.postId, anchor.postId);
      expect(reversed!.top, closeTo(anchor.top, 1));
    },
  );
}
