import 'package:flutter/material.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';

import 'package:bluerum/app/theme/app_colors.dart';
import 'package:bluerum/core/utils/media_utils.dart';
import 'package:bluerum/core/utils/markdown_utils.dart';
import 'package:bluerum/core/utils/time_ago.dart';
import 'package:bluerum/features/community/presentation/community_detail_screen.dart';
import 'package:bluerum/features/feed/data/feed_view_settings.dart';
import 'package:bluerum/features/feed/presentation/post_card_vm.dart';
import 'package:bluerum/features/profile/presentation/profile_screen.dart';
import 'package:bluerum/shared/models/post.dart';
import 'package:bluerum/shared/widgets/media/post_still_image.dart';
import 'package:bluerum/shared/widgets/post/vote_bounce_button.dart';

/// The two dense home-feed layouts. Large remains the existing PostCard.
class HomeFeedPostRow extends StatelessWidget {
  const HomeFeedPostRow({
    super.key,
    required this.postView,
    required this.vm,
    required this.mode,
    required this.isRead,
    required this.effectiveVote,
    required this.effectiveSaved,
    required this.onOpen,
    required this.onUpvote,
    required this.onDownvote,
    required this.onSave,
  });

  final PostView postView;
  final PostCardVm vm;
  final FeedViewMode mode;
  final bool isRead;
  final int effectiveVote;
  final bool effectiveSaved;
  final VoidCallback onOpen;
  final VoidCallback onUpvote;
  final VoidCallback onDownvote;
  final VoidCallback onSave;

  bool get _compact => mode == FeedViewMode.compact;

