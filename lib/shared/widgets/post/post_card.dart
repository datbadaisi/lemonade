import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:bluerum/app/providers.dart';
import 'package:bluerum/app/theme/app_colors.dart';
import 'package:bluerum/shared/models/post.dart';
import 'package:bluerum/core/utils/markdown_utils.dart';
import 'package:bluerum/core/utils/media_utils.dart';
import 'package:bluerum/shared/widgets/media/blurred_image_background.dart';
import 'package:bluerum/shared/widgets/media/post_still_image.dart';
import 'package:bluerum/shared/widgets/media/video_player_widget.dart';
import 'package:bluerum/shared/widgets/avatar/network_avatar.dart';
import 'package:bluerum/shared/widgets/skeleton/skeleton.dart';
import 'package:bluerum/features/profile/presentation/profile_screen.dart';
import 'package:bluerum/features/community/presentation/community_detail_screen.dart';
import 'package:bluerum/features/community/data/community_repository_impl.dart';
import 'package:bluerum/features/post/data/post_repository_impl.dart';
import 'package:bluerum/features/feed/presentation/post_card_vm.dart';
import 'package:bluerum/shared/widgets/post/vote_bounce_button.dart';

// ── Post card design system ──────────────────────────────────────────
// Spacing (4-pt grid): 4 micro · 8 section · 12 shell-Y · 16 shell-X
// Type: 10 label · 12 meta/action/link · 13 body preview* · 16 title
//   *13 is the only half-step (12 too small, 14 too heavy for preview)
// Color hierarchy:
//   #000 title + c/ · #000 body · #333 action idle · #525252 meta
//   #E0E0E0 control borders · media hairline black@~12% (= #E0 on white)
//   AppColors.action / downvote for active controls

const double _spaceXs = 4;
const double _spaceSm = 8;
const double _spaceMd = 12;
const double _spaceLg = 16;

const double _fontLabel = 10;
const double _fontBody = 12;
const double _fontPreview = 13;
const double _fontTitle = 16;

const double _iconSm = 12;
const double _iconMd = 16;
const double _avatarMeta = 20;

const double _actionBarH = 32;
const double _pillH = 32;
const double _voteBtnW = 28;
const double _pillPadH = 8;

const Color _borderLight = Color(0xFFE0E0E0);
/// Media frame hairline: black ~12% — same weight as #E0E0E0 on white
/// (action-pill border), but still softens on mid-tone photos.
const Color _mediaBorder = Color(0x1F000000);
const Color _textSecondary = Color(0xFF525252);
const Color _accent = Color(0xFF000000);
const Color _textPrimary = Color(0xFF000000);
const Color _textBlack = Color(0xFF000000);
const Color _actionIdle = Color(0xFF333333);
const Color _skeletonBase = Color(0xFFE8E8E8);
/// Feed media frame fill — same as skeleton so placeholder→photo never
/// flashes black/gray layers (was a major inertial-scroll flicker source).
const Color _feedMediaFill = Color(0xFFE8E8E8);

/// Builds body-preview spans, swapping the spoiler marker glyph for the same
/// chevron icon used by interactive spoilers on the post detail screen.
List<InlineSpan> _bodyPreviewSpans(String plainText, TextStyle style) {
  final marker = '$kSpoilerCollapsedMarker ';
  if (!plainText.contains(marker)) {
    return [TextSpan(text: plainText)];
  }

  final iconColor = (style.color ?? _textPrimary).withValues(alpha: 0.6);
  final spans = <InlineSpan>[];
  var start = 0;

  while (true) {
    final index = plainText.indexOf(marker, start);
    if (index < 0) {
      if (start < plainText.length) {
        spans.add(TextSpan(text: plainText.substring(start)));
      }
      break;
    }
    if (index > start) {
      spans.add(TextSpan(text: plainText.substring(start, index)));
    }
    spans.add(WidgetSpan(
      alignment: PlaceholderAlignment.middle,
      child: Padding(
        padding: const EdgeInsets.only(right: _spaceXs),
        child: Icon(
          MingCuteIcons.mgc_right_line,
          size: _iconMd,
          color: iconColor))));
    start = index + marker.length;
  }

  return spans;
}

