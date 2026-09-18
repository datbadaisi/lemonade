import 'package:flutter/material.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:bluerum/app/theme/app_colors.dart';
import 'package:bluerum/core/utils/media_utils.dart';
import 'package:bluerum/core/utils/time_ago.dart';
import 'package:bluerum/features/post/presentation/comment_thread_chrome.dart';
import 'package:bluerum/features/post/presentation/post_detail_post_actions.dart';
import 'package:bluerum/features/post/presentation/post_detail_theme.dart';
import 'package:bluerum/features/profile/presentation/profile_screen.dart';
import 'package:bluerum/shared/models/post.dart';
import 'package:bluerum/shared/widgets/avatar/network_avatar.dart';
import 'package:bluerum/shared/widgets/markdown/bluerum_markdown.dart';
import 'package:bluerum/shared/widgets/media/full_screen_media_viewer.dart';
import 'package:bluerum/shared/widgets/media/network_media_image.dart';
import 'package:bluerum/shared/widgets/media/video_player_widget.dart';
import 'package:bluerum/shared/widgets/post/post_card.dart';
import 'package:bluerum/shared/widgets/post/post_image_carousel.dart';

/// Post author / title / body / media / actions block for [PostDetailScreen].
class PostDetailHeader extends StatelessWidget {
  const PostDetailHeader({
    super.key,
    required this.postView,
    required this.mediaItems,
    required this.markdownBody,
    required this.resolvedImageRatio,
    required this.decodedImageWidth,
    required this.postVoteListenable,
    required this.onUpvote,
    required this.onDownvote,
    required this.onShare,
    required this.onComment,
    required this.onLinkTap,
  });

  final PostView postView;
  final List<MediaItem> mediaItems;
  final String? markdownBody;
  final double? resolvedImageRatio;
  final int Function(BuildContext context) decodedImageWidth;
  final ValueNotifier<int> postVoteListenable;
  final VoidCallback onUpvote;
  final VoidCallback onDownvote;
  final VoidCallback onShare;
  final VoidCallback onComment;
  final ValueChanged<String?> onLinkTap;

