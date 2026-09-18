import 'dart:collection';

import 'package:flutter/painting.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

/// Intentional RAM policy for the post-detail **comment list**.
///
/// Philosophy (trade RAM → smoother fling, especially reverse):
/// 1. **Keep recently visited comment Element trees** (budgeted LRU) so reverse
///    fling does not re-inflate author/action chrome + re-probe images.
/// 2. **Prefer keeping media rows** when the budget is full.
/// 3. **Never keep ads** in this registry (platform views are managed separately).
/// 4. **Remember row heights** for better jump/precache estimates.
/// 5. **Boost ImageCache** while detail is open (pixels are shared; this is the
///    cheapest reverse-scroll win after keep-alive).
///
/// Not unbounded: [maxKeptRows] caps live comment subtrees. Image pixels are
/// capped by [boostImageCache] / bootstrap defaults.
final class CommentListMemoryPolicy {
  /// Default 72: balanced reverse-fling vs RAM (was 96 — Wave 6 dial).
  CommentListMemoryPolicy({this.maxKeptRows = 72, this.maxMeasuredRows = 400});

  /// Live comment Element trees we try to retain (not ads, not header).
  final int maxKeptRows;

  /// Height samples are useful for jump/anchor estimates, not an unbounded
  /// history of every row ever visited in a very long thread.
  final int maxMeasuredRows;

  /// ListView [cacheExtent] — paint ahead of the viewport (logical px).
  /// 1600 balances cold mounts vs work in the ahead window (was 2000).
  static const double listCacheExtent = 1600;

  /// ImageCache while post-detail is on screen (still modest — process-wide).
  static const int imageCacheCount = 120;
  static const int imageCacheBytes = 64 << 20; // 64 MiB

  /// Bootstrap defaults to restore on dispose.
  static const int defaultImageCacheCount = 80;
  static const int defaultImageCacheBytes = 48 << 20;

  final LinkedHashMap<int, _KeepSlot> _keep = LinkedHashMap<int, _KeepSlot>();
  final LinkedHashMap<int, double> _heights = LinkedHashMap<int, double>();

  @visibleForTesting
  int get measuredHeightCount => _heights.length;

  /// Comment ids currently preferred for [AutomaticKeepAliveClientMixin].
  bool shouldKeep(int commentId) => _keep.containsKey(commentId);

  double? heightOf(int commentId) => _heights[commentId];

  /// Average of known heights, or [fallback] when empty.
  double averageHeight({double fallback = 120}) {
    if (_heights.isEmpty) return fallback;
    var sum = 0.0;
    for (final h in _heights.values) {
      sum += h;
    }
    return sum / _heights.length;
  }

  /// Estimated scroll offset for a flat **row** index (post-header excluded).
  /// Prefer [estimateListOffsetForIndex] when ads are interleaved.
  double estimateOffsetForRow(int rowIndex, {double headerEstimate = 280}) {
    if (rowIndex <= 0) return headerEstimate;
    final avg = averageHeight();
    // Sum known heights for denser estimate when we have samples.
    if (_heights.length >= 4) {
      return headerEstimate + rowIndex * avg;
    }
    return headerEstimate + rowIndex * avg;
  }

  /// Last measured post-header height (list index 0).
  double? headerHeight;

  void recordHeaderHeight(double height) {
    if (height <= 0 || height.isNaN) return;
    if (headerHeight != null && (headerHeight! - height).abs() < 1) return;
    headerHeight = height;
  }

  void recordHeight(int commentId, double height) {
    if (height <= 0 || height.isNaN) return;
    final prev = _heights[commentId];
    if (prev != null && (prev - height).abs() < 0.5) {
      // Touch the sample: recently revisited rows are most valuable for a
      // reverse fling or an anchor restore.
      _heights.remove(commentId);
      _heights[commentId] = prev;
      return;
    }
    _heights.remove(commentId);
    _heights[commentId] = height;
    while (_heights.length > maxMeasuredRows) {
      _heights.remove(_heights.keys.first);
    }
  }

  /// Mark [commentId] as recently used. May evict older non-media rows.
  void touch(
    int commentId, {
    required bool hasMedia,
    required VoidCallback requestKeepAliveUpdate,
  }) {
    final existing = _keep.remove(commentId);
    if (existing != null) {
      existing.hasMedia = existing.hasMedia || hasMedia;
      existing.onUpdate = requestKeepAliveUpdate;
      _keep[commentId] = existing;
    } else {
      _keep[commentId] = _KeepSlot(
        hasMedia: hasMedia,
        onUpdate: requestKeepAliveUpdate,
      );
    }
    _enforceBudget();
  }

  void detach(int commentId) {
    _keep.remove(commentId);
  }

  void clear() {
    final slots = List<_KeepSlot>.from(_keep.values);
    _keep.clear();
    _heights.clear();
    headerHeight = null;
    for (final s in slots) {
      // Drop keep-alive so disposed routes free Element trees promptly.
      s.onUpdate();
    }
  }

