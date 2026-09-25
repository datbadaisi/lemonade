import 'package:flutter/material.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';

import 'package:bluerum/features/feed/data/feed_view_settings.dart';
import 'package:bluerum/shared/models/post.dart';
import 'package:bluerum/shared/widgets/post_list/post_list_memory.dart';

import 'feed_list_index.dart';
import 'home_feed_tile.dart';

/// Posts sliver — only rebuilds when [postIds] change, not when load-more
/// footer flags flip on the parent [HomeScreen].
class HomeFeedPostsSliver extends StatelessWidget {
  const HomeFeedPostsSliver({
    super.key,
    required this.postIds,
    required this.memoryPolicy,
    required this.viewMode,
    required this.indexMapFor,
    required this.findChildIndex,
    required this.onOpen,
    required this.onUpvote,
    required this.onDownvote,
    required this.onSave,
  });

  final List<int> postIds;
  final PostListMemoryPolicy memoryPolicy;
  final FeedViewMode viewMode;
  final FeedListIndexMap Function(List<int> postIds) indexMapFor;
  final int? Function(Key key) findChildIndex;
  final void Function(PostView pv) onOpen;
  final Future<bool> Function(PostView pv) onUpvote;
  final Future<bool> Function(PostView pv) onDownvote;
  final Future<bool> Function(PostView pv) onSave;

  @override
  Widget build(BuildContext context) {
    indexMapFor(postIds);
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final postId = postIds[index];
          return HomeFeedTile(
            key: ValueKey(postId),
            postId: postId,
            memoryPolicy: memoryPolicy,
            viewMode: viewMode,
            onOpen: onOpen,
            onUpvote: onUpvote,
            onDownvote: onDownvote,
            onSave: onSave,
          );
        },
        childCount: postIds.length,
        findChildIndexCallback: findChildIndex,
        // Commercial virtualization: destroy off-screen Element trees.
        addAutomaticKeepAlives: false,
        addRepaintBoundaries: true,
      ),
    );
  }
}

/// Full-viewport empty / error states for the home feed list.
class HomeFeedStatusSliver {
  HomeFeedStatusSliver._();

  static const Color textPrimary = Color(0xFF000000);
  static const Color textSecondary = Color(0xFF525252);

  static Widget error({required String error, required VoidCallback onRetry}) {
    return SliverFillRemaining(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                MingCuteIcons.mgc_wifi_off_line,
                size: 48,
                color: textSecondary,
              ),
              const SizedBox(height: 12),
              const Text(
                'Something went wrong',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error,
                style: const TextStyle(fontSize: 13, color: textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              HomeFeedActionButton(label: 'Retry', onTap: onRetry),
            ],
          ),
        ),
      ),
    );
  }

  static Widget empty() {
    return const SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              MingCuteIcons.mgc_folder_open_line,
              size: 48,
              color: textSecondary,
            ),
            SizedBox(height: 12),
            Text(
              'No posts found',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Primary action pill used on home empty/error footers.
class HomeFeedActionButton extends StatelessWidget {
  const HomeFeedActionButton({
    super.key,
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(9999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF000000),
            borderRadius: BorderRadius.circular(9999),
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
