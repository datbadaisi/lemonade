import 'package:flutter/material.dart';

/// Base / highlight colors for image & layout shimmer placeholders.
const Color kShimmerBase = Color(0xFFE8E8E8);

/// Very soft highlight — barely lighter than base for a gentle wash.
const Color kShimmerHighlight = Color(0xFFECECEC);

/// Sliding shimmer gradient that is seamless when [progress] loops 0→1.
///
/// The highlight band fully leaves the visible area at both ends of the
/// animation, so [AnimationController.repeat] has no visible jump/flick.
LinearGradient slidingShimmerGradient(double progress) {
  // progress 0: band fully left of view; progress 1: fully right of view.
  // Wider span + soft multi-stop ramp = broad, diffuse glow.
  final dx = -2.4 + 4.8 * progress;
  return LinearGradient(
    begin: Alignment(dx, -0.2),
    end: Alignment(dx + 1.8, 0.2),
    colors: const [
      kShimmerBase,
      kShimmerBase,
      Color(0xFFEAEAEA),
      kShimmerHighlight,
      Color(0xFFEAEAEA),
      kShimmerBase,
      kShimmerBase,
    ],
    stops: const [0.0, 0.15, 0.32, 0.5, 0.68, 0.85, 1.0],
  );
}

/// Drop-in shimmer for image / avatar loading placeholders.
///
/// Use as a [CachedNetworkImage] `placeholder`, or anywhere a soft loading
/// surface is needed. Expands to parent constraints when size is omitted.
class ShimmerPlaceholder extends StatefulWidget {
  final double? width;
  final double? height;
  final double borderRadius;
  final BoxShape shape;

  const ShimmerPlaceholder({
    super.key,
    this.width,
    this.height,
    this.borderRadius = 0,
    this.shape = BoxShape.rectangle,
  });

  /// Fills the parent (typical image placeholder inside a sized box).
  const ShimmerPlaceholder.fill({super.key})
      : width = null,
        height = null,
        borderRadius = 0,
        shape = BoxShape.rectangle;

  const ShimmerPlaceholder.circle({super.key, required double size})
      : width = size,
        height = size,
        borderRadius = 0,
        shape = BoxShape.circle;

  @override
  State<ShimmerPlaceholder> createState() => _ShimmerPlaceholderState();
}

class _ShimmerPlaceholderState extends State<ShimmerPlaceholder>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            shape: widget.shape,
            borderRadius: widget.shape == BoxShape.circle
                ? null
                : (widget.borderRadius > 0
                    ? BorderRadius.circular(widget.borderRadius)
                    : null),
            gradient: slidingShimmerGradient(_controller.value),
          ),
        );
      },
    );
  }
}

class Skeleton extends StatefulWidget {
  final double? width;
  final double? height;
  final double borderRadius;
  final BoxShape shape;

  const Skeleton({
    super.key,
    this.width,
    this.height,
    this.borderRadius = 8,
    this.shape = BoxShape.rectangle,
  });

  const Skeleton.circle({super.key, required double size})
      : width = size,
        height = size,
        borderRadius = 0,
        shape = BoxShape.circle;

  @override
  State<Skeleton> createState() => _SkeletonState();
}

class _SkeletonState extends State<Skeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // Sliding sweep (not reverse) so the loop end matches the start visually.
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            shape: widget.shape,
            borderRadius: widget.shape == BoxShape.circle
                ? null
                : BorderRadius.circular(widget.borderRadius),
            gradient: slidingShimmerGradient(_controller.value),
          ),
        );
      },
    );
  }
}

// ── Layout skeletons (mirror real widgets; spacing from PostCard design system)
// Spacing: 4 · 8 · 12 · 16
// PostCard: pad X16 Y12 · avatar 20 · title 16 · preview 13 · action bar 32 · media r20

/// Feed / list skeleton that mirrors [PostCard] shell and hierarchy.
///
/// Meta row → title → optional body lines → media (16:9, r20) → action pills.
class PostCardSkeleton extends StatelessWidget {
  /// When false, skips the body-preview block (title + media only).
  final bool showBodyPreview;

  /// When false, skips the media block (text-only posts).
  final bool showMedia;