class PostCard extends ConsumerStatefulWidget {
  final PostView postView;
  final VoidCallback? onTap;
  final VoidCallback? onUpvote;
  final VoidCallback? onDownvote;
  final VoidCallback? onSave;
  final int? effectiveVote;
  final bool? effectiveSaved;
  final bool showCreator;
  final VoidCallback? onCommunityTap;

  /// Optional precomputed VM (home feed). When null, memoizes from [postView].
  final PostCardVm? vm;

  /// When true (list/feed), use solid letterbox + feed decode tier + no progressive full-res.
  final bool feedOptimized;

  const PostCard({
    super.key,
    required this.postView,
    this.onTap,
    this.onUpvote,
    this.onDownvote,
    this.onSave,
    this.effectiveVote,
    this.effectiveSaved,
    this.showCreator = true,
    this.onCommunityTap,
    this.vm,
    this.feedOptimized = false,
  });

  @override
  ConsumerState<PostCard> createState() => _PostCardState();
}

class _PostCardState extends ConsumerState<PostCard> {
  bool _subscribing = false;

  // Hot-path memo: body preview + media extract once per post body identity.
  int? _memoPostId;
  String? _memoBodySource;
  String _memoBodyPreview = '';
  List<MediaItem> _memoMedia = const [];

  void _ensureMemo(PostView postView) {
    final body = postView.post.body;
    if (_memoPostId == postView.post.id && _memoBodySource == body) {
      return;
    }
    _memoPostId = postView.post.id;
    _memoBodySource = body;
    _memoBodyPreview =
        body != null ? markdownToPlainText(body).trim() : '';
    _memoMedia = List<MediaItem>.unmodifiable(extractPostMedia(postView));
  }

  bool _isAlreadySubscribed(String subscribed, int communityId) {
    if (subscribed == 'Subscribed' || subscribed == 'Pending') return true;
    // Select only this id so unrelated session mutations skip rebuild.
    return ref.watch(
      sessionSubscribedCommunityIdsProvider.select(
        (s) => s.contains(communityId),
      ),
    );
  }

  Future<void> _subscribeToCommunity() async {
    if (_subscribing) return;

    final auth = ref.read(authRepositoryProvider);
    if (!auth.isLoggedIn) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Log in to subscribe to communities')));
      return;
    }

    final communityId = widget.postView.community.id;
    final communityName = widget.postView.community.name;
    setState(() => _subscribing = true);

    try {
      await ref.read(communityRepositoryProvider).follow(
        communityId: communityId,
        follow: true);

      if (!mounted) return;
      ref
          .read(sessionSubscribedCommunityIdsProvider.notifier)
          .add(communityId);
      setState(() => _subscribing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Subscribed to c/$communityName')));
    } catch (e) {
      if (!mounted) return;
      setState(() => _subscribing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Subscription failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final postView = widget.postView;
    final post = postView.post;
    final community = postView.community;
    final creator = postView.creator;
    final vm = widget.vm;

    final List<MediaItem> mediaItems;
    final String bodyPreview;
    if (vm != null) {
      mediaItems = vm.mediaItems;
      bodyPreview = vm.bodyPreview;
    } else {
      _ensureMemo(postView);
      mediaItems = _memoMedia;
      bodyPreview = _memoBodyPreview;
    }

    final hasMedia = mediaItems.isNotEmpty;
    final firstMedia = hasMedia ? mediaItems.first : null;
    final extraMediaCount = mediaItems.isEmpty ? 0 : mediaItems.length - 1;
    final showSubscribe =
        !_isAlreadySubscribed(postView.subscribed, community.id);
    // Select only this post id — avoid rebuild when other posts are marked read.
    final isRead = postView.read ||
        ref.watch(
          sessionReadPostIdsProvider.select((s) => s.contains(post.id)),
        );

    return RepaintBoundary(
      child: Container(
        color: Colors.white,
        child: InkWell(
          onTap: widget.onTap ?? () {},
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: _spaceLg,
              vertical: _spaceMd,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              // Metadata row: community · author · time
              _MetadataRow(
                community: community,
                creator: creator,
                published: post.published,
                postNsfw: post.nsfw,
                showCreator: widget.showCreator,
                deferAvatarWhileScrolling: widget.feedOptimized,
                onCreatorTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ProfileScreen(personId: creator.id)));
                },
                onCommunityTap: widget.onCommunityTap ??
                    () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => CommunityDetailScreen(
                            communityId: community.id,
                            communityName: community.name)));
                    }),

