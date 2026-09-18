import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bluerum/features/feed/presentation/feed_controller.dart';
import 'package:bluerum/features/feed/presentation/feed_list_memory.dart';
import 'package:bluerum/features/feed/presentation/post_card_vm.dart';
import 'package:bluerum/features/feed/presentation/post_interaction_providers.dart';
import 'package:bluerum/shared/models/post.dart';
import 'package:bluerum/shared/widgets/post/post_card.dart';
import 'package:bluerum/shared/widgets/post_list/post_list_memory.dart';

/// Home-feed row: full [PostCard] chrome, **no off-screen keep-alive**.
///
/// Instagram / X-style: recycle cells when they leave the cache extent.
/// Heights are recorded via shared [PostListHeightProbe] for prefetch math.
class HomeFeedTile extends ConsumerWidget {
  const HomeFeedTile({
    super.key,
    required this.postId,
    required this.memoryPolicy,
    required this.onOpen,
    required this.onUpvote,
    required this.onDownvote,
    required this.onSave,
  });

  final int postId;
  final FeedListMemoryPolicy memoryPolicy;
  final void Function(PostView pv) onOpen;
  final Future<bool> Function(PostView pv) onUpvote;
  final Future<bool> Function(PostView pv) onDownvote;
  final Future<bool> Function(PostView pv) onSave;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pv = ref.watch(postViewProvider(postId));
    if (pv == null) return const SizedBox.shrink();
    final vm = ref.watch(postCardVmProvider(postId));
    final voteOverlay = ref.watch(
      postMyVoteOverlaysProvider.select((m) => m[postId]),
    );
    final savedOverlay = ref.watch(
      postSavedOverlaysProvider.select((m) => m[postId]),
    );

    return PostListHeightProbe(
      postId: postId,
      policy: memoryPolicy,
      child: PostCard(
        postView: pv,
        vm: vm,
        feedOptimized: true,
        effectiveVote: effectiveMyVote(pv, voteOverlay),
        effectiveSaved: effectiveSaved(pv, savedOverlay),
        onTap: () => onOpen(pv),
        onUpvote: () => onUpvote(pv),
        onDownvote: () => onDownvote(pv),
        onSave: () => onSave(pv),
      ),
    );
  }
}