  @override
  Widget build(BuildContext context) {
    final post = postView.post;
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(
        horizontal: PostDetailTokens.spaceLg,
        vertical: PostDetailTokens.spaceMd,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _AuthorRow(postView: postView, published: post.published, nsfw: post.nsfw),
          const SizedBox(height: PostDetailTokens.spaceSm),
          if (post.deleted)
            const Text(
              '[deleted]',
              style: TextStyle(
                fontSize: PostDetailTokens.fontTitle,
                fontWeight: FontWeight.w700,
                fontStyle: FontStyle.italic,
                color: PostDetailTokens.textSecondary,
                height: 1.3,
              ),
            )
          else
            Text(
              post.name,
              style: const TextStyle(
                fontSize: PostDetailTokens.fontTitle,
                fontWeight: FontWeight.w700,
                color: PostDetailTokens.textBlack,
                height: 1.3,
              ),
            ),
          if (!post.deleted)
            _MediaAndBody(
              post: post,
              mediaItems: mediaItems,
              markdownBody: markdownBody,
              resolvedImageRatio: resolvedImageRatio,
              decodedImageWidth: decodedImageWidth,
              onLinkTap: onLinkTap,
            ),
          const SizedBox(height: PostDetailTokens.spaceSm),
          ValueListenableBuilder<int>(
            valueListenable: postVoteListenable,
            builder: (context, vote, _) {
              return PostDetailPostActions(
                postView: postView,
                effectiveVote: vote,
                onUpvote: onUpvote,
                onDownvote: onDownvote,
                onShare: onShare,
                onComment: onComment,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _AuthorRow extends StatelessWidget {
  const _AuthorRow({
    required this.postView,
    required this.published,
    required this.nsfw,
  });

  final PostView postView;
  final String published;
  final bool nsfw;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      ProfileScreen(personId: postView.creator.id),
                ),
              );
            },
            behavior: HitTestBehavior.opaque,
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    right: PostDetailTokens.spaceXs,
                  ),
                  child: NetworkAvatar(
                    size: PostDetailTokens.avatar,
                    imageUrl: postView.creator.avatar,
                    name: postView.creator.displayNameOrName,
                  ),
                ),
                Expanded(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          'u/${postView.creator.name}',
                          style: const TextStyle(
                            fontSize: PostDetailTokens.fontMeta,
                            color: PostDetailTokens.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (postView.creatorIsAdmin) ...[
                        const SizedBox(width: PostDetailTokens.spaceXs),
                        const DetailRoleBadge(
                          label: 'ADMIN',
                          color: Color(0xFFFF4500),
                        ),
                      ],
                      if (postView.creatorIsModerator) ...[
                        const SizedBox(width: PostDetailTokens.spaceXs),
                        const DetailRoleBadge(
                          label: 'MOD',
                          color: PostDetailTokens.textPrimary,
                        ),
                      ],
                      if (postView.creator.banned) ...[
                        const SizedBox(width: PostDetailTokens.spaceXs),
                        const DetailRoleBadge(
                          label: 'BANNED',
                          color: AppColors.danger,
                        ),
                      ],
                      if (postView.creatorBannedFromCommunity) ...[
                        const SizedBox(width: PostDetailTokens.spaceXs),
                        const DetailRoleBadge(
                          label: 'COMMUNITY BANNED',
                          color: AppColors.danger,
                        ),
                      ],
                      if (postView.creator.deleted) ...[
                        const SizedBox(width: PostDetailTokens.spaceXs),
                        const DetailRoleBadge(
                          label: 'DELETED',
                          color: PostDetailTokens.textSecondary,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: PostDetailTokens.spaceSm),
        Text(
          formatCommentTimeAgo(published),
          style: const TextStyle(
            fontSize: PostDetailTokens.fontMeta,
            color: PostDetailTokens.textSecondary,
          ),
        ),
        if (nsfw) ...[
          const SizedBox(width: PostDetailTokens.spaceXs),
          const DetailRoleBadge(
            label: 'NSFW',
            color: PostDetailTokens.textPrimary,
          ),
        ],
      ],
    );
  }
}

class _MediaAndBody extends StatelessWidget {
  const _MediaAndBody({
    required this.post,
    required this.mediaItems,
    required this.markdownBody,
    required this.resolvedImageRatio,
    required this.decodedImageWidth,
    required this.onLinkTap,
  });

  final Post post;
  final List<MediaItem> mediaItems;
  final String? markdownBody;
  final double? resolvedImageRatio;
  final int Function(BuildContext context) decodedImageWidth;
  final ValueChanged<String?> onLinkTap;