              const SizedBox(height: _spaceSm),

              // Title — slightly muted when the post has been read
              Text(
                post.name,
                style: TextStyle(
                  fontSize: _fontTitle,
                  fontWeight: FontWeight.w700,
                  color: isRead
                      ? _textBlack.withValues(alpha: 0.42)
                      : _textBlack,
                  height: 1.3),
                maxLines: 3,
                overflow: TextOverflow.ellipsis),

              // Link Preview
              if (post.embedTitle != null)
                Padding(
                  padding: const EdgeInsets.only(top: _spaceSm),
                  child: LinkPreview(post: post)),

              if (bodyPreview.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: _spaceSm),
                  // Spoiler marker → same mgc_right_line chevron as post detail
                  // (plain Text would show the raw ▶ glyph, which looks like an
                  // awkward emoji). WidgetSpan only appears when a spoiler is
                  // present; other cards stay a single TextSpan.
                  child: Text.rich(
                    TextSpan(
                      style: const TextStyle(
                        fontSize: _fontPreview,
                        color: _textPrimary,
                        height: 1.45,
                      ),
                      children: _bodyPreviewSpans(
                        bodyPreview,
                        const TextStyle(
                          fontSize: _fontPreview,
                          color: _textPrimary,
                          height: 1.45,
                        ),
                      ),
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

              // Thumbnail (locked aspect + feed-optimized media path)
              if (hasMedia && firstMedia != null)
                Padding(
                  padding: const EdgeInsets.only(top: _spaceSm),
                  child: PostCardMediaWidget(
                    postView: postView,
                    firstMedia: firstMedia,
                    extraMediaCount: extraMediaCount,
                    altText: post.altText ?? post.name,
                    lockedAspectRatio: vm?.aspectRatio,
                    // List cards: solid letterbox (no ImageFiltered on feed path).
                    solidLetterbox: true,
                    feedDecode: widget.feedOptimized,
                    allowProgressiveFullRes: !widget.feedOptimized,
                  )),

              const SizedBox(height: _spaceSm),

              // Bottom bar: vote inline + actions
              _BottomBar(
                postView: postView,
                effectiveVote: widget.effectiveVote ?? postView.myVote ?? 0,
                effectiveSaved: widget.effectiveSaved ?? postView.saved,
                onUpvote: widget.onUpvote,
                onDownvote: widget.onDownvote,
                onSave: widget.onSave,
                showSubscribe: showSubscribe,
                isSubscribing: _subscribing,
                onSubscribe: _subscribeToCommunity),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------- Metadata ----------

class _MetadataRow extends StatefulWidget {
  final dynamic community;
  final dynamic creator;
  final String published;
  final bool postNsfw;
  final VoidCallback? onCreatorTap;
  final VoidCallback? onCommunityTap;
  final bool showCreator;
  final bool deferAvatarWhileScrolling;

  const _MetadataRow({
    required this.community,
    required this.creator,
    required this.published,
    required this.postNsfw,
    this.onCreatorTap,
    this.onCommunityTap,
    this.showCreator = true,
    this.deferAvatarWhileScrolling = false,
  });

  @override
  State<_MetadataRow> createState() => _MetadataRowState();
}

class _MetadataRowState extends State<_MetadataRow> {
  late final TapGestureRecognizer _communityTap;
  late final TapGestureRecognizer _creatorTap;

  // ── Time-ago cache (cleared every 60 s to stay fresh at boundaries) ──
  static final Map<String, String> _timeCache = {};
  static DateTime _cacheClearedAt = DateTime.now();

  @override
  void initState() {
    super.initState();
    _communityTap = TapGestureRecognizer()..onTap = widget.onCommunityTap;
    _creatorTap = TapGestureRecognizer()..onTap = widget.onCreatorTap;
  }

  @override
  void didUpdateWidget(covariant _MetadataRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    _communityTap.onTap = widget.onCommunityTap;
    _creatorTap.onTap = widget.onCreatorTap;
  }

  @override
  void dispose() {
    _communityTap.dispose();
    _creatorTap.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final community = widget.community;
    final creator = widget.creator;
    return SizedBox(
      height: _avatarMeta,
      child: Row(
        children: [
          NetworkAvatar(
            size: _avatarMeta,
            imageUrl: community.icon,
            name: community.title.isNotEmpty
                ? community.title
                : community.name,
            deferWhileScrolling: widget.deferAvatarWhileScrolling,
          ),
          const SizedBox(width: _spaceXs),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'c/${community.name}',
                    style: const TextStyle(
                      fontSize: _fontBody,
                      fontWeight: FontWeight.w700,
                      color: _textBlack),
                    recognizer: _communityTap),
                  if (widget.showCreator)
                    TextSpan(
                      text: ' · u/${creator.name}',
                      style: const TextStyle(
                        fontSize: _fontBody,
                        color: _textSecondary),
                      recognizer: _creatorTap),
                ]),
              overflow: TextOverflow.ellipsis)),
          Text(
            _timeAgo(widget.published),
            style: const TextStyle(fontSize: _fontBody, color: _textSecondary)),
          if (widget.postNsfw) ...[
            const SizedBox(width: _spaceXs),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: _spaceXs,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: _accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(_spaceXs)),
              child: const Text(
                'NSFW',
                style: TextStyle(
                  fontSize: _fontLabel,
                  fontWeight: FontWeight.w700,
                  color: _accent))),
          ],
        ]));
  }

  String _timeAgo(String published) {
    final now = DateTime.now();
    if (now.difference(_cacheClearedAt).inSeconds >= 60) {
      _timeCache.clear();
      _cacheClearedAt = now;
    }
    final bucket =
        '${now.year}-${now.month}-${now.day}-${now.hour}-${now.minute}';
    final key = '$published|$bucket';
    if (_timeCache.containsKey(key)) return _timeCache[key]!;

    final date = DateTime.tryParse(published);
    if (date == null) return '';
    final diff = now.toUtc().difference(date);
    late final String result;
    if (diff.inDays > 365) {
      result = '${diff.inDays ~/ 365} yr. ago';
    } else if (diff.inDays > 30) {
      result = '${diff.inDays ~/ 30} mo. ago';
    } else if (diff.inDays > 0) {
      result = '${diff.inDays} d. ago';
    } else if (diff.inHours > 0) {
      result = '${diff.inHours} hr. ago';
    } else if (diff.inMinutes > 0) {
      result = '${diff.inMinutes} min. ago';
    } else {
      result = 'just now';
    }
    _timeCache[key] = result;
    return result;
  }
}

