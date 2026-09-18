import 'dart:collection';

import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

/// Intentional RAM policy for any **post-card list** surface (home, community,
/// profile, search, saved) — same contract as post-detail comment keep-alive
/// with post-card dials.
///
/// Commercial feeds (IG / X / Reddit) recycle a **handful** of cells — they do
/// not keep dozens of full media cards alive. Keeping ~20+ full [PostCard]
/// trees + decoded bitmaps OOMs mid-range Android after a few dozen posts.
///
/// Policy:
/// 1. Default **pure virtualization** ([maxKeptRows] `0`) — Home standard.
/// 2. Optional budgeted keep-alive only if reverse-fling is critical (6–8 max).
/// 3. Remember measured card heights for better prefetch index math.
///
/// Pair [maxKeptRows] `0` with [SliverChildBuilderDelegate.addAutomaticKeepAlives]
/// `false` and [PostListHeightProbe] (not [PostListKeepAlive]).
final class PostListMemoryPolicy {
  /// Default 0 — pure virtualization (recommended for all media post lists).
  /// Pass 6–8 only if reverse-fling is critical and the surface is light.
  PostListMemoryPolicy({this.maxKeptRows = 0});

  final int maxKeptRows;

  /// Whether off-screen keep-alive is enabled for this policy.
  bool get allowsKeepAlive => maxKeptRows > 0;

  /// Paint-ahead window (logical px). ~1 card — not multi-screen of full trees.
  static const double listCacheExtent = 480;

  /// Slightly larger only for secondary lists without native ads.
  static const double secondaryCacheExtent = 600;

  final LinkedHashMap<int, _KeepSlot> _keep = LinkedHashMap<int, _KeepSlot>();
  final Map<int, double> _heights = <int, double>{};

  bool shouldKeep(int postId) => _keep.containsKey(postId);

  double? heightOf(int postId) => _heights[postId];

  double averageHeight({double fallback = 360}) {
    if (_heights.isEmpty) return fallback;
    var sum = 0.0;
    for (final h in _heights.values) {
      sum += h;
    }
    return sum / _heights.length;
  }

  void recordHeight(int postId, double height) {
    if (height <= 0 || height.isNaN) return;
    final prev = _heights[postId];
    if (prev != null && (prev - height).abs() < 0.5) return;
    // Re-touch for LRU if already present.
    _heights.remove(postId);
    _heights[postId] = height;
    // Cap map — only need recent heights for prefetch estimates.
    while (_heights.length > 64) {
      _heights.remove(_heights.keys.first);
    }
  }

  void touch(
    int postId, {
    required bool hasMedia,
    required VoidCallback requestKeepAliveUpdate,
  }) {
    final existing = _keep.remove(postId);
    if (existing != null) {
      existing.hasMedia = existing.hasMedia || hasMedia;
      existing.onUpdate = requestKeepAliveUpdate;
      _keep[postId] = existing;
    } else {
      _keep[postId] = _KeepSlot(
        hasMedia: hasMedia,
        onUpdate: requestKeepAliveUpdate,
      );
    }
    _enforceBudget();
  }

  void detach(int postId) {
    _keep.remove(postId);
  }

  void clear() {
    final slots = List<_KeepSlot>.from(_keep.values);
    _keep.clear();
    _heights.clear();
    for (final s in slots) {
      s.onUpdate();
    }
  }

  void _enforceBudget() {
    // maxKeptRows 0 → pure virtualization: never pin off-screen subtrees.
    if (maxKeptRows <= 0) {
      if (_keep.isEmpty) return;
      final slots = List<_KeepSlot>.from(_keep.values);
      _keep.clear();
      for (final s in slots) {
        s.onUpdate();
      }
      return;
    }
    if (_keep.length <= maxKeptRows) return;
    while (_keep.length > maxKeptRows) {
      int? victimId;
      for (final e in _keep.entries) {
        if (!e.value.hasMedia) {
          victimId = e.key;
          break;
        }
      }
      victimId ??= _keep.keys.first;
      final slot = _keep.remove(victimId);
      slot?.onUpdate();
    }
  }
}

final class _KeepSlot {
  _KeepSlot({required this.hasMedia, required this.onUpdate});

  bool hasMedia;
  VoidCallback onUpdate;
}

/// Records measured card height without [AutomaticKeepAliveClientMixin].
///
/// Use when [PostListMemoryPolicy.maxKeptRows] is `0` (Home-class pure recycle).
class PostListHeightProbe extends StatefulWidget {
  const PostListHeightProbe({
    super.key,
    required this.postId,
    required this.policy,
    required this.child,
  });

  final int postId;
  final PostListMemoryPolicy policy;
  final Widget child;

  @override
  State<PostListHeightProbe> createState() => _PostListHeightProbeState();
}

class _PostListHeightProbeState extends State<PostListHeightProbe> {
  bool _measured = false;

  @override
  void didUpdateWidget(covariant PostListHeightProbe oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.postId != widget.postId) _measured = false;
  }

  @override
  Widget build(BuildContext context) {
    if (!_measured) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _measured) return;
        final box = context.findRenderObject() as RenderBox?;
        if (box != null && box.hasSize) {
          widget.policy.recordHeight(widget.postId, box.size.height);
          _measured = true;
        }
      });
    }
    return widget.child;
  }
}

/// Wraps a post-card tile under [PostListMemoryPolicy] **keep-alive** budget.
///
/// Only use when [PostListMemoryPolicy.allowsKeepAlive] is true. Pair with
/// [SliverChildBuilderDelegate.addAutomaticKeepAlives] = true.
/// For pure virtualization use [PostListHeightProbe] instead.
class PostListKeepAlive extends StatefulWidget {
  const PostListKeepAlive({
    super.key,
    required this.postId,
    required this.hasMedia,
    required this.policy,
    required this.child,
  });

  final int postId;
  final bool hasMedia;
  final PostListMemoryPolicy policy;
  final Widget child;

  @override
  State<PostListKeepAlive> createState() => _PostListKeepAliveState();
}

class _PostListKeepAliveState extends State<PostListKeepAlive>
    with AutomaticKeepAliveClientMixin {
  bool _measured = false;

  @override
  bool get wantKeepAlive => widget.policy.shouldKeep(widget.postId);

  @override
  void initState() {
    super.initState();
    _touch(refreshLru: true);
  }

  @override
  void didUpdateWidget(covariant PostListKeepAlive oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.postId != widget.postId) {
      oldWidget.policy.detach(oldWidget.postId);
      _measured = false;
      _touch(refreshLru: true);
    } else if (oldWidget.hasMedia != widget.hasMedia && widget.hasMedia) {
      _touch(refreshLru: true);
    }
  }

  @override
  void dispose() {
    widget.policy.detach(widget.postId);
    super.dispose();
  }

  void _touch({required bool refreshLru}) {
    if (!refreshLru && widget.policy.shouldKeep(widget.postId)) {
      updateKeepAlive();
      return;
    }
    widget.policy.touch(
      widget.postId,
      hasMedia: widget.hasMedia,
      requestKeepAliveUpdate: () {
        if (mounted) updateKeepAlive();
      },
    );
    updateKeepAlive();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (!_measured) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _measured) return;
        final box = context.findRenderObject() as RenderBox?;
        if (box != null && box.hasSize) {
          widget.policy.recordHeight(widget.postId, box.size.height);
          _measured = true;
        }
      });
    }
    return widget.child;
  }
}