  Widget _markdown(BuildContext context, String data) {
    return Theme(
      data: Theme.of(context).copyWith(
        scrollbarTheme: ScrollbarThemeData(
          thumbColor: WidgetStateProperty.all(Colors.transparent),
          trackColor: WidgetStateProperty.all(Colors.transparent),
          thickness: WidgetStateProperty.all(0.0),
          radius: Radius.zero,
          interactive: false,
        ),
      ),
      child: ScrollConfiguration(
        behavior: const NoScrollbarBehavior(),
        child: BluerumMarkdown(
          data: data,
          selectable: true,
          onTapLink: (_, href, _) => onLinkTap(href),
          styleSheet: postDetailMarkdownStyle,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasMultipleMedia = mediaItems.length >= 2;
    final hasBodyText = markdownBody != null && markdownBody!.trim().isNotEmpty;

    if (hasMultipleMedia) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasBodyText)
            Padding(
              padding: const EdgeInsets.only(top: PostDetailTokens.spaceSm),
              child: _markdown(context, markdownBody!),
            ),
          Padding(
            padding: const EdgeInsets.only(top: PostDetailTokens.spaceSm),
            child: PostImageCarousel(
              mediaItems: mediaItems,
              aspectRatio: resolvedImageRatio,
              heroTagPrefix: post.id.toString(),
              memCacheWidth: decodedImageWidth(context),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (post.embedTitle != null)
          Padding(
            padding: const EdgeInsets.only(top: PostDetailTokens.spaceSm),
            child: LinkPreview(post: post, isDetail: true),
          ),
        if (hasBodyText)
          Padding(
            padding: const EdgeInsets.only(top: PostDetailTokens.spaceSm),
            child: _markdown(context, markdownBody!),
          ),
        if (mediaItems.length == 1)
          _SingleMedia(
            post: post,
            item: mediaItems.first,
            mediaItems: mediaItems,
            resolvedImageRatio: resolvedImageRatio,
            decodedImageWidth: decodedImageWidth,
          ),
      ],
    );
  }
}

class _SingleMedia extends StatelessWidget {
  const _SingleMedia({
    required this.post,
    required this.item,
    required this.mediaItems,
    required this.resolvedImageRatio,
    required this.decodedImageWidth,
  });

  final Post post;
  final MediaItem item;
  final List<MediaItem> mediaItems;
  final double? resolvedImageRatio;
  final int Function(BuildContext context) decodedImageWidth;

  @override
  Widget build(BuildContext context) {
    final displayUrl =
        item.type == MediaType.image ? item.url : item.thumbnailUrl;

    return GestureDetector(
      onTap: () async {
        if (item.isVideo && item.videoType == VideoType.youtube) {
          final uri = Uri.parse(item.url);
          try {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          } catch (_) {}
          return;
        }
        FullScreenMediaViewer.open(context, mediaItems: mediaItems);
      },
      child: Padding(
        padding: const EdgeInsets.only(top: PostDetailTokens.spaceSm),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              PostDetailTokens.spaceLg + PostDetailTokens.spaceXs,
            ),
          ),
          foregroundDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              PostDetailTokens.spaceLg + PostDetailTokens.spaceXs,
            ),
            border: Border.all(color: const Color(0x1F000000)),
          ),
          clipBehavior: Clip.antiAlias,
          child: Builder(
            builder: (context) {
              final screenHeight = MediaQuery.sizeOf(context).height;
              final screenWidth = MediaQuery.sizeOf(context).width;
              final maxHeight = screenHeight * 1.2;
              final contentWidth =
                  screenWidth - (PostDetailTokens.spaceLg * 2);
              final ratio = resolvedImageRatio ?? 16 / 9;
              final calcHeight = contentWidth / ratio;
              final useCapped = calcHeight > maxHeight;
              final frameH = useCapped ? maxHeight : calcHeight;
              final frameW = contentWidth;

              Widget mediaWidget;
              if (displayUrl != null && displayUrl.isNotEmpty) {
                final imageWidget = NetworkMediaImage(
                  imageUrl: displayUrl,
                  fit: BoxFit.contain,
                  width: frameW,
                  height: frameH,
                  memCacheWidth: decodedImageWidth(context),
                  errorWidget: (_) => Container(
                    color: const Color(0xFFE8E8E8),
                    child: Center(
                      child: Icon(
                        item.isVideo
                            ? MingCuteIcons.mgc_video_camera_line
                            : MingCuteIcons.mgc_pic_2_line,
                        color: PostDetailTokens.textSecondary,
                      ),
                    ),
                  ),
                );
                mediaWidget = Stack(
                  fit: StackFit.expand,
                  children: [
                    const ColoredBox(color: Color(0xFFE8E8E8)),
                    imageWidget,
                  ],
                );
              } else if (item.isVideo && item.videoType == VideoType.native) {
                mediaWidget = VideoThumbnailPlayer(videoUrl: item.url);
              } else {
                mediaWidget = Container(
                  color: Colors.black,
                  child: Center(
                    child: Icon(
                      item.isVideo
                          ? MingCuteIcons.mgc_video_camera_line
                          : MingCuteIcons.mgc_pic_2_line,
                      color: Colors.white54,
                      size: 32,
                    ),
                  ),
                );
              }

              return SizedBox(
                width: frameW,
                height: frameH,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    mediaWidget,
                    if (item.isVideo)
                      Positioned(
                        bottom: PostDetailTokens.spaceMd,
                        left: PostDetailTokens.spaceMd,
                        child: Container(
                          padding: const EdgeInsets.all(
                            PostDetailTokens.spaceSm,
                          ),
                          decoration: BoxDecoration(
                            color: PostDetailTokens.textBlack.withValues(
                              alpha: 0.55,
                            ),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.2),
                              width: 1,
                            ),
                          ),
                          child: Icon(
                            item.videoType == VideoType.youtube
                                ? MingCuteIcons.mgc_youtube_fill
                                : MingCuteIcons.mgc_play_fill,
                            color: Colors.white,
                            size: PostDetailTokens.iconMd,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