  const PostCardSkeleton({
    super.key,
    this.showBodyPreview = true,
    this.showMedia = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Metadata: community avatar · c/name · u/author · time (right)
          SizedBox(
            height: 20,
            child: Row(
              children: [
                const Skeleton.circle(size: 20),
                const SizedBox(width: 4),
                const Skeleton(height: 12, width: 88, borderRadius: 4),
                const SizedBox(width: 6),
                const Skeleton(height: 12, width: 64, borderRadius: 4),
                const Spacer(),
                const Skeleton(height: 12, width: 36, borderRadius: 4),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Title (font 16 / height 1.3 → ~21; use 16 bars for density)
          const Skeleton(height: 16, width: double.infinity, borderRadius: 4),
          const SizedBox(height: 6),
          const Skeleton(height: 16, width: 220, borderRadius: 4),
          if (showBodyPreview) ...[
            const SizedBox(height: 8),
            const Skeleton(height: 13, width: double.infinity, borderRadius: 4),
            const SizedBox(height: 4),
            const Skeleton(height: 13, width: 240, borderRadius: 4),
          ],
          if (showMedia) ...[
            const SizedBox(height: 8),
            const AspectRatio(
              aspectRatio: 16 / 9,
              child: Skeleton(borderRadius: 20),
            ),
          ],
          const SizedBox(height: 8),
          // Bottom bar: comments pill + vote pill (height 32)
          const SizedBox(
            height: 32,
            child: Row(
              children: [
                Skeleton(height: 32, width: 52, borderRadius: 9999),
                SizedBox(width: 8),
                Skeleton(height: 32, width: 96, borderRadius: 9999),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Profile comments tab skeleton — mirrors [_CommentCard] on profile.
///
/// Community · time + score → post title → body lines.
class ProfileCommentCardSkeleton extends StatelessWidget {
  const ProfileCommentCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(12),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Skeleton(height: 12, width: 100, borderRadius: 4),
                    SizedBox(width: 6),
                    Skeleton(height: 12, width: 40, borderRadius: 4),
                  ],
                ),
              ),
              Skeleton(height: 12, width: 28, borderRadius: 4),
            ],
          ),
          SizedBox(height: 8),
          Skeleton(height: 14, width: double.infinity, borderRadius: 4),
          SizedBox(height: 4),
          Skeleton(height: 14, width: 200, borderRadius: 4),
          SizedBox(height: 8),
          Skeleton(height: 13, width: double.infinity, borderRadius: 4),
          SizedBox(height: 4),
          Skeleton(height: 13, width: double.infinity, borderRadius: 4),
          SizedBox(height: 4),
          Skeleton(height: 13, width: 180, borderRadius: 4),
        ],
      ),
    );
  }
}

/// Search "Comments" row skeleton — mirrors [_CommentSearchRow].
class SearchCommentRowSkeleton extends StatelessWidget {
  const SearchCommentRowSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Skeleton(height: 12, width: 160, borderRadius: 4),
          SizedBox(height: 4),
          Skeleton(height: 14, width: double.infinity, borderRadius: 4),
          SizedBox(height: 4),
          Skeleton(height: 14, width: 220, borderRadius: 4),
          SizedBox(height: 8),
          Row(
            children: [
              Skeleton.circle(size: 24),
              SizedBox(width: 8),
              Skeleton(height: 12, width: 100, borderRadius: 4),
            ],
          ),
          SizedBox(height: 8),
          Skeleton(height: 13, width: double.infinity, borderRadius: 4),
          SizedBox(height: 4),
          Skeleton(height: 13, width: double.infinity, borderRadius: 4),
          SizedBox(height: 4),
          Skeleton(height: 13, width: 200, borderRadius: 4),
        ],
      ),
    );
  }
}