// ---------- Bottom bar: vote + actions ----------

class _BottomBar extends StatelessWidget {
  final PostView postView;
  final VoidCallback? onUpvote;
  final VoidCallback? onDownvote;
  final VoidCallback? onSave;
  final VoidCallback? onSubscribe;
  final bool showSubscribe;
  final bool isSubscribing;
  final int effectiveVote;
  final bool effectiveSaved;

  const _BottomBar({
    required this.postView,
    required this.effectiveVote,
    required this.effectiveSaved,
    this.onUpvote,
    this.onDownvote,
    this.onSave,
    this.onSubscribe,
    this.showSubscribe = false,
    this.isSubscribing = false,
  });

  @override
  Widget build(BuildContext context) {
    final counts = postView.counts;
    final displayedScore =
        counts.score + effectiveVote - (postView.myVote ?? 0);

    return SizedBox(
      height: _actionBarH,
      child: Row(
        children: [
          // Comments pill
          _PillButton(
            icon: MingCuteIcons.mgc_chat_1_line,
            label: _formatCount(counts.comments),
            tooltip: 'Comments'),

          const SizedBox(width: _spaceSm),

          // Vote pill: ▲ score ▼
          Container(
            height: _pillH,
            padding: const EdgeInsets.symmetric(horizontal: _pillPadH),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(9999),
              border: Border.all(color: _borderLight)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                VoteBounceButton(
                  onPressed: onUpvote,
                  tooltip: effectiveVote == 1 ? 'Remove upvote' : 'Upvote',
                  width: _voteBtnW,
                  height: _pillH,
                  direction: 1,
                  child: Icon(
                    effectiveVote == 1
                        ? MingCuteIcons.mgc_large_arrow_up_fill
                        : MingCuteIcons.mgc_large_arrow_up_line,
                    size: _iconMd,
                    color: effectiveVote == 1
                        ? AppColors.action
                        : _actionIdle)),
                Text(
                  _formatCount(displayedScore),
                  style: const TextStyle(
                    fontSize: _fontBody,
                    fontWeight: FontWeight.w700,
                    color: _actionIdle)),
                VoteBounceButton(
                  onPressed: onDownvote,
                  tooltip: effectiveVote == -1 ? 'Remove downvote' : 'Downvote',
                  width: _voteBtnW,
                  height: _pillH,
                  direction: 1,
                  child: Icon(
                    effectiveVote == -1
                        ? MingCuteIcons.mgc_large_arrow_down_fill
                        : MingCuteIcons.mgc_large_arrow_down_line,
                    size: _iconMd,
                    color: effectiveVote == -1
                        ? AppColors.downvote
                        : _actionIdle)),
              ])),

          const Spacer(),

          // Subscribe to community (hidden when already subscribed)
          if (showSubscribe)
            _SubscribePill(
              isLoading: isSubscribing,
              onTap: isSubscribing ? null : onSubscribe),
        ]));
  }


  String _formatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    if (count == 0) return '';
    return count.toString();
  }
}

