import 'package:flutter/material.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:bluerum/core/utils/media_utils.dart';
import 'package:bluerum/shared/widgets/media/full_screen_media_viewer.dart';
import 'package:bluerum/shared/widgets/media/media_aspect_cache.dart';
import 'package:bluerum/shared/widgets/media/media_fit.dart';
import 'package:bluerum/shared/widgets/media/media_precache.dart';
import 'package:bluerum/shared/widgets/media/scroll_stable_network_image.dart';
import 'package:bluerum/shared/widgets/post/post_image_carousel.dart';

/// Comment media attachment.
///
/// - **Single** item: aspect-fit still (full picture, no crop), capped at ~55%
///   screen height.
/// - **Multiple** items: same [PostImageCarousel] chrome as post detail
///   (swipeable [PageView] + glass dots), also height-capped for the list.
class CommentMediaWidget extends StatefulWidget {
  final MediaItem item;
  final List<MediaItem> allMedia;

  /// Thread depth — parent owns indent; kept for call-site compatibility.
  final double depth;

  /// Deprecated: multi-media uses a carousel; kept for call-site compatibility.
  final int extraCount;

  const CommentMediaWidget({
    super.key,
    required this.item,
    required this.allMedia,
    required this.depth,
    this.extraCount = 0,
  });

  @override
  State<CommentMediaWidget> createState() => _CommentMediaWidgetState();
}

class _CommentMediaWidgetState extends State<CommentMediaWidget> {
  /// Known width/height ratio (defaults to 16:9 until measured).
  double _aspect = 16 / 9;

  ImageStream? _stream;
  ImageStreamListener? _listener;
  String? _probedUrl;

  MediaItem get item => widget.item;

  String? get _displayUrl =>
      item.type == MediaType.image ? item.url : item.thumbnailUrl;

  @override
  void initState() {
    super.initState();
    _bootstrapAspect();
  }

  @override
  void didUpdateWidget(covariant CommentMediaWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldUrl = oldWidget.item.type == MediaType.image
        ? oldWidget.item.url
        : oldWidget.item.thumbnailUrl;
    if (oldUrl != _displayUrl) {
      _detachStream();
      _aspect = 16 / 9;
      _bootstrapAspect();
    }
  }

  @override
  void dispose() {
    _detachStream();
    super.dispose();
  }

  void _detachStream() {
    if (_stream != null && _listener != null) {
      _stream!.removeListener(_listener!);
    }
    _stream = null;
    _listener = null;
    _probedUrl = null;
  }

  void _bootstrapAspect() {
    if (item.isVideo &&
        (item.thumbnailUrl == null || item.thumbnailUrl!.isEmpty)) {
      _aspect = 16 / 9;
      return;
    }

    final url = _displayUrl;
    if (url == null || url.isEmpty) {
      _aspect = 16 / 9;
      return;
    }

    final cached = cachedMediaAspect(url);
    if (cached != null) {
      _aspect = cached;
      return;
    }

    _aspect = 16 / 9;
    _probeAspect(url);
  }

  void _probeAspect(String url) {
    if (_probedUrl == url) return;
    _probedUrl = url;

    // Need MediaQuery for decode width — same key as paint so ImageCache hits.
    void attach() {
      if (!mounted || _displayUrl != url) return;
      _detachStream();
      _probedUrl = url;
      final provider = mediaImageProvider(
        url,
        cacheWidth: inPageMediaMemCacheWidth(context),
      );
      _stream = provider.resolve(const ImageConfiguration());
      _listener = ImageStreamListener(
        (ImageInfo info, bool sync) {
          final w = info.image.width;
          final h = info.image.height;
          if (w <= 0 || h <= 0) return;
          // ResizeImage keeps source aspect; ratio is still correct.
          final ratio = w / h;
          putMediaAspect(url, ratio);
          _applyAspect(ratio);
        },
        onError: (_, _) {},
      );
      _stream!.addListener(_listener!);
    }

    // Defer so didChangeDependencies / MediaQuery are available; also skip
    // decode stampede mid-fling (same FPS policy as paint).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (scrollActivityBusy(context)) {
        whenScrollActivityIdle(context, attach);
      } else {
        attach();
      }
    });
  }

  void _applyAspect(double ratio) {
    if (!mounted) return;
    final next = ratio.clamp(0.2, 5.0);
    if ((_aspect - next).abs() < 0.01) return;

    void commit() {
      if (!mounted) return;
      if ((_aspect - next).abs() < 0.01) return;
      setState(() => _aspect = next);
    }

    // Avoid height jumps mid-fling.
    if (scrollActivityBusy(context)) {
      whenScrollActivityIdle(context, commit);
    } else {
      commit();
    }
  }

  Future<void> _openMedia(BuildContext context) async {
    if (item.isVideo && item.videoType == VideoType.youtube) {
      final uri = Uri.parse(item.url);
      try {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (_) {}
      return;
    }

    final start = widget.allMedia
        .indexOf(item)
        .clamp(0, widget.allMedia.isEmpty ? 0 : widget.allMedia.length - 1);

    await FullScreenMediaViewer.open(
      context,
      mediaItems: widget.allMedia,
      initialIndex: start,
    );
  }

  @override
  Widget build(BuildContext context) {
    final maxH = MediaQuery.sizeOf(context).height * 0.55;

    // Multi-media: same carousel as post detail (swipe + dots), height-capped.
    if (widget.allMedia.length > 1) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: PostImageCarousel(
          mediaItems: widget.allMedia,
          aspectRatio: _aspect,
          maxHeight: maxH,
        ),
      );
    }

    final displayUrl = _displayUrl;
    final cacheW = inPageMediaMemCacheWidth(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxW = constraints.maxWidth.isFinite && constraints.maxWidth > 0
              ? constraints.maxWidth
              : MediaQuery.sizeOf(context).width - 32;

          final size = fitCommentMediaSize(
            aspect: _aspect,
            maxW: maxW,
            maxH: maxH,
          );

          Widget mediaChild;
          if (displayUrl != null && displayUrl.isNotEmpty) {
            mediaChild = ScrollStableNetworkImage(
              imageUrl: displayUrl,
              memCacheWidth: cacheW,
              width: size.width,
              height: size.height,
              // Contain = never crop; box matches aspect so usually pixel-tight.
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
          } else {
            mediaChild = ColoredBox(
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

          // Match feed/post media chrome: radius 20 + hairline border drawn
          // as *foreground* so the image cannot paint over it (DecoratedBox
          // under the child was why the border looked “missing”).
          return Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () => _openMedia(context),
              child: Container(
                width: size.width,
                height: size.height,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8E8E8),
                  borderRadius: BorderRadius.circular(20),
                ),
                foregroundDecoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0x1F000000)),
                ),
                clipBehavior: Clip.hardEdge,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    mediaChild,
                    if (item.isVideo)
                      Positioned(
                        bottom: 10,
                        left: 10,
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
              ),
            ),
          );
        },
      ),
    );
  }
}
