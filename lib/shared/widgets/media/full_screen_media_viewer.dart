import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:bluerum/core/utils/media_utils.dart';
import 'package:bluerum/shared/widgets/media/video_player_widget.dart';
import 'package:bluerum/shared/widgets/media/media_precache.dart';

/// Full-screen media gallery (images + video). Open via [open] for a consistent
/// fade-only route (no scale “pop” that reads as a layout flick).
class FullScreenMediaViewer extends StatefulWidget {
  final List<MediaItem> mediaItems;
  final int initialIndex;
  final PageController? carouselController;
  final Animation<double>? routeAnimation;

  const FullScreenMediaViewer({
    super.key,
    required this.mediaItems,
    this.initialIndex = 0,
    this.carouselController,
    this.routeAnimation,
  });

  /// Fade-only push — image is already full-size on first frame (no 0.95 scale).
  static Future<int?> open(
    BuildContext context, {
    required List<MediaItem> mediaItems,
    int initialIndex = 0,
    PageController? carouselController,
  }) {
    return Navigator.of(context).push<int>(
      PageRouteBuilder<int>(
        opaque: false,
        pageBuilder: (context, animation, secondaryAnimation) =>
            FullScreenMediaViewer(
              mediaItems: mediaItems,
              initialIndex: initialIndex,
              carouselController: carouselController,
              routeAnimation: animation,
            ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 180),
        reverseTransitionDuration: const Duration(milliseconds: 160),
      ),
    );
  }

  @override
  State<FullScreenMediaViewer> createState() => _FullScreenMediaViewerState();
}

