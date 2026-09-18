import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:video_player/video_player.dart';

import 'package:bluerum/shared/widgets/media/media_budget.dart';
import 'package:bluerum/shared/widgets/media/scroll_stable_network_image.dart';
import 'package:bluerum/shared/widgets/media/video_thumbnail_cache.dart';

class NativeVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final bool autoPlay;
  final bool loop;

  const NativeVideoPlayer({
    super.key,
    required this.videoUrl,
    this.autoPlay = false,
    this.loop = false,
  });

  @override
  State<NativeVideoPlayer> createState() => _NativeVideoPlayerState();
}

class _NativeVideoPlayerState extends State<NativeVideoPlayer> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  bool _showControls = true;
  Timer? _controlsTimer;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    final uri = Uri.tryParse(widget.videoUrl);
    if (uri == null) {
      setState(() => _hasError = true);
      return;
    }

    _controller = VideoPlayerController.networkUrl(uri);
    try {
      await _controller!.initialize();
      if (!mounted) return;

      // Autoplay starts clean — no seek bar / play button flash.
      if (widget.autoPlay) {
        _showControls = false;
      }

      setState(() {
        _isInitialized = true;
      });

      if (widget.autoPlay) {
        _controller!.play();
      }
      if (widget.loop) {
        _controller!.setLooping(true);
      }

      _controller!.addListener(_onControllerUpdate);
      if (!widget.autoPlay) {
        _startControlsTimer();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _hasError = true);
      }
    }
  }

  void _onControllerUpdate() {
    if (!mounted) return;
    setState(() {});
  }

  void _togglePlay() {
    if (_controller == null || !_isInitialized) return;
    if (_controller!.value.isPlaying) {
      _controller!.pause();
    } else {
      _controller!.play();
      _startControlsTimer();
    }
    setState(() {});
  }

  void _toggleMute() {
    if (_controller == null || !_isInitialized) return;
    final isMuted = _controller!.value.volume == 0.0;
    _controller!.setVolume(isMuted ? 1.0 : 0.0);
    setState(() {});
  }

  void _toggleControlsVisibility() {
    setState(() {
      _showControls = !_showControls;
    });
    if (_showControls) {
      _startControlsTimer();
    }
  }

  void _startControlsTimer() {
    _controlsTimer?.cancel();
    _controlsTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && _controller != null && _controller!.value.isPlaying) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _controlsTimer?.cancel();
    if (_controller != null) {
      _controller!.removeListener(_onControllerUpdate);
      _controller!.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Transparent shell so full-screen ambient blur shows in letterbox / safe
    // areas (same continuous look as images). Solid black only for error states.
    if (_hasError) {
      return const ColoredBox(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                MingCuteIcons.mgc_camcorder_off_line,
                color: Colors.white60,
                size: 48,
              ),
              SizedBox(height: 12),
              Text(
                'Could not load video',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    if (!_isInitialized || _controller == null) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    final value = _controller!.value;
    final isPlaying = value.isPlaying;
    final isMuted = value.volume == 0.0;
    final position = value.position;
    final duration = value.duration;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Stack(
      fit: StackFit.expand,
      children: [
        // Video — centered, letterbox shows ambient behind
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _toggleControlsVisibility,
          child: Center(
            child: AspectRatio(
              aspectRatio: value.aspectRatio == 0
                  ? 16 / 9
                  : value.aspectRatio,
              child: VideoPlayer(_controller!),
            ),
          ),
        ),

        // Central play/pause overlay when paused or controls visible
        if (_showControls || !isPlaying)
          AnimatedOpacity(
            opacity: _showControls ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: Center(
              child: Material(
                color: Colors.transparent,
                child: IconButton(
                  iconSize: 64,
                  icon: Icon(
                    isPlaying
                        ? MingCuteIcons.mgc_pause_circle_fill
                        : MingCuteIcons.mgc_play_circle_fill,
                    color: Colors.white,
                  ),
                  onPressed: _togglePlay,
                ),
              ),
            ),
          ),

        // Bottom control bar — sits above the home indicator
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: AnimatedOpacity(
            opacity: _showControls ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, Color(0xD9000000)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + bottomInset),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  VideoProgressIndicator(
                    _controller!,
                    allowScrubbing: true,
                    colors: const VideoProgressColors(
                      playedColor: Colors.white,
                      bufferedColor: Colors.white24,
                      backgroundColor: Colors.white12,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_formatDuration(position)} / ${_formatDuration(duration)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: Icon(
                          isMuted
                              ? MingCuteIcons.mgc_volume_mute_fill
                              : MingCuteIcons.mgc_volume_fill,
                          color: Colors.white,
                          size: 20,
                        ),
                        onPressed: _toggleMute,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class VideoThumbnailPlayer extends StatefulWidget {
  final String videoUrl;

  /// When false (default for list cells), never initialize a network
  /// [VideoPlayerController] as thumbnail fallback — that freezes scroll.
  final bool allowPlayerFallback;

  const VideoThumbnailPlayer({
    super.key,
    required this.videoUrl,
    this.allowPlayerFallback = false,
  });

  @override
  State<VideoThumbnailPlayer> createState() => _VideoThumbnailPlayerState();
}

class _VideoThumbnailPlayerState extends State<VideoThumbnailPlayer> {
  Uint8List? _thumbBytes;
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  bool _usingPlayerFallback = false;
  /// Bumps on URL change / dispose path so stale loads never setState.
  int _generation = 0;
  bool _loadScheduled = false;

  @override
  void initState() {
    super.initState();
    // Instant paint when feed already warmed this URL.
    _thumbBytes = VideoThumbnailCache.peek(widget.videoUrl);
    MediaBudgetEpoch.listenable.addListener(_onMediaBudgetFlushed);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Need a [Scrollable] ancestor — only available after dependencies.
    if (_thumbBytes == null && !_hasError && !_loadScheduled) {
      _scheduleLoad();
    }
  }

  @override
  void didUpdateWidget(covariant VideoThumbnailPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoUrl != widget.videoUrl) {
      _controller?.dispose();
      _controller = null;
      _isInitialized = false;
      _hasError = false;
      _usingPlayerFallback = false;
      _loadScheduled = false;
      _generation++;
      _thumbBytes = VideoThumbnailCache.peek(widget.videoUrl);
      if (_thumbBytes == null) {
        _scheduleLoad();
      }
    }
  }

  /// Queue/in-flight extract was dropped — re-arm unless already painted.
  void _onMediaBudgetFlushed() {
    if (!mounted || _thumbBytes != null) return;
    _hasError = false;
    _loadScheduled = false;
    _scheduleLoad();
  }

  /// FPS-first: never touch MediaCodec while the list is flinging/dragging.
  void _scheduleLoad() {
    if (!mounted || _thumbBytes != null || _hasError) return;
    _loadScheduled = true;
    final gen = _generation;

    if (scrollActivityBusy(context)) {
      _loadScheduled = false;
      whenScrollActivityIdle(context, () {
        if (!mounted || gen != _generation) return;
        if (_thumbBytes != null || _hasError) return;
        _scheduleLoad();
      });
      return;
    }

    unawaited(_loadThumbnail(gen));
  }

  Future<void> _loadThumbnail(int gen) async {
    final bytes = await VideoThumbnailCache.load(widget.videoUrl);
    if (!mounted || gen != _generation) return;
    if (bytes != null && bytes.isNotEmpty) {
      setState(() {
        _thumbBytes = bytes;
        _hasError = false;
      });
      return;
    }
    // Plugin failed (some hosts / formats). Player fallback is opt-in only —
    // never from comment/feed list cells mid-scroll.
    if (widget.allowPlayerFallback) {
      await _initializePlayerFallback();
    } else if (mounted && gen == _generation) {
      setState(() => _hasError = true);
    }
  }

  Future<void> _initializePlayerFallback() async {
    final uri = Uri.tryParse(widget.videoUrl);
    if (uri == null) {
      if (mounted) setState(() => _hasError = true);
      return;
    }
    _usingPlayerFallback = true;
    _controller = VideoPlayerController.networkUrl(uri);
    try {
      await _controller!.initialize();
      if (!mounted) return;
      setState(() {
        _isInitialized = true;
        _hasError = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() => _hasError = true);
      }
    }
  }

  @override
  void dispose() {
    MediaBudgetEpoch.listenable.removeListener(_onMediaBudgetFlushed);
    _controller?.dispose();
    super.dispose();
  }

  Widget _error() {
    return Container(
      color: Colors.black12,
      child: const Center(
        child: Icon(
          MingCuteIcons.mgc_camcorder_off_line,
          color: Colors.black38,
          size: 32,
        ),
      ),
    );
  }

  Widget _loading() {
    return Container(
      color: Colors.black12,
      child: const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.black45),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_thumbBytes != null) {
      return SizedBox.expand(
        child: Image.memory(
          _thumbBytes!,
          fit: BoxFit.cover,
          gaplessPlayback: true,
          // Avoid a second decode flicker when the same bytes remount on detail.
          filterQuality: FilterQuality.low,
        ),
      );
    }

    if (_hasError) return _error();

    if (_usingPlayerFallback && _isInitialized && _controller != null) {
      return SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.cover,
          clipBehavior: Clip.hardEdge,
          child: SizedBox(
            width: _controller!.value.size.width,
            height: _controller!.value.size.height,
            child: VideoPlayer(_controller!),
          ),
        ),
      );
    }

    return _loading();
  }
}