  void _enforceBudget() {
    if (_keep.length <= maxKeptRows) return;

    // Evict oldest first; prefer non-media victims.
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

  /// Nested post-detail routes (continue-thread → child post) share one boost.
  static int _boostDepth = 0;

  /// True while at least one post-detail route still holds the boost.
  static bool get hasOpenDetailBoost => _boostDepth > 0;

  /// Raise ImageCache for reverse-fling repaint hits while detail is open.
  ///
  /// Refcounted so push/pop of nested detail does not thrash limits mid-route.
  static void boostImageCache() {
    _boostDepth++;
    if (_boostDepth != 1) return;
    final cache = PaintingBinding.instance.imageCache;
    cache.maximumSize = imageCacheCount;
    cache.maximumSizeBytes = imageCacheBytes;
  }

  /// Restore app-wide defaults when the last post-detail route leaves.
  ///
  /// Returns true when this call closed the **last** boosted detail (safe to
  /// re-arm feed media after the pop transition).
  static bool restoreImageCache() {
    if (_boostDepth <= 0) return false;
    _boostDepth--;
    if (_boostDepth > 0) return false;
    final cache = PaintingBinding.instance.imageCache;
    cache.maximumSize = defaultImageCacheCount;
    cache.maximumSizeBytes = defaultImageCacheBytes;
    return true;
  }

  @visibleForTesting
  static int get debugBoostDepth => _boostDepth;

  @visibleForTesting
  static void debugResetBoostDepth() {
    _boostDepth = 0;
    final cache = PaintingBinding.instance.imageCache;
    cache.maximumSize = defaultImageCacheCount;
    cache.maximumSizeBytes = defaultImageCacheBytes;
  }
}

final class _KeepSlot {
  _KeepSlot({required this.hasMedia, required this.onUpdate});

  bool hasMedia;
  VoidCallback onUpdate;
}

/// Wraps a comment row so it can stay alive under [CommentListMemoryPolicy].
///
/// Uses [AutomaticKeepAliveClientMixin] with [ListView.addAutomaticKeepAlives]
/// **true** (do not pair with the old raw [KeepAlive] + keepAlives:false pattern
/// that left blank gray holes).
class CommentKeepAlive extends StatefulWidget {
  const CommentKeepAlive({
    super.key,
    required this.commentId,
    required this.hasMedia,
    required this.policy,
    required this.child,
  });

  final int commentId;
  final bool hasMedia;
  final CommentListMemoryPolicy policy;
  final Widget child;

  @override
  State<CommentKeepAlive> createState() => _CommentKeepAliveState();
}

class _CommentKeepAliveState extends State<CommentKeepAlive>
    with AutomaticKeepAliveClientMixin {
  bool _measured = false;

  @override
  bool get wantKeepAlive => widget.policy.shouldKeep(widget.commentId);

  @override
  void initState() {
    super.initState();
    _touch(refreshLru: true);
  }

  @override
  void didUpdateWidget(covariant CommentKeepAlive oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.commentId != widget.commentId) {
      oldWidget.policy.detach(oldWidget.commentId);
      _measured = false;
      _touch(refreshLru: true);
    } else if (oldWidget.hasMedia != widget.hasMedia && widget.hasMedia) {
      _touch(refreshLru: true);
    }
  }

  @override
  void dispose() {
    widget.policy.detach(widget.commentId);
    super.dispose();
  }

  void _touch({required bool refreshLru}) {
    if (!refreshLru && widget.policy.shouldKeep(widget.commentId)) {
      updateKeepAlive();
      return;
    }
    widget.policy.touch(
      widget.commentId,
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
    // Measure once per mount (or after id change). Heights feed jump estimates.
    if (!_measured) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _measured) return;
        final box = context.findRenderObject() as RenderBox?;
        if (box != null && box.hasSize) {
          widget.policy.recordHeight(widget.commentId, box.size.height);
          _measured = true;
        }
      });
    }
    return widget.child;
  }
}

/// Keeps the post header Element alive for the lifetime of the list (1 row).
class HeaderKeepAlive extends StatefulWidget {
  const HeaderKeepAlive({super.key, required this.child, this.policy});

  final Widget child;
  final CommentListMemoryPolicy? policy;

  @override
  State<HeaderKeepAlive> createState() => _HeaderKeepAliveState();
}

class _HeaderKeepAliveState extends State<HeaderKeepAlive>
    with AutomaticKeepAliveClientMixin {
  bool _measured = false;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (!_measured && widget.policy != null) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _measured) return;
        final box = context.findRenderObject() as RenderBox?;
        if (box != null && box.hasSize) {
          widget.policy!.recordHeaderHeight(box.size.height);
          _measured = true;
        }
      });
    }
    return widget.child;
  }
}