/// Search community row — mirrors [_CommunitySearchRow].
class SearchCommunityRowSkeleton extends StatelessWidget {
  const SearchCommunityRowSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Skeleton.circle(size: 40),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Skeleton(height: 14, width: 140, borderRadius: 4),
                SizedBox(height: 4),
                Skeleton(height: 12, width: 180, borderRadius: 4),
                SizedBox(height: 4),
                Skeleton(height: 12, width: double.infinity, borderRadius: 4),
                SizedBox(height: 2),
                Skeleton(height: 12, width: 200, borderRadius: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Search user row — mirrors [_UserSearchRow].
class SearchUserRowSkeleton extends StatelessWidget {
  const SearchUserRowSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        children: [
          Skeleton.circle(size: 38),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Skeleton(height: 14, width: 110, borderRadius: 4),
                SizedBox(height: 4),
                Skeleton(height: 12, width: 90, borderRadius: 4),
                SizedBox(height: 4),
                Skeleton(height: 10, width: 150, borderRadius: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Notification inbox tile — mirrors notification card (title → meta → type → body).
class NotificationTileSkeleton extends StatelessWidget {
  const NotificationTileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(12),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Skeleton(height: 14, width: double.infinity, borderRadius: 4),
          SizedBox(height: 4),
          Skeleton(height: 14, width: 200, borderRadius: 4),
          SizedBox(height: 8),
          Row(
            children: [
              Skeleton.circle(size: 24),
              SizedBox(width: 8),
              Skeleton(height: 12, width: 140, borderRadius: 4),
            ],
          ),
          SizedBox(height: 4),
          Skeleton(height: 12, width: 140, borderRadius: 4),
          SizedBox(height: 8),
          Skeleton(height: 13, width: double.infinity, borderRadius: 4),
          SizedBox(height: 4),
          Skeleton(height: 13, width: double.infinity, borderRadius: 4),
          SizedBox(height: 4),
          Skeleton(height: 13, width: 180, borderRadius: 4),
        ],
      ),
    );
  }
}

/// Messages conversation row — avatar · name · preview · time.
class ConversationTileSkeleton extends StatelessWidget {
  const ConversationTileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: const Row(
        children: [
          Skeleton.circle(size: 40),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Skeleton(height: 14, width: 120, borderRadius: 4),
                SizedBox(height: 4),
                Skeleton(height: 13, width: double.infinity, borderRadius: 4),
              ],
            ),
          ),
          SizedBox(width: 12),
          Skeleton(height: 12, width: 36, borderRadius: 4),
        ],
      ),
    );
  }
}

/// Subscribed communities row — avatar · title/subtitle · Unsubscribe pill.
class SubscribedCommunityTileSkeleton extends StatelessWidget {
  const SubscribedCommunityTileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Skeleton.circle(size: 40),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Skeleton(height: 15, width: 140, borderRadius: 4),
                SizedBox(height: 4),
                Skeleton(height: 13, width: 180, borderRadius: 4),
              ],
            ),
          ),
          SizedBox(width: 12),
          Skeleton(height: 32, width: 96, borderRadius: 9999),
        ],
      ),
    );
  }
}

/// Create-post community picker row (ListTile-style, 36px avatar).
class CommunityPickerRowSkeleton extends StatelessWidget {
  const CommunityPickerRowSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: Row(
        children: [
          Skeleton.circle(size: 36),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Skeleton(height: 14, width: 140, borderRadius: 4),
                SizedBox(height: 8),
                Skeleton(height: 12, width: 200, borderRadius: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Discover horizontal community cell (avatar + 4 text lines + optional Join).
class DiscoverCommunityRowSkeleton extends StatelessWidget {
  final bool showJoinPill;

  const DiscoverCommunityRowSkeleton({
    super.key,
    this.showJoinPill = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Skeleton.circle(size: 44),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Skeleton(height: 14, width: 140, borderRadius: 4),
                      SizedBox(height: 4),
                      Skeleton(height: 12, width: 90, borderRadius: 4),
                      SizedBox(height: 4),
                      Skeleton(height: 12, width: 180, borderRadius: 4),
                      SizedBox(height: 4),
                      Skeleton(height: 10, width: 120, borderRadius: 4),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (showJoinPill) ...[
            const SizedBox(width: 8),
            const Skeleton(height: 28, width: 48, borderRadius: 9999),
          ],
        ],
      ),
    );
  }
}

/// Post detail header skeleton — author meta · title · body · action pills.
class PostDetailHeaderSkeleton extends StatelessWidget {
  const PostDetailHeaderSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author row: avatar 20 · u/name · time
          Row(
            children: [
              Skeleton.circle(size: 20),
              SizedBox(width: 4),
              Skeleton(height: 12, width: 100, borderRadius: 4),
              Spacer(),
              Skeleton(height: 12, width: 40, borderRadius: 4),
            ],
          ),
          SizedBox(height: 8),
          Skeleton(height: 16, width: double.infinity, borderRadius: 4),
          SizedBox(height: 6),
          Skeleton(height: 16, width: 220, borderRadius: 4),
          SizedBox(height: 8),
          Skeleton(height: 13, width: double.infinity, borderRadius: 4),
          SizedBox(height: 4),
          Skeleton(height: 13, width: double.infinity, borderRadius: 4),
          SizedBox(height: 4),
          Skeleton(height: 13, width: 160, borderRadius: 4),
          SizedBox(height: 8),
          // Actions: comments + vote + spacer + share
          SizedBox(
            height: 32,
            child: Row(
              children: [
                Skeleton(height: 32, width: 52, borderRadius: 9999),
                SizedBox(width: 8),
                Skeleton(height: 32, width: 96, borderRadius: 9999),
                Spacer(),
                Skeleton(height: 32, width: 32, borderRadius: 9999),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
