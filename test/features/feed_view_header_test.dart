import 'package:bluerum/features/feed/data/feed_view_settings.dart';
import 'package:bluerum/features/feed/presentation/home_feed_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('feed view button selects a mode', (tester) async {
    final controller = AnimationController(vsync: tester);
    addTearDown(controller.dispose);
    FeedViewMode? selected;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Stack(
            children: [
              HomeFeedHeader(
                topInset: 0,
                titleAnimController: controller,
                titleScale: const AlwaysStoppedAnimation<double>(1),
                titleColor: Colors.black,
                onTitleTap: () {},
                viewMode: FeedViewMode.large,
                onViewModeSelected: (mode) => selected = mode,
                lifetimeOwned: false,
              ),
            ],
          ),
        ),
      ),
    );

    await tester.tap(find.byTooltip('Feed view: Large'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Compact'));
    await tester.pumpAndSettle();

    expect(selected, FeedViewMode.compact);
    expect(tester.takeException(), isNull);
  });
}