// ---------- Subscribe pill ----------

class _SubscribePill extends StatelessWidget {
  final bool isLoading;
  final VoidCallback? onTap;

  const _SubscribePill({
    required this.isLoading,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Subscribe to community',
      child: Tooltip(
        message: 'Subscribe to community',
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(9999),
          child: Container(
            height: _pillH,
            padding: const EdgeInsets.symmetric(horizontal: _pillPadH),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(9999),
              // Match label blue so the pill reads as one interactive control.
              border: Border.all(color: AppColors.action),
            ),
            alignment: Alignment.center,
            child: isLoading
                ? const SizedBox(
                    width: _iconSm,
                    height: _iconSm,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.action,
                    ),
                  )
                : const Text(
                    'Subscribe',
                    style: TextStyle(
                      fontSize: _fontBody,
                      fontWeight: FontWeight.w600,
                      color: AppColors.action,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

// ---------- Pill button (icon + optional label) ----------

class _PillButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? tooltip;
  final VoidCallback? onTap;

  const _PillButton({
    required this.icon,
    required this.label,
    this.tooltip,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: onTap != null,
      label: tooltip ?? label,
      child: Tooltip(
        message: tooltip ?? label,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(9999),
          child: Container(
            height: _pillH,
            padding: const EdgeInsets.symmetric(horizontal: _pillPadH),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(9999),
              border: Border.all(color: _borderLight)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: _iconMd, color: _actionIdle),
                if (label.isNotEmpty) ...[
                  const SizedBox(width: _spaceXs),
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: _fontBody,
                      fontWeight: FontWeight.w600,
                      color: _actionIdle)),
                ],
              ])))));
  }
}

// ---------- Link Preview ----------

class LinkPreview extends StatelessWidget {
  final dynamic post;
  final bool isDetail;

  const LinkPreview({super.key, required this.post, this.isDetail = false});

