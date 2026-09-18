import 'package:flutter/material.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:bluerum/core/utils/media_utils.dart';
import 'package:bluerum/shared/widgets/media/full_screen_media_viewer.dart';
import 'package:bluerum/shared/widgets/media/media_precache.dart';
import 'package:bluerum/shared/widgets/media/scroll_stable_network_image.dart';
import 'package:bluerum/shared/widgets/media/video_player_widget.dart';

/// Multi-image / multi-media strip with a real [PageView] + glass dots.
///
/// Used on **post detail** and **comment multi-media** (same chrome).
class PostImageCarousel extends StatefulWidget {
  final List<MediaItem> mediaItems;
  final double? aspectRatio;
  final String? heroTagPrefix;

  /// Cap carousel height (e.g. comments use ~55% screen). Defaults to 1.2× screen.
  final double? maxHeight;

  /// Override decode width (e.g. [inPageMediaMemCacheWidth] for post-detail hero
  /// so ImageCache hits the feed card key).
  final int? memCacheWidth;

  const PostImageCarousel({
    super.key,
    required this.mediaItems,
    this.aspectRatio,
    this.heroTagPrefix,
    this.maxHeight,
    this.memCacheWidth,
  });

  @override
  State<PostImageCarousel> createState() => _PostImageCarouselState();
}

class _PostImageCarouselState extends State<PostImageCarousel> {
  late final PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _precachePages(_currentPage);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  int _decodedImageWidth() =>
      widget.memCacheWidth ?? inPageMediaMemCacheWidth(context);

  void _precachePages(int index) {
    if (!mounted) return;
    if (scrollActivityBusy(context)) {
      whenScrollActivityIdle(context, () {
        if (mounted) _precachePages(index);
      });
      return;
    }

    final urls = widget.mediaItems
        .map((item) => item.isImage ? item.url : (item.thumbnailUrl ?? ''))
        .toList(growable: false);
    final cacheWidth = _decodedImageWidth();

    // Neighbors only — avoid queuing the whole strip onto the global slot.
    for (var candidate = index; candidate <= index + 1; candidate++) {
      if (candidate < 0 || candidate >= urls.length) continue;
      final url = urls[candidate];
      if (url.isEmpty) continue;
      final captured = url;
      ImageDecodeBudget.schedule((done) {
        if (!mounted) {
          done();
          return;
        }
        precacheMediaImage(
          context,
          captured,
          cacheWidth: cacheWidth,
        ).whenComplete(done);
      });
    }
  }

  Future<void> _openItem(int index) async {
    final items = widget.mediaItems;
    final item = items[index];

    if (item.isVideo && item.videoType == VideoType.youtube) {
      final uri = Uri.parse(item.url);
      try {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (_) {}
      return;
    }

    if (!mounted) return;
    final result = await FullScreenMediaViewer.open(
      context,
      mediaItems: items,
      initialIndex: index,
      carouselController: _pageController,
    );
    if (result != null && mounted && _pageController.hasClients) {
      _pageController.animateToPage(
        result,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
      );
    }
  }

  Widget _buildSlide({
    required MediaItem item,
    required int index,
    required double contentWidth,
    required double carouselHeight,
  }) {
    final displayUrl =
        item.type == MediaType.image ? item.url : item.thumbnailUrl;

    Widget mediaContent;
    if (displayUrl != null && displayUrl.isNotEmpty) {
      // Always contain: full image in-page (post detail + comment carousel).
      // Tall slides are height-capped by the parent; gray letterbox, never crop.
      final imageWidget = ScrollStableNetworkImage(
        imageUrl: displayUrl,
        memCacheWidth: _decodedImageWidth(),
        width: contentWidth,
        height: carouselHeight,
        fit: BoxFit.contain,
        errorWidget: (_) => ColoredBox(
          color: const Color(0xFFE8E8E8),
          child: Center(
            child: Icon(
              item.isVideo
                  ? MingCuteIcons.mgc_video_camera_line
                  : MingCuteIcons.mgc_pic_2_line,
              color: const Color(0xFF525252),
            ),
          ),
        ),
      );
      mediaContent = Stack(
        fit: StackFit.expand,
        children: [
          const ColoredBox(color: Color(0xFFE8E8E8)),
          imageWidget,
        ],
      );
    } else if (item.isVideo && item.videoType == VideoType.native) {
      mediaContent = VideoThumbnailPlayer(videoUrl: item.url);
    } else {
      mediaContent = Container(
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

    return GestureDetector(
      onTap: () => _openItem(index),
      child: Stack(
        fit: StackFit.expand,
        children: [
          mediaContent,
          if (item.isVideo)
            Positioned(
              bottom: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.55),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 0.8,
                  ),
                ),
                child: Icon(
                  item.videoType == VideoType.youtube
                      ? MingCuteIcons.mgc_youtube_fill
                      : MingCuteIcons.mgc_play_fill,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.mediaItems;
    if (items.isEmpty) return const SizedBox.shrink();

    final screenHeight = MediaQuery.sizeOf(context).height;
    final maxHeight = widget.maxHeight ?? screenHeight * 1.2;

    return LayoutBuilder(
      builder: (context, constraints) {
        final contentWidth = constraints.maxWidth;
        final ratio = widget.aspectRatio ?? 16 / 9;
        final calcHeight = contentWidth / ratio;
        final useCapped = calcHeight > maxHeight;
        final carouselHeight = useCapped ? maxHeight : calcHeight;

        return ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Container(
            height: carouselHeight,
            width: double.infinity,
            foregroundDecoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0x1F000000)),
            ),
            child: Stack(
              children: [
                PageView.builder(
                  controller: _pageController,
                  // Snappy page snap; bounce only at ends feels wrong mid-gallery.
                  physics: const PageScrollPhysics(
                    parent: ClampingScrollPhysics(),
                  ),
                  allowImplicitScrolling: true,
                  onPageChanged: (page) {
                    setState(() => _currentPage = page);
                    _precachePages(page);
                  },
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    return _buildSlide(
                      item: items[index],
                      index: index,
                      contentWidth: contentWidth,
                      carouselHeight: carouselHeight,
                    );
                  },
                ),
                if (items.length > 1)
                  Positioned(
                    bottom: 12,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: _GlassDotIndicator(
                        count: items.length,
                        activeIndex: _currentPage,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _GlassDotIndicator extends StatelessWidget {
  final int count;
  final int activeIndex;

  const _GlassDotIndicator({required this.count, required this.activeIndex});

  double _scale(int index) {
    final d = (index - activeIndex).abs();
    if (d == 0) return 1.0;
    if (d == 1) return 0.7;
    if (d == 2) return 0.5;
    return 0.35;
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 28,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
            width: 0.8,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: List.generate(count, (i) {
            final d = (i - activeIndex).abs();
            final scale = _scale(i);
            final isActive = i == activeIndex;
            return AnimatedContainer(
              key: ValueKey(i),
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              margin: EdgeInsets.symmetric(horizontal: d <= 2 ? 3.0 : 2.0),
              width: 6 * scale,
              height: 6 * scale,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive
                    ? Colors.white
                    : Colors.white.withValues(alpha: d <= 2 ? 0.6 : 0.3),
              ),
            );
          }),
        ),
      ),
    );
  }
}
