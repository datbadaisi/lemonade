import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:bluerum/shared/widgets/media/media_budget.dart';
import 'package:bluerum/shared/widgets/skeleton/skeleton.dart';

/// Circular network avatar that keeps a square layout slot and correct aspect ratio.
///
/// Use this for **every** person / community / site icon shown as a circle.
///
/// Guarantees:
/// 1. Fixed [size]×[size] box so parent [Row]/[Flexible] pressure cannot squash
///    the circle into an oval.
/// 2. [BoxFit.cover] crop only — never stretch. Only [memCacheWidth] is set.
/// 3. Decode width = logical [size] × devicePixelRatio × [memCacheScale] so
///    icons stay sharp on 2×/3× screens (not a fixed low logical scale).
/// 4. Optional [deferWhileScrolling]: solid gray disc while list flings; after
///    idle, paint via [CachedNetworkImage] (no process-wide still budget — that
///    FIFO is for feed images, not 40px icons).
/// 5. Letter / [fallbackIcon] only when there is **no** URL (or load failed) —
///    never as a “loading stand-in” (avoids group-icon flash before paint).
class NetworkAvatar extends StatefulWidget {
  const NetworkAvatar({
    super.key,
    required this.size,
    this.imageUrl,
    this.name,
    this.fallbackIcon,
    this.fallback,
    this.backgroundColor = const Color(0xFFE8E8E8),
    this.foregroundColor = const Color(0xFF525252),
    /// Oversample on top of physical pixels (1.0 = exact DPR).
    this.memCacheScale = 1.25,
    this.fadeInDuration = const Duration(milliseconds: 150),
    this.useShimmerPlaceholder = true,
    this.filterQuality = FilterQuality.medium,
    this.deferWhileScrolling = false,
  });

  /// Canonical list-row avatar (Search / Notifications / Blocks / pickers…).
  ///
  /// Gray disc mid-fling / while decoding; CNI after idle. Decoded at device
  /// pixels so 38–44px community/user icons stay sharp.
  const NetworkAvatar.forList({
    super.key,
    required this.size,
    this.imageUrl,
    this.name,
    this.fallbackIcon,
    this.fallback,
    this.backgroundColor = const Color(0xFFE8E8E8),
    this.foregroundColor = const Color(0xFF525252),
  })  : memCacheScale = 1.2,
        fadeInDuration = Duration.zero,
        useShimmerPlaceholder = false,
        filterQuality = FilterQuality.medium,
        deferWhileScrolling = true;

  final double size;
  final String? imageUrl;
  final String? name;
  final IconData? fallbackIcon;
  final Widget? fallback;
  final Color backgroundColor;
  final Color foregroundColor;
  final double memCacheScale;
  final Duration fadeInDuration;
  final bool useShimmerPlaceholder;
  final FilterQuality filterQuality;

  /// List rows: true — gray disc while flinging; network after idle.
  final bool deferWhileScrolling;

  @override
  State<NetworkAvatar> createState() => _NetworkAvatarState();
}

class _NetworkAvatarState extends State<NetworkAvatar> {
  bool _allowNetwork = true;

  bool get _hasUrl =>
      widget.imageUrl != null && widget.imageUrl!.trim().isNotEmpty;

  /// Physical decode width. Avatars are tiny vs feed stills — full DPR is fine.
  int _cacheWidthFor(BuildContext context) {
    final dpr = MediaQuery.devicePixelRatioOf(context).clamp(1.0, 3.0);
    return (widget.size * dpr * widget.memCacheScale).round().clamp(1, 384);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncScrollGate();
  }

  @override
  void didUpdateWidget(covariant NetworkAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl ||
        oldWidget.deferWhileScrolling != widget.deferWhileScrolling) {
      _syncScrollGate();
    }
  }

  void _syncScrollGate() {
    if (!widget.deferWhileScrolling || !_hasUrl) {
      _allowNetwork = true;
      return;
    }
    if (scrollActivityBusy(context)) {
      if (_allowNetwork) {
        _allowNetwork = false;
      }
      whenScrollActivityIdle(context, () {
        if (!mounted) return;
        if (!_allowNetwork) setState(() => _allowNetwork = true);
      });
    } else {
      _allowNetwork = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    // URL known but not painting yet (scroll gate) → gray only.
    // Letter / icon only when there is no URL, or load permanently failed.
    final Widget child;
    if (!_hasUrl) {
      child = _buildFallback();
    } else if (!_allowNetwork) {
      child = _buildPendingDisc();
    } else {
      child = _buildNetworkImage(context);
    }

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: ClipOval(
        clipBehavior: Clip.antiAlias,
        child: ColoredBox(
          color: widget.backgroundColor,
          child: child,
        ),
      ),
    );
  }

  Widget _buildNetworkImage(BuildContext context) {
    final cacheWidth = _cacheWidthFor(context);
    // List + chrome: CNI only. Do not join ScrollStable / ImageDecodeBudget —
    // those queues are for feed stills (1 concurrent) and made avatar lists
    // paint top→bottom hundreds of ms apart.
    return CachedNetworkImage(
      imageUrl: widget.imageUrl!,
      width: widget.size,
      height: widget.size,
      fit: BoxFit.cover,
      alignment: Alignment.center,
      memCacheWidth: cacheWidth,
      fadeInDuration: widget.fadeInDuration,
      fadeOutDuration: Duration.zero,
      imageBuilder: (context, imageProvider) => Image(
        image: imageProvider,
        width: widget.size,
        height: widget.size,
        fit: BoxFit.cover,
        alignment: Alignment.center,
        gaplessPlayback: true,
        filterQuality: widget.filterQuality,
      ),
      placeholder: (_, _) => widget.useShimmerPlaceholder
          ? ShimmerPlaceholder.circle(size: widget.size)
          : _buildPendingDisc(),
      errorWidget: (_, _, _) => _buildFallback(),
    );
  }

  /// Solid muted disc — used while scroll-gated or decode pending.
  Widget _buildPendingDisc() {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: ColoredBox(color: widget.backgroundColor),
    );
  }

  Widget _buildFallback() {
    if (widget.fallback != null) return widget.fallback!;
    if (widget.fallbackIcon != null) {
      return Container(
        width: widget.size,
        height: widget.size,
        color: widget.backgroundColor,
        alignment: Alignment.center,
        child: Icon(
          widget.fallbackIcon,
          size: widget.size * 0.55,
          color: widget.foregroundColor,
        ),
      );
    }
    return Container(
      width: widget.size,
      height: widget.size,
      color: widget.backgroundColor,
      alignment: Alignment.center,
      child: Text(
        _letterFromName(widget.name),
        style: TextStyle(
          fontSize: widget.size * 0.45,
          fontWeight: FontWeight.w600,
          color: widget.foregroundColor,
        ),
      ),
    );
  }

  static String _letterFromName(String? name) {
    final trimmed = name?.trim() ?? '';
    if (trimmed.isEmpty) return '?';
    return String.fromCharCode(trimmed.runes.first).toUpperCase();
  }
}