  @override
  Widget build(BuildContext context) {
    final host = _getHost(post.url);

    return InkWell(
      onTap: () async {
        final urlStr = post.url;
        if (urlStr != null && urlStr.isNotEmpty) {
          final uri = Uri.tryParse(urlStr);
          if (uri != null && uri.hasScheme) {
            try {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            } catch (_) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Could not open link')));
              }
            }
          }
        }
      },
      borderRadius: BorderRadius.circular(_spaceXs),
      // No vertical padding — section gaps (_spaceSm) live on the parent.
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (host != null)
              Padding(
                padding: const EdgeInsets.only(bottom: _spaceXs),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      MingCuteIcons.mgc_globe_2_line,
                      size: _iconSm,
                      color: _textSecondary),
                    const SizedBox(width: _spaceXs),
                    Text(
                      host.toLowerCase(),
                      style: const TextStyle(
                        fontSize: _fontLabel,
                        fontWeight: FontWeight.w700,
                        color: _textSecondary,
                        letterSpacing: 0.2)),
                  ])),
            Text(
              post.embedTitle ?? post.url ?? 'Link',
              style: const TextStyle(
                // Same as feed card (12) — detail no longer steps up.
                fontSize: _fontBody,
                fontWeight: FontWeight.w600,
                color: _textBlack,
                height: 1.3),
              maxLines: isDetail ? null : 2,
              overflow: isDetail ? null : TextOverflow.ellipsis),
            if (post.embedDescription != null &&
                post.embedDescription.isNotEmpty) ...[
              const SizedBox(height: _spaceXs),
              Text(
                post.embedDescription,
                style: const TextStyle(
                  fontSize: _fontBody,
                  color: _textSecondary,
                  height: 1.45),
                maxLines: isDetail ? null : 2,
                overflow: isDetail ? null : TextOverflow.ellipsis),
            ],
          ])));
  }

  String? _getHost(String? url) {
    if (url == null || url.isEmpty) return null;
    try {
      final uri = Uri.parse(url);
      return uri.host.replaceFirst('www.', '');
    } catch (_) {
      return null;
    }
  }
}

// ---------- PostCardMediaWidget (locked aspect + solid letterbox) ----------

class PostCardMediaWidget extends StatefulWidget {
  final PostView postView;
  final MediaItem firstMedia;
  final int extraMediaCount;
  final String altText;

  /// When set (from [PostCardVm]), skips mid-scroll ImageStream height thrash.
  final double? lockedAspectRatio;

  /// Solid letterbox instead of [BlurredImageBackground] (home feed product).
  final bool solidLetterbox;

  /// Use feed list decode path (ScrollStable + solid gray fill).
  final bool feedDecode;

  /// Progressive dual-layer full-res (detail only; off on feed).
  final bool allowProgressiveFullRes;

  const PostCardMediaWidget({
    super.key,
    required this.postView,
    required this.firstMedia,
    required this.extraMediaCount,
    required this.altText,
    this.lockedAspectRatio,
    this.solidLetterbox = true,
    this.feedDecode = false,
    this.allowProgressiveFullRes = false,
  });

  @override
  State<PostCardMediaWidget> createState() => _PostCardMediaWidgetState();
}

class _PostCardMediaWidgetState extends State<PostCardMediaWidget> {
  /// Locked once — never updated after first non-null resolution.
  double? _lockedRatio;

  @override
  void initState() {
    super.initState();
    _bootstrapRatio();
  }

