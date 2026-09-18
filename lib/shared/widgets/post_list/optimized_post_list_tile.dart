import 'package:bluerum/features/feed/presentation/post_card_vm.dart';
import 'package:bluerum/features/feed/presentation/post_interaction_providers.dart';
import 'package:bluerum/shared/models/post.dart';
import 'package:bluerum/shared/widgets/post/post_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'post_list_memory.dart';
import 'post_list_vm_cache.dart';

/// Single post-card row: [feedOptimized] media path + VM + vote/save overlays
/// isolated to this tile (no parent list setState on vote).
class OptimizedPostListTile extends ConsumerWidget {
  const OptimizedPostListTile({
    super.key,
    required this.postView,
    required this.vmCache,
    required this.onOpen,
    this.onUpvote,
    this.onDownvote,
    this.onSave,
    this.showCreator = true,
    this.onCommunityTap,
    this.memoryPolicy,
  });

  final PostView postView;
  final PostListVmCache vmCache;
  final void Function(PostView pv) onOpen;
  final Future<void> Function(PostView pv)? onUpvote;
  final Future<void> Function(PostView pv)? onDownvote;
  final Future<void> Function(PostView pv)? onSave;
  final bool showCreator;
  final VoidCallback? onCommunityTap;

  /// When set: height probe always; keep-alive only if [PostListMemoryPolicy.allowsKeepAlive].
  final PostListMemoryPolicy? memoryPolicy;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postId = postView.post.id;
    final vm = vmCache.vmFor(postView);
    final voteOverlay = ref.watch(
      postMyVoteOverlaysProvider.select((m) => m[postId]),
    );
    final savedOverlay = ref.watch(
      postSavedOverlaysProvider.select((m) => m[postId]),
    );

    final card = PostCard(
      postView: postView,
      vm: vm,
      feedOptimized: true,
      showCreator: showCreator,
      onCommunityTap: onCommunityTap,
      effectiveVote: effectiveMyVote(postView, voteOverlay),
      effectiveSaved: effectiveSaved(postView, savedOverlay),
      onTap: () => onOpen(postView),
      onUpvote: onUpvote == null ? null : () => onUpvote!(postView),
      onDownvote: onDownvote == null ? null : () => onDownvote!(postView),
      onSave: onSave == null ? null : () => onSave!(postView),
    );

    final policy = memoryPolicy;
    if (policy == null) return card;

    // Home-class: pure recycle + measured heights for prefetch math.
    if (!policy.allowsKeepAlive) {
      return PostListHeightProbe(
        postId: postId,
        policy: policy,
        child: card,
      );
    }

    return PostListKeepAlive(
      postId: postId,
      hasMedia: vm.hasMedia,
      policy: policy,
      child: card,
    );
  }
}

/// Convenience when only a [PostCardVm] is needed outside the tile.
PostCardVm postListVm(PostListVmCache cache, PostView pv) => cache.vmFor(pv);
