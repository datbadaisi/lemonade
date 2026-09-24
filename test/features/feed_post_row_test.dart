import 'package:bluerum/features/feed/data/feed_view_settings.dart';
import 'package:bluerum/features/feed/presentation/home_feed_post_row.dart';
import 'package:bluerum/features/feed/presentation/post_card_vm.dart';
import 'package:bluerum/shared/models/post.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';

void main() {
  final post = PostView(
    post: const Post(
      id: 1,
      name: 'A long title for a narrow phone screen',
      body: 'Body preview text',
    ),
    creator: const Person(id: 2, name: 'creator'),
    community: const Community(id: 3, name: 'community'),
    counts: const PostAggregates(postId: 1, score: 12, comments: 5),
  );

  Future<void> pumpRow(
    WidgetTester tester,
    FeedViewMode mode, {
    required VoidCallback onOpen,
    required VoidCallback onUpvote,
    required VoidCallback onDownvote,
    required VoidCallback onSave,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 320,
              child: HomeFeedPostRow(
                postView: post,
                vm: PostCardVm.fromPostView(post),
                mode: mode,
                isRead: false,
                effectiveVote: 0,
                effectiveSaved: false,
                onOpen: onOpen,
                onUpvote: onUpvote,
                onDownvote: onDownvote,
                onSave: onSave,
              ),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('Compact fits a narrow screen and keeps actions usable', (
    tester,
  ) async {
    var opens = 0;
    var upvotes = 0;
    var downvotes = 0;
    var saves = 0;
    await pumpRow(
      tester,
      FeedViewMode.compact,
      onOpen: () => opens++,
      onUpvote: () => upvotes++,
      onDownvote: () => downvotes++,
      onSave: () => saves++,
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Body preview text'), findsNothing);
    await tester.tap(find.text('A long title for a narrow phone screen'));
    await tester.tap(find.byTooltip('Upvote'));
    await tester.tap(find.byTooltip('Downvote'));
    await tester.tap(find.byTooltip('Save post'));
    expect((opens, upvotes, downvotes, saves), (1, 1, 1, 1));
  });

  testWidgets('Normal shows a body preview without overflowing', (
    tester,
  ) async {
    await pumpRow(
      tester,
      FeedViewMode.normal,
      onOpen: () {},
      onUpvote: () {},
      onDownvote: () {},
      onSave: () {},
    );

    expect(find.text('Body preview text'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('media placeholder stays on the left in Compact', (tester) async {
    final mediaPost = post.copyWith(
      post: post.post.copyWith(url: 'https://example.com/video.mp4'),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 320,
            child: HomeFeedPostRow(
              postView: mediaPost,
              vm: PostCardVm.fromPostView(mediaPost),
              mode: FeedViewMode.compact,
              isRead: false,
              effectiveVote: 0,
              effectiveSaved: false,
              onOpen: () {},
              onUpvote: () {},
              onDownvote: () {},
              onSave: () {},
            ),
          ),
        ),
      ),
    );

    final thumbnail = find.byIcon(MingCuteIcons.mgc_video_camera_line);
    expect(thumbnail, findsOneWidget);
    expect(
      tester.getTopLeft(thumbnail).dx,
      lessThan(
        tester
            .getTopLeft(find.text('A long title for a narrow phone screen'))
            .dx,
      ),
    );
    expect(tester.takeException(), isNull);
  });
}