class _FullScreenMediaViewerState extends State<FullScreenMediaViewer>
    with SingleTickerProviderStateMixin {
  late final PageController _pageController;
  int _currentIndex = 0;
  late double _routeProgress;
  Animation<double>? _routeAnim;

  // Vertical drag-to-dismiss
  double _dragOffset = 0.0;
  bool _isDragging = false;
  late AnimationController _dismissController;
  late Animation<double> _dismissAnimation;

  bool _isZoomed = false;

  /// Pointer count without setState — avoids rebuilds mid-gesture.
  int _pointerCount = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(
      0,
      widget.mediaItems.isEmpty ? 0 : widget.mediaItems.length - 1,
    );
    _pageController = PageController(initialPage: _currentIndex);

    _routeAnim = widget.routeAnimation;
    _routeProgress = _routeAnim?.value ?? 1.0;
    _routeAnim?.addListener(_onRouteProgress);

    _dismissController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _dismissAnimation = _dismissController.drive(
      Tween<double>(begin: 0, end: 0),
    );
    _dismissController.addListener(() {
      if (!_isDragging) {
        setState(() => _dragOffset = _dismissAnimation.value);
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _precachePages(_currentIndex);
    });
  }

  void _precachePages(int index) {
    if (!mounted) return;
    precacheMediaAround(
      context,
      widget.mediaItems
          .map((item) => item.isImage ? item.url : (item.thumbnailUrl ?? ''))
          .toList(growable: false),
      index,
      cacheWidth: _memCacheWidth(),
      radius: 1,
    );
  }

  int _memCacheWidth() =>
      (MediaQuery.sizeOf(context).width *
              MediaQuery.devicePixelRatioOf(context))
          .round()
          .clamp(1, 1600);

  void _onRouteProgress() {
    if (!mounted) return;
    setState(() => _routeProgress = _routeAnim?.value ?? 1.0);
  }

  @override
  void didUpdateWidget(FullScreenMediaViewer old) {
    super.didUpdateWidget(old);
    if (widget.routeAnimation != old.routeAnimation) {
      old.routeAnimation?.removeListener(_onRouteProgress);
      _routeAnim = widget.routeAnimation;
      _routeAnim?.addListener(_onRouteProgress);
    }
  }

  @override
  void dispose() {
    _routeAnim?.removeListener(_onRouteProgress);
    _pageController.dispose();
    _dismissController.dispose();
    super.dispose();
  }

  void _closeViewer() {
    widget.carouselController?.jumpToPage(_currentIndex);
    Navigator.pop(context, _currentIndex);
  }

  void _onPageChanged(int i) {
    setState(() {
      _currentIndex = i;
      _isZoomed = false;
    });
    widget.carouselController?.jumpToPage(i);
    _precachePages(i);
  }

  bool get _canDismiss => !_isZoomed && _pointerCount <= 1;

  @override
  Widget build(BuildContext context) {
    final items = widget.mediaItems;
    final bgOpacity = _routeProgress.clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: ColoredBox(
              color: Colors.black.withValues(alpha: bgOpacity),
            ),
          ),

          Positioned.fill(
            child: Transform.translate(
              offset: Offset(0, _dragOffset),
              child: Transform.scale(
                scale: 1.0 - (_dragOffset.abs() / 2000.0).clamp(0.0, 0.12),
                child: Listener(
                  onPointerDown: (_) => _pointerCount++,
                  onPointerUp: (_) {
                    if (_pointerCount > 0) _pointerCount--;
                  },
                  onPointerCancel: (_) {
                    if (_pointerCount > 0) _pointerCount--;
                  },
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onVerticalDragStart: !_canDismiss
                        ? null
                        : (_) {
                            _isDragging = true;
                            _dismissController.stop();
                          },
                    onVerticalDragUpdate: !_canDismiss
                        ? null
                        : (details) {
                            if (_pointerCount > 1) return;
                            setState(() => _dragOffset += details.delta.dy);
                          },
                    onVerticalDragEnd: !_canDismiss
                        ? null
                        : (details) {
                            _isDragging = false;
                            final velocity = details.primaryVelocity ?? 0.0;
                            if (_dragOffset.abs() > 100 ||
                                velocity.abs() > 800) {
                              _closeViewer();
                            } else {
                              _dismissAnimation = _dismissController.drive(
                                Tween<double>(begin: _dragOffset, end: 0.0),
                              );
                              _dismissController.forward(from: 0.0);
                            }
                          },
                    child: PageView.builder(
                      controller: _pageController,
                      physics: _isZoomed
                          ? const NeverScrollableScrollPhysics()
                          : const PageScrollPhysics(
                              parent: ClampingScrollPhysics(),
                            ),
                      allowImplicitScrolling: true,
                      onPageChanged: _onPageChanged,
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        if (item.type == MediaType.video) {
                          if (item.videoType == VideoType.native) {
                            // Only keep the current player alive.
                            if (index != _currentIndex) {
                              return const SizedBox.expand();
                            }
                            return NativeVideoPlayer(
                              videoUrl: item.url,
                              autoPlay: true,
                            );
                          }
                          return _buildYouTubePlaceholder(item);
                        }
                        return InteractiveImagePage(
                          key: ValueKey('fs-img-${item.url}'),
                          url: item.url,
                          onTap: _closeViewer,
                          onZoomChanged: (zoomed) {
                            if (_isZoomed == zoomed) return;
                            setState(() => _isZoomed = zoomed);
                          },
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            top: MediaQuery.paddingOf(context).top + 16,
            right: 28,
            child: ClipOval(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.35),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                      width: 0.8,
                    ),
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: const Icon(
                      MingCuteIcons.mgc_close_line,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: _closeViewer,
                  ),
                ),
              ),
            ),
          ),

          if (items.length > 1)
            Positioned(
              top: MediaQuery.paddingOf(context).top + 16,
              left: 0,
              right: 0,
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                          width: 0.8,
                        ),
                      ),
                      child: Text(
                        '${_currentIndex + 1} / ${items.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
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

  Widget _buildYouTubePlaceholder(MediaItem item) {
    final thumbUrl = item.thumbnailUrl;
    return Center(
      child: GestureDetector(
        onTap: () async {
          final uri = Uri.parse(item.url);
          try {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          } catch (_) {}
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.black45,
          ),
          clipBehavior: Clip.antiAlias,
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (thumbUrl != null)
                  CachedNetworkImage(
                    imageUrl: thumbUrl,
                    fit: BoxFit.cover,
                    fadeInDuration: Duration.zero,
                    fadeOutDuration: Duration.zero,
                  ),
                Container(
                  color: Colors.black38,
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          MingCuteIcons.mgc_youtube_fill,
                          color: Colors.red,
                          size: 64,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Tap to play in YouTube',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Full-screen image page: PageView-friendly zoom.
///
/// Critical: [InteractiveViewer.panEnabled] is **false** until zoomed so
/// horizontal swipes go to [PageView] (main cause of sticky/sượng paging).
///
/// Layout is **always** full viewport + [BoxFit.contain] — never an aspect
/// box that starts at 16:9 and resizes after decode (that was the first-open
/// “small then flick full” glitch).
class InteractiveImagePage extends StatefulWidget {
  final String url;
  final VoidCallback onTap;
  final ValueChanged<bool> onZoomChanged;

  const InteractiveImagePage({
    super.key,
    required this.url,
    required this.onTap,
    required this.onZoomChanged,
  });

  @override
  State<InteractiveImagePage> createState() => _InteractiveImagePageState();
}

class _InteractiveImagePageState extends State<InteractiveImagePage>
    with AutomaticKeepAliveClientMixin {
  final TransformationController _transformationController =
      TransformationController();
  bool _isZoomed = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _transformationController.addListener(_onTransformationChanged);
  }

  void _onTransformationChanged() {
    final scale = _transformationController.value.getMaxScaleOnAxis();
    final isZoomed = scale > 1.05;
    if (isZoomed != _isZoomed) {
      setState(() => _isZoomed = isZoomed);
      widget.onZoomChanged(isZoomed);
    }
  }

  void _resetZoom() {
    _transformationController.value = Matrix4.identity();
  }

  @override
  void didUpdateWidget(covariant InteractiveImagePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _resetZoom();
    }
  }

  @override
  void dispose() {
    _transformationController.removeListener(_onTransformationChanged);
    _transformationController.dispose();
    super.dispose();
  }

  int _memCacheWidth() =>
      (MediaQuery.sizeOf(context).width *
              MediaQuery.devicePixelRatioOf(context))
          .round()
          .clamp(1, 1600);

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return GestureDetector(
      onTap: widget.onTap,
      onDoubleTap: () {
        if (_isZoomed) {
          _resetZoom();
        } else {
          final size = MediaQuery.sizeOf(context);
          final m = Matrix4.identity()
            ..translateByDouble(size.width / 2, size.height / 2, 0, 1)
            ..scaleByDouble(2.0, 2.0, 1.0, 1)
            ..translateByDouble(-size.width / 2, -size.height / 2, 0, 1);
          _transformationController.value = m;
        }
      },
      child: InteractiveViewer(
        transformationController: _transformationController,
        minScale: 1.0,
        maxScale: 4.0,
        // Let PageView own horizontal drag until the user pinches/double-taps.
        panEnabled: _isZoomed,
        scaleEnabled: true,
        clipBehavior: Clip.none,
        child: SizedBox.expand(
          child: CachedNetworkImage(
            imageUrl: widget.url,
            fit: BoxFit.contain,
            alignment: Alignment.center,
            width: double.infinity,
            height: double.infinity,
            memCacheWidth: _memCacheWidth(),
            fadeInDuration: Duration.zero,
            fadeOutDuration: Duration.zero,
            // Avoid a second fade when the same URL is already decoded.
            useOldImageOnUrlChange: true,
            placeholder: (_, _) => const ColoredBox(color: Colors.transparent),
            errorWidget: (_, _, _) => const Icon(
              MingCuteIcons.mgc_pic_2_line,
              color: Color(0xFF525252),
              size: 48,
            ),
          ),
        ),
      ),
    );
  }
}