  @override
  Widget build(BuildContext context) {
    final post = postView.post;
    final media = vm.firstMedia;
    final thumbnailSize = _compact ? 64.0 : 88.0;
    final displayedScore =
        postView.counts.score + effectiveVote - (postView.myVote ?? 0);

    return RepaintBoundary(
      child: Material(
        color: AppColors.card,
        child: InkWell(
          onTap: onOpen,
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: _compact ? 8 : 16,
                  vertical: _compact ? 8 : 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (media != null) ...[
                          _Thumbnail(
                            media: media,
                            size: thumbnailSize,
                            altText: post.altText ?? post.name,
                            extraMediaCount: vm.extraMediaCount,
                          ),
                          SizedBox(width: _compact ? 8 : 12),
                        ],
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _metadata(context),
                              const SizedBox(height: 4),
                              Text(
                                vm.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: _compact ? 14 : 16,
                                  height: 1.3,
                                  fontWeight: FontWeight.w700,
                                  color: isRead
                                      ? AppColors.textPrimary.withValues(
                                          alpha: 0.42,
                                        )
                                      : AppColors.textPrimary,
                                ),
                              ),
                              if (!_compact && vm.bodyPreview.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text(
                                  vm.bodyPreview.replaceAll(
                                    '$kSpoilerCollapsedMarker ',
                                    'Spoiler: ',
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    height: 1.45,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _actions(displayedScore),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _metadata(BuildContext context) {
    final community = postView.community;
    final creator = postView.creator;
    const metaStyle = TextStyle(fontSize: 12, color: AppColors.textSecondary);
    return Row(
      children: [
        Flexible(
          child: InkWell(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => CommunityDetailScreen(
                  communityId: community.id,
                  communityName: community.name,
                ),
              ),
            ),
            child: Text(
              'c/${community.name}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: metaStyle.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        if (!_compact) ...[
          Text(' · ', style: metaStyle),
          Flexible(
            child: InkWell(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ProfileScreen(personId: creator.id),
                ),
              ),
              child: Text(
                'u/${creator.name}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: metaStyle,
              ),
            ),
          ),
        ],
        const SizedBox(width: 4),
        Text(formatCommentTimeAgo(vm.publishedIso), style: metaStyle),
        if (vm.isNsfw) ...[
          const SizedBox(width: 4),
          DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: Text(
                'NSFW',
                style: metaStyle.copyWith(
                  fontSize: 10,
                  color: AppColors.accent,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _actions(int displayedScore) {
    return SizedBox(
      height: 32,
      child: Row(
        children: [
          Tooltip(
            message: 'Comments',
            child: _pill(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    MingCuteIcons.mgc_chat_1_line,
                    size: 16,
                    color: Color(0xFF333333),
                  ),
                  if (postView.counts.comments != 0) ...[
                    const SizedBox(width: 4),
                    Text(
                      _formatCount(postView.counts.comments),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF333333),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          _pill(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                VoteBounceButton(
                  onPressed: onUpvote,
                  tooltip: effectiveVote == 1 ? 'Remove upvote' : 'Upvote',
                  width: 28,
                  height: 32,
                  direction: 1,
                  child: Icon(
                    effectiveVote == 1
                        ? MingCuteIcons.mgc_large_arrow_up_fill
                        : MingCuteIcons.mgc_large_arrow_up_line,
                    size: 16,
                    color: effectiveVote == 1
                        ? AppColors.action
                        : const Color(0xFF333333),
                  ),
                ),
                Text(
                  _formatCount(displayedScore),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF333333),
                  ),
                ),
                VoteBounceButton(
                  onPressed: onDownvote,
                  tooltip: effectiveVote == -1 ? 'Remove downvote' : 'Downvote',
                  width: 28,
                  height: 32,
                  direction: 1,
                  child: Icon(
                    effectiveVote == -1
                        ? MingCuteIcons.mgc_large_arrow_down_fill
                        : MingCuteIcons.mgc_large_arrow_down_line,
                    size: 16,
                    color: effectiveVote == -1
                        ? AppColors.downvote
                        : const Color(0xFF333333),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Tooltip(
            message: effectiveSaved ? 'Remove saved post' : 'Save post',
            child: _pill(
              horizontalPadding: 0,
              child: InkWell(
                onTap: onSave,
                borderRadius: BorderRadius.circular(9999),
                child: SizedBox(
                  width: 32,
                  height: 32,
                  child: Icon(
                    effectiveSaved
                        ? MingCuteIcons.mgc_bookmark_fill
                        : MingCuteIcons.mgc_bookmark_line,
                    size: 16,
                    color: effectiveSaved
                        ? AppColors.action
                        : const Color(0xFF333333),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pill({required Widget child, double horizontalPadding = 8}) {
    return Container(
      height: 32,
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(9999),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return count.toString();
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({
    required this.media,
    required this.size,
    required this.altText,
    required this.extraMediaCount,
  });

  final MediaItem media;
  final double size;
  final String altText;
  final int extraMediaCount;

  @override
  Widget build(BuildContext context) {
    final imageUrl = media.thumbnailUrl ?? (media.isImage ? media.url : null);
    final fallbackUrl = imageUrl == media.url ? media.fallbackUrl : media.url;
    final cacheWidth = (size * MediaQuery.devicePixelRatioOf(context)).ceil();
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
      foregroundDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0x1F000000)),
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (imageUrl != null && imageUrl.isNotEmpty)
            PostStillImage(
              url: imageUrl,
              fallbackUrl: fallbackUrl,
              altText: altText,
              listDecode: true,
              allowProgressiveFullRes: false,
              memCacheWidth: cacheWidth,
            )
          else
            const ColoredBox(
              color: Color(0xFFE8E8E8),
              child: Icon(
                MingCuteIcons.mgc_video_camera_line,
                color: AppColors.textSecondary,
              ),
            ),
          if (media.isVideo)
            const Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: EdgeInsets.all(4),
                child: Icon(
                  MingCuteIcons.mgc_play_circle_fill,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          if (extraMediaCount > 0)
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                  padding: const EdgeInsets.all(8),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(9999),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    child: Text(
                      '+$extraMediaCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