  @override
  void didUpdateWidget(covariant PostCardMediaWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.firstMedia.url != widget.firstMedia.url ||
        oldWidget.lockedAspectRatio != widget.lockedAspectRatio) {
      _lockedRatio = null;
      _bootstrapRatio();
    }
  }

  void _lock(double ratio) {
    if (_lockedRatio != null) return;
    _lockedRatio = ratio.clamp(0.8, 3.0);
  }

  void _bootstrapRatio() {
    if (widget.lockedAspectRatio != null) {
      _lock(widget.lockedAspectRatio!);
      return;
    }
    if (widget.firstMedia.isVideo &&
        widget.firstMedia.videoType == VideoType.youtube) {
      _lock(16 / 9);
      return;
    }

    final details = widget.postView.imageDetails;
    final isGif = widget.firstMedia.url.toLowerCase().contains('.gif') ||
        (details?.link.toLowerCase().contains('.gif') ?? false);

    if (details != null &&
        details.width > 0 &&
        details.height > 0 &&
        !isGif) {
      _lock(details.aspectRatio);
      return;
    }

    // Stable default only — do NOT resolve a full-res ImageStream here.
    // A discarded listener still starts decode/network and was a silent hitch
    // when aspect was unknown (no imageDetails / cache).
    _lock(16 / 9);
  }

  @override
  Widget build(BuildContext context) {
    final details = widget.postView.imageDetails;
    final imageAspectRatio = _lockedRatio ?? 16 / 9;
    // letterbox when original would clamp — approximate from locked ratio.
    final isClamped = imageAspectRatio <= 0.801 || imageAspectRatio >= 2.999;

    String? fullResUrl;
    if (widget.allowProgressiveFullRes) {
      final link = details?.link;
      if (link != null &&
          link.isNotEmpty &&
          link != widget.firstMedia.url &&
          link != widget.firstMedia.fallbackUrl) {
        fullResUrl = link;
      }
    }

    // Feed: hardEdge is much cheaper than antiAlias on every media card.
    final clip = widget.feedDecode ? Clip.hardEdge : Clip.antiAlias;

    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
      foregroundDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _mediaBorder)),
      clipBehavior: clip,
      child: AspectRatio(
        aspectRatio: imageAspectRatio,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Letterbox / empty media fill. Feed uses soft gray only — never
            // black — so ScrollStable placeholder and this layer are one color.
            if (widget.solidLetterbox)
              ColoredBox(
                color: widget.feedDecode ? _feedMediaFill : Colors.black,
              )
            else
              Builder(builder: (_) {
                String? bgUrl;
                if (widget.firstMedia.type == MediaType.image) {
                  bgUrl = widget.firstMedia.url;
                } else if (widget.firstMedia.thumbnailUrl != null &&
                    widget.firstMedia.thumbnailUrl!.isNotEmpty) {
                  bgUrl = widget.firstMedia.thumbnailUrl;
                }
                return bgUrl != null
                    ? BlurredImageBackground(imageUrl: bgUrl)
                    : const ColoredBox(color: Colors.black);
              }),
            if (widget.firstMedia.type == MediaType.image)
              PostStillImage(
                url: widget.firstMedia.url,
                fullResUrl: fullResUrl,
                fallbackUrl: widget.firstMedia.fallbackUrl,
                altText: widget.altText,
                fit: isClamped ? BoxFit.contain : BoxFit.cover,
                listDecode: widget.feedDecode,
                allowProgressiveFullRes: widget.allowProgressiveFullRes,
                placeholderColor:
                    widget.feedDecode ? _feedMediaFill : _skeletonBase,
              )
            else if (widget.firstMedia.thumbnailUrl != null &&
                widget.firstMedia.thumbnailUrl!.isNotEmpty)
              PostStillImage(
                url: widget.firstMedia.thumbnailUrl!,
                fallbackUrl: widget.firstMedia.fallbackUrl,
                altText: widget.altText,
                fit: isClamped ? BoxFit.contain : BoxFit.cover,
                listDecode: widget.feedDecode,
                allowProgressiveFullRes: false,
                placeholderColor:
                    widget.feedDecode ? _feedMediaFill : _skeletonBase,
              )
            else if (widget.firstMedia.videoType == VideoType.native)
              VideoThumbnailPlayer(videoUrl: widget.firstMedia.url)
            else
              ColoredBox(
                color: widget.feedDecode ? _feedMediaFill : Colors.black,
                child: Center(
                  child: Icon(
                    MingCuteIcons.mgc_video_camera_line,
                    color: widget.feedDecode
                        ? _textSecondary
                        : Colors.white60,
                    size: _spaceLg * 2,
                  ),
                ),
              ),
            // Solid translucent badges (no BackdropFilter on feed path).
            if (widget.firstMedia.type == MediaType.video)
              Positioned(
                bottom: _spaceMd,
                left: _spaceMd,
                child: Container(
                  padding: const EdgeInsets.all(_spaceSm),
                  decoration: BoxDecoration(
                    color: _textBlack.withValues(alpha: 0.55),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    widget.firstMedia.videoType == VideoType.youtube
                        ? MingCuteIcons.mgc_youtube_fill
                        : MingCuteIcons.mgc_play_fill,
                    color: Colors.white,
                    size: _iconMd,
                  ),
                ),
              ),
            if (widget.extraMediaCount > 0)
              Positioned(
                top: _spaceMd,
                right: _spaceMd,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: _spaceSm,
                    vertical: _spaceXs,
                  ),
                  decoration: BoxDecoration(
                    color: _textBlack.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(_spaceMd),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '+${widget.extraMediaCount}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: _fontBody,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
